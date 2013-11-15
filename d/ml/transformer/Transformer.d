import std.range, std.stdio, std.file;
import std.algorithm;
import std.conv, std.container;
import std.csv;

import Parser;
import FeatureTransforms;
import Data;

class Transformer {
  private DList!FeatureTransform transforms;
  private int finalOutputSize;
  private int totalVectorSize;

  this(string[] inputFeatures, string configFile) {
    TransformFactory.createTransforms(configFile, transforms);

    initializeTransforms(inputFeatures, transforms, totalVectorSize, finalOutputSize);
  }

  void initializeTransforms(
    string[] inputFeatures,
    ref DList!FeatureTransform transforms,
    out int totalSize,
    out int outputSize
  ) {
    int[string] featureIndices;
    int[string] featureSizes;
    int currentFeatureIndex = 0;
    foreach(flabel; inputFeatures) {
      featureIndices[flabel] = cast(int)currentFeatureIndex;
      featureSizes[flabel] = 1;
      currentFeatureIndex += 1;
    }

    // Prepare the structures for representing the DAG
    byte[string][string] dependencies;
    byte[string][string] dependants;
    FeatureTransform[string] transformMap;
    foreach (t; transforms) {
      transformMap[t.name] = t;

      string[] deps =
        array(filter!(a => (a in featureIndices) == null)(t.inputs));

      byte[string] empty;
      dependencies[t.name] = empty;

      foreach (dep; deps) {
        dependencies[t.name][dep] = 1;
        dependants[dep][t.name] = 1;
      }
    }

    // Topological sort for the DAG of transforms
    transforms.clear();
    while (dependencies.length > 0) {
      string[] processedTransforms;
      foreach (name, deps; dependencies) {
        if (deps.length != 0) {
          continue;
        }

        auto currentTrans = transformMap[name];
        currentTrans.setOutputIndex(currentFeatureIndex);
        transforms.insertBack(currentTrans);

        featureIndices[name] = currentFeatureIndex;
        featureSizes[name] = currentTrans.size();
        currentFeatureIndex += currentTrans.size();

        if (name in dependants) {
          foreach (dependant; dependants[name].byKey()) {
            dependencies[dependant].remove(name);
          }
        }

        processedTransforms ~= name;
      }

      // Remove the nodes which we are done with
      foreach (ptrans; processedTransforms) {
        dependencies.remove(ptrans);
      }
    }

    outputSize = 0;
    foreach (t; transforms) {
      int[] depIndices; 
      int[] depSizes;
      depIndices.length = t.inputs.length;
      depSizes.length = t.inputs.length;

      foreach (i, dep; t.inputs) {
        depIndices[i] = featureIndices[dep];
        depSizes[i] = featureSizes[dep];
      }

      t.setInputs(depIndices, depSizes);

      if (t.includeInOutput) {
        outputSize += t.size();
      }
    }

    totalSize = currentFeatureIndex;
  }

  void preprocess(DataSet data) {
    // Let the transforms do a first pass on the data for finding the best
    // transform values
    foreach (example; data.examples) {
      foreach (t; transforms) {
        t.process(example.features);
      }
    }

    // Signal the transformations to do any final processing
    foreach (t; transforms) {
      t.finalize();
    }
  }

  void transform(RawExample ex, out TransformedExample transex) {
    transex.features.length = finalOutputSize;
    allFeatures.length = totalVectorSize;

    allFeatures[0..ex.features.length] = ex.features[];
    allFeatures[ex.features.length..$] = FeatureValue(
      FeatureValueType.DOUBLE,
      null,
      0.0
    );

    int outIndex = 0; 
    foreach(t; transforms) {
      t.transform(allFeatures);

      // Check whether we need to include this transform in the output vector
      // We also assume that the output of the transformation is numerical
      if (t.includeInOutput) {
        foreach (i; 0 .. t.size()) {
          transex.features[outIndex++] =
            allFeatures[t.outputStartIndex + i].numval;
        }
      }
    }

    transex.target = ex.target;
  }

  void transformSet(DataSet data, out TransformedDataSet output) {
    output.examples.length = data.examples.length;

    foreach (i, example; data.examples) {
      transform(example, output.examples[i]);
    }
  }

  private FeatureVector allFeatures;
}

int main(string args[]) {
  if (args.length != 3) {
    writeln("Wrong number of arguments");
    return -1;
  }

  auto data = Parser.Parser.parseCsvFile(args[1]);
  auto transformer = new Transformer(data.featureLabels, args[2]);
  transformer.preprocess(data);

  TransformedDataSet transdata;
  transformer.transformSet(data, transdata);

  const char delim = ',';
  foreach(example; transdata.examples) {
    write(example.target);
    foreach (value; example.features) {
      write(delim, value);
    }
    writeln();
  }

  return 0;
}
