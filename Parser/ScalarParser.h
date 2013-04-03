// Copyright Ruben Sethi 2013 - All rights reserved
#pragma once

#include <string>
#include <vector>
#include <iostream>

class ScalarParser {
 public:
  explicit ScalarParser(char delimiter = ',')
           : delimiter_(delimiter) { }

  bool parseCsvHeader(std::istream& input);

  bool parseExample(std::string& input, bool containsTarget,
                    std::vector<double>* features, double* target);

  const std::vector<std::string>& getColumns() {
    return columns_;
  }

 private:
  char delimiter_;
  std::vector<std::string> columns_;
};
