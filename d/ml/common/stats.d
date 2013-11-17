module common.stats;

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
