module workflow.execution;

import std.stdio;
import std.json;
import std.file;
import std.algorithm;
import std.range;
import std.conv;
import std.random;
import std.container;
import std.stdio;

import common.util;
import common.data;
import common.parser;
import common.json;
import transform.transformer;
import algorithm.modelfactory;
import workflow.evaluator;

struct OutputConfig {
  bool writeFeatures = true;
  bool writeTarget = true;
  string predictionLabel;
  string delimiter = ",";
  string[] copyColumns;
}

struct InputConfig {
  string targetName = "target";
  string trainingFile;
  string testFile;
}

class WorkflowExecution {
  private {
    JSONValue config;
    InputConfig inputConfig;
    OutputConfig outputConfig;
    EvaluationConfig evalConfig;

    DataSet rawTrainingData;
    DataSet rawTestData;
    TransformedDataSet trainingData;
    TransformedDataSet testData;

    string dataDir;

    Transformer transformer;
    Model model;
    PredictionEvaluator evaluator;
  }

  this(string configFile, string dataRoot) {
    config = parseJson(configFile);
    inputConfig = getInputConfig(config);
    outputConfig = getOutputConfig(config);
    evalConfig = getEvalConfig(config);

    dataDir = dataRoot;
    model = ModelFactory.create(config);
    evaluator = new PredictionEvaluator(evalConfig);
    transformer = new Transformer(config);
  }

  void run() {
    // Get training data
    DataSet rawData;
    getTransformedData(
      dataDir ~ inputConfig.trainingFile,
      config,
      true,
      trainingData,
      rawData);
    TransformedDataSet predictionData = trainingData;

    // Get test data
    if (!inputConfig.testFile.empty) {
      getTransformedData(
        dataDir ~ inputConfig.testFile,
        config,
        false,
        testData,
        rawData);

      predictionData = testData;
    }

    if (evalConfig.enabled) {
      crossValidation();
    } else {
      // Evaluate on test set and write output to stdout
      double[] preds;
      trainAndPredict(trainingData, predictionData, preds);
      writeResults(rawData, predictionData, preds);
    }
  }

  public void save(string file) {
    // Copy whole input config
    auto copy = config;
    // Update the transform config
    transformer.saveTransforms(copy);
    // Update the last trained model
    model.saveModel(copy);
    if(file.empty) {
      writeln(toJSON(&copy));
    } else {
      std.file.write(file, toJSON(&copy));
    }
  }

  private void crossValidation() {
    // randomize training set
    TransformedExample[] randExamples;
    getRandomizedTrainingExamples(randExamples);

    TransformedDataSet trainData;
    TransformedDataSet testData;

    ulong blockSize = randExamples.length / evalConfig.crossValidationFolds;
    foreach (iteration; 0 .. evalConfig.crossValidationFolds) {
      trainData.examples = randExamples[0 .. iteration * blockSize]
        ~ randExamples[(iteration + 1) * blockSize .. $];
      testData.examples =
        randExamples[iteration * blockSize .. (iteration + 1) * blockSize];

      double[] preds;
      trainAndPredict(trainData, testData, preds);
      evaluator.measurePredictions(testData, preds);
    }

    evaluator.done();
  }

  private void getRandomizedTrainingExamples(out TransformedExample[] result) {
    ulong[] originalIndices;
    DList!ulong randomizedIndices;

    originalIndices.length = trainingData.examples.length;
    // initialize original indices
    foreach(i; 0 .. trainingData.examples.length) {
      originalIndices[i] = i;
    }

    auto randGen = Mt19937(cast(uint)evalConfig.seed);
    while (originalIndices.length > 0) {
      auto index = uniform(0, originalIndices.length, randGen);
      randomizedIndices.insert(originalIndices[index]);
      originalIndices = originalIndices[0 .. index]
        ~ originalIndices[index + 1 .. originalIndices.length];
    }

    result = array(map!(a => trainingData.examples[a])(randomizedIndices[]));
  }

  private void trainAndPredict(ref TransformedDataSet trainData,
                               ref TransformedDataSet predData,
                               out double[] preds) {
    model.batchTrain(trainData);
    model.batchPredict(predData, preds);
    assert(preds.length > 0, "Got no predictions");
    assert(preds.length == predData.examples.length,
           "Predictions length doesn't match example length");
  }

  private void writeResults(
    ref DataSet rawPredData,
    ref TransformedDataSet predictionData,
    double[] preds
  ) {
    // Write the header
    string[] labels = [ outputConfig.predictionLabel ];
    if (outputConfig.writeTarget) {
      labels = [ trainingData.targetLabel ] ~ labels;
    }
    if (outputConfig.writeFeatures) {
      labels = labels ~ predictionData.featureLabels;
    }
    if (outputConfig.copyColumns.length > 0) {
      labels = labels ~ outputConfig.copyColumns;
    }
    writeln(joiner(labels, outputConfig.delimiter));

    // Get the indicies for the columns that should be raw copied to output
    int[] colIndices =array(
      map!(a => findIndex(rawPredData.featureLabels, a))
      (outputConfig.copyColumns)
    );

    // Write the predictions and vector to stdout
    foreach(i; 0 .. preds.length) {
      auto example = predictionData.examples[i];
      auto line = [ to!string(preds[i]) ];
      if (outputConfig.writeTarget) {
        line = [ to!string(example.target) ] ~ line;
      }
      if (outputConfig.writeFeatures) {
        line = line ~ array(map!(a => to!string(a))(example.features));
      }
      if (outputConfig.copyColumns.length > 0) {
        auto rpd = rawPredData.examples[i];
        line = line ~ array(
          map!(
            a => normalizeRawInputColumn(rpd.features[a].strval)
          )(colIndices)
        );
      }
      writeln(joiner(line, outputConfig.delimiter));
    }
  }

  private string normalizeRawInputColumn(string input) {
    string result = input;
    if (isStringCsvField(input)) {
      result = "\"" ~ normalize(result) ~ "\"";
    }

    return result;
  }

  private void getTransformedData(
    string dataFile,
    JSONValue config,
    bool hasTarget,
    out TransformedDataSet data,
    out DataSet rawData
  ) {
    auto inConfig = getInputConfig(config);

    rawData =
      Parser.parseCsvFile(dataFile, hasTarget ? inConfig.targetName : "");
    transformer.initializeTransforms(rawData.featureLabels);

    if (transformer.shouldPreprocess()) {
      transformer.preprocess(rawData);
    }

    transformer.transformSet(rawData, data);
  }

  private EvaluationConfig getEvalConfig(JSONValue config) {
    EvaluationConfig result;
    JSONValue evalNode;
    bool success = JSONUtil.parseValue(config, "evaluation", evalNode);

    if (!success) return result;

    JSONUtil.parseValue(evalNode, "enable", result.enabled);
    JSONUtil.parseValue(evalNode, "folds", result.crossValidationFolds);
    JSONUtil.parseValue(evalNode, "measurement", result.measurementMethod);
    JSONUtil.parseValue(evalNode, "seed", result.seed);

    return result;
  }

  private InputConfig getInputConfig(JSONValue config) {
    InputConfig result;
    JSONValue inputConfig;
    bool success = JSONUtil.parseValue(config, "input", inputConfig);
    assert(success, "Could not find 'input' node in config");
    success =
      JSONUtil.parseValue(inputConfig, "training_data", result.trainingFile);
    assert(success, "Could not find training data file name");
    JSONUtil.parseValue(inputConfig, "test_data", result.testFile);

    JSONUtil.parseValue(inputConfig, "target_name", result.targetName);
    return result;
  }


  private OutputConfig getOutputConfig(JSONValue config) {
    OutputConfig result;
    JSONValue outputConfig;
    if (!JSONUtil.parseValue(config, "output", outputConfig)) {
      // didn't find the object
      return result;
    }
    JSONUtil.parseValue(outputConfig,
                       "prediction_label", 
                       result.predictionLabel);
    JSONUtil.parseValue(outputConfig, "features", result.writeFeatures);
    JSONUtil.parseValue(outputConfig, "target", result.writeTarget);
    JSONUtil.parseValue(outputConfig, "delimiter", result.delimiter);
    JSONUtil.parseValue(outputConfig, "raw_copy_cols", result.copyColumns);

    return result;
  }
}
