#include "DateTransform.h"

#include <StringUtil.h>
#include <vector>
#include <string>
#include <iostream>
#include <sstream>

using namespace std;

DateTransform::DateTransform(const vector<string>& input)
              : Transform(input) {
  includeMonth_ = input.size() > 3 && string(input[3]) == "true";
}

void DateTransform::execute(const string& value,
                              vector<double>* out) {
  int year;
  int month;
  if (!StringUtil::parseDate(value, &year, &month)) {
    cerr << "Could not parse date: " << value << endl;
    (*out)[this->offset] = 0;
    return;
  }

  if (year < 1900) {
    (*out)[this->offset] = 0;
    return;
  }

  double normalizedYear = ((double)year - 1900) / 2013;
  (*out)[this->offset] = normalizedYear;

  if (includeMonth_) {
    for (int i = 0; i < 12; i++) {
      (*out)[this->offset + 1 + i] = i == month - 1 ? normalizedYear : 0;
    }
  }
}

int DateTransform::getNumOutputs() const {
  return includeMonth_ ? 13 : 1;
}

void DateTransform::getNames(vector<string>* names) const {
  names->clear();
  names->push_back(name_ + "_year");

  if (includeMonth_) {
    // Add the names for the months
    for (int i = 0; i < 12; i++) {
      stringstream ss;
      ss << i + 1;
      names->push_back(name_ + "_month" + ss.str());
    }
  }
}
