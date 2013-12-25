module common.json;

import std.stdio;
import std.json;
import std.traits;


class JSONUtil {
  static bool parseValue(T)(ref JSONValue json, string key, ref T result) {
    assert(json.type == JSON_TYPE.OBJECT);

    if (key !in json.object) return false;

    auto keyNode = json.object[key];
    return getValue(keyNode, result);
  }

  static bool getValue(T)(ref JSONValue json, ref T result) { 
    static if (is(T == string)) {
      if (json.type != JSON_TYPE.STRING) return false;
      result = json.str;
      return true;
    } static if (isArray!T && !is(T == string)) {
      if (json.type != JSON_TYPE.ARRAY) return false;
      result.length = json.array.length;

      foreach(i; 0 .. result.length) {
        if (getValue(json.array[i], result[i]) == false) {
          return false;
        }
      }

      return true;
    } static if (is(T == long)) {
      if (json.type != JSON_TYPE.INTEGER) return false;
      result = json.integer;
      return true;
    } static if (is(T == real)) {
      if (json.type != JSON_TYPE.FLOAT) return false;
      result = json.floating;
      return true;
    } static if (is(T == bool)) {
      result = json.type == JSON_TYPE.TRUE;
      return true;
    } static if (is(T == JSONValue)) {
      if (json.type != JSON_TYPE.OBJECT) return false;
      result = json;
      return true;
    } else {
      assert(false, "Type not supported for parsing");
    }
  }

  static void saveValue(T)(ref JSONValue config, string key, T value) {
    assert(config.type == JSON_TYPE.OBJECT, "Config not an object node");
    config.object[key] = createNode(value);
  }

  private static JSONValue createNode(T)(ref T value) {
    JSONValue ret;
    static if (is(T == long)) {
      ret.type = JSON_TYPE.INTEGER;
      ret.integer = value;
    }
    static if (is(T == string)) {
      ret.type = JSON_TYPE.STRING;
      ret.str = value;
    }
    static if (is(T == real) || is(T == double)) {
      ret.type = JSON_TYPE.FLOAT;
      ret.floating = value;
    }
    static if (isArray!T && !is(T == string)) {
      ret.type = JSON_TYPE.ARRAY;
      ret.array.length = value.length;

      foreach(i; 0 .. value.length) {
        ret[i] = createNode(value[i]);
      }
    }
    return ret;
  }
}
