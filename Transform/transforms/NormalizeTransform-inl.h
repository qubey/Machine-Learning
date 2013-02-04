// Copyright 2013 Ruben Sethi.  All rights reserved

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

template <typename T>
NormalizeTransform<T>::NormalizeTransform(const vector<string>& input)
              : Transform(input) {
  string minStr(input[3]);
  if (!StringUtil::parse(minStr, &min_)) {
    cerr << "Could not parse min for feature " << name_ << endl;
  }

  string maxStr(input[4]);
  if (!StringUtil::parse(maxStr, &max_)) {
    cerr << "Could not parse max for feature " << name_ << endl;
  }
}

template <typename T>
void NormalizeTransform<T>::execute(const string& value,
                                    vector<double>* out) {
  out->clear();

  T input;
  if (!StringUtil::parse(value, &input)) {
    cerr << "Invalid value for " << name_ << ": " << value << endl;
    return;
  }

  out->push_back(((double) input - min_) / (max_ - min_));
}

template <typename T>
int NormalizeTransform<T>::getNumOutputs() const {
  return 1;
}

template <typename T>
void NormalizeTransform<T>::getNames(vector<string>* names) const {
  names->clear();
  names->push_back(name_);
}
