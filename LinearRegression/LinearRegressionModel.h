// Copyright 2013 Ruben Sethi.  All rights reserved

#pragma once

#include <string>
#include <vector>

class LinearRegressionModel {
 public: 
  explicit LinearRegressionModel() { }

  void initialize(std::vector<std::string>& names,
                  std::vector<double>& weights);

  bool setInputColumns(std::vector<std::string>& columns);

  bool train(std::vector<double>& example, double target, double rate);

  bool predict(std::vector<double>& example, double* target);

  std::vector<double> getWeights() { return featureWeights_; }

 private:
  std::vector<std::string> featureNames_;
  std::vector<double> featureWeights_;
};
