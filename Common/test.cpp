#include "StringUtil.h"

#include <string>
#include <vector>
#include <iostream>

using namespace std;

int main(int argc, char** argv) {
  vector<string> values;
  StringUtil::split("this,\"is,my,stuff\",quoted", ',', &values);
  for (const string& value : values) {
    cout << value << endl;
  }
}
