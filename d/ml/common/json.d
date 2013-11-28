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

  static bool getBool(ref JSONValue json, string key, ref bool result) {
    assert(json.type == JSON_TYPE.OBJECT);
  
    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    result = keyNode.type == JSON_TYPE.TRUE;
    return true;
  }

  static bool getObject(ref JSONValue json, string key, ref JSONValue result) {
    assert(json.type == JSON_TYPE.OBJECT);
  
    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    if (keyNode.type != JSON_TYPE.OBJECT) return false;

    result = keyNode;
    return true;
  }

  static bool getArray(T)(ref JSONValue json, string key, ref T[] result)
    if (is(T == string) || is(T == real) || is(T == long)) {
    assert(json.type == JSON_TYPE.OBJECT);

    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    if (keyNode.type != JSON_TYPE.ARRAY) return false;

    result.length = keyNode.array.length;
    static if(is(T == real)) {
      foreach(i, node; keyNode.array) {
        assert(node.type == JSON_TYPE.FLOAT);
        result[i] = node.floating;
      }
    }
    static if(is(T == string)) {
      foreach(i, node; keyNode.array) {
        assert(node.type == JSON_TYPE.STRING);
        result[i] = node.str;
      }
    }
    static if(is(T == long)) {
      foreach(i, node; keyNode.array) {
        assert(node.type == JSON_TYPE.INTEGER);
        result[i] = node.integer;
      }
    }

    return true;
  }
}
