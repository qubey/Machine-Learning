#include "ExpandTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

ExpandTransform::ExpandTransform(const vector<string>& input)
              : Transform(input), currentCount_(0) {
  if (!StringUtil::parse(input[2], &cardinality_)) {
    cardinality_ = -1;
    cerr << "Error: bad cardinality for transform " << name_ << endl;
    return;
  }

  for (int i = 3; i < input.size(); i++) {
    values_[input[i]] = i - 3;
  }
}

void ExpandTransform::execute(const string& input,
                              vector<double>* out) {
  if (cardinality_ < 1) {
    return;
  }

  string value(input);
  StringUtil::cleanse(&value);

  if (this->offset + cardinality_ - 1 >= out->size()) {
    cerr << "Error (" << name_ << "): offset (" << this->offset << " + "
         << cardinality_
         << ") larger than output vector (" << out->size() << ")" << endl;
    return;
  }

  int mappedValue = -1;
  if (value.size() > 0 && values_.find(value) == values_.end()) {
    cerr << "Expand transform " << name_ << ": unrecognized value ("
         << value << ")" << endl;
  } else {
    mappedValue = values_[value];
  }

  for (int i = 0; i < cardinality_; i++) {
    (*out)[this->offset + i] = i == mappedValue ? 1 : 0;
  }
}

int ExpandTransform::getNumOutputs() const {
  return cardinality_ < 1 ? 0 : cardinality_;
}

void ExpandTransform::getNames(vector<string>* names) const {
  names->clear();
  if (cardinality_ < 1) {
    return;
  }

  names->resize(cardinality_);
  for (const auto& featureValue : values_) {
    if (featureValue.second < cardinality_) {
      (*names)[featureValue.second] = name_ + "_" + featureValue.first;
    }
  }
}
