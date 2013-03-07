// Copyright Ruben Sethi 2013 - All rights reserved
#pragma once

#include "RegressionModel.h"
#include <string>
#include <vector>

class Predictor {
 public:
  explicit Predictor(char delimiter = ',') : delimiter_(delimiter) { }

  bool initializeModel(const char *modelFile);

  bool parseCsvHeader();

  bool parseExample(std::string& input, bool containsTarget,
                    std::vector<double>* features, double* target);

  bool setModel(RegressionModel* model) {
    model_ = model;
  }

 private:
  RegressionModel* model_;
  char delimiter_;
};
