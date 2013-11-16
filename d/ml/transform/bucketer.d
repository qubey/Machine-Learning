module transform.bucketer;

import std.stdio;
import std.json;
import std.container;
import std.conv;
import std.algorithm;
import std.array;

import transform.data;
import transform.featuretransforms;

class BucketTransform : FeatureTransform {
  protected int buckets;

  this(JSONValue config) {
    super(config);
    assert("buckets" in config.object);
    auto bucketNode = config.object["buckets"];
    assert(bucketNode.type == JSON_TYPE.INTEGER);
    buckets = cast(int) bucketNode.integer;
  }

  override int size() {
    return buckets;
  }
}

class QuantileBucketTransform : BucketTransform {
  private SList!double values;
  private int count;
  private double[] boundaries;

  this(JSONValue config) {
    super(config);
    boundaries.length = buckets;
    count = 0;
  }

  override void process(ref FeatureVector ex) {
    double value;
    if (getInputDouble(ex, value)) {
      values.insert(value);
      count++;
    }
  }

  override void finalize() {
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
