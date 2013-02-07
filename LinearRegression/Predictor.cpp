#include "StringUtil.h"
#include "LinearRegressionModel.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

const char kDelimiter = ',';

bool initializeModel(const char *modelFile, LinearRegressionModel* model) {
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
    StringUtil::split(line, kDelimiter, &lineValues);
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

bool parseCsvHeader(LinearRegressionModel* model) {
  string line;
  getline(cin, line);
  if (line.size() == 0) {
    cerr << "CSV header is missing" << endl;
    return false;
  }

  vector<string> columns;
  StringUtil::split(line, kDelimiter, &columns);
  // Assume the first column is the target
  columns.erase(columns.begin());
  columns.push_back("Bias");

  return model->setInputColumns(columns);
}

bool parseExample(string& input, bool containsTarget,
                  vector<double>* features, double* target) {
  if (features == nullptr) {
    cerr << "Pointer to features is null" << endl;
    return false;
  }

  vector<string> strValues;
  StringUtil::split(input, kDelimiter, &strValues);
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

int main(int argc, char** argv) {
  if (argc != 2 && argc != 3) {
    cerr << "Usage: " << argv[0] << " <model.csv> [<data_has_target>]" << endl;
    return -1;
  }

  bool dataContainsTarget = argc == 3 && string(argv[2]) == "true";
  cerr << "Data contains target: " << dataContainsTarget << endl;

  LinearRegressionModel model;
  // This initialization assumes the Bias is contained in the model definition
  if (!initializeModel(argv[1], &model)) {
    cerr << "Could not initialize model" << endl;
    return -1;
  }

  if (!parseCsvHeader(&model)) {
    return -1;
  }

  // Write output CSV header
  if (dataContainsTarget) {
    cout << "Actual,";
  }
  cout << "Predicted" << endl;

  string line;
  vector<double> values;
  double target;
  double predicted;
  double meanSquaredErrorSum = 0;
  int count = 0;
  while (getline(cin, line)) {
    values.clear();
    if (!parseExample(line, dataContainsTarget, &values, &target)) {
      cerr << "Could not parse line: " << line << endl;
      continue;
    }

    if (!model.predict(values, &predicted)) {
      cerr << "Error predicting." << endl;
      predicted = 0;
    }

    if (dataContainsTarget) {
      meanSquaredErrorSum += (target - predicted) * (target - predicted);
      count++;

      cout << target << ",";
    }
    cout << predicted << endl;
  }

  if (dataContainsTarget) {
    cerr << "RMSE: " << sqrt(meanSquaredErrorSum / count) << endl;
  }

  return 0;
}
