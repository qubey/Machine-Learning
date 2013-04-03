// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "NeuralNetwork.h"

#include <fstream>
#include <iostream>
#include <string>

using namespace std;

bool NeuralNetwork::parseDefinition(const char* inputFile) {
  fstream modelCsv(inputFile);
  if (!modelCsv.good()) {
    cerr << "ERROR: Could not open file: " << inputFile << endl;
    cerr << "ERROR: Could not initialize neural network" << endl;
    return false;
  }

  string line;
  double inputCount;
  getline(modelCsv, line);
  if (!StringUtil::parse(line, &inputCount)) {
    cerr << "ERROR: Could not parse input count: " << line << endl;
    return false;
  }

  int lastLayerSize = inputCount;
  int lineNumber = 2;
  while(getline(modelCsv, line)) {
    double layerSize;
    if (!StringUtil::parse(line, &layerSize)) {
      cerr << "ERROR: Could not parse node count on line "
           << lineNumber << endl;
      return false;
    }

    int currentLayerSize = static_cast<int>(layerSize);
    networkLayers_.push_back(vector<NetworkNode>());
    // Each node must have the correct number of weights associated with it
    for (int i = 0; i < currentLayerSize; i++) {
      networkLayers_.back().push_back(NetworkNode(lastLayerSize + 1));
    }
    lastLayerSize = currentLayerSize;

    lineNumber++;
  }
  modelCsv.close();

  if (networkLayers_.size() == 0) {
    cerr << "ERROR: There are 0 nodes after parsing the network config"
         << endl;
    return false;
  }

  // TODO: PLEASE MAKE THIS SUPPORT MULTIPLE OUTPUTS!!!
  if (networkLayers_.back().size() != 1) {
    cerr << "ERROR: Only supports an output size of 1 right now"
         << endl;
    return false;
  }

  return true;
}

double NeuralNetwork::predict(const vector<double>& input) {
  if (networkLayers_.size() == 0) {
    cerr << "ERROR: Neural network has not been initialized" << endl;
    return -1;
  }

  if (input.size() != inputSize_) {
    cerr << "Input size is " << input.size() << ", when it should be "
         << inputSize_ << endl;
    return -1;
  }

  vector<double> currentValues = input;
  for (int i = 0; i < networkLayers_.size(); i++) {
    const auto& layer = networkLayers_[i];

    // Add the bias at every level
    currentValues.push_back(1);
    vector<double> nextValues;
    nextValues.reserve(layer.size() + 1);

    for (int j = 0; j < layer.size(); j++) {
      nextValues.push_back(layer[j].evaluate(currentValues));
    }

    currentValues.swap(nextValues);
  }

  return currentValues.back();
}
