#include "StringUtil.h"
#include "LinearRegressionModel.h"
#include "Predictor.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

bool Predictor::initializeModel(const char *modelFile, RegressionModel* model) {
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
    StringUtil::split(line, ',', &lineValues);
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

  model->initialize(featureNames, featureWeights);
  return true;
}
