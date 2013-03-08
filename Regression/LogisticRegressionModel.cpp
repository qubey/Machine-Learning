// Copyright 2013 Ruben Sethi.  All rights reserved

#include "LogisticRegressionModel.h"
#include <iostream>
#include <unordered_map>
#include <cmath>

using namespace std;

bool LogisticRegressionModel::train(vector<double>& example, double target) {
  if (example.size() != featureWeights_.size()) {
    cerr << "Training example size (" << example.size() << ") does not match "
         << "feature weight size (" << featureWeights_.size() << ")" << endl;
    return false;
  }

  double paren = 0;
  for (int i = 0; i < example.size(); i++) {
    paren += featureWeights_[i] * example[i];
  }
  paren = 1.0 / (1.0 + exp(-1 * paren));

  for (int i = 0; i < example.size(); i++) {
    featureWeights_[i] = featureWeights_[i]
                        + learningRate_ * (target - paren) * example[i]
                        - weightPenalty_ * featureWeights_[i];
  }

  return true;
}

bool LogisticRegressionModel::predict(vector<double>& example, double* target) {
  if (example.size() != featureWeights_.size()) {
    cerr << "Predict example size (" << example.size() << ") does not match "
         << "feature weight size (" << featureWeights_.size() << ")" << endl;
    return false;
  }

  double pTarget = 0;
  for (int i = 0; i < example.size(); i++) {
    pTarget += example[i] * featureWeights_[i];
  }

  *target = 1.0 / (1 + exp(-1 * pTarget));
  return true;
}
