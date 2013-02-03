#include <string>
#include <vector>

class StringUtil {
 public:
  static std::vector<std::string> split(std::string& input, char delim);

 private:
  explicit StringUtil() { }
};
