// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <unordered_set>

class FeatureCardinality {
 public:
  explicit FeatureCardinality(size_t max = 200)
           : values_(), maxCardinality_(max), integer_(true), double_(true),
             isFirst_(true) { }

  void addValue(std::string& value);

  size_t getCardinality() const;

  std::string getType() const;

  std::pair<double, double> getDoubleBounds() const;

  std::pair<int, int> getIntBounds() const;

 private:
  std::unordered_set<std::string> values_;
  size_t maxCardinality_;
  bool integer_;
  bool double_;
  double maxDouble_;
  int maxInt_;
  double minDouble_;
  int minInt_;
  bool isFirst_;
};
