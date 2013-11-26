module tools.transformdata;

import std.stdio;
import std.json;
import std.file;

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

  return 0;
}
