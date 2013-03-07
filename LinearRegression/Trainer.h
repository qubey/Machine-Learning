// Copyright Ruben Sethi 2013 - All rights reserved.
#pragma once

#include "RegressionModel.h"

#include <iostream>
#include <string>
#include <vector>
#include <fstream>

class Trainer {
 public:
  explicit Trainer(char delimiter = ',') : delimiter_(delimiter) { }

  void setModel(RegressionModel* model) {
    model_ = model;
  }

  void trainModel(std::fstream& stream);

 private:
  RegressionModel* model_;
  char delimiter_;
};
