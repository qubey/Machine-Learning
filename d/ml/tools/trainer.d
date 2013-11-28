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

struct OutputConfig {
  bool writeFeatures = true;
  bool writeTarget = true;
  string delimiter = ",";
}

void setBool(JSONValue config, string key, ref bool result) {
  assert(config.type == JSON_TYPE.OBJECT);
  if (key !in config.object) return;

  auto node = config.object[key];
  result = node.type == JSON_TYPE.TRUE;
}

OutputConfig getOutputConfig(JSONValue config) {
  OutputConfig result;
  if ("output" !in config.object) return result;

  auto outputConfig = config.object["output"];
  setBool(outputConfig, "features", result.writeFeatures);
  setBool(outputConfig, "target", result.writeTarget);

  if ("delimiter" !in outputConfig.object) {
    return result;
  }
  auto delimNode = outputConfig.object["delimiter"];
  assert(delimNode.type == JSON_TYPE.STRING);
  result.delimiter = delimNode.str;
  return result;
}

void getTransformedData(
  string dataFile,
  JSONValue config,
  bool hasTarget,
  out TransformedDataSet data
) {
  auto transformer = new Transformer(config);

  auto rawData = Parser.parseCsvFile(dataFile, hasTarget);
  transformer.initializeTransforms(rawData.featureLabels);

  if (transformer.shouldPreprocess()) {
    transformer.preprocess(rawData);
  }

  transformer.transformSet(rawData, data);
}

int main(string args[]) {
  if (args.length != 3 && args.length != 4) {
    writeln(args[0] ~ " <data file> <transform config>");
    return -1;
  }
  auto config = parseJson(args[2]);
  TransformedDataSet trainingData;
  getTransformedData(args[1], config, true, trainingData);

  TransformedDataSet testData;
  if (args.length == 4) {
    getTransformedData(args[3], config, false, testData);
  }

  auto model = ModelFactory.create(config);
  model.batchTrain(trainingData);

  double[] preds;
  auto predictionData = testData.examples.length > 0 ? testData : trainingData;
  model.batchPredict(predictionData, preds);
  assert(preds.length > 0, "Got no predictions");
  assert(preds.length == predictionData.examples.length,
         "Predictions length doesn't match example length");


  auto outconfig = getOutputConfig(config);
  string[] labels = [ "pred" ];
  if (outconfig.writeTarget) {
    labels = [ trainingData.targetLabel ] ~ labels;
  }
  if (outconfig.writeFeatures) {
    labels = labels ~ predictionData.featureLabels;
  }
  writeln(joiner(labels, outconfig.delimiter));

  // Write the predictions and vector to stdout
  foreach(i; 0 .. preds.length) {
    auto example = predictionData.examples[i];
    auto line = [ to!string(preds[i]) ];
    if (outconfig.writeTarget) {
      line = [ to!string(example.target) ] ~ line;
    }
    if (outconfig.writeFeatures) {
      line = line ~ array(map!(a => to!string(a))(example.features));
    }
    writeln(joiner(line, outconfig.delimiter));
  }

  return 0;
}
