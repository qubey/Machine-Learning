#include "Cardinality.h"

using namespace std;

void FeatureCardinality::addValue(string& value) {
  if (values_.size() > maxCardinality_
      || value.size() == 0) {
    return;
  }

  if (values_.find(value) == values_.end()) {
    values_.insert(value);
  }
}

size_t FeatureCardinality::getCardinality() const {
  return values_.size() > maxCardinality_ ? -1 : values_.size();
}
