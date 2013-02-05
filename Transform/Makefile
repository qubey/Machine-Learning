all: cardinality transformer

transformer:
	g++ -ggdb -std=c++11 Transformer.cpp Transforms/*.cpp -o transformer -I../Common/ -L../bin -lstring

cardinality:
	g++ -std=c++11 Cardinality.cpp ComputeCardinality.cpp -o cardinality -I../common/ -L../bin -lstring

clean:
	rm -r cardinality* transformer*

