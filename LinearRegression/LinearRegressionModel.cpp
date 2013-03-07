// Copyright 2013 Ruben Sethi.  All rights reserved

#include "LinearRegressionModel.h"
#include <iostream>
#include <unordered_map>

using namespace std;

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
