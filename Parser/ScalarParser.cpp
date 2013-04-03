#include "StringUtil.h"
#include "ScalarParser.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

bool ScalarParser::parseCsvHeader(istream& input) {
  string line;
  getline(input, line);
  if (line.size() == 0) {
    cerr << "CSV header is missing" << endl;
    return false;
  }

  StringUtil::split(line, delimiter_, &columns_);
  // Assume the first column is the target
  columns_.erase(columns_.begin());
  columns_.push_back("Bias");

  return true;
}

bool ScalarParser::parseExample(string& input, bool containsTarget,
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
