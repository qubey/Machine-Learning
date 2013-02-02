#include "Matrix.h"

using namespace std;

Matrix Matrix::operator*(Matrix& input) {
  if (input.rowCount() != numCols_) {
    return Matrix(0);
  }

  Matrix result(numRows_, input.columnCount());
  for (int i = 0; i < numRows_; i++) {
    for (int j = 0; j < input.columnCount(); j++) {
      for (int k = 0; k < numCols_; k++) {
        result[i][j] += values_[i][k] * input[k][j];
      }
    }
  }

  return result;
}

Matrix Matrix::operator*(double scalar) {
  Matrix result = *this;

  for (int i = 0; i < numRows_; i++) {
    for (int j = 0; j < numCols_; j++) {
      result[i][j] *= scalar;
    }
  }

  return result;
}

Vector Matrix::operator*(Vector& op) {
  if (op.size() != numCols_) {
    return Vector();
  }

  Vector result(numRows_);
  for (int i = 0; i < numRows_; i++) {
    for (int j = 0; j < numCols_; j++) {
      result[i] += values_[i][j] * op[j];
    }
  }

  return result;
}

Matrix Matrix::toUpperTriangular(Vector* input) {
  Matrix U = *this;
  int currentRow = 0;
  for (int i = 0; i < numCols_; i++) {
    if (U[currentRow][i] == 0) {
      int k = currentRow+1;
      while (k < numRows_ && U[k][i] == 0) k++;
      if (k == numRows_) continue;
      U[currentRow].swap(U[k]);
    }
    for (int j = currentRow+1; j < numRows_; j++) {
      if (U[j][i] == 0) {
        continue;
      }

      double multiplier = U[j][i] / U[currentRow][i];
      for (int k = 0; k < numCols_; k++) {
        U[j][k] = U[j][k] - U[currentRow][k] * multiplier;
      }

      if (input != NULL && input->size() == numCols_) {
        (*input)[j] -= (*input)[currentRow] * multiplier;
      }
    }

    currentRow++;
  }

  return U;
}

Matrix Matrix::toUpperTriangular() {
  return toUpperTriangular(NULL);
}

Vector Matrix::solveFor(Vector input) {
  if (input.size() != numCols_ || numRows_ < numCols_) {
    return Vector();
  }

  Vector result(numCols_);
  Matrix U = toUpperTriangular(&input);

  for (int i = numCols_ - 1; i >= 0; i--) {
    double element = input[i];
    for (int j = i+1; j < numCols_; j++) {
      element -= U[i][j] * result[j];
    }

    result[i] = element / U[i][i];
  }

  return result;
}

Matrix Matrix::solveFor(Matrix& input) {
  if (numRows_ != numCols_ || numRows_ != input.rowCount()
      || numCols_ != input.columnCount()) {
    return Matrix(0);
  }

  Matrix result(numRows_, numCols_);

  for (int i = 0; i < numCols_; i++) {
    Vector column(numRows_);
    // Copy the column we are solving for
    for (int j = 0; j < numRows_; j++) {
      column[j] = input[j][i];
    }

    Vector resultColumn = solveFor(column);

    for (int j = 0; j < numRows_; j++) {
      result[j][i] = resultColumn[j];
    }
  }

  return result;
}

Matrix Matrix::inverse() {
  Matrix id(numRows_);

  for (int i = 0; i < numRows_; i++) {
    id[i][i] = 1;
  }

  // Getting the inverse is the same as solving for the identity matrix
  return solveFor(id);
}

Matrix Matrix::transpose() {
  Matrix result(numCols_, numRows_);

  for (int i = 0; i < numRows_; i++) {
    for (int j = 0; j < numCols_; j++) {
      result[j][i] = values_[i][j];
    }
  }

  return result;
}

Matrix Matrix::toRREF() {
  Matrix result = toUpperTriangular();

  int row = 0, column = 0;
  int switchColumn = 0;

  while (row < numRows_ && column < numCols_) {
    if (result[row][column] != 0) {
      // Normalize the row
      double divisor = result[row][column];
      for (int i = 0; i < numCols_; i++) {
        result[row][i] = result[row][i] / divisor;
      }

      if (column != switchColumn) {
        result.switchColumns(column, switchColumn);
      }

      row++;
      switchColumn++;
    }

    // At this point, the row we are at will denote the rank of the
    // matrix.  We can use this to now to convert the matrix to the form
    // [I F]
    // [0 0]
    for (int i = row - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        double multiplier = result[j][i];
        result.subtractRow(j, i, multiplier);
      }
    }

    column++;
  }

  return result;
}

Matrix Matrix::projectionMatrix() {
  Matrix aTranspose = this->transpose();
  Matrix parenthesis = (aTranspose * (*this)).inverse();
  return *this * parenthesis * aTranspose;
}

void Matrix::switchColumns(int a, int b) {
  Vector temp(numRows_);
  for (int i = 0; i < numRows_; i++) {
    temp[i] = values_[i][a];
  }

  for (int i = 0; i < numRows_; i++) {
    values_[i][a] = values_[i][b];
  }

  for (int i = 0; i < numRows_; i++) {
    values_[i][b] = temp[i];
  }
}

void Matrix::subtractRow(int first, int second, double multiplier) {
  for (int i = 0; i < numCols_; i++) {
    values_[first][i] -= values_[second][i] * multiplier;
  }
}
