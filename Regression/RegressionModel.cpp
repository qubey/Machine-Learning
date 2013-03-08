// Copyright 2013 Ruben Sethi.  All rights reserved

#include "RegressionModel.h"
#include <iostream>
#include <unordered_map>

using namespace std;

void RegressionModel::initialize(vector<string>& names,
                                       vector<double>& weights,
                                       double weightPenalty,
                                       double learningRate) {
  learningRate_ = learningRate;
  weightPenalty_ = weightPenalty;
  featureNames_ = names;
  featureWeights_ = weights;

  if (featureNames_.size() != featureWeights_.size()) {
    cerr << "Feature names do not match feature weights!" << endl;
  }
}

bool RegressionModel::setInputColumns(vector<string>& columns) {
  unordered_map<string, int> indices;
  vector<string> fNames(columns.size());
  vector<double> fWeights(columns.size());

  if (columns.size() != featureNames_.size()) {
    cerr << "Mismatch input column size and model weight size!" << endl;
  }

  for (int i = 0; i < columns.size(); i++) {
    indices[columns[i]] = i;
  }

  for (int i = 0; i < featureNames_.size(); i++) {
    if (indices.find(featureNames_[i]) == indices.end()) {
      cerr << "Could not find index for feature: " << featureNames_[i]
           << endl;
      continue;
    }

    int newIndex = indices[featureNames_[i]];
    fNames[newIndex] = featureNames_[i];
    fWeights[newIndex] = featureWeights_[i];
  }

  for (int i = 0; i < fNames.size(); i++) {
    if (fNames[i].size() == 0) {
      cerr << "Error: index " << i << " has no feature associated with it"
           << endl;
      return false;
    }
  }
  
  featureNames_ = fNames;
  featureWeights_ = fWeights;
  return true;
}
