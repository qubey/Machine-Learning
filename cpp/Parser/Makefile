all:
	g++ -std=c++11 -shared ScalarParser.cpp -o $(GIT_ML_ROOT)/bin/libparser.so \
		-I$(GIT_ML_ROOT)/bin/headers \
		-L$(GIT_ML_ROOT)/bin -lstring
	cp -f *.h $(GIT_ML_ROOT)/bin/headers/

clean:
	rm $(GIT_ML_ROOT)/bin/libparser.so
