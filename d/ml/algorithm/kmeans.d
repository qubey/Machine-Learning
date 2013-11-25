module algorithm.kmeans;

import std.algorithm;
import std.stdio;
import std.string;
import std.range;
import std.json;
import std.random;

import common.data;
import algorithm.model;

class KMeansModel : Model {
  private {
    const int kPrecision = 1000;
    int k; // number of clusters
    double[][] centroids;
    int seed;
  }

  this(JSONValue config) {
    super(config);
    assert("k" in config.object, "Missing 'k' value for k-means");
    auto knode = config.object["k"];
    assert(knode.type == JSON_TYPE.INTEGER,
           "k value for k-means should be int");

    if ("seed" in config.object) {
      auto seedNode = config.object["seed"];
      assert(seedNode.type == JSON_TYPE.INTEGER, "Seed for kmeans not an int");
      seed = cast(int) seedNode.integer;
    } else {
      seed = 66;
    }

    // Initialize the number of clusters
    k = cast(int)knode.integer;
    centroids.length = k;
  }

  override void batchTrain(const ref TransformedDataSet data) {
    assert(data.examples.length > 0, "Data given has 0 examples");
    assert(data.examples[0].features.length > 0, "Data given has 0 features");

    initializeCentroids(data);
  }

  // Initialize the starting random centroids for the k means algorithm
  // This does one pass over the full data to find the range in which the
  // randomized values should fall.
  private void initializeCentroids(const ref TransformedDataSet data) {
    auto firstExample = data.examples[0];

    double[] featureMins, featureMaxes;
    featureMins.length = featureMaxes.length = firstExample.features.length;

    // initialize min/max feature values
    foreach (i, value; firstExample.features) {
      featureMins[i] = featureMaxes[i] = value;
    }

    // Find each feature min and max
    foreach (ex; data.examples) {
      assert(ex.features.length > 0, "Bad example given");

      foreach(i, fval; ex.features) {
        if (fval > featureMaxes[i]) featureMaxes[i] = fval;
        if (fval < featureMins[i]) featureMins[i] = fval;
      }
    }


    foreach(i; 0 .. k) {
      centroids[i].length = firstExample.features.length;
    }

    auto randGen = Mt19937(seed);
    foreach (curClass; 0 .. k) {
      foreach(i; 0 .. featureMins.length) {
        double num = uniform(featureMins[i], featureMaxes[i], randGen);
        centroids[curClass][i] = num;
      }
    }
  }
}
