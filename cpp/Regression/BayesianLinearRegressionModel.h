// Copyright 2013 Ruben Sethi.  All rights reserved

#pragma once

#include <string>
#include <vector>

// This is incomplete because it doesn't take into account the hyperparameter
// inference from the data; you have to specify them before training
class BayesianLinearRegressionModel {
 public: 
  explicit BayesianLinearRegressionModel() : exampleCount_(0) { }

  void initialize(std::vector<std::string>& names,
                  std::vector<double>& weights,
                  double beta = 1, double weightVariance = 1);

  bool setInputColumns(std::vector<std::string>& columns);

  bool train(std::vector<double>& example, double target);

  bool predict(std::vector<double>& example, double* target);

  std::vector<double> getWeights() { return featureWeights_; }

 private:
  std::vector<std::string> featureNames_;
  std::vector<double> featureWeights_;
  double beta_;
  double weightVariance_;
  int exampleCount_;
};
