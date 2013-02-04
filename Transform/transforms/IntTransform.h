#include "Transform.h"

template<typename T>
class NormalizeTransform : public Transform {
 public:
  explicit NormalizeTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, std::vector<double>* out) const;

  int getNumOutputs() const;

 private:
  T min_;
  T max_;
};
