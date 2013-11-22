module tools.transformdata;

import std.stdio;
import std.range;
import std.algorithm;

import common.data;
import common.parser;
import transform.transformer;

int main(string args[]) {
  if (args.length != 3) {
    writeln(args[0] ~ " <data file> <transform config>");
    return -1;
  }

  auto transformer = new Transformer(args[2]);

  auto data = Parser.parseCsvFile(args[1]);
  transformer.initializeTransforms(data.featureLabels);

  if (transformer.shouldPreprocess()) {
    transformer.preprocess(data);
  }

  TransformedDataSet transdata;
  transformer.transformSet(data, transdata);

  const string delim = ",";
  // output the labels first
  auto labels = [ data.targetLabel ];
  foreach (t; transformer.getTransforms()) {
    if (t.includeInOutput) {
      labels = array(chain(labels, t.getOutputNames()));
    }
  }
  writeln(joiner(labels, delim));

  // output the transformed data
  foreach(example; transdata.examples) {
    write(example.target);
    foreach (value; example.features) {
      write(delim, value);
    }
    writeln();
  }

  return 0;
}
