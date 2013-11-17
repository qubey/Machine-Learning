module common.stringutil;

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
