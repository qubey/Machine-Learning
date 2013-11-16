import std.range, std.stdio, std.file;
import std.conv, std.container;
import std.csv;

enum FeatureValueType {
  STRING,
  DOUBLE
}

struct FeatureValue {
  FeatureValueType type;
  string strval;
  double numval;
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
  string[] featureLabels;
}
