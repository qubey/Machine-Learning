// Copyright 2013 Ruben Sethi.  All rights reserved
#pragma once

#include <string>
#include <vector>

class Transform {
 public:
  explicit Transform(const std::vector<std::string>& input);

  enum InputType {
    INTEGER,
    DOUBLE,
    STRING
  };

  std::string getName() const { return name_; }

  virtual void execute(const std::string& value,
                       std::vector<double>* out) = 0;

  virtual int getNumOutputs() const = 0;

  virtual void getNames(std::vector<std::string>* names) const = 0;

  int offset;

 protected:
  std::string name_;
  InputType type_;
  int cardinality_;
};
