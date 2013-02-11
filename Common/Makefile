all: string test

string:
	g++ -std=c++11 -shared -o ../bin/libstring.so StringUtil.cpp

test:
	g++ -std=c++11 StringUtil.cpp test.cpp -o test

clean:
	rm ../bin/libstring.so test
