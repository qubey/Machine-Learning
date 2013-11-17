module tools.transformdata;

import std.stdio;

import transform.data;
import transform.transformer;
import transform.parser;

int main(string args[]) {
  if (args.length != 3) {
    writeln("Wrong number of arguments");
    return -1;
  }

  auto data = Parser.parseCsvFile(args[1]);
  auto transformer = new Transformer(data.featureLabels, args[2]);
  transformer.preprocess(data);

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