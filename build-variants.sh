#!/bin/sh

. tools/wheels/cibw_before_build.sh "${PWD}"
export PKG_CONFIG_PATH
pip install build auditwheel
python -m build -w "${@}"
# tag updating needs to be updated for variants
auditwheel repair --no-update-tags --plat "$PLAT" dist/*.whl
