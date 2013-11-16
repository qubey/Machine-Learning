bin = ${D_MAKE_ROOT}/bin
libs = $(bin)/util/libutil.a $(bin)/transform/libtransform.o
include_flags = -I${D_MAKE_ROOT}
out_dir = $(bin)/tools

all:
	mkdir -p $(out_dir)
	dmd transform_data.d $(libs) -of$(out_dir)/transform_data $(include_flags)

clean:
	rm -f $(out_dir)/*
