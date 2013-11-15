output = ${D_MAKE_ROOT}/bin/transformer
all:
	mkdir -p $(output)
	dmd Transforms.d Data.d Transformer.d -of$(output)/Transformer

clean:
	rm -rf $(output)/*
