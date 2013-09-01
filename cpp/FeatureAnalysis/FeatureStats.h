// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <vector>
#include <unordered_map>

class FeatureStats {
 public:
  explicit FeatureStats(size_t max = 200)
           : values_(), maxCardinality_(max), integer_(true), double_(true),
             isFirst_(true), currentCardinality_(0) { }

  void addValue(std::string& value, bool cleanse = true);

  size_t getCardinality() const;

  std::string getType() const;

  std::pair<double, double> getDoubleBounds() const;

  std::pair<int, int> getIntBounds() const;

  void getFeatureValues(std::vector<std::string>* values);

  const std::unordered_map<std::string, int>& getDistribution() {
    return counts_;
  }

 private:
  std::unordered_map<std::string, int> values_;
  std::unordered_map<std::string, int> counts_;
  size_t maxCardinality_;
  bool integer_;
  bool double_;
  double maxDouble_;
  int maxInt_;
  double minDouble_;
  int minInt_;
  bool isFirst_;
  int currentCardinality_;
};
