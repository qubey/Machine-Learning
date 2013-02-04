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
    vector<string> info = StringUtil::split(line, kDelimiter);
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

int main(int argc, char** argv) {
  if (argc != 2) {
    cerr << "Error: expects one argument.  " << argv[0]
         << " <feature info file>" << endl;
    return -1;
  }

  unordered_map<string, shared_ptr<Transform>> featureTransforms;
  if (!parseFeatureTransforms(argv[1], &featureTransforms)) {
    return -1;
  }
}
