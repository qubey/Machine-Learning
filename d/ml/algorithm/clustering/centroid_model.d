module algorithm.clustering.centroid_model;

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

class CentroidModel : Model {
  protected {
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

  // Initialize the centroids to their starting points
  protected abstract void initializeCentroids(ref TransformedDataSet data);

  // Given the partitioned data, compute the new centroids
  protected abstract void computeCentroids(ref DList!TransformedExample data[]);

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

  override void batchPredict(ref TransformedDataSet data, out double[] preds) {
    assert(data.examples.length > 0, "Data for predictions must be > 0");
    preds.length = data.examples.length;

    foreach (i, ex; data.examples) {
      double closestCentroid = 0;
      double minDistance = computeDistance(centroids[0], ex.features);

      // Find the closest centroid
      foreach (idx; 1 .. centroids.length) {
        double dist = computeDistance(centroids[idx], ex.features);
        if (dist < minDistance) {
          minDistance = dist;
          closestCentroid = idx;
        }
      }

      preds[i] = closestCentroid;
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
  protected double computeDistance(const double[] from, const double[] to) {
    if (from.length != to.length) {
      return double.max;
    }

    double squaredSum = 0;
    foreach(i; 0 .. from.length) {
      double diff = from[i] - to[i];
      squaredSum += (diff * diff);
    }

    return sqrt(squaredSum);
  }

}
