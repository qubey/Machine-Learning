#include "Matrix.h"
#include "Utils.h"
#include <iostream>

class Matrix;

void Utils::printVector(std::vector<double>& input) {
    std::cout << "[";
    for (int j = 0; j < input.size(); j++) {
      std::cout << input[j];
      if (j < input.size() - 1) {
        std::cout << "\t";
      }
    }

    std::cout << "]" << std::endl;
}

void Utils::printMatrix(Matrix& input) {
  std::cout << "Size: " << input.rowCount() << std::endl;

  for (int i = 0; i < input.rowCount(); i++) {
    printVector(input[i]);
  }
}

