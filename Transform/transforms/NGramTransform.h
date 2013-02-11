// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"

#include <unordered_map>
#include <memory>

class NGramTransform : public Transform {
 public:
  explicit NGramTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, std::vector<double>* out);

  int getNumOutputs() const;

  // This will only get filled after all of the data is processed
  void getNames(std::vector<std::string>* names) const;

  void addBaseTransform(std::shared_ptr<Transform>& transform);

  std::vector<std::string> baseNames;

 private:
  std::vector<std::shared_ptr<Transform> > baseTransforms_;
};
