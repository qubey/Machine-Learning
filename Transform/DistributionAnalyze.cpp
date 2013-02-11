// Copyright 2013 Ruben Sethi.  All rights reserved

#include "FeatureStats.h"
#include <StringUtil.h>

#include <string>
#include <iostream>
#include <sstream>
#include <unordered_map>

using namespace std;

const char kOutputDelimiter = ',';

int main(int argc, char **argv) {
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " <feature_name>" << endl;
    return -1;
  }

  string feature(argv[1]);
  string line;
  std::getline(std::cin, line);

  vector<string> features;
  StringUtil::split(line, ',', &features);
  int featureIndex = -1;
  for (int i = 0; i < features.size(); i++) {
    if (feature == features[i]) {
      featureIndex = i;
      break;
    }
  }

  if (featureIndex == -1) {
    cerr << "Could not find feature " << feature << endl;
    return -1;
  }

  FeatureStats stats;

  while (getline(std::cin, line)) {
    vector<string> featureValues;
    StringUtil::split(line, ',', &featureValues);
    stats.addValue(featureValues[featureIndex], false);
  }

  for (const auto& kv : stats.getDistribution()) {
    cout << kv.first << ": " << kv.second << endl;
  }
}
