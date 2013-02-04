#include "ExpandTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

ExpandTransform::ExpandTransform(const vector<string>& input)
              : Transform(input) {
}

void ExpandTransform::execute(const string& value,
                              vector<double>* out) {
  out->clear();

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
