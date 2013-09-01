all: feature_stats analyze print

print: PrintFeatures.cpp
	g++ -std=c++11 PrintFeatures.cpp -o print \
			-I$(GIT_ML_ROOT)/bin/headers/ \
			-L$(GIT_ML_ROOT)/bin -lstring

analyze:
	g++ -std=c++11 DistributionAnalyze.cpp FeatureStats.cpp -o analyze \
			-I$(GIT_ML_ROOT)/bin/headers/ \
			-L$(GIT_ML_ROOT)/bin -lstring

feature_stats:
	g++ -std=c++11 FeatureStats.cpp ComputeStats.cpp -o feature_stats \
			-I$(GIT_ML_ROOT)/bin/headers/ \
			-L$(GIT_ML_ROOT)/bin -lstring

clean:
	rm -r feature_stats* analyze print

