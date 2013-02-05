// Copyright 2013 Ruben Sethi.  All rights reserved

#include "transforms/TransformFactory.h"
#include <StringUtil.h>

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <memory>

using namespace std;

const char kDelimiter = ',';

bool parseFeatureTransforms(const char* file,
                         unordered_map<string, shared_ptr<Transform>>* output) {
  fstream featureData(file);
  if (!featureData.good()) {
    cerr << "Couldn't open file " << file << endl;
    return false;
  }

  // Parse the file containing the feature information
  string line;
  while (getline(featureData, line)) {
    vector<string> info;
    StringUtil::split(line, kDelimiter, &info);
    if (info.size() < 3) {
      cerr << "Invalid line: " << line << endl;
      continue;
    }

    shared_ptr<Transform> transform = TransformFactory::createTransform(info);
    (*output)[transform->getName()] = transform;
  }
  featureData.close();

  return true;
}

void constructTransformMap(
        unordered_map<string, shared_ptr<Transform>>& transforms,
        const char *targetName,
        vector<shared_ptr<Transform>>* out,
        int* targetIndex) {
  out->clear();

  string line;
  getline(cin, line);

  vector<string> features;
  StringUtil::split(line, kDelimiter, &features);
  string target(targetName);

  out->resize(features.size());
  for (int i = 0; i < features.size(); i++)  {
    if (features[i] == target) {
      *targetIndex = i;
      continue;
    }

    if (transforms.find(features[i]) != transforms.end()) {
      (*out)[i] = transforms[features[i]];
    }
  }
}

int main(int argc, char** argv) {
  if (argc != 3) {
    cerr << "Error: expects one argument.  " << argv[0]
         << " <feature_info_file> <target_feature_name>" << endl;
    return -1;
  }

  unordered_map<string, shared_ptr<Transform>> featureTransforms;
  if (!parseFeatureTransforms(argv[1], &featureTransforms)) {
    return -1;
  }

  vector<shared_ptr<Transform>> executionTransforms;
  int targetIndex;
  constructTransformMap(featureTransforms, argv[2],
                        &executionTransforms, &targetIndex);

  // Get the total number of output features
  int outputCount = 0;
  for (int i = 0; i < executionTransforms.size(); i++) {
    if (executionTransforms[i]) {
      outputCount += executionTransforms[i]->getNumOutputs();
    }
  }

  string line;
  vector<double> finalFeatures(outputCount);
  vector<double> transformedValues;
  int offset = 0;
  while (getline(cin, line)) {
    vector<string> featureValues;
    StringUtil::split(line, kDelimiter, &featureValues);

    for (int i = 0; i < featureValues.size()
                    && i < executionTransforms.size(); i++) {
      if (!executionTransforms[i]) {
        continue;
      }

      executionTransforms[i]->execute(featureValues[i], &transformedValues);

      for (int j = 0; j < executionTransforms[i]->getNumOutputs(); j++) {
        finalFeatures[offset++] = transformedValues[j];
      }
    }

    cout << featureValues[targetIndex];
    for (int i = 0; i < finalFeatures.size(); i++) {
      cout << kDelimiter << finalFeatures[i];
    }
    cout << endl;
    offset = 0;
  }

  bool isFirstName = true;
  vector<string> names;
  for (int i = 0; i < executionTransforms.size(); i++) {
    if(!executionTransforms[i]) {
     continue;
    }

    executionTransforms[i]->getNames(&names);
    if (names.size() == 0) {
      continue;
    }

    for (const auto& name : names) {
      if (!isFirstName) {
        cout << kDelimiter;
      }
      cout << name;
      isFirstName = false;
    }
  }
}
