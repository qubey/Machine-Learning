// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <vector>

class StringUtil {
 public:
  static void split(std::string& input, char delim,
                    std::vector<std::string>* out);

  static bool parse(const std::string& input, double* out);

  static bool parse(const std::string& input, int* out);

 private:
  explicit StringUtil() { }
};
