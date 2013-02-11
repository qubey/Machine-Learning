// Copyright 2013 Ruben Sethi.  All rights reserved.

#include "FeatureStats.h"
#include "StringUtil.h"

#include <iostream>

using namespace std;

void FeatureStats::addValue(string& value, bool cleanse) {
  if (cleanse) {
    StringUtil::cleanse(&value);
  }

  if (value.size() == 0) {
    return;
  }

  // Check whether or not it is a double or integer
  double doubleValue;
  double_ = double_ && StringUtil::parse(value, &doubleValue); 
  int intValue;
  integer_ = integer_ && StringUtil::parse(value, &intValue);

  if (isFirst_) {
    maxDouble_ = doubleValue;
    maxInt_ = intValue;
    minDouble_ = doubleValue;
    minInt_ = intValue;
    isFirst_ = false;
  }

  if (integer_) {
    if (maxInt_ < intValue) {
      maxInt_ = intValue;
    }

    if (minInt_ > intValue) {
      minInt_ = intValue;
    }
  }

  if (double_) {
    if (maxDouble_ < doubleValue) {
      maxDouble_ = doubleValue;
    }

    if (minDouble_ > doubleValue) {
      minDouble_ = doubleValue;
    }
  }

  if (values_.size() > maxCardinality_) {
    return;
  }

  if (values_.find(value) == values_.end()) {
    values_[value] = currentCardinality_++;
    counts_[value] = 0;
  } else {
    counts_[value] += 1;
  }
}

size_t FeatureStats::getCardinality() const {
  return values_.size() >= maxCardinality_ ? -1 : values_.size();
}

std::string FeatureStats::getType() const {
  string type = "String";
  if (integer_) {
    type = "Integer";
  } else if (double_) {
    type = "Double";
  }

  return type;
}

void FeatureStats::getFeatureValues(vector<string>* output) {
  output->clear();
  output->resize(currentCardinality_);

  for (const auto& value : values_) {
    (*output)[value.second] = value.first;
  }
}

pair<double, double> FeatureStats::getDoubleBounds() const {
  return make_pair(minDouble_, maxDouble_);
}

pair<int, int> FeatureStats::getIntBounds() const {
  return make_pair(minInt_, maxInt_);
}
