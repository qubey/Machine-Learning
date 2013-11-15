import std.json;
import std.regex;
import std.container;
import std.algorithm;
import std.stdio;
import std.file;
import std.conv;
import std.math;
import std.array;
import std.string;
import std.range;

import Data;
import stringutil;

// Base class for all transformations
class FeatureTransform {
  string name;
  string[] inputs;
  bool includeInOutput;
  int outputStartIndex;

  this(JSONValue config) {
    assert(config.type == JSON_TYPE.OBJECT);

    auto nameNode = config.object["name"];
    assert(nameNode.type == JSON_TYPE.STRING);
    name = nameNode.str;

    auto inputNode = config.object["input"];
    assert(inputNode.type == JSON_TYPE.ARRAY);
    inputs.length = inputNode.array.length;
    foreach (i, node; inputNode.array) {
      inputs[i] = node.str;
    }

    if ("output" in config.object) {
      auto outputNode = config.object["output"];
      includeInOutput = outputNode.type == JSON_TYPE.TRUE;
    }
  }

  void setInputs(int[] indices, int[] sizes) {
    assert(indices.length == inputs.length);
    assert(sizes.length == indices.length);
    inputFeatureIndices = indices;
    inputSizes = sizes;
  }

  void setOutputIndex(int o) {
    outputStartIndex = o;
  }

  abstract void process(ref FeatureVector ex);
  abstract void finalize();
  abstract bool transform(ref FeatureVector ex);
  abstract int size();

  protected bool getInputDouble(ref FeatureVector ex, out double val) {
    // If the input is a dobule, we know we should only have one input index
    assert(inputFeatureIndices.length == 1);

    auto inval = ex[inputFeatureIndices[0]];
    try {
      val = inval.type == FeatureValueType.STRING ?
        to!double(inval.strval) : inval.numval;
    } catch (Exception e) {
      return false;
    }

    return true;
  }

  protected void setOutputValue(
    ref FeatureVector ex,
    int index,
    double value
  ) {
    assert(index < size());
    ex[outputStartIndex + index] = FeatureValue(
      FeatureValueType.DOUBLE,
      null,
      value
    );
  }

  private int[] inputFeatureIndices;
  private int[] inputSizes;
}

// Normalizes a feature to be in the range [0,1]
class NormalizeTransform : FeatureTransform {
  double min;
  double max;
  bool initialized;

  this(JSONValue config) {
    super(config);
    initialized = false;
    assert(inputs.length == 1);
  }

  override void process(ref FeatureVector ex) {
    double value;
    if (getInputDouble(ex, value)) {
      if (!initialized) {
        min = max = value;
        initialized = true;
        return; 
      }

      if (value < min) min = value;
      if (value > max) max = value;
    }
  }

  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value);
    success &= (max - min) != 0;

    if (success) {
      setOutputValue(ex, 0, (value - min) / (max - min));
    }

    return success;
  }

  override int size() { return 1; }
}

// Tokenizes the feature and takes the highest N occurring words
// to transform the input string into N boolean features
class BagOfWordsTransform : FeatureTransform {
  private struct Token {
    string name;
    int count;
  }
  private Token[string] tokenCounts;
  private int maxCardinality;
  private int[string] tokenIndices;

  this(JSONValue config) {
    super(config);
    auto cardNode = config.object["max_card"];
    assert(cardNode.type == JSON_TYPE.INTEGER);
    maxCardinality = cast(int)cardNode.integer;
    assert(inputs.length == 1);
  }

  override void process(ref FeatureVector ex) {
    string[] tokens = getTokens(ex);

    foreach (token; tokens) {
      if (token.empty) continue;

      if (token in tokenCounts) {
        tokenCounts[token].count += 1;
      } else {
        Token t;
        t.name = token;
        t.count = 1;
        tokenCounts[token] = t;
      }
    }
  }

  override void finalize() {
    auto tokens = tokenCounts.values;
    topN!("a.count > b.count")(tokens, maxCardinality);

    string words;
    foreach (i, token; take(tokens, maxCardinality)) {
      if (words.empty) {
        words = token.name;
      } else {
        words ~= ", " ~ token.name;
      }
      words ~= ": " ~ to!string(token.count);

      tokenIndices[token.name] = cast(int)i;
    }
    writeln("Bag of words transform: " ~ name ~ ": " ~ words);
  }

  override bool transform(ref FeatureVector ex) {
    string[] tokens = getTokens(ex);
    
    foreach (token; tokens) {
      if (token in tokenIndices) {
        setOutputValue(ex, tokenIndices[token], 1);
      }
    }

    return true;
  }

  override int size() {
    return maxCardinality;
  }

  private string[] getTokens(ref FeatureVector ex) {
    assert(inputFeatureIndices.length == 1);

    auto fval = ex[inputFeatureIndices[0]];
    assert(fval.type == FeatureValueType.STRING);

    string[] tokens = scrub(fval.strval);
    return tokens;
  }
}

/*
class NgramTransform : FeatureTransform {
}
*/

// Leaves the feature unchanged (just copies it to the output vector)
class IdentityTransform : FeatureTransform {
  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
  }

  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value);
    if (success) {
      setOutputValue(ex, 0, value);
    }
    return success;
  }

  override int size() { return 1; }
}


// Takes the logarithm of the input feature
class LogTransform : FeatureTransform {
  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
  }
  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value);
    success &= value > 0.0;

    if (success) {
      setOutputValue(ex, 0, log(value));
    }

    return success;
  }
  override int size() { return 1; }
}

// Raises e to the power of the feature value
class ExpTransform : FeatureTransform {
  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
  }
  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value);
    if (success) {
      setOutputValue(ex, 0, exp(value));
    }
    return success;
  }
  override int size() { return 1; }
}

class InverseTransform : FeatureTransform {
  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
  }
  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value) && value != 0;
    if (success) {
      setOutputValue(ex, 0, 1.0 / value);
    }
    return success;
  }
  override int size() { return 1; }
}

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
      writeln(&stderr, "Error reading JSON:");
      writeln(&stderr, e.msg);
      return;
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
        default:
          writeln("Unkown transform: " ~ transformType);
          continue;
      }

      transforms.insertBack(transform);
    }
  }
}
