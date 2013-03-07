all: test libmatrix

libmatrix:
	g++ -shared -o $(GIT_ML_ROOT)/bin/libmatrix.so Matrix.cpp Utils.cpp
	cp *.h $(GIT_ML_ROOT)/bin/headers/

test:
	g++ -g Matrix.cpp Utils.cpp TestMatrix.cpp -o test

clean:
	rm -r test*

