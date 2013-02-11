// Copyright 2013 Ruben Sethi.  All rights reserved

#include "LinearRegressionModel.h"
#include <iostream>
#include <unordered_map>

using namespace std;

void LinearRegressionModel::initialize(vector<string>& names,
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

bool LinearRegressionModel::setInputColumns(vector<string>& columns) {
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

bool LinearRegressionModel::train(vector<double>& example, double target) {
  if (example.size() != featureWeights_.size()) {
    cerr << "Training example size (" << example.size() << ") does not match "
         << "feature weight size (" << featureWeights_.size() << ")" << endl;
    return false;
  }

  double paren = 0;
  for (int i = 0; i < example.size(); i++) {
    paren += featureWeights_[i] * example[i];
  }

  for (int i = 0; i < example.size(); i++) {
    featureWeights_[i] = featureWeights_[i]
                        + learningRate_ * (target - paren) * example[i]
                        - weightPenalty_ * featureWeights_[i];
  }

  return true;
}

bool LinearRegressionModel::predict(vector<double>& example, double* target) {
  if (example.size() != featureWeights_.size()) {
    cerr << "Predict example size (" << example.size() << ") does not match "
         << "feature weight size (" << featureWeights_.size() << ")" << endl;
    return false;
  }

  double pTarget = 0;
  for (int i = 0; i < example.size(); i++) {
    pTarget += example[i] * featureWeights_[i];
  }

  *target = pTarget;
  return true;
}
