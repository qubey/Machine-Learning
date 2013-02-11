// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"

#include <unordered_map>

class DateTransform : public Transform {
 public:
  explicit DateTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, std::vector<double>* out);

  int getNumOutputs() const;

  // This will only get filled after all of the data is processed
  void getNames(std::vector<std::string>* names) const;
 private:
  bool includeMonth_;
};
