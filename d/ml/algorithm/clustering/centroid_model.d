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
import common.json;
import algorithm.model;

class CentroidModel : Model {
  protected {
    long k; // number of clusters
    double[][] centroids;
    long seed;
    long iterations;
  }

  this(JSONValue config) {
    super(config);

    bool success;
    success = JSONUtil.parseValue(config, "k", k);
    assert(success, "Could not find k value for model");

    seed = 66;
    JSONUtil.parseValue(config, "seed", seed);

    success = JSONUtil.parseValue(config, "iterations", iterations);
    assert(success, "Could not find 'iterations' in model config");

    // Check whether we have a starting point for the centroids
    JSONUtil.parseValue(config, "centroids", centroids);
  }

  override void save(ref JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT, "Config should be of type object");
    JSONUtil.saveValue(config, "k", k);
    JSONUtil.saveValue(config, "seed", seed);
    JSONUtil.saveValue(config, "iterations", iterations);
    JSONUtil.saveValue(config, "centroids", centroids);
  }

  // Initialize the centroids to their starting points
  protected abstract void initializeCentroids(ref TransformedDataSet data);

  // Given the partitioned data, compute the new centroids
  protected abstract void computeCentroids(ref DList!TransformedExample data[]);

  override void batchTrain(ref TransformedDataSet data) {
    assert(data.examples.length > 0, "Data given has 0 examples");
    assert(data.examples[0].features.length > 0, "Data given has 0 features");
    centroids.length = k;

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
      long closestCentroid = 0;

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
