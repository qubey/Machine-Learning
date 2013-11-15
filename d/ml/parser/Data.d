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
  int target;
  FeatureVector features;
}

struct DataSet {
  DList!RawExample examples;
  string targetLabel;
  string[] featureLabels;
}
