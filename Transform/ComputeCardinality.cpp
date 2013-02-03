// Copyright 2013 Ruben Sethi.  All rights reserved

#include "Cardinality.h"
#include <StringUtil.h>

#include <string>
#include <iostream>
#include <sstream>
#include <unordered_map>

using namespace std;

const char kOutputDelimiter = ',';

int main(int argc, char **argv) {
  string line;
  std::getline(std::cin, line);

  vector<string> features = StringUtil::split(line, ',');
  vector<FeatureCardinality> cardinalities(features.size());

  while (getline(std::cin, line)) {
    vector<string> featureValues = StringUtil::split(line, ',');
    for (int i = 0; i < featureValues.size()
                    && i < features.size(); i++) {
      cardinalities[i].addValue(featureValues[i]);
    }
  }

  for (int i = 0; i < cardinalities.size(); i++) {
    size_t cardinality = cardinalities[i].getCardinality();
    ostringstream ss;
    ss << cardinality;
    std::cout << features[i] << kOutputDelimiter
              << (cardinality == -1 ? "LIMIT" : ss.str())
              << kOutputDelimiter << cardinalities[i].getType()
              << std::endl;
  }
}
