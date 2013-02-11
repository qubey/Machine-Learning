// Copyright 2013 Ruben Sethi.  All rights reserved

#include "FeatureStats.h"
#include <StringUtil.h>

#include <string>
#include <iostream>
#include <sstream>
#include <unordered_map>

using namespace std;

const char kOutputDelimiter = ',';

void printFeatureStats(vector<string>& features,
                       vector<FeatureStats>& featureStats) {
  for (int i = 0; i < featureStats.size(); i++) {
    string type = featureStats[i].getType();
    size_t cardinality = featureStats[i].getCardinality();

    stringstream extraInfo;
    if (cardinality != -1) {
      vector<string> values;
      featureStats[i].getFeatureValues(&values);
      for (const string& value : values) {
        extraInfo << kOutputDelimiter << value;
      }
    } else if (type == "Double") {
      pair<int, int> intBounds = featureStats[i].getIntBounds();
      extraInfo << kOutputDelimiter << intBounds.first
             << kOutputDelimiter << intBounds.second;
    } else if (type == "Integer")  {
      pair<double, double> doubleBounds = featureStats[i].getDoubleBounds();
      extraInfo << kOutputDelimiter << doubleBounds.first
             << kOutputDelimiter << doubleBounds.second;
    }


    ostringstream ss;
    ss << cardinality;
    std::cout << features[i] << kOutputDelimiter
              << featureStats[i].getType() << kOutputDelimiter
              << (cardinality == -1 ? "LIMIT" : ss.str())
              << extraInfo.str()
              << std::endl;
  }
}

int main(int argc, char **argv) {
  string line;
  std::getline(std::cin, line);

  vector<string> features;
  StringUtil::split(line, ',', &features);
  vector<FeatureStats> featureStats(features.size());

  while (getline(std::cin, line)) {
    vector<string> featureValues;
    StringUtil::split(line, ',', &featureValues);
    if (featureValues.size() != features.size()) {
      continue;
    }
    for (int i = 0; i < featureValues.size()
                    && i < features.size(); i++) {
      featureStats[i].addValue(featureValues[i]);
    }
  }

  printFeatureStats(features, featureStats);
}
