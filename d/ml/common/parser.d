module transform.parser;

import std.csv;
import std.conv;
import std.array;
import std.stdio;
import std.container;
import std.file;

import common.data;

class Parser {
  static DataSet parseCsvFile(string fileName, bool hasTarget = true) {
    DataSet data;
    string dataText = readText(fileName);
    auto records = csvReader(dataText, null);
    auto exampleResults = DList!RawExample();

    int start = 0;
    if (hasTarget) {
      data.targetLabel = records.header[0];
      start = 1;
    }
    data.featureLabels = records.header[start .. records.header.length];

    foreach (recordObj; records) {
      auto record = array(recordObj);
      RawExample ex;
      if (hasTarget) {
        ex.target = to!int(record[0]);
      }
      ex.features.length = record.length - start;
      foreach (i, item; record[start .. record.length]) {
        ex.features[i] = FeatureValue(item);
      }
      exampleResults.insertBack(ex);
    }
    data.examples = array(exampleResults[]);
    return data;
  }
}
