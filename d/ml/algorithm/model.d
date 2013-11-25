module algorithm.model;

import std.stdio;
import std.json;

import common.data;

class Model {
  this(JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT,
           "JSON node for configuration should be an object");
  }

  abstract void batchTrain(const ref TransformedDataSet data);

  
}
