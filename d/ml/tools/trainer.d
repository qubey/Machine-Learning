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
import common.json;
import transform.transformer;
import algorithm.modelfactory;

struct OutputConfig {
  bool writeFeatures = true;
  bool writeTarget = true;
  string delimiter = ",";
  string[] copyColumns;
}

struct InputConfig {
  string targetName = "target";
  string trainingFile;
  string testFile;
}

OutputConfig getOutputConfig(JSONValue config) {
  OutputConfig result;
  JSONValue outputConfig;
  if (!JSONUtil.getObject(config, "output", outputConfig)) {
    // didn't find the object
    return result;
  }
  JSONUtil.getBool(outputConfig, "features", result.writeFeatures);
  JSONUtil.getBool(outputConfig, "target", result.writeTarget);
  JSONUtil.getString(outputConfig, "delimiter", result.delimiter);
  JSONUtil.getArray!string(outputConfig, "raw_copy_cols", result.copyColumns);

  return result;
}

InputConfig getInputConfig(JSONValue config) {
  InputConfig result;
  JSONValue inputConfig;
  bool success = JSONUtil.getObject(config, "input", inputConfig);
  assert(success, "Could not find 'input' node in config");
  success =
    JSONUtil.getString(inputConfig, "training_data", result.trainingFile);
  assert(success, "Could not find training data file name");
  JSONUtil.getString(inputConfig, "test_data", result.testFile);

  JSONUtil.getString(inputConfig, "target_name", result.targetName);
  return result;
}

void getTransformedData(
  string dataFile,
  JSONValue config,
  bool hasTarget,
  out TransformedDataSet data,
  out DataSet rawData
) {
  auto transformer = new Transformer(config);
  auto inConfig = getInputConfig(config);

  rawData =
    Parser.parseCsvFile(dataFile, hasTarget ? inConfig.targetName : "");
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
  DataSet rawData;
  TransformedDataSet trainingData;
  getTransformedData(args[1], config, true, trainingData, rawData);

  TransformedDataSet testData;
  if (args.length == 4) {
    getTransformedData(args[3], config, false, testData, rawData);
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
  if (outconfig.copyColumns.length > 0) {
    labels = labels ~ outconfig.copyColumns;
  }
  writeln(joiner(labels, outconfig.delimiter));

  int[] colIndices =array(
    map!(a => findIndex(rawData.featureLabels, a))(outconfig.copyColumns)
  );

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
    if (outconfig.copyColumns.length > 0) {
      line = line ~ array(
        map!(
          a => to!string(rawData.examples[i].features[a].strval)
        )(colIndices)
      );
    }
    writeln(joiner(line, outconfig.delimiter));
  }

  return 0;
}
