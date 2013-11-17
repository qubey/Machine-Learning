bin = ${D_MAKE_ROOT}/bin
libs = $(bin)/common/libcommon.o $(bin)/transform/libtransform.o
include_flags = -I${D_MAKE_ROOT}
out_dir = $(bin)/tools

all:
	mkdir -p $(out_dir)
	dmd transform_data.d $(libs) -of$(out_dir)/transform_data $(include_flags)
	dmd mutual_info.d $(libs) -of$(out_dir)/mutual_info $(include_flags)
	dmd process_transforms.d $(libs) -of$(out_dir)/process_transforms \
    $(include_flags)
	dmd validate_transforms.d $(libs) -of$(out_dir)/validate_transforms \
    $(include_flags)

clean:
	rm -f $(out_dir)/*
