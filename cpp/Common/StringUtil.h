// Copyright 2013 Ruben Sethi.  All rights reserved.

#pragma once

#include <string>
#include <vector>

class StringUtil {
 public:
  static void split(const std::string& input, char delim,
                    std::vector<std::string>* out);

  static bool parse(const std::string& input, double* out);

  static bool parse(const std::string& input, int* out);

  // Gets the year portion of a date string.  Very hacky.
  static bool parseDate(const std::string& input, int* year, int* month);

  static void toLower(std::string* input);

  static void cleanse(std::string* input);

 private:
  explicit StringUtil() { }
};
