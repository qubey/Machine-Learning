module common.matrix;


class MatrixUtil {
  // This algorithm is wrong.  We need to account for when there are 0's
  // in the diagonal much better because this does not handle that case.
  static T[][] inverse(T)(T[][] rawInput) {
    assert(rawInput.length == rawInput[0].length);
    long n = rawInput.length;

    // Copy the input so we don't modify the original
    real[][] input;
    input.length = n;
    foreach(i; 0 .. n) {
      assert(rawInput.length == rawInput[i].length);
      input[i][] = rawInput[i][];
    }

    // Initialize the result matrix as the identity
    real[][] result;
    result.length = n;
    foreach (i, r; result) {
      r.length = n;
      r[i] = 1.0;
    }

    // Do the inversion
    int currentIndex = 0;
    foreach (i; 0 .. n) {
      while (input[i][currentIndex++] != 0) { };
      if (currentIndex >= n) break;

      real currentValue = input[i][currentIndex];
      input[i][] /= currentValue;
      result[i][] /= currentValue;

      foreach (j; 0 .. n) {
        if (i == j || result[j][currentIndex] == 0) {
          continue;
        }

        real ratio = input[j][currentIndex] / input[i][currentIndex];
        input[j][] -= (input[i][] * ratio);
        result[j][] -= (input[i][] * ratio);
      }
    }

    return result;
  }

  static real determinant(T)(T[][] input) {
  }

  static T[][] transpose(T)(T[][] input) {
    T[][] result;
    result.length = input[0].length;
    foreach (i, r; result) {
      r.length = input.length;
      foreach (j; 0 .. input.length) {
        r[j] = input[j][i];
      }
    }

    return result;
  }
}
