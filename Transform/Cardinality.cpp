// Copyright 2013 Ruben Sethi.  All rights reserved.

#include "Cardinality.h"
#include "StringUtil.h"

#include <iostream>

using namespace std;

void FeatureCardinality::addValue(string& value) {
  if (value.size() == 0) {
    return;
  }

  // Check whether or not it is a double or integer
  double doubleValue;
  double_ = double_ && StringUtil::parse(value, &doubleValue); 
  int intValue;
  integer_ = integer_ && StringUtil::parse(value, &intValue);

  if (values_.size() > maxCardinality_) {
    return;
  }

  if (values_.find(value) == values_.end()) {
    values_.insert(value);
  }
}

size_t FeatureCardinality::getCardinality() const {
  return values_.size() > maxCardinality_ ? -1 : values_.size();
}

std::string FeatureCardinality::getType() const {
  string type = "String";
  if (integer_) {
    type = "Integer";
  } else if (double_) {
    type = "Double";
  }

  return type;
}
