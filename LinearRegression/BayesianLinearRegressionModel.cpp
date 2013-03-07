// Copyright 2013 Ruben Sethi.  All rights reserved

#include "BayesianLinearRegressionModel.h"
#include <iostream>
#include <unordered_map>

using namespace std;

const int kLogFrequency = 10000;

void BayesianLinearRegressionModel::initialize(vector<string>& names,
                                       vector<double>& weights,
                                       double beta,
                                       double weightVariance) {
  cerr << "Initial variance: " << weightVariance << endl;
  cerr << "Beta: " << beta << endl;
  beta_ = beta;
  weightVariance_ = weightVariance;
  featureNames_ = names;
  featureWeights_ = weights;

  if (featureNames_.size() != featureWeights_.size()) {
    cerr << "Feature names do not match feature weights!" << endl;
  }
}

bool BayesianLinearRegressionModel::setInputColumns(vector<string>& columns) {
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

bool BayesianLinearRegressionModel::train(vector<double>& example, double target) {
  if (example.size() != featureWeights_.size()) {
    cerr << "Training example size (" << example.size() << ") does not match "
         << "feature weight size (" << featureWeights_.size() << ")" << endl;
    return false;
  }

  double input = 0;
  for (int i = 0; i < example.size(); i++) {
    input += example[i] * example[i];
  }

  double priorPrecision = 1 / weightVariance_; 

  double precision = (1.0 / weightVariance_) + beta_ * input;
  weightVariance_ = 1.0 / precision;

  for (int i = 0; i < example.size(); i++) {
    featureWeights_[i] = weightVariance_ 
                         * (priorPrecision * featureWeights_[i]
                            + beta_ * example[i] * target);
  }

  if (++exampleCount_ % kLogFrequency == 0) {
    cerr << "Weight variance: " << weightVariance_ << endl;
    weightVariance_ *= 2;
  }

  return true;
}

bool BayesianLinearRegressionModel::predict(vector<double>& example, double* target) {
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
