module transform.factory;

import std.json;
import std.container;
import std.file;
import std.stdio;

import transform.bucketer;
public import transform.featuretransforms;

class TransformFactory {
  static void createTransforms(
    string jsonConfigFile,
    out DList!FeatureTransform transforms
  ) {
    string jsonText = readText(jsonConfigFile);
    JSONValue jsonRoot;
    try {
      jsonRoot = parseJSON(jsonText);
    } catch (Exception e) {
      assert(false, "Error reading JSON: " ~ e.msg);
    }

    JSONValue transformArray = jsonRoot.object["transforms"];

    assert(transformArray.type == JSON_TYPE.ARRAY);
    foreach (node; transformArray.array) {
      string transformType = node.object["type"].str;
      FeatureTransform transform;
      switch (transformType) {
        case "exp":
          transform = new ExpTransform(node);
          break;
        case "inverse":
          transform = new InverseTransform(node);
          break;
        case "log":
          transform = new LogTransform(node);
          break;
        case "id":
          transform = new IdentityTransform(node);
          break;
        case "words":
          transform = new BagOfWordsTransform(node);
          break;
        case "normalize":
          transform = new NormalizeTransform(node);
          break;
        case "ngram":
          transform = new NgramTransform(node);
          break;
        case "greater_than":
          transform = new GreaterThanTransform(node);
          break;
        case "quantile_bucket":
          transform = new QuantileBucketTransform(node);
          break;
        case "vec_to_id":
          transform = new VecToIntTransform(node);
          break;
        default:
          assert(false, "Unkown transform: " ~ transformType);
          continue;
      }

      transforms.insertBack(transform);
    }
  }
}
