#include "NGramTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>
#include <sstream>

using namespace std;

NGramTransform::NGramTransform(const vector<string>& input)
              : Transform(input) {
  for (int i = 3; i < input.size(); i++) {
    baseNames.push_back(string(input[i]));
  }
}

void NGramTransform::execute(const string& value,
                              vector<double>* out) {
  vector<int> indices(baseTransforms_.size(), 0);

  int count = getNumOutputs();

  for (int i = 0; i < count; i++) {
    double value = 1;
    for (int j = 0; j < indices.size(); j++) {
      double baseValue = (*out)[baseTransforms_[j]->offset + indices[j]];
      value *= (*out)[baseTransforms_[j]->offset + indices[j]];
    }

    (*out)[this->offset + i] = value;

    bool carry = true;
    int index = 0;
    while (carry) {
      carry = false;
      indices[index] += 1;
      if (indices[index] == baseTransforms_[index]->getNumOutputs()) {
        indices[index] = 0;
        index++;
        carry = index < indices.size();
      }
    }
  }
}

int NGramTransform::getNumOutputs() const {
  int count = 1;
  for (const auto& transform : baseTransforms_) {
    count *= transform->getNumOutputs();
  }

  return count;
}

void NGramTransform::getNames(vector<string>* names) const {
  names->clear();
  for (int i = 0; i < getNumOutputs(); i++) {
    stringstream ss;
    ss << i;
    names->push_back(name_ + "_" + ss.str());
  }
}

void NGramTransform::addBaseTransform(shared_ptr<Transform>& transform) {
  if (!transform) {
    cerr << "Base transform for NGram is null" << endl;
    return;
  }

  baseTransforms_.push_back(transform);
}
