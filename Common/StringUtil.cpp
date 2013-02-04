// Copyright 2013 Ruben Sethi.  All rights reserved.

#include "StringUtil.h"

#include <sstream>
#include <iostream>

using namespace std;

void StringUtil::split(string& input, char delim, vector<string>* out) {
  if (out == nullptr) {
    cerr << "Null output vector specified for string split" << endl;
    return;
  }

  istringstream data(input);

  while (!data.eof() && !data.fail()) {
    string piece;
    getline(data, piece, delim);
    out->push_back(piece);
  }
}

bool StringUtil::parse(const std::string& input, double* out) {
  bool success = true;
  try {
    *out = stod(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}

bool StringUtil::parse(const std::string& input, int* out) {
  bool success = true;
  try {
    *out = stoi(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}
