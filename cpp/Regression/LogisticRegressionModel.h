// Copyright 2013 Ruben Sethi.  All rights reserved

#pragma once

#include <string>
#include <vector>
#include "RegressionModel.h"

class LogisticRegressionModel : public RegressionModel {
 public: 
  bool train(std::vector<double>& example, double target);

  bool predict(std::vector<double>& example, double* target);
};
