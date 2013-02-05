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
                              vector<double>* out) {
  if (cardinality_ < 1) {
    return;
  }

  out->clear();
  out->resize(cardinality_);

  if (values_.find(value) == values_.end()) {
    values_[value] = values_.size();
  }

  (*out)[values_[value]] = 1;
}

int ExpandTransform::getNumOutputs() const {
  return cardinality_;
}

void ExpandTransform::getNames(vector<string>* names) const {
  names->clear();

  for (const auto& featureValue : values_) {
    names->push_back(name_ + "_" + featureValue.first);
  }
}
