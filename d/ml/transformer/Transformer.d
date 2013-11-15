import std.range, std.stdio, std.file;
import std.algorithm;
import std.conv, std.container;
import std.csv;

import Transforms;
import Data;

auto getData(string fileName) {
  auto data = new DataSet;
  string dataText = readText(fileName);
  auto records = csvReader(dataText, null);

  data.targetLabel = records.header[0];
  data.featureLabels = records.header[1..records.header.length];

  foreach (recordObj; records) {
    auto record = array(recordObj);
    RawExample ex;
    ex.target = to!int(record[0]);
    ex.features.length = record.length - 1;
    foreach (i, item; record[1..record.length]) {
      ex.features[i] = FeatureValue( FeatureValueType.STRING, item, 0.0 );
    }
    data.examples.insertBack(ex);
  }

  return data;
}

void initializeTransforms(
  const ref DataSet data,
  ref DList!FeatureTransform transforms,
  out int totalSize,
  out int outputSize
) {
  int[string] featureIndices;
  int[string] featureSizes;
  int currentFeatureIndex = 0;
  foreach(flabel; data.featureLabels) {
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
  writeln("Transform map: " ~ to!string(transformMap));
  writeln("Dependencies: " ~ to!string(dependencies));

  // Topological sort for the DAG of transforms
  transforms.clear();
  while (dependencies.length > 0) {
    string[] processedTransforms;
    foreach (name, deps; dependencies) {
      if (deps.length != 0) {
        continue;
      }

      auto currentTrans = transformMap[name];
      currentTrans.setOutputIndex(currentFeatureIndex);
      transforms.insertBack(currentTrans);
      writeln("Inserted: " ~ to!string(currentTrans));

      featureIndices[name] = currentFeatureIndex;
      featureSizes[name] = currentTrans.size();
      currentFeatureIndex += currentTrans.size();

      if (name in dependants) {
        foreach (dependant; dependants[name].byKey()) {
          dependencies[dependant].remove(name);
        }
      }

      processedTransforms ~= name;
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

    if (t.includeInOutput) {
      outputSize += t.size();
    }
  }

  totalSize = currentFeatureIndex;
}

int main(string args[]) {
  if (args.length != 3) {
    writeln("Wrong number of arguments");
    return -1;
  }

  auto data = getData(args[1]);

  DList!FeatureTransform transforms;
  TransformFactory.createTransforms(args[2], transforms);
  writeln("Transforms size 1: " ~ to!string(transforms));
  int outSize;
  int totalSize;
  initializeTransforms(*data, transforms, totalSize, outSize);
  writeln("Transforms size 2: " ~ to!string(transforms));

  
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

  const char delim = ',';
  FeatureVector transformedFeatures;
  double[] output;
  transformedFeatures.length = totalSize;
  output.length = outSize;
  foreach (example; data.examples) {
    transformedFeatures[0..example.features.length] = example.features[];
    transformedFeatures[example.features.length..$] = FeatureValue(
      FeatureValueType.DOUBLE,
      null,
      0.0
    );

    int outIndex = 0;
    foreach(t; transforms) {
      t.transform(transformedFeatures);

      if (t.includeInOutput) {
        foreach (i; 0 .. t.size()) {
          output[outIndex++] =
            transformedFeatures[t.outputStartIndex + i].numval;
        }
      }
    }

    write(example.target);
    foreach (value; output) {
      write(delim, value);
    }
    writeln();
  }

  return 0;
}
