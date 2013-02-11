// Copyright 2013 Ruben Sethi.  All rights reserved

#include <StringUtil.h>

#include <string>
#include <iostream>
#include <sstream>
#include <unordered_map>

using namespace std;

const char kOutputDelimiter = ',';

int main(int argc, char **argv) {
  if (argc < 2) {
    cerr << "Usage: " << argv[0] << " <feature_name>" << endl;
    return -1;
  }

  vector<string> featureNames;
  for (int i = 1; i < argc; i++) {
    featureNames.push_back(string(argv[i]));
  }

  string line;
  std::getline(std::cin, line);

  // Process the feature names and find the index for each of them
  vector<int> featureIndices(featureNames.size(), -1);
  vector<string> features;
  StringUtil::split(line, ',', &features);
  for (int i = 0; i < features.size(); i++) {
    for (int j = 0; j < featureNames.size(); j++) {
      if (featureNames[j] == features[i]) {
        featureIndices[j] = i;
        break;
      }
    }
  }

  // Make sure we got all of the features
  for (int i = 0; i < featureNames.size(); i++) {
    if (featureIndices[i] == -1) {
      cerr << "Could not find feature " << featureNames[i] << endl;
      return -1;
    }
  }

  // Print out header
  for (int i = 0; i < featureNames.size(); i++) {
    if (i > 0) {
      cout << kOutputDelimiter;
    }
    cout << featureNames[i];
  }
  cout << endl;

  while (getline(std::cin, line)) {
    vector<string> featureValues;
    StringUtil::split(line, ',', &featureValues);
    for (int i = 0; i < featureIndices.size(); i++) {
      if (i > 0) {
        cout << kOutputDelimiter;
      }
      cout << featureValues[featureIndices[i]];
    }
    cout << endl;
  }
}
