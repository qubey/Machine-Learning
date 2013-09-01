// Copyright 2013 Ruben Sethi.  All rights reserved.

#include "StringUtil.h"

#include <sstream>
#include <iostream>
#include <algorithm>
#include <ctype.h>

using namespace std;

void StringUtil::split(const string& input, char delim, vector<string>* out) {
  if (out == nullptr) {
    cerr << "Null output vector specified for string split" << endl;
    return;
  }

  if (input.size() == 0) return;

  int startIndex = 0;
  int currentIndex = 0;
  while (currentIndex < input.size()) {
    char c = input[currentIndex];
    if (c == '\"') {
      while (currentIndex < input.size() && input[++currentIndex] != c);
    } else if (c == delim) {
      out->push_back(input.substr(startIndex, currentIndex - startIndex));
      startIndex = currentIndex + 1;
    }

    currentIndex++;
  }

  int correction = 0;
  if (input.back() == '\n') {
    correction = 1;
  }
  // Get the last element
  out->push_back(input.substr(startIndex,
                              currentIndex - startIndex - correction));
}

bool StringUtil::parse(const std::string& input, double* out) {
  bool success = true;
  try {
    *out = stod(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}

bool StringUtil::parse(const std::string& input, int* out) {
  bool success = true;
  try {
    *out = stoi(input);
  } catch (const std::exception& e) {
    success = false;
  }
  return success;
}

bool StringUtil::parseDate(const std::string& input, int* year, int* month) {
  vector<string> scrubbed;
  split(input, ' ', &scrubbed);

  vector<string> pieces;
  split(scrubbed[0], '/', &pieces);

  try {
    int value = stol(pieces.back());
    if (value < 14) {
      value += 2000;
    } else if (value < 100) {
      value += 1900;
    }
    *year = value;

    value = stol(pieces.front());
    *month = value;
  } catch (const std::exception& e) {
    return false;
  }

  return true;
}

void StringUtil::toLower(std::string* input) {
  std::transform(input->begin(), input->end(), input->begin(),
                 [](char value) {
                    return tolower(value);
                 });
}

void StringUtil::cleanse(string* input) {
  int index = 0;
  for (int i = 0; i < input->size(); i++) {
    char current = (*input)[i];
    if (!isalnum(current) && current != '_' && !isprint(current)
        && !isgraph(current)) {
      continue;
    }
    if (isspace(current) || ispunct(current) || iscntrl(current)) {
      continue;
    }

    (*input)[index] = tolower(current);
    index++;
  }

  if (index != input->size() - 1) {
    input->erase(index, input->size() - index);
  }
}
