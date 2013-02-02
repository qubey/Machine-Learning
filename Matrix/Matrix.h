#ifndef MATRIX_H_
#define MATRIX_H_

#include <vector>
#include <iostream>
#include "Utils.h"

typedef std::vector<double> Vector;

class Matrix {
  private:
    std::vector< Vector > values_;
    int numRows_;
    int numCols_;

    void subtractRow(int first, int second, double multiplier);

  public:
    Matrix(int rows, int cols)
    : numRows_(rows), numCols_(cols), values_(rows) {
      for (int i = 0; i < numRows_; i++) {
        values_[i].resize(numCols_);
      }
    }

    Matrix(int size)
    : numRows_(size), numCols_(size), values_(size) {
      for (int i = 0; i < numRows_; i++) {
        values_[i].resize(numCols_);
      }
    }

    Vector& operator[] (int x) {
      return values_[x];
    }

    int rowCount() const {
      return numRows_;
    }

    int columnCount() const {
      return numCols_;
    }

    Matrix operator*(Matrix& input);

    Vector operator*(Vector& op);

    Matrix operator*(double scalar);

    // Solve the equation Ab = c for b
    // where A is this matrix, c is a given vector,
    // and b is the vector result of this call
    Vector solveFor(Vector input);

    // Calculate B in the equation AB = C
    // where A is this matrix, and C is given as a parameter
    Matrix solveFor(Matrix& input);

    Matrix inverse();

    Matrix transpose();

    Matrix toUpperTriangular(Vector* input);

    Matrix toUpperTriangular();

    // Converts this matrix to reduced row echelon form
    Matrix toRREF();

    Matrix projectionMatrix();

    void switchColumns(int first, int second);
};

#endif
