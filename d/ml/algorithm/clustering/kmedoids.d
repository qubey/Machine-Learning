module algorithm.clustering.kmedoids;

import std.conv;
import std.json;
import std.container;
import std.algorithm;
import std.range;

import algorithm.model;
import algorithm.clustering.centroid_model;
import common.data;

class KMedoidsModel : CentroidModel {

  this(JSONValue config) {
    super(config);
  }

  override protected void computeCentroids(
    ref DList!TransformedExample data[]
  ) {
    foreach (i, list; data) {
      double minDistance = double.max;
      double[] newCentroid;
      foreach (potCenter; list) {
        double distance = reduce!((a,b) => a+b)(
          map!(a => computeDistance(potCenter.features, a.features))(list[])
        );

        if (distance < minDistance) {
          minDistance = distance;
          newCentroid = potCenter.features;
        }
      }

      centroids[i] = newCentroid;
    }
  }

  override protected void initializeCentroids(ref TransformedDataSet data) {
    double[] zeroVector;
    zeroVector.length = data.examples[0].features.length;
    zeroVector[0 .. $] = 0;
    DList!(double[]) initialCentroids;

    // get the first centroid (find the max relative to the 0 vector)
    double[] distances;
    distances =
      array(map!(a => computeDistance(zeroVector, a.features))(data.examples));
    initialCentroids.insert(data.examples[findMax(distances)].features);

    foreach(i; 1 .. k) {
      distances[0 .. $] = 0;
      foreach(centroid; initialCentroids) {
        auto curDist =
          map!(a => computeDistance(centroid, a.features))(data.examples);
        distances[] += array(curDist)[];
      }

      initialCentroids.insert(data.examples[findMax(distances)].features);
    }

    centroids = array(initialCentroids);
    assert(centroids.length == k);
  }

  private int findMax(ref double[] values) {
    assert(values.length > 0, "Values should be > 0");

    int idx = 0;
    foreach(i; 0 .. values.length) {
      if (values[i] > values[idx]) idx = cast(int)i;
    }

    return idx;
  }
}
