#ifndef UTILS_H_
#define UTILS_H_

#include <iostream>
#include <vector>

class Matrix;

class Utils {
  public:
    static void printVector(std::vector<double>& input);

    static void printMatrix(Matrix& input);
};


#endif
