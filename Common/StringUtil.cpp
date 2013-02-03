// Copyright 2013 Ruben Sethi.  All rights reserved.

#include "StringUtil.h"

#include <sstream>

using namespace std;

vector<string> StringUtil::split(string& input, char delim) {
  vector<string> result;
  istringstream data(input);

  while (!data.eof() && !data.fail()) {
    string piece;
    getline(data, piece, delim);
    result.push_back(piece);
  }
  
  return result;
}

bool StringUtil::parse(std::string& input, double* out) {
  bool success = true;
  try {
    *out = stod(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}

bool StringUtil::parse(std::string& input, int* out) {
  bool success = true;
  try {
    *out = stoi(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}
