// Copyright 2013 Ruben Sethi.  All rights reserved

#include "transforms/NGramTransform.h"
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
              unordered_map<string, shared_ptr<Transform>>* featureTransforms,
              vector<shared_ptr<Transform>>* transformTransforms) {
  fstream featureData(file);
  if (!featureData.good()) {
    cerr << "Couldn't open file " << file << endl;
    return false;
  }

  vector<shared_ptr<NGramTransform> > ngrams;
  // Parse the file containing the feature information
  string line;
  while (getline(featureData, line)) {
    if (line[0] == '#') {
      // Commented line
      continue;
    }

    vector<string> info;
    StringUtil::split(line, kDelimiter, &info);
    if (info.size() < 3) {
      cerr << "Invalid line: " << line << endl;
      continue;
    }

    if (info[1] == "NGram") {
      ngrams.push_back(make_shared<NGramTransform>(info));
    } else {
      shared_ptr<Transform> transform = TransformFactory::createTransform(info);
      (*featureTransforms)[transform->getName()] = transform;
    }
  }
  featureData.close();

  // Fill in the base transforms for the ngrams
  // This does not support ngrams of ngrams
  for (const auto& ngram : ngrams) {
    for (const auto& base : ngram->baseNames) {
      if (featureTransforms->find(base) == featureTransforms->end()) {
        cerr << "Could not find base: " << base << endl;
        continue;
      }

      ngram->addBaseTransform((*featureTransforms)[base]);
    }

    transformTransforms->push_back(ngram);
  }

  return true;
}

void constructTransformMap(
        unordered_map<string, shared_ptr<Transform>>& transforms,
        const char *targetName,
        vector<shared_ptr<Transform>>* out,
        int* targetIndex,
        int* featureCount) {
  out->clear();

  string line;
  getline(cin, line);

  vector<string> features;
  StringUtil::split(line, kDelimiter, &features);
  string target(targetName);
  *featureCount = features.size();

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
  vector<shared_ptr<Transform>> transformTransforms;
  if (!parseFeatureTransforms(argv[1], &featureTransforms,
                              &transformTransforms)) {
    return -1;
  }

  vector<shared_ptr<Transform>> executionTransforms;
  int targetIndex;
  int featureCount;
  constructTransformMap(featureTransforms, argv[2],
                        &executionTransforms, &targetIndex, &featureCount);

  // Get the total number of output features
  int outputCount = 0;
  for (int i = 0; i < executionTransforms.size(); i++) {
    if (executionTransforms[i]) {
      executionTransforms[i]->offset = outputCount;
      outputCount += executionTransforms[i]->getNumOutputs();
    }
  }

  for (int i = 0; i < transformTransforms.size(); i++) {
    if (!transformTransforms[i]) {
      cerr << "Missing transform" << endl;
      continue;
    }

    transformTransforms[i]->offset = outputCount;
    outputCount += transformTransforms[i]->getNumOutputs();
  }

  cerr << "Total number of output features: " << outputCount << endl;

  // Serialize the names of each column
  cout << argv[2];
  vector<string> names;
  for (int i = 0; i < executionTransforms.size(); i++) {
    if(!executionTransforms[i]) {
     continue;
    }

    executionTransforms[i]->getNames(&names);
    if (names.size() == 0) {
      continue;
    }

    if (names.size() != executionTransforms[i]->getNumOutputs()) {
      cerr << "Transform " << executionTransforms[i]->getName()
           << " had output size " << executionTransforms[i]->getNumOutputs()
           << " and name size " << names.size() << endl;
      return -1;
    }

    for (const auto& name : names) {
      cout << "," << name;
    }
  }

  for (const auto& transform : transformTransforms) {
    transform->getNames(&names);
    if (names.size() != transform->getNumOutputs()) {
      cerr << "Transform " << transform->getName()
           << " had output size " << transform->getNumOutputs()
           << " and name size " << names.size() << endl;
      return -1;
    }

    for (const auto& name : names) {
      cout << "," << name;
    }
  }
  cout << endl;

  // Read standard input and transform each row
  string line;
  vector<double> finalFeatures(outputCount);
  vector<string> featureValues;
  while (getline(cin, line)) {
    featureValues.clear();
    StringUtil::split(line, kDelimiter, &featureValues);

    if (featureValues.size() != featureCount) {
      continue;
    }

    for (int i = 0; i < featureValues.size()
                    && i < executionTransforms.size(); i++) {
      if (!executionTransforms[i]) {
        continue;
      }

      executionTransforms[i]->execute(featureValues[i], &finalFeatures);
    }

    for (const auto& transform : transformTransforms) {
      transform->execute(string(), &finalFeatures);
    }

    cout << featureValues[targetIndex];
    for (int i = 0; i < finalFeatures.size(); i++) {
      cout << kDelimiter << finalFeatures[i];
    }
    cout << endl;
  }
}
