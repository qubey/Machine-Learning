all: transformer

transformer: Transformer.cpp Transforms/*.cpp
	g++ -std=c++11 Transformer.cpp Transforms/*.cpp -o transformer -I../Common/ -L../bin -lstring

clean:
	rm -r transformer*

