import std.csv;
import std.conv;
import std.array;
import std.stdio;
import std.container;
import std.file;

import Data;

class Parser {
  static DataSet parseCsvFile(string fileName) {
    DataSet data;
    string dataText = readText(fileName);
    auto records = csvReader(dataText, null);
    auto exampleResults = DList!RawExample();

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
      exampleResults.insertBack(ex);
    }
    data.examples = array(exampleResults[]);
    return data;
  }
}
