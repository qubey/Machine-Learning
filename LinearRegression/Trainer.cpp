#include "StringUtil.h"
#include "LinearRegressionModel.h"

#include <iostream>
#include <string>
#include <vector>
#include <fstream>

using namespace std;

const char kDelimiter = ',';

int main(int argc, char** argv) {
  if (argc != 3) {
    cerr << "Usage: " << argv[0] << " <input_file> <learning_rate>" << endl;
    return -1;
  }

  fstream inputFile(argv[1]);
  if (!inputFile.good()) {
    cerr << "Could not open file " << argv[1] << endl;
    return -1;
  }

  double learningRate;
  if (!StringUtil::parse(string(argv[2]), &learningRate)) {
    cerr << "Could not parse learning rate: " << argv[2] << endl;
    return -1;
  }

  string line;
  // first read value names
  getline(inputFile, line);
  // The first feature name should be the target
  vector<string> featureNames;
  StringUtil::split(line, ',', &featureNames);
  featureNames.push_back("Bias");
  // We don't need the name of the target
  featureNames.erase(featureNames.begin());

  // The first weight will be the bias
  vector<double> weights(featureNames.size());

  LinearRegressionModel model;
  model.initialize(featureNames, weights);
  
  int64_t linesSkipped = 0;
  while (getline(inputFile, line)) {
    // Parse line
    vector<string> values;
    StringUtil::split(line, ',', &values);

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

    model.train(example, target, learningRate);
  }

  weights = model.getWeights();
  for (int i = 0; i < weights.size(); i++) {
    cout << featureNames[i] << kDelimiter
         << weights[i] << endl;
  }
}
