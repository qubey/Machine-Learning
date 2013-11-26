module common.data;

import std.range, std.stdio, std.file;
import std.conv, std.container;
import std.csv;

enum FeatureValueType {
  STRING,
  DOUBLE
}

struct FeatureValue {
  FeatureValueType type;
  union {
    string strval;
    double numval;
  }

  this(string str) {
    type = FeatureValueType.STRING;
    strval = str;
  }

  this(double num) {
    type = FeatureValueType.DOUBLE;
    numval = num;
  }
}

alias FeatureVector = FeatureValue[];

struct RawExample {
  double target;
  FeatureVector features;
}

struct DataSet {
  RawExample[] examples;
  string targetLabel;
  string[] featureLabels;
}

struct TransformedExample {
  double[] features;
  double target;
}

struct TransformedDataSet {
  TransformedExample[] examples;
  string targetLabel;
  string[] featureLabels;
}
