#include "ExpandTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

ExpandTransform::ExpandTransform(const vector<string>& input)
              : Transform(input) {
  if (cardinality_ < 1) {
    cerr << "Error: bad cardinality for transform " << name_ << endl;
  }
}

void ExpandTransform::execute(const string& value,
                              int offset,
                              vector<double>* out) {
  if (cardinality_ < 1) {
    return;
  }

  if (offset + cardinality_ - 1 >= out->size()) {
    cerr << "Error (" << name_ << "): offset (" << offset << " + "
         << cardinality_
         << ") larger than output vector (" << out->size() << ")" << endl;
    return;
  }

  if (value.size() > 0 && values_.find(value) == values_.end()) {
    values_[value] = values_.size();
    if (values_.size() > cardinality_) {
      cerr << "Error: map exceeded specified cardinality for feature "
           << name_ << endl;
    }
  }

  int mappedValue = value.size() == 0 ? -1 : values_[value];
  for (int i = 0; i < cardinality_; i++) {
    (*out)[offset + i] = i == mappedValue ? 1 : 0;
  }
}

int ExpandTransform::getNumOutputs() const {
  return cardinality_ < 1 ? 0 : cardinality_;
}

void ExpandTransform::getNames(vector<string>* names) const {
  names->clear();

  for (const auto& featureValue : values_) {
    names->push_back(name_ + "_" + featureValue.first);
  }
}
