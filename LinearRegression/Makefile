all: trainer predictor

trainer:
	g++ -std=c++11 Trainer.cpp LinearRegressionModel.cpp -o train -I../Common/ -L../bin -lstring

predictor:
	g++ -std=c++11 Predictor.cpp LinearRegressionModel.cpp -o predict -I../Common/ -L../bin -lstring

clean:
	rm -r train* predict*

