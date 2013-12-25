module algorithm.classification.naivebayes;

import std.json;
import std.conv;
import std.stdio;
import std.range;

import algorithm.model;
import common.data;
import common.stats;
import common.json;

// TODO:
// 1. Implement Bayesian Naive Bayes (priors)
// 2. Implement different distributions for the priors and conditionals
// 2. a. Make the featureProbs a Multinoulli instead of bernoulli

class NaiveBayesModel : Model {
  private {
    Bernoulli[][] featureProbs;
    Multinoulli classProb;
    real featurePrior = 0;
    long featurePriorWeight = 0;
    long classPriorWeight = 0;
  }
  
  this(JSONValue config) {
    super(config);

    long k;
    assert(JSONUtil.parseValue(config, "k", k),
           "Need to specify number of classes");

    JSONUtil.parseValue(config, "feature_prior", featurePrior);
    JSONUtil.parseValue(config, "feature_prior_weight", featurePriorWeight);
    JSONUtil.parseValue(config, "class_prior_weight", classPriorWeight);

    classProb = Multinoulli(k, classPriorWeight);
    featureProbs.length = k;
  }

  override void save(ref JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT, "Config should be object");
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
        double classProb = classProb.get(k);
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
      featureProbs[i][] = Bernoulli(featurePrior, featurePriorWeight);
    }

    foreach (ex; data.examples) {
      assert(ex.target < classProb.classes(),
             "Target larger than k: " ~ to!string(ex.target));
      assert(ex.target >= 0, "Target < 0: " ~ to!string(ex.target));

      // Count the empirical class prior probability
      classProb.count(ex.target);

      // For each class, feature pair, count the class-conditional probability
      foreach(k; 0 .. featureProbs.length) {
        foreach (i; 0 .. ex.features.length) {
          auto val = ex.features[i];
          featureProbs[k][i].count(ex.target == cast(int)k && val == 1.0);
        }
      }
    }
  }
}
