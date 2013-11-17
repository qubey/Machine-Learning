module tools.transformdata;

import std.stdio;
import std.conv;

import common.data;
import common.parser;
import transform.transformer;

int main(string args[]) {
  if (args.length != 4) {
    writeln("Wrong number of arguments: " ~ to!string(args.length));
    return -1;
  }

  auto data = Parser.parseCsvFile(args[1]);
  auto transformer = new Transformer(data.featureLabels, args[2]);
  transformer.preprocess(data);
  transformer.saveTransforms(args[3]);

  return 0;
}
