#include "StringUtil.h"
#include "LinearRegressionModel.h"
#include "Predictor.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

bool Predictor::initializeModel(const char *modelFile) {
  // Read the CSV file containing the trained model definition
  string line;
  fstream modelCsv(modelFile);
  if (!modelCsv.good()) {
    cerr << "Could not open file " << modelFile << endl;
    return false;
  }

  vector<string> lineValues;
  vector<string> featureNames;
  vector<double> featureWeights;
  while (getline(modelCsv, line)) {
    lineValues.clear();
    StringUtil::split(line, delimiter_, &lineValues);
    if (lineValues.size() != 2) {
      cerr << "Invalid row: " << line << endl;
      continue;
    }

    double weight;
    if (!StringUtil::parse(lineValues[1], &weight)) {
      cerr << "Couldn't parse weight for line: " << line << endl;
      continue;
    }

    featureNames.push_back(lineValues[0]);
    featureWeights.push_back(weight);
  }
  modelCsv.close();

  model_->initialize(featureNames, featureWeights);
  return true;
}

bool Predictor::parseCsvHeader() {
  string line;
  getline(cin, line);
  if (line.size() == 0) {
    cerr << "CSV header is missing" << endl;
    return false;
  }

  vector<string> columns;
  StringUtil::split(line, delimiter_, &columns);
  // Assume the first column is the target
  columns.erase(columns.begin());
  columns.push_back("Bias");

  return model_->setInputColumns(columns);
}

bool Predictor::parseExample(string& input, bool containsTarget,
                             vector<double>* features, double* target) {
  if (features == nullptr) {
    cerr << "Pointer to features is null" << endl;
    return false;
  }

  vector<string> strValues;
  StringUtil::split(input, delimiter_, &strValues);
  bool isFirst = true;
  for (const string& strValue : strValues) {
    double value;
    if (!StringUtil::parse(strValue, &value)) {
      return false;
    }

    if (isFirst && containsTarget) {
      *target = value;
    } else {
      features->push_back(value);
    }

    isFirst = false;
  }

  // Add bias to the end
  features->push_back(1);

  return true;
}
