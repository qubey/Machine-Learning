module workflow.evaluator;

import std.json;
import std.conv;
import std.stdio;

import common.data;

struct EvaluationConfig {
  bool enabled = false;
  long crossValidationFolds = 10;
  string measurementMethod;
  long seed;
}

class PredictionEvaluator {
  private {
    EvaluationConfig evalConfig;
    double accumulatedAccuracy = 0.0;
    ulong count = 0;
  }

  this(EvaluationConfig config) {
    evalConfig = config;
  }

  void measurePredictions(ref TransformedDataSet data, double[] preds) {
    switch(evalConfig.measurementMethod) {
      case "percent_correct":
        percentCorrect(data, preds);
        break;
      default:
        assert(false, "Invalid measurement method: "
               ~ evalConfig.measurementMethod);
    }
  }

  void done() {
    writeln("Average accuracy: " ~ to!string(accumulatedAccuracy / count));
  }

  private void percentCorrect(
    ref TransformedDataSet data,
    double[] predictions
  ) {
    assert(data.examples.length == predictions.length);

    ulong correct = 0;
    foreach(i; 0 .. predictions.length) {
      if (data.examples[i].target == predictions[i]) correct++;
    }

    double accuracy = cast(double) correct / predictions.length;
    accumulatedAccuracy += accuracy;
    count++;
    writeln("Accuracy: " ~ to!string(accuracy));
  }
}
