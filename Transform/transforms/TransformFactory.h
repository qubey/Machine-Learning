// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"
#include "NormalizeTransform.h"
#include "ExpandTransform.h"
#include "DummyTransform.h"

#include <string>
#include <vector>

class TransformFactory {
 public:
  static Transform createTransform(const std::vector<std::string>& input) {
    std::string type = input[1];
    if (type != "String") {
      return input[2] == "LIMIT" ? NormalizeTransform(input)
                                 : ExpandTransform(input);
    } else {
      return input[2] == "LIMIT" ? DummyTransform(input)
                                 : ExpandTransform(input);
    }
  }
};
