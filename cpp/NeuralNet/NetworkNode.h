// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include <memory>
#include <vector>
#include <iostream>

class NetworkNode {
 public:
  explicit NetworkNode(int numInputs) : weights_(numInputs) { }

  double evaluate(std::vector<double>& input) {
    if (input.size() != weights_.size()) {
      std::cerr << "CRITICAL: input size not equal to size of weight vector"
                << std::endl;
      return -1;
    }

    double result = 0;
    for (int i = 0; i < input.size(); i++) {
      result += weights_[i] * input[i];
    }

    return result;
  }

 private:
  std::vector<double> weights_;
};
