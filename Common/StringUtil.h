// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <vector>

class StringUtil {
 public:
  static std::vector<std::string> split(std::string& input, char delim);

  static bool parse(const std::string& input, double* out);

  static bool parse(const std::string& input, int* out);

 private:
  explicit StringUtil() { }
};
