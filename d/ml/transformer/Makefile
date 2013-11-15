output = ${D_MAKE_ROOT}/bin/transformer
util_dir = ${D_MAKE_ROOT}/util
all:
	mkdir -p $(output)
	dmd *.d $(util_dir)/*.d \
    -of$(output)/Transformer -I${D_MAKE_ROOT}

clean:
	rm -rf $(output)/*
