module algorithm.kmeans;

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

class KMeansModel : Model {
  private {
    const int kPrecision = 1000;
    int k; // number of clusters
    double[][] centroids;
    int seed;
    int iterations;
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

    assert ("iterations" in config.object, "Missing iterations count");
    auto iterationNode = config.object["iterations"];
    assert(iterationNode.type == JSON_TYPE.INTEGER);
    iterations = cast(int) iterationNode.integer;
  }

  override void batchTrain(ref TransformedDataSet data) {
    assert(data.examples.length > 0, "Data given has 0 examples");
    assert(data.examples[0].features.length > 0, "Data given has 0 features");

    initializeCentroids(data);

    // initialize the classified data
    DList!TransformedExample  partitionedData[];
    partitionedData.length = k;

    // start the iterations until convergence
    foreach (i; 0 .. iterations) {
      // Start from a clean slate
      foreach(list; partitionedData) {
        list.clear();
      }

      partitionData(data, partitionedData);
      computeCentroids(partitionedData);
    }
  }

  /*
   * Given the partitioned data, computes new centroids
   */
  private void computeCentroids(ref DList!TransformedExample data[]) {
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
        centroids[i][j] = sum[j] / count;
      }
    }
  }

  /*
   * Use the current centroids to partition the data into the k classes
   */
  private void partitionData(
    ref TransformedDataSet data,
    ref DList!TransformedExample partitionedData[]
  ) {
    foreach (ex; data.examples) {
      double minDistance = computeDistance(centroids[0], ex.features);
      int closestCentroid = 0;

      foreach(centroid; 1 .. k) {
        double distance = computeDistance(centroids[centroid], ex.features);
        if (distance < minDistance) {
          minDistance = distance;
          closestCentroid = centroid;
        }
      }

      partitionedData[closestCentroid].insert(ex);
    }
  }

  // Computes the L2 norm of the difference of two vectors
  double computeDistance(const double[] from, const double[] to) {
    assert(from.length == to.length, "Data points are not of the same length");

    double squaredSum = 0;
    foreach(i; 0 .. from.length) {
      double diff = from[i] - to[i];
      squaredSum += (diff * diff);
    }

    return sqrt(squaredSum);
  }

  // Initialize the starting random centroids for the k means algorithm
  // This does one pass over the full data to find the range in which the
  // randomized values should fall.
  private void initializeCentroids(ref TransformedDataSet data) {
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
