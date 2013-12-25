module tools.transformdata;

import std.stdio;
import std.conv;

import workflow.execution;

int main(string args[]) {
  if (args.length != 3) {
    writeln(args[0] ~ " <config file> <data root>");
    writeln(to!string(args));
    return -1;
  }

  auto workflow = new WorkflowExecution(args[1], args[2]);
  workflow.run();
  workflow.save("");

  return 0;
}
