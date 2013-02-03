all: test libmatrix

libmatrix:
	g++ -shared -o ../bin/libmatrix.so Matrix.cpp Utils.cpp

test:
	g++ -g Matrix.cpp Utils.cpp TestMatrix.cpp -o test

clean:
	rm -r test*

