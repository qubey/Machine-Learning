BIN="./bin/tools/trainer"
#CONFIG="${D_MAKE_ROOT}/configs/transforms_titanic.json"
CONFIG="${D_MAKE_ROOT}/configs/titanic.cluster.json"

#
# TRANSFORM DATA
#

#./bin/tools/transform_data ${DATA_DIR}/titanic/train.csv ${D_MAKE_ROOT}/configs/transforms_titanic.json
#./bin/tools/transform_data ${DATA_DIR}/titanic/train.csv output.json

#./bin/transform/transform_data ${DATA_DIR}/insults/train.csv ${D_MAKE_ROOT}/configs/transforms_insults.json

#./bin/transform/transform_data ${DATA_DIR}/bulldozer/train2.csv ${D_MAKE_ROOT}/configs/transforms_bulldozer.json

#
# MUTUAL INFORMATION
#

#./bin/tools/mutual_info ${DATA_DIR}/titanic/train.csv ${D_MAKE_ROOT}/configs/transforms_titanic.json

#
# PROCESS & VALIDATE TRANSFORMS
#

#./bin/tools/process_transforms ${DATA_DIR}/titanic/train.csv ${D_MAKE_ROOT}/configs/transforms_titanic.json output.json && ./bin/tools/validate_transforms output.json

#
# TRAIN MODELS
#
#./bin/tools/trainer ${DATA_DIR}/titanic/train.csv ${D_MAKE_ROOT}/configs/transforms_titanic.json

#./bin/tools/trainer ${DATA_DIR}/insults/train.csv ${D_MAKE_ROOT}/configs/transforms_insults.json

${BIN} ${CONFIG} ${DATA_DIR}
