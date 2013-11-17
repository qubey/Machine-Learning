module tools.transformdata;

import std.stdio;

import common.data;
import common.parser;
import transform.transformer;

int main(string args[]) {
  if (args.length != 3) {
    writeln("Wrong number of arguments");
    return -1;
  }

  auto transformer = new Transformer(args[2]);

  auto data = Parser.parseCsvFile(args[1]);
  transformer.initializeTransforms(data.featureLabels);

  if (transformer.shouldPreprocess()) {
    writeln("Preprocessing data...");
    transformer.preprocess(data);
  } else {
    writeln("Transforms already initialized");
  }

  TransformedDataSet transdata;
  transformer.transformSet(data, transdata);

  const char delim = ',';
  foreach(example; transdata.examples) {
    write(example.target);
    foreach (value; example.features) {
      write(delim, value);
    }
    writeln();
  }

  return 0;
}
