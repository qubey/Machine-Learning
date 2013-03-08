all: trainer predictor logistic_predictor logistic_trainer

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

logistic_trainer:
	g++ -std=c++11 LogisticTrain.cpp Trainer.cpp RegressionModel.cpp\
								 LogisticRegressionModel.cpp -o train \
			-I$(GIT_ML_ROOT)/bin/headers \
			-L$(GIT_ML_ROOT)/bin -lstring

logistic_predictor:
	g++ -std=c++11 LogisticPredict.cpp Predictor.cpp RegressionModel.cpp\
								 LogisticRegressionModel.cpp -o predict \
			-I$(GIT_ML_ROOT)/bin/headers \
			-L$(GIT_ML_ROOT)/bin -lstring

clean:
	rm -r train* predict*

