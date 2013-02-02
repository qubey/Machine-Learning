#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#include "Matrix.h"
#include "Utils.h"

int main(int argc, char **argv) {
  /*
  if (argc != 3) {
    std::cerr << "Error: wrong number of arguments" << std::endl;
    return -1;
  }

  int size = atoi(argv[1]);  
  int multiplier = atoi(argv[2]);
  if (size <= 0 || multiplier == 0) {
    std::cerr << "Invalid number(s) specified" << std::endl;
    std::cerr << "Usage: " << argv[0] << " <size> <multiplier>" << std::endl;
    return -1;
  }

  Matrix idMatrix(size);
  for (int i = 0; i < size; i++) {
    idMatrix[i][i] = multiplier;
  }

  std::vector<double> simple(size);
  for (int i = 0; i < size; i++) {
    simple[i] = i+1;
  }

  Matrix weirdMtx(size);
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      weirdMtx[i][j] = i*j+(i+1)*j*(i+1)*j*(i+1)+1;
    }
  }

  //Matrix temp = idMatrix * weirdMtx;
  //printMatrix(temp);
  Utils::printMatrix(weirdMtx);
  std::cout << std::endl;

  std::vector<double> result = weirdMtx * simple;
  Utils::printVector(result);
  std::cout << std::endl;

  std::vector<double> x = weirdMtx.solveFor(result);
  Utils::printVector(x);
  */

  /*
  Matrix mtx(2);

  mtx[0][0] = 1;
  mtx[0][1] = 3;
  mtx[1][0] = 2;
  mtx[1][1] = 7;

  Matrix result = mtx.inverse();
  Utils::printMatrix(result);
  */

  Matrix mtx(3, 4);
  mtx[0][0] = 1;
  mtx[0][1] = mtx[0][2] = mtx[0][3] = 2;
  for (int i = 0; i < 4; i++) {
    mtx[1][i] = 2*(i+1);
  }
  mtx[2][0] = 3;
  mtx[2][1] = 6;
  mtx[2][2] = 8;
  mtx[2][3] = 10;
  
  Utils::printMatrix(mtx);
  Matrix temp = mtx.toRREF();
  Utils::printMatrix(temp);
}
