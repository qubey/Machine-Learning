module algorithm.classification.lda;

import std.json;
import std.conv;
import std.range;
import std.container;

import algorithm.model;
import common.data;
import common.stats;
import common.json;

class LDAModel : Model {
  private {
    Gaussian[] classDensities;
    long k;
    Multinoulli priors;
    Gaussian overallDensity;
  }

  this(JSONValue config) {
    super(config);
    assert(JSONUtil.parseValue(config, "k", k),
           "Need to specify 'k', the number of classes");
  }

  override void batchTrain(ref TransformedDataSet data) {
    priors = Multinoulli(k, 0);
    // Get the MLE priors
    foreach (ex; data.examples) {
      priors.count(ex.target);
    }

    classDensities.length = k;
    classDensities[] = Gaussian(data.examples[0].features.length);
    overallDensity = Gaussian(data.examples[0].features.length);

    DList!(double[])[] classPoints;
    DList!(double[]) allPoints;
    classPoints.length = classDensities.length;

    foreach (point; data.examples) {
      assert(point.target >= 0);
      assert(point.target < classDensities.length);
      classPoints[cast(long) point.target].insert(point.features);
      allPoints.insert(point.features);
    }

    // Compute the class-conditional probability density

    foreach(i, points; classPoints) {
      classDensities[i].compute(array(points[]));
    }
    overallDensity.compute(array(allPoints[]));
  }

  override void batchPredict(ref TransformedDataSet data, out double[] preds) {
    
  }
}
