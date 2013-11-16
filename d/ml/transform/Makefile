output = ${D_MAKE_ROOT}/bin/transform
bin_dir = ${D_MAKE_ROOT}/bin
libs = $(bin_dir)/util/libutil.a
include_flags = -I${D_MAKE_ROOT}

all:
	mkdir -p $(output)
	dmd -c *.d $(libs) -of$(output)/libtransform.o $(include_flags)

clean:
	rm -rf $(output)/*
