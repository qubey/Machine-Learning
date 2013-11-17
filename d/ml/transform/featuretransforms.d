module transform.featuretransforms;

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

import common.data;
import common.stringutil;

// Base class for all transformations
class FeatureTransform {
  string name;
  string[] inputs;
  bool includeInOutput;
  int outputStartIndex;
  int finalOutputIndex;

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
    sort(inputs);

    if ("output" in config.object) {
      auto outputNode = config.object["output"];
      includeInOutput = outputNode.type == JSON_TYPE.TRUE;
    }
  }

  void save(ref JSONValue config) {
    config.type = JSON_TYPE.OBJECT;
    JSONValue nameNode;
    nameNode.type = JSON_TYPE.STRING;
    nameNode.str = name;
    config.object["name"] = nameNode;

    JSONValue typeNode;
    typeNode.type = JSON_TYPE.STRING;
    typeNode.str = getTypeName();
    config.object["type"] = typeNode;

    SList!JSONValue inputItems;
    foreach (input; inputs) {
      JSONValue val;
      val.type = JSON_TYPE.STRING;
      val.str = input;
      inputItems.insert(val);
    }

    JSONValue inputNode;
    inputNode.type = JSON_TYPE.ARRAY;
    inputNode.array = array(inputItems[]);
    config.object["input"] = inputNode;

    JSONValue outputNode;
    outputNode.type = (includeInOutput ? JSON_TYPE.TRUE : JSON_TYPE.FALSE);
    config.object["output"] = outputNode;
  }

  bool requiresPreprocess() {
    return false;
  }

  void setInputs(int[] indices, int[] sizes) {
    assert(indices.length == inputs.length);
    assert(sizes.length == indices.length);

    inputFeatureIndices = indices;
    inputSizes = sizes;
  }

  void setFinalOutputIndex(int fo) {
    finalOutputIndex = fo;
  }

  void setOutputIndex(int o) {
    outputStartIndex = o;
  }

  void process(ref FeatureVector ex, double target) {
    process(ex);
  }

  abstract string getTypeName();

  abstract void process(ref FeatureVector ex);
  abstract void finalize();
  abstract bool transform(ref FeatureVector ex);
  abstract int size();

  protected bool getInputDouble(ref FeatureVector ex, out double val) {
    assert(inputFeatureIndices.length == 1);
    return getInputDouble(ex, 0, 0, val);
  }

  protected bool getInputDouble(
    ref FeatureVector ex,
    int feature,
    int offset,
    out double val
  ) {
    assert(feature >= 0);
    assert(feature < inputs.length);
    assert(offset < inputSizes[feature]);

    auto inval = ex[inputFeatureIndices[feature] + offset];
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

  protected int[] inputFeatureIndices;
  protected int[] inputSizes;
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

    if ("info" in config.object) {
      auto infoNode = config.object["info"];
      assert(infoNode.type == JSON_TYPE.OBJECT,
             "Info node of wrong type for " ~ name);
      assert("min" in infoNode.object, "Min not found for transform " ~ name);
      assert("max" in infoNode.object, "Max not found for transform " ~ name);
      min = cast(double)infoNode.object["min"].floating;
      max = cast(double)infoNode.object["max"].floating;
      initialized = true;
    }
  }

  override string getTypeName() { return "normalize"; }

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

  override bool requiresPreprocess() {
    return !initialized;
  }

  override void save(ref JSONValue writeConfig) {
    super.save(writeConfig);

    JSONValue minNode;
    JSONValue maxNode;
    minNode.type = maxNode.type = JSON_TYPE.FLOAT;
    minNode.floating = cast(real) min;
    maxNode.floating = cast(real) max;

    JSONValue inputNode;
    inputNode.type = JSON_TYPE.OBJECT;
    inputNode.object["min"] = minNode;
    inputNode.object["max"] = maxNode;
    writeConfig.object["info"] = inputNode;
  }
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

    if ("info" in config.object) {
      foreach (token, indexNode; config.object["info"].object) {
        assert(indexNode.type == JSON_TYPE.INTEGER);
        tokenIndices[token] = cast(int)indexNode.integer;
      }
    }
  }

  override string getTypeName() { return "words"; }

  override void save(ref JSONValue config) {
    super.save(config);

    JSONValue cardNode;
    cardNode.type = JSON_TYPE.INTEGER;
    cardNode.integer = maxCardinality;
    config.object["max_card"] = cardNode;

    JSONValue infoNode;
    infoNode.type = JSON_TYPE.OBJECT;
    if (tokenIndices.length > 0) {
      foreach (token, index; tokenIndices) {
        JSONValue tokenNode;
        tokenNode.type = JSON_TYPE.INTEGER;
        tokenNode.integer = index;
        infoNode.object[token] = tokenNode;
      }
    }

    config.object["info"] = infoNode;
  }

  override bool requiresPreprocess() {
    return tokenIndices.length == 0;
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
    sort!("a.count > b.count")(tokens);

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

    tokenCounts.clear();
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

class NgramTransform : FeatureTransform {
  private int outSize;
 
  this(JSONValue config) {
    super(config);
    assert(inputs.length > 1);
  }

  override string getTypeName() { return "ngram"; }

  override void setInputs(int[] indices, int[] sizes) {
    super.setInputs(indices, sizes);
    outSize = 1;
    foreach (insize; inputSizes) {
      outSize *= insize;
    }
  }

  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    assert(ex.length == outputStartIndex + size());

    int[] curIndices;
    curIndices.length = inputs.length;

    int outIndex = 0;
    while (outIndex < outSize) {
      double val = 1.0;
      foreach (i, idx; curIndices) {
        double fval = 0;
        if (!getInputDouble(ex, cast(int)i, idx, fval)) {
          return false;
        }
        val *= fval;
        if (val == 0.0) break;
      }
      setOutputValue(ex, outIndex, val);
      outIndex++;

      // increment the indices for the next value
      bool carry = true;
      int carryIndex = 0;
      while (carry) {
        curIndices[carryIndex] += 1;
        curIndices[carryIndex] %= inputSizes[carryIndex];

        carry = curIndices[carryIndex] == 0 && carryIndex < inputs.length - 1;
        carryIndex++;
      }
    }

    return true;
  }

  override int size() {
    return outSize;
  }
}

// Leaves the feature unchanged (just copies it to the output vector)
class IdentityTransform : FeatureTransform {
  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
  }

  override string getTypeName() { return "id"; }

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

  override string getTypeName() { return "log"; }

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

  override string getTypeName() { return "exp"; }

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

  override string getTypeName() { return "inverse"; }
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

class GreaterThanTransform : FeatureTransform {
  private double threshold;

  this(JSONValue config) {
    super(config);
    assert(inputs.length == 1);
    assert("threshold" in config.object);

    auto node = config.object["threshold"];
    assert(node.type == JSON_TYPE.FLOAT);
    threshold = cast(double)node.floating;
  }

  override void save(ref JSONValue config) {
    super.save(config);
    JSONValue thresholdNode;
    thresholdNode.type = JSON_TYPE.FLOAT;
    thresholdNode.floating = cast(real) threshold;

    config.object["threshold"] = thresholdNode;
  }

  override string getTypeName() { return "greater_than"; }

  override void process(ref FeatureVector ex) { }
  override void finalize() { }

  override bool transform(ref FeatureVector ex) {
    double value;
    bool success = getInputDouble(ex, value) && value != 0;
    if (success) {
      setOutputValue(ex, 0, value > threshold ? 1.0 : 0.0);
    }
    return success;
  }
  override int size() { return 1; }
}
