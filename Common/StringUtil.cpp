#include "StringUtil.h"

#include <sstream>

std::vector<std::string> StringUtil::split(std::string& input, char delim) {
  std::vector<std::string> result;
  std::istringstream data(input);

  while (!data.eof() && !data.fail()) {
    std::string piece;
    std::getline(data, piece, delim);
    result.push_back(piece);
  }
  
  return result;
}
