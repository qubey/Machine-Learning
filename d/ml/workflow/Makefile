bin = ${D_MAKE_ROOT}/bin
libs = $(bin)/common/libcommon.o $(bin)/transform/libtransform.o \
  $(bin)/algorithm/libmodels.o
include_flags = -I${D_MAKE_ROOT}
out_dir = $(bin)/workflow

all:
	mkdir -p $(out_dir)
	dmd *.d -c $(libs) -of$(out_dir)/libworkflow.o \
    $(include_flags)

clean:
	rm -f $(out_dir)/*
