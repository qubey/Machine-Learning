all: feature_stats transformer analyze print

print: PrintFeatures.cpp
	g++ -std=c++11 PrintFeatures.cpp -o print -I../common/ -L../bin -lstring

analyze:
	g++ -std=c++11 DistributionAnalyze.cpp FeatureStats.cpp -o analyze -I../common/ -L../bin -lstring

transformer:
	g++ -std=c++11 Transformer.cpp Transforms/*.cpp -o transformer -I../Common/ -L../bin -lstring

feature_stats:
	g++ -std=c++11 FeatureStats.cpp ComputeStats.cpp -o feature_stats -I../common/ -L../bin -lstring

clean:
	rm -r feature_stats* transformer* analyze

