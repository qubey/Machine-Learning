module tools.transformdata;

import std.stdio;
import std.json;
import std.file;
import std.algorithm;
import std.range;
import std.conv;

import common.util;
import common.data;
import common.parser;
import transform.transformer;
import algorithm.modelfactory;

void getTransformedData(
  string dataFile,
  JSONValue config,
  out TransformedDataSet data
) {
  auto transformer = new Transformer(config);

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
  auto config = parseJson(args[2]);
  TransformedDataSet transdata;
  getTransformedData(args[1], config, transdata);

  auto model = ModelFactory.create(config);
  model.batchTrain(transdata);

  double[] preds;
  model.batchPredict(transdata, preds);
  assert(preds.length > 0, "Got no predictions");
  assert(preds.length == transdata.examples.length,
         "Predictions length doesn't match example length");

  auto labels = chain([ transdata.targetLabel ],
                      transdata.featureLabels,
                      [ "pred" ]);
  writeln(joiner(labels, ","));

  // Write the predictions and vector to stdout
  foreach(i; 0 .. preds.length) {
    auto example = transdata.examples[i];
    auto line = chain([ to!string(example.target) ],
                    map!(a => to!string(a))(example.features),
                    [ to!string(preds[i]) ]);
    writeln(joiner(line, ","));
  }

  return 0;
}
