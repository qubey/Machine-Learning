#pragma once

#include <string>
#include <unordered_set>

class FeatureCardinality {
 public:
  explicit FeatureCardinality(size_t max = 200)
           : values_(), maxCardinality_(max) { }

  void addValue(std::string& value);

  size_t getCardinality() const;

 private:
  std::unordered_set<std::string> values_;
  size_t maxCardinality_;
};
