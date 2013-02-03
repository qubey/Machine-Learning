// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <unordered_set>

class FeatureCardinality {
 public:
  explicit FeatureCardinality(size_t max = 200)
           : values_(), maxCardinality_(max), integer_(true), double_(true) { }

  void addValue(std::string& value);

  size_t getCardinality() const;

  std::string getType() const;

 private:
  std::unordered_set<std::string> values_;
  size_t maxCardinality_;
  bool integer_;
  bool double_;
};
