all: cardinality transformer

transformer:
	g++ -std=c++11 Transformer.cpp -o transformer -I../Common/ -L../bin -lstring -ltransform

cardinality:
	g++ -std=c++11 Cardinality.cpp ComputeCardinality.cpp -o cardinality -I../common/ -L../bin -lstring

clean:
	rm -r cardinality* transformer*

