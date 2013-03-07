all: string test

string:
	g++ -std=c++11 -shared -o $(GIT_ML_ROOT)/bin/libstring.so StringUtil.cpp
	cp *.h $(GIT_ML_ROOT)/bin/headers/

test:
	g++ -std=c++11 StringUtil.cpp test.cpp -o test

clean:
	rm $(GIT_ML_ROOT)/bin/libstring.so test
