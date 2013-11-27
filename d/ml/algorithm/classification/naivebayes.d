module algorithm.classification.naivebayes;

import std.json;
import std.conv;

import algorithm.model;
import common.data;
import common.stats;

// TODO:
// 1. Implement Bayesian Naive Bayes (priors)
// 2. Implement different distributions for the priors and conditionals

class NaiveBayesModel : Model {
  private {
    Bernoulli[][] featureProbs;
    Multinoulli classPrior;
  }
  
  this(JSONValue config) {
    super(config);

    assert("k" in config.object, "Need to specify number of classes");
    auto kNode = config.object["k"];
    assert(kNode.type == JSON_TYPE.INTEGER, "K should be an int");

    auto k = cast(int) kNode.integer;
    classPrior = Multinoulli(k);
    featureProbs.length = k;
  }

  override void batchPredict(ref TransformedDataSet data, out double[] preds) {
    assert(data.examples.length > 0, "No data to predict on");
    assert(data.examples[0].features.length == featureProbs[0].length,
           "Data should have the same number of features as training data");

    preds.length = data.examples.length;

    foreach (i, ex; data.examples) {
      double maxProb = 0;
      double maxK = 0;
      double sum = 0;
      foreach (k; 0 .. featureProbs.length) {
        double classProb = classPrior.get(k);
        auto featureClassProbs = featureProbs[k];

        foreach (f; 0 .. ex.features.length) {
          double val = ex.features[f];
          classProb *= (val == 1 ?
            featureClassProbs[f].get()
            : featureClassProbs[f].inverse()
          );
        }

        if (classProb > maxProb) {
          maxProb = classProb;
          maxK = k;
        }
        sum += classProb;
      }

      preds[i] = maxK;
    }
  }

  override void batchTrain(ref TransformedDataSet data) {
    foreach(i; 0 .. featureProbs.length) {
      featureProbs[i].length = data.examples[0].features.length;
    }

    foreach (ex; data.examples) {
      assert(ex.target < classPrior.classes(),
             "Target larger than k: " ~ to!string(ex.target));
      assert(ex.target >= 0, "Target < 0: " ~ to!string(ex.target));

      // Count the empirical class prior probability
      classPrior.count(ex.target);

      // For each class, feature pair, count the class-conditional probability
      foreach(k; 0 .. featureProbs.length) {
        foreach (i; 0 .. ex.features.length) {
          featureProbs[k][i].count(ex.target == cast(int)k);
        }
      }
    }
  }
}
