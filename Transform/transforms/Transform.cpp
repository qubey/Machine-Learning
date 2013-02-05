#include "Transform.h"

#include <StringUtil.h>
#include <iostream>

using namespace std;

Transform::Transform(const vector<string>& input) {
  name_ = input[0];
  if (input[1] == "Double") {
    type_ = DOUBLE;
  } else if (input[1] == "Integer") {
    type_ = INTEGER;
  } else {
    type_ = STRING;
  }

  string cardinalityStr(input[2]);
  if (!StringUtil::parse(cardinalityStr, &cardinality_)) {
    cardinality_ = -1;
    cerr << "Transform: " << name_ << ": "
         << "could not parse cardinality" <<endl;
  }
}
