module transform.transformer;

import std.json;
import std.range, std.stdio, std.file;
import std.algorithm;
import std.conv, std.container;
import std.csv;

import common.data;
import transform.factory;

class Transformer {
  private DList!FeatureTransform transforms;
  private int finalOutputSize;
  private int totalVectorSize;

  this(string configFile) {
    TransformFactory.createTransforms(configFile, transforms);
  }

  this(string[] inputFeatures, string configFile) {
    this(configFile);
    initializeTransforms(inputFeatures);
  }

  void initializeTransforms(string[] inputFeatures) {
    initializeTransforms(
      inputFeatures,
      transforms,
      totalVectorSize,
      finalOutputSize
    );
  }

  bool shouldPreprocess() {
    foreach (t; transforms) {
      if (t.requiresPreprocess()) {
        return true;
      }
    }

    return false;
  }

  auto getTransforms() {
    return transforms;
  }

  void initializeTransforms(
    string[] inputFeatures,
    ref DList!FeatureTransform transforms,
    out int totalSize,
    out int outputSize
  ) {
    int[string] featureIndices;
    int[string] featureSizes;
    int currentFeatureIndex = 0;
    foreach(flabel; inputFeatures) {
      featureIndices[flabel] = cast(int)currentFeatureIndex;
      featureSizes[flabel] = 1;
      currentFeatureIndex += 1;
    }

    // Prepare the structures for representing the DAG
    byte[string][string] dependencies;
    byte[string][string] dependants;
    FeatureTransform[string] transformMap;
    foreach (t; transforms) {
      transformMap[t.name] = t;

      string[] deps =
        array(filter!(a => (a in featureIndices) == null)(t.inputs));

      byte[string] empty;
      dependencies[t.name] = empty;

      foreach (dep; deps) {
        dependencies[t.name][dep] = 1;
        dependants[dep][t.name] = 1;
      }
    }

    // Do a sanity check to make sure all of the dependencies exist
    foreach (name, deps; dependencies) {
      foreach (depName; deps.byKey()) {
        if (depName !in featureIndices && depName !in transformMap) {
          writeln("Could not find input " ~ depName ~ " for transform " ~
                  name);
          assert(false);
        }
      }
    }

    // Topological sort for the DAG of transforms
    transforms.clear();
    while (dependencies.length > 0) {
      string[] processedTransforms;
      bool foundNode = false;
      foreach (name, deps; dependencies) {
        if (deps.length != 0) {
          continue;
        }
        foundNode = true;

        auto currentTrans = transformMap[name];
        transforms.insertBack(currentTrans);

        if (name in dependants) {
          foreach (dependant; dependants[name].byKey()) {
            dependencies[dependant].remove(name);
          }
        }

        processedTransforms ~= name;
      }

      // Check for circular dependencies
      if (!foundNode) {
        writeln("Circular dependency found.");
        assert(false);
      }

      // Remove the nodes which we are done with
      foreach (ptrans; processedTransforms) {
        dependencies.remove(ptrans);
      }
    }

    outputSize = 0;
    foreach (t; transforms) {
      int[] depIndices; 
      int[] depSizes;
      depIndices.length = t.inputs.length;
      depSizes.length = t.inputs.length;

      foreach (i, dep; t.inputs) {
        depIndices[i] = featureIndices[dep];
        depSizes[i] = featureSizes[dep];
      }

      t.setInputs(depIndices, depSizes);
      t.setOutputIndex(currentFeatureIndex);

      featureIndices[t.name] = currentFeatureIndex;
      featureSizes[t.name] = t.size();
      currentFeatureIndex += t.size();

      if (t.includeInOutput) {
        t.setFinalOutputIndex(outputSize);
        outputSize += t.size();
      }
    }

    totalSize = currentFeatureIndex;
  }

  void preprocess(DataSet data) {
    // Let the transforms do a first pass on the data for finding the best
    // transform values
    foreach (example; data.examples) {
      foreach (t; transforms) {
        t.process(example.features);
      }
    }

    // Signal the transformations to do any final processing
    foreach (t; transforms) {
      t.finalize();
    }
  }

  void transform(RawExample ex, out TransformedExample transex) {
    transex.features.length = finalOutputSize;
    allFeatures.length = totalVectorSize;

    allFeatures[0..ex.features.length] = ex.features[];
    allFeatures[ex.features.length..$] = FeatureValue(
      FeatureValueType.DOUBLE,
      null,
      0.0
    );

    int outIndex = 0; 
    foreach(t; transforms) {
      t.transform(allFeatures);

      // Check whether we need to include this transform in the output vector
      // We also assume that the output of the transformation is numerical
      if (t.includeInOutput) {
        foreach (i; 0 .. t.size()) {
          transex.features[outIndex++] =
            allFeatures[t.outputStartIndex + i].numval;
        }
      }
    }

    transex.target = ex.target;
  }

  void transformSet(DataSet data, out TransformedDataSet output) {
    output.examples.length = data.examples.length;

    foreach (i, example; data.examples) {
      transform(example, output.examples[i]);
    }
  }

  void saveTransforms(string filename) {
    JSONValue initialRoot;
    try {
      string initialJsonText = readText(filename);
      initialRoot = parseJSON(initialJsonText);
      assert(initialRoot.type == JSON_TYPE.OBJECT,
             "Existing JSON root node must be object for JSON serialize");
    } catch (Exception e) {
      initialRoot.type = JSON_TYPE.OBJECT;
    }

    try {
      JSONValue transformNode;
      transformNode.type = JSON_TYPE.ARRAY;
      foreach (t; transforms) {
        JSONValue tconf;
        t.save(tconf);
        transformNode.array ~= tconf;
      }

      initialRoot.object["transforms"] = transformNode;

      std.file.write(filename, toJSON(&initialRoot));
    } catch (Exception e) {
      assert(false, "Error writing JSON: " ~ e.msg);
    }
  }

  private FeatureVector allFeatures;
}
