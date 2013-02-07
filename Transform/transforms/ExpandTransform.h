#include "Transform.h"

#include <unordered_map>

class ExpandTransform : public Transform {
 public:
  explicit ExpandTransform(const std::vector<std::string>& input);

  void execute(const std::string& value, int offset, std::vector<double>* out);

  int getNumOutputs() const;

  // This will only get filled after all of the data is processed
  void getNames(std::vector<std::string>* names) const;

 private:
  std::unordered_map<std::string, int> values_;
  int currentCount_;
};
