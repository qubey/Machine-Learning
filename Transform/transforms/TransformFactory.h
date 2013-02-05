// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"
#include "NormalizeTransform.h"
#include "ExpandTransform.h"
#include "DummyTransform.h"

#include <string>
#include <vector>
#include <memory>
#include <iostream>

class TransformFactory {
 public:
  static std::shared_ptr<Transform> createTransform(
                                    const std::vector<std::string>& input) {
    std::string type = input[1];
    if (type != "String") {
      if (input[2] != "LIMIT") {
        return std::make_shared<ExpandTransform>(input);
      } else if (type == "Double") {
        return std::make_shared<NormalizeTransform<double> >(input);
      } else {
        return std::make_shared<NormalizeTransform<int> >(input);
      }
    } else if (input[2] == "LIMIT") {
      return std::make_shared<DummyTransform>(input);
    } else {
      return std::make_shared<ExpandTransform>(input);
    }
  }
};
