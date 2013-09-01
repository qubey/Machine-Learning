// Copyright 2013 Ruben Sethi.  All rights reserved

#pragma once

#include <string>
#include <vector>

class RegressionModel {
 public: 
  explicit RegressionModel() { }

  void initialize(std::vector<std::string>& names,
                  std::vector<double>& weights,
                  double weightPenalty = 0, double learningRate = 0.001);

  bool setInputColumns(const std::vector<std::string>& columns);

  virtual bool train(std::vector<double>& example, double target) = 0;

  virtual bool predict(std::vector<double>& example, double* target) = 0;

  std::vector<double> getWeights() { return featureWeights_; }

 protected:
  std::vector<std::string> featureNames_;
  std::vector<double> featureWeights_;
  double weightPenalty_;
  double learningRate_;
};
