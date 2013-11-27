bin_dir = ${D_MAKE_ROOT}/bin
output = $(bin_dir)/algorithm
libs = $(bin_dir)/common/libcommon.o
include_flags = -I${D_MAKE_ROOT}
src = *.d clustering/*.d classification/*.d

all:
	mkdir -p $(output)
	dmd -c $(src) $(libs) -of$(output)/libmodels.o $(include_flags)

clean:
	rm -rf $(output)/*
