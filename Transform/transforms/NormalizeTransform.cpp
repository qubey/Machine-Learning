// Copyright 2013 Ruben Sethi.  All rights reserved
#include "NormalizeTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

NormalizeTransform::NormalizeTransform(const vector<string>& input)
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

void NormalizeTransform::execute(const string& value,
                                    int offset,
                                    vector<double>* out) {
  if (offset >= out->size()) {
    cerr << "Error (" << name_ << "): offset (" << offset
         << ") larger than output vector (" << out->size() << ")" << endl;
    return;
  }

  double input;
  if (!StringUtil::parse(value, &input)) {
    (*out)[offset] = 0;
    return;
  }

  double transValue = (((double) input - min_) / (max_ - min_));
  if (transValue > 1) {
    cerr << "Error for " << name_ << ": value is " << transValue << ", "
         << "where min is " << min_ << " and max is " << max_ << endl;
  }

  (*out)[offset] = transValue;
}

int NormalizeTransform::getNumOutputs() const {
  return 1;
}

void NormalizeTransform::getNames(vector<string>* names) const {
  names->clear();
  names->push_back(name_);
}
