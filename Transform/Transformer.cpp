// Copyright 2013 Ruben Sethi.  All rights reserved

#include <StringUtil.h> 

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <unordered_map>
#include <vector>

using namespace std;

const char kDelimiter = ',';

bool parseFeatureInfo(const char* file,
                      unordered_map<string, pair<string, int>>* output) {
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

    int cardinality;
    if (!StringUtil::parse(info[2], &cardinality)) {
      continue;
    }

    (*output)[info[0]] = make_pair(info[1], cardinality);
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

  unordered_map<string, pair<string, int>> featureInfo;
  if (!parseFeatureInfo(argv[1], &featureInfo)) {
    return -1;
  }
}
