module tools.mutualinfo;

import std.stdio;
import std.container;
import std.array;
import std.math;
import std.conv;
import std.algorithm;

import transform.data;
import transform.factory;
import transform.transformer;
import transform.parser;

struct Fraction {
  ulong numerator;
  ulong denominator;

  Fraction opBinary(string op)(Fraction rhs) {
    static if (op == "+") {
      Fraction result;
      if (rhs.denominator == denominator) {
        result.numerator = numerator + rhs.numerator;
        result.denominator = denominator;
      } else {
        result.numerator =
          numerator * rhs.denominator + rhs.numerator * denominator;
        result.denominator = denominator * rhs.denominator;
      }
    } else static if (op == "*") {
      Fraction result;
      result.numerator = numerator * rhs.numerator;
      result.denominator = denominator * rhs.denominator;
    } else {
      assert(false, op ~ " not implemented for Fraction");
    }
  }

  real get() {
    auto ret = cast(real)numerator / cast(real)denominator;
    return ret;
  }
}

struct DiscreteProbability {
  Fraction prob;

  void count(bool x) {
    if (x) {
      prob.numerator += 1;
    }
    prob.denominator += 1;
  }

  real get() {
    return prob.get();
  }
}

struct DiscreteJointProbability {
  Fraction prob;

  void count(bool x, bool y) {
    if (x && y) {
      prob.numerator += 1;
    }

    prob.denominator += 1;
  }

  real get() {
    return prob.get();
  }
}

int main(string args[]) {
  if (args.length != 3) {
    writeln("Wrong number of arguments");
    return -1;
  }

  auto data = Parser.parseCsvFile(args[1]);
  auto transformer = new Transformer(data.featureLabels, args[2]);
  transformer.preprocess(data);

  TransformedDataSet transdata;
  transformer.transformSet(data, transdata);
  auto transforms = transformer.getTransforms();

  DList!FeatureTransform outputTransforms;
  foreach (t; transforms) {
    if (t.includeInOutput) {
      outputTransforms.insertBack(t);
    }
  }
  auto finaltrans = array(outputTransforms);

  // jProbs[featureIndex][targetClass][featureValue]
  DiscreteJointProbability[][][] jProbs; 
  // featureProbs[featureIndex][featureValue]
  DiscreteProbability[][] featureProbs;
  // targetProbs[targetClass]
  DiscreteProbability[] targetProbs;

  // Here we assume the target cardinality is 2
  // and that the feature cardinality is 2, aka {0, 1}
  jProbs.length = featureProbs.length = transdata.examples[0].features.length;
  foreach(i; 0 .. jProbs.length) {
    jProbs[i].length = featureProbs[i].length = 2; // # classes
    foreach (j; 0 .. 2) { // # discrete values x can take
      jProbs[i][j].length = 2;
    }
  }
  targetProbs.length = 2; // # classes
  
  // Get the mutual information of every transformed column
  foreach (ex; transdata.examples) {
    // loop through all of the classes
    foreach (i, fval; ex.features) {
      foreach (f; 0 .. 2) { // cardinality of x
        featureProbs[i][f].count(cast(ulong)fval == f);

        foreach (k; 0 .. 2) { // # classes
          jProbs[i][k][f].count(
            cast(ulong)fval == f,
            cast(ulong)ex.target == k
          );
        }
      }
    }
    foreach (k; 0 .. 2) { // # classes
      targetProbs[k].count(cast(ulong)ex.target == k);
    }
  }

  foreach (t; finaltrans) {
    write(t.name ~ ": ");
    DList!real transinfo;

    // loop through all of the classes
    foreach (i; 0 .. t.size()) {
      real mutualinfo = 0.0;
      foreach (k; 0 .. 2) { // # classes
        real yprob = targetProbs[k].get();
        // If our feature is only 0 or 1
        foreach (f; 0 .. 2) { // feature cardinality
          real jointProb = jProbs[t.finalOutputIndex + i][k][f].get();
          real xprob = featureProbs[t.finalOutputIndex + i][f].get();
          if (xprob * yprob > 0 && jointProb > 0) {
            mutualinfo += jointProb * log2( jointProb / (xprob * yprob) );
          }
        }
      }

      transinfo.insert(mutualinfo);
    }

    auto sortedInfo = array(sort!("a > b")(array(transinfo[])));
    foreach (i, info; sortedInfo) {
      write((i > 0 ? ", " : "") ~ to!string(info));
    }
    writeln();
  }

  return 0;
}
