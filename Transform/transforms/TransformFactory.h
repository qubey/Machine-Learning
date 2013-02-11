// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include "Transform.h"
#include "NormalizeTransform.h"
#include "ExpandTransform.h"
#include "DummyTransform.h"
#include "DateTransform.h"
#include "NGramTransform.h"

#include <string>
#include <vector>
#include <memory>
#include <iostream>

class TransformFactory {
 public:
  static std::shared_ptr<Transform> createTransform(
                                    const std::vector<std::string>& input) {
    std::string type = input[1];
    std::string cardinality = input[2];

    if (cardinality == "LIMIT") {
      if (type == "String") {
        return std::make_shared<DummyTransform>(input);
      } else if (type == "Date") {
        return std::make_shared<DateTransform>(input);
      } else if (type == "NGram") {
        return std::make_shared<NGramTransform>(input);
      } else {
        return std::make_shared<NormalizeTransform>(input);
      }
    } else if (type == "Double" || type == "Integer" || type == "String") {
      return std::make_shared<ExpandTransform>(input);
    }


    std::cerr << "Couldn't determine transform type for "
              << input[0] << ", " << input[1] << ", " << input[2]
              << std::endl;

    return std::shared_ptr<Transform>();
  }
};
