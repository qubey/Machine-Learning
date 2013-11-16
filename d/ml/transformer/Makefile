output = ${D_MAKE_ROOT}/bin/transformer
include_dir = ${D_MAKE_ROOT}/bin
all:
	mkdir -p $(output)
	dmd *.d $(include_dir)/util/libutil.a \
    -of$(output)/Transformer -I${D_MAKE_ROOT}

clean:
	rm -rf $(output)/*
