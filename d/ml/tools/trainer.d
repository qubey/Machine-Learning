module tools.transformdata;

import std.stdio;
import std.range;
import std.algorithm;

import common.data;
import common.parser;
import transform.transformer;

void getTransformedData(
  string dataFile,
  string configFile,
  out TransformedDataSet data
) {
  auto transformer = new Transformer(configFile);

  auto rawData = Parser.parseCsvFile(dataFile);
  transformer.initializeTransforms(rawData.featureLabels);

  if (transformer.shouldPreprocess()) {
    transformer.preprocess(rawData);
  }

  transformer.transformSet(rawData, data);
}

int main(string args[]) {
  if (args.length != 3) {
    writeln(args[0] ~ " <data file> <transform config>");
    return -1;
  }
  TransformedDataSet transdata;
  getTransformedData(args[1], args[2], transdata);

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
