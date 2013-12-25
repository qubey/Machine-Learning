module algorithm.model;

import std.stdio;
import std.json;

import common.data;

class Model {
  this(JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT,
           "JSON node for configuration should be an object");
  }

  abstract void batchTrain(ref TransformedDataSet data);

  abstract void batchPredict(ref TransformedDataSet data, out double[] preds);

  void saveModel(ref JSONValue config) {
    JSONValue modelNode;
    modelNode.type = JSON_TYPE.OBJECT;
    save(modelNode);
    config.object["model"] = modelNode;
  }

  protected abstract void save(ref JSONValue config);
}
