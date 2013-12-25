module algorithm.clustering.kmeans;

import std.algorithm;
import std.stdio;
import std.string;
import std.range;
import std.json;
import std.random;
import std.container;
import std.math;
import std.conv;
import std.array;

import common.data;
import algorithm.model;
import algorithm.clustering.centroid_model;

class KMeansModel : CentroidModel {
  this(JSONValue config) {
    super(config);
  }

  /*
   * Given the partitioned data, computes new centroids
   */
  override protected void computeCentroids(
    ref DList!TransformedExample data[]
  ) {
    foreach(i, list; data) {
      if (walkLength(list[]) == 0) {
        continue;
      }

      double[] sum;
      int count = 0;
      sum.length = list.front().features.length;

      foreach (item; list) {
        foreach (j, val; item.features) {
          sum[j] += val;
        }
        count++;
      }

      foreach(j; 0 .. centroids[i].length) {
        auto center = sum[j] / count;
        if (!isNaN(center)) {
          centroids[i][j] = center;
        }
      }
    }
  }

  // This does one pass over the full data to find the range in which the
  // randomized values should fall.
  override protected void initializeCentroids(ref TransformedDataSet data) {
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

    auto randGen = Mt19937(cast(uint)seed);
    foreach (curClass; 0 .. k) {
      foreach(i; 0 .. featureMins.length) {
        double num = 0.0;
        if (featureMins[i] != featureMaxes[i]) {
          num = uniform(featureMins[i], featureMaxes[i], randGen);
        }
        centroids[curClass][i] = num;
      }
    }
  }
}
