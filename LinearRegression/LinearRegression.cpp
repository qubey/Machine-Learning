#include "StringUtil.h"

#include <iostream>
#include <string>
#include <vector>

using namespace std;

const double kLearningRate = 1;

vector<double> update(vector<double> weights, vector<double> example,
                      double target, double rate) {
  if (example.size() != weights.size()) {
    cerr << "Error: weight vector not the same size as example vector";
    return vector<double>();
  }

  vector<double> newWeights(weights.size());

  double paren = 0;
  for (int i = 0; i < example.size(); i++) {
    paren += weights[i] * example[i];
  }

  for (int i = 0; i < example.size(); i++) {
    newWeights[i] = weights[i] + rate * (target - paren) * example[i];
  }

  return newWeights;
}

int main(int argc, char** argv) {
  string line;
  // first read value names
  getline(cin, line);
  vector<string> featureNames = StringUtil::split(line, ',');
  vector<double> weights(featureNames.size() - 1);
  
  int64_t linesSkipped = 0;
  while (getline(cin, line)) {
    // Parse line
    vector<string> values = StringUtil::split(line, ',');
    double target;
    if (!StringUtil::parse(line, &target)) {
      linesSkipped++;
      continue;
    }

    // Convert features from string to doubles
    vector<double> example;
    example.reserve(values.size() - 1);
    for (int i = 0; i < example.size(); i++) {
      double value;
      if (!StringUtil::parse(values[i+1], &value)) {
        break;
      }
      example.push_back(value);
    }

    if (example.size() != featureNames.size() - 1) {
      cerr << "Invalid feature count for line.  Expected "
           << featureNames.size() - 1
           << "but had " << example.size() << endl;
      continue;
    }

    weights = update(weights, example, target, kLearningRate);
  }

  cout << "WEIGHTS:" << endl;
  cout << "----------------------------" << endl;
  for (int i = 0; i < weights.size(); i++) {
    cout << featureNames[i+1] << ": "
         << weights[i] << endl;
  }
}
