module transform.parser;

import std.csv;
import std.conv;
import std.array;
import std.stdio;
import std.container;
import std.file;
import std.string;

import common.data;
import common.util;

class Parser {
  static DataSet parseCsvFile(string fileName, string target) {
    DataSet data;
    string dataText = readText(fileName);
    auto records = csvReader(dataText, null);
    auto exampleResults = DList!RawExample();

    int targetIndex = findIndex(records.header, target);

    assert(target.empty ? targetIndex == -1 : targetIndex != -1,
           "Did not find target in data: " ~ target
           ~ ", index: " ~ to!string(targetIndex));

    if (targetIndex != -1) {
      data.featureLabels = records.header[0 .. targetIndex]
                           ~ records.header[targetIndex .. $];
      data.targetLabel = target;
    } else {
      data.featureLabels = records.header[];
    }

    foreach (recordObj; records) {
      auto record = array(recordObj);
      RawExample ex;
      if (targetIndex != -1) {
        ex.target = to!int(record[targetIndex]);
      }
      ex.features.length = record.length;
      foreach (i, item; record) {
        ex.features[i] = FeatureValue(item);
      }
      exampleResults.insertBack(ex);
    }
    data.examples = array(exampleResults[]);
    return data;
  }

  private static int findIndex(string[] values, string key) {
    int idx = -1;
    if (key.empty) {
      return idx;
    }

    foreach(i; 0 .. values.length) {
      auto res = icmp(strip(values[i]), strip(key));
      if (!res) {
        idx = cast(int)i;
        break;
      }
    }

    return idx;
  }
}
