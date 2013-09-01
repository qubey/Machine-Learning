#include "Transform.h"

#include <StringUtil.h>
#include <iostream>

using namespace std;

Transform::Transform(const vector<string>& input) {
  name_ = input[0];
}
