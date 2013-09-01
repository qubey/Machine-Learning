// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "NetworkNode.h"

#include <vector>

class NeuralNetwork {
 public:
  explicit NeuralNetwork() { }

  // This file just has a list of numbers defining the number of
  // nodes in each network layer.  There is one number per line
  // and the first number represents the number of inputs (features)
  // not including the bias
  bool parseDefinition(const char* inputFile);

  // We will only support a single output for now
  double predict(std::vector<double> input);

 private:
  // This represents the network.  networkLayers_[0] stands for the first
  // hidden network layer
  std::vector< std::vector<NetworkNode> > networkLayers_;

  // This should not include the bias
  int inputSize_;
}
