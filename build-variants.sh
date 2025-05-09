#!/bin/sh

if ! grep -q Ubuntu /etc/os-release; then
	export INSTALL_OPENBLAS=false
fi

. tools/wheels/cibw_before_build.sh "${PWD}"
export PKG_CONFIG_PATH
pip install build auditwheel
python -m build -w "${@}"
if grep -q Ubuntu /etc/os-release; then
	# tag updating needs to be updated for variants
	auditwheel repair --no-update-tags --plat "$PLAT" dist/*.whl
else
	# quick hack to make workflows simpler
	mv dist wheelhouse
fi
