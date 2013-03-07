all: trainer predictor

trainer:
	g++ -std=c++11 Train.cpp Trainer.cpp RegressionModel.cpp\
								 LinearRegressionModel.cpp -o train \
			-I$(GIT_ML_ROOT)/bin/headers \
			-L$(GIT_ML_ROOT)/bin -lstring

predictor:
	g++ -std=c++11 Predict.cpp Predictor.cpp RegressionModel.cpp\
								 LinearRegressionModel.cpp -o predict \
			-I$(GIT_ML_ROOT)/bin/headers \
			-L$(GIT_ML_ROOT)/bin -lstring

clean:
	rm -r train* predict*

