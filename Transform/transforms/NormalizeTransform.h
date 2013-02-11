// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"

class NormalizeTransform : public Transform {
 public:
  explicit NormalizeTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, std::vector<double>* out);

  int getNumOutputs() const;

  void getNames(std::vector<std::string>* names) const;

 private:
  double min_;
  double max_;
};
