#include "StringUtil.h"
#include "LinearRegressionModel.h"
#include "Predictor.h"
#include "ScalarParser.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

const char kDelimiter = ',';

int main(int argc, char** argv) {
  if (argc != 2 && argc != 3) {
    cerr << "Usage: " << argv[0] << " <model.csv> [<data_has_target>]" << endl;
    return -1;
  }

  bool dataContainsTarget = argc == 3 && string(argv[2]) == "true";
  cerr << "Data contains target: " << dataContainsTarget << endl;

  LinearRegressionModel model;
  // This initialization assumes the Bias is contained in the model definition
  if (!Predictor::initializeModel(argv[1], &model)) {
    cerr << "Could not initialize model" << endl;
    return -1;
  }

  ScalarParser parser;
  if (!parser.parseCsvHeader(std::cin)) {
    return -1;
  }

  if (!model.setInputColumns(parser.getColumns())) {
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
    if (!parser.parseExample(line, dataContainsTarget, &values, &target)) {
      cerr << "Could not parse line: " << line << endl;
      continue;
    }

    if (!model.predict(values, &predicted)) {
      cerr << "Error predicting." << endl;
      predicted = 0;
    }

    if (dataContainsTarget) {
      if (predicted < 1) {
        cerr << "Predicted lower than threshold: " << predicted << endl;
        predicted = 1;
      }
      double difference = log(target / predicted);
      meanSquaredErrorSum += difference * difference;
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
