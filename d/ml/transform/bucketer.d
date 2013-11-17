module transform.bucketer;

import std.stdio;
import std.json;
import std.container;
import std.conv;
import std.algorithm;
import std.array;

import common.data;
import transform.featuretransforms;

class BucketTransform : FeatureTransform {
  protected int buckets;
  protected double[] boundaries;

  this(JSONValue config) {
    super(config);
    assert("buckets" in config.object);
    auto bucketNode = config.object["buckets"];
    assert(bucketNode.type == JSON_TYPE.INTEGER);
    buckets = cast(int) bucketNode.integer;

    if ("info" in config.object) {
      auto infoNode = config.object["info"];
      assert(infoNode.type == JSON_TYPE.OBJECT,
             "Info node should be an object for " ~ name);
      assert("boundaries" in infoNode.object,
             "Info node should have boundaries for " ~ name);
      auto boundaryNode = infoNode.object["boundaries"];
      assert(boundaryNode.type == JSON_TYPE.ARRAY,
             "Boundary node should be an array for " ~ name);

      boundaries = array(
        map!(a =>
              cast(double)(a.type == JSON_TYPE.FLOAT ? a.floating : a.integer))
            (boundaryNode.array)
      );
      boundaries = array(sort(boundaries));
    }
  }

  override void save(ref JSONValue config) {
    super.save(config);

    JSONValue bucketsNode;
    bucketsNode.type = JSON_TYPE.INTEGER;
    bucketsNode.integer = buckets;
    config.object["buckets"] = bucketsNode;

    if (boundaries.length > 0) {
      JSONValue boundaryNode;
      boundaryNode.type = JSON_TYPE.ARRAY;

      foreach (i, bound; boundaries) {
        JSONValue boundNode;
        boundNode.type = JSON_TYPE.FLOAT;
        boundNode.floating = cast(real) bound;

        boundaryNode.array ~= boundNode;
      }

      JSONValue infoNode;
      infoNode.type = JSON_TYPE.OBJECT;
      infoNode.object["boundaries"] = boundaryNode;
      config.object["info"] = infoNode;
    }
  }

  override string[] getOutputNames() {
    string[] results;
    results.length = buckets;

    foreach(i; 0 .. buckets) {
      results[i] = name ~ "_" ~ to!string(i);
    }

    return results;
  }

  override bool requiresPreprocess() {
    return boundaries.length == 0;
  }

  override int size() {
    return buckets;
  }
}

class QuantileBucketTransform : BucketTransform {
  private SList!double values;
  private int count;

  this(JSONValue config) {
    super(config);
    count = 0;
  }

  override string getTypeName() { return "quantile_bucket"; }

  override void process(ref FeatureVector ex) {
    double value;
    if (getInputDouble(ex, value)) {
      values.insert(value);
      count++;
    }
  }

  override void finalize() {
    boundaries.length = buckets;
    double[] sortedValues = array(sort(array(values[])));
    values.clear();
    foreach (i; 0 .. buckets) {
      boundaries[i] = sortedValues[
        i * ((count - 1) / buckets)
      ];
    }
  }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value); 
    if (success) {
      int index = 0;
      while (index < buckets - 1 && value > boundaries[index]) { index++; }
      setOutputValue(ex, index, 1);
    }

    return success;
  }
}
