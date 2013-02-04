// Copyright 2013 Ruben Sethi.  All rights reserved

#include "Transform.h"

template<typename T>
class NormalizeTransform : public Transform {
 public:
  explicit NormalizeTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, std::vector<double>* out);

  int getNumOutputs() const;

  void getNames(std::vector<std::string>* names) const;

 private:
  T min_;
  T max_;
};
