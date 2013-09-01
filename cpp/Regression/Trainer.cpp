#include "Trainer.h"
#include "StringUtil.h"
#include "LinearRegressionModel.h"

#include <iostream>
#include <string>
#include <vector>
#include <fstream>

using namespace std;

const char kDelimiter = ',';

void Trainer::trainModel(fstream& stream) {
  stream.seekg(0, ios::beg);
  string line;

  // Ignore the first line
  getline(stream, line);

  int64_t linesSkipped = 0;
  while (getline(stream, line)) {
    // Parse line
    vector<string> values;
    StringUtil::split(line, delimiter_, &values);

    double target;
    if (!StringUtil::parse(values[0], &target)) {
      linesSkipped++;
      continue;
    }

    // Convert features from string to doubles
    vector<double> example;
    example.reserve(values.size());
    for (int i = 0; i < values.size() - 1; i++) {
      double value;
      if (!StringUtil::parse(values[i+1], &value)) {
        break;
      }
      example.push_back(value);
    }
    // This is for the bias
    example.push_back(1);

    model_->train(example, target);
  }
}
