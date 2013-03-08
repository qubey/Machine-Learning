#include "Trainer.h"
#include "StringUtil.h"
#include "LinearRegressionModel.h"

#include <iostream>
#include <string>
#include <vector>
#include <fstream>

using namespace std;

const char kDelimiter = ',';

int main(int argc, char** argv) {
  if (argc < 4) {
    cerr << "Usage: " << argv[0]
         << " <input_file> <learning_rate> <weight_penalty> <num_data_passes>"
         << endl;
    return -1;
  }

  fstream inputFile(argv[1], fstream::in);
  if (!inputFile.good()) {
    cerr << "Could not open file " << argv[1] << endl;
    return -1;
  }

  double learningRate;
  if (!StringUtil::parse(string(argv[2]), &learningRate)) {
    cerr << "Could not parse learning rate: " << argv[2] << endl;
    return -1;
  }

  double weightPenalty;
  if (!StringUtil::parse(string(argv[3]), &weightPenalty)) {
    cerr << "Could not parse weight penalty: " << argv[3] << endl;
    return -1;
  }

  int numberOfPasses = 1;
  if (argc > 4 && StringUtil::parse(string(argv[4]), &numberOfPasses)) {
    cerr << "Number of passes set to " << numberOfPasses << endl;
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
  model.initialize(featureNames, weights, weightPenalty, learningRate);

  Trainer trainer;
  trainer.setModel(&model);

  for (int i = 0; i < numberOfPasses; i++) {
    if (i > 0) {
      inputFile.open(argv[1], fstream::in);
      if (!inputFile.good()) {
        cerr << "Could not re-open file!" << endl;
        break;
      }
    }
    trainer.trainModel(inputFile);
    inputFile.close();
  }
  
  weights = model.getWeights();
  for (int i = 0; i < weights.size(); i++) {
    cout << featureNames[i] << kDelimiter
         << weights[i] << endl;
  }
}
