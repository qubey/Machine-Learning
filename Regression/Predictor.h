// Copyright Ruben Sethi 2013 - All rights reserved
#pragma once

#include "RegressionModel.h"
#include <string>
#include <vector>

class Predictor {
 public:
  static bool initializeModel(const char *modelFile, RegressionModel* model);
};
