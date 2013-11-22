module tools.transformdata;

import std.stdio;
import std.conv;

import common.data;
import common.parser;
import transform.transformer;

int main(string args[]) {
  if (args.length != 2) {
    writeln(args[0] ~ " <transform config file>");
    return -1;
  }

  auto transformer = new Transformer(args[1]);

  foreach (t; transformer.getTransforms()) {
    assert(
      !t.requiresPreprocess(),
      "Transform " ~ t.name ~ " not initialized"
    );
  }

  writeln("Transforms have all been properly initialized!");
  return 0;
}
