// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"

class DummyTransform : public Transform {
 public:
  explicit DummyTransform(const std::vector<std::string>& input)
           : Transform(input) { }

  void execute(const std::string& value,
               std::vector<double>* out) { }

  int getNumOutputs() const { return 0; }

  void getNames(std::vector<std::string>* names) const { names->clear(); }
};
