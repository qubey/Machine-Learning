output = ${D_MAKE_ROOT}/bin/transformer
all:
	mkdir -p $(output)
	dmd FeatureTransforms.d Data.d Parser.d Transformer.d -of$(output)/Transformer

clean:
	rm -rf $(output)/*
