module common.stats;

struct Multinoulli {
  ulong[] numerators;
  ulong denominator;

  this(int k) {
    this(k, 0);
  }

  // This assumes that every class is equally probable
  this(long k, long priorWeight) {
    numerators.length = k;
    numerators[] = priorWeight / k;
    denominator = priorWeight;
  }

  void count(double k) {
    if (k < numerators.length && k >= 0) {
      numerators[cast(int)k]++;
    }

    denominator++;
  }

  ulong classes() {
    return numerators.length;
  }

  real get(ulong k) {
    if (denominator == 0) return 0.0;
    assert(k < numerators.length && k >= 0);
    return (cast(real)numerators[k]) / denominator;
  }
}

struct Bernoulli {
  ulong num = 0;
  ulong denom = 0;

  this(real priorProbability, long priorWeight) {
    num = cast(ulong) priorProbability * priorWeight;
    denom = priorWeight;
  }

  void count(double k) {
    count(k == 1.0);
  }

  void count(bool positive) {
    if (positive) num++;
    denom++;
  }

  real get() {
    if (denom == 0) return 0.0;
    return (cast(real)num) / denom;
  }

  real inverse() {
    return 1 - get();
  }
}

struct Gaussian {
  double[] mean;
  double[][] covariance;

  this(long dimensions) {
    mean.length = dimensions;
    covariance.length = dimensions;
    foreach (i; 0 .. dimensions) {
      covariance.length = dimensions;
    }

    mean[] = 0.0L;

    foreach (cov; covariance) {
      cov[] = 0.0L;
    }
  }

  void compute(double[][] input) {
    assert(input.length > 0);
    assert(input[0].length == mean.length);

    // Compute the MLE mean
    foreach (point; input) {
      mean[] += point[];
    }
    mean[] /= input.length;

    // Compute the covariance matrix
    foreach (point; input) {
      double[] diff;
      diff.length = point.length;
      diff[] = point[] - mean[];

      // Do the diff * diff_transpose multiplication
      foreach (i; 0 .. diff.length) {
        foreach (j; 0 .. diff.length) {
          covariance[i][j] += diff[i] * diff[j];
        }
      }
    }
    foreach (cov; covariance) {
      cov[] /= input.length;
    }
  }
}

struct Fraction {
  ulong numerator;
  ulong denominator;

  Fraction opBinary(string op)(Fraction rhs) {
    static if (op == "+") {
      Fraction result;
      if (rhs.denominator == denominator) {
        result.numerator = numerator + rhs.numerator;
        result.denominator = denominator;
      } else {
        result.numerator =
          numerator * rhs.denominator + rhs.numerator * denominator;
        result.denominator = denominator * rhs.denominator;
      }
    } else static if (op == "*") {
      Fraction result;
      result.numerator = numerator * rhs.numerator;
      result.denominator = denominator * rhs.denominator;
    } else {
      assert(false, op ~ " not implemented for Fraction");
    }
  }

  real get() {
    auto ret = cast(real)numerator / cast(real)denominator;
    return ret;
  }
}

struct DiscreteProbability {
  Fraction prob;

  void count(double x) {
    count(x == 1.0);
  }

  void count(bool x) {
    if (x) {
      prob.numerator += 1;
    }
    prob.denominator += 1;
  }

  real get() {
    return prob.get();
  }
}

struct DiscreteJointProbability {
  Fraction prob;

  void count(bool x, bool y) {
    if (x && y) {
      prob.numerator += 1;
    }

    prob.denominator += 1;
  }

  real get() {
    return prob.get();
  }
}
