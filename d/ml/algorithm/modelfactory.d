module algorithm.modelfactory;

import std.json;

public import algorithm.model;
import algorithm.kmeans;

class ModelFactory {
  static Model create(JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT, "Config is of wrong type");
    assert("model" in config.object, "Missing model spec in config");

    auto modelConfig = config.object["model"];
    assert(modelConfig.type == JSON_TYPE.OBJECT,
           "Model config is not an object");
    assert("type" in modelConfig.object, "Model config missing type");

    auto typeNode = modelConfig.object["type"];
    assert(typeNode.type == JSON_TYPE.STRING,
           "Model type should be a string");
    string type = typeNode.str;

    Model ret;
    switch(type) {
      case "kmeans":
        ret = new KMeansModel(modelConfig);
        break;
      default:
        assert(false, "Invalid model type: " ~ type);
    }

    return ret;
  }
}
