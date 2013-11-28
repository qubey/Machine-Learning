module common.json;

import std.json;


class JSONUtil {
  static bool getString(ref JSONValue json, string key, ref string result) {
    assert(json.type == JSON_TYPE.OBJECT);

    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    if (keyNode.type != JSON_TYPE.STRING) return false;
    result = keyNode.str;

    return true;
  }

  static bool getInt(ref JSONValue json, string key, ref long result) {
    assert(json.type == JSON_TYPE.OBJECT);
  
    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    if (keyNode.type != JSON_TYPE.INTEGER) return false;

    result = keyNode.integer;
    return true;
  }

  static bool getFloat(ref JSONValue json, string key, ref real result) {
    assert(json.type == JSON_TYPE.OBJECT);
  
    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    if (keyNode.type != JSON_TYPE.FLOAT) return false;

    result = keyNode.floating;
    return true;
  }
}
