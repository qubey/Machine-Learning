module common.util;

import std.file;
import std.json;
import std.regex;
import std.algorithm;
import std.string;
import std.array;

const auto kIgnoreWords =
    r"^(from|by|has|or|of|a|an|the|it|its)$";

string[] scrub(string rawInput) {
  auto input = removechars(toLower(rawInput),  ",.()\"\':");
  string[] rawTokens = split(input);
  return array(filter!(a => !match(a, kIgnoreWords))(rawTokens));
}

JSONValue parseJson(string filename) {
  string jsonText = readText(filename);
  JSONValue jsonRoot;
  try {
    jsonRoot = parseJSON(jsonText);
  } catch (Exception e) {
    assert(false, "Error reading JSON: " ~ e.msg);
  }
  return jsonRoot;
}

int findIndex(T)(T[] values, T key) {
  int idx = -1;

  foreach(i; 0 .. values.length) {
    if (values[i] == key) {
      idx = cast(int)i;
      break;
    }
  }

  return idx;
}
