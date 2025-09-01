#!/bin/sh

set -ex

if [[ ${BLAS:-openblas} != openblas ]]; then
	export INSTALL_OPENBLAS=false
fi

if [[ -n ${CPU} ]]; then
	if [[ ${BLAS} == accelerate ]]; then
		BLAS=accel  # to fit in label
	fi
	set -- "${@}" -Cvariant-label=${CPU}_${BLAS}
fi

. tools/wheels/cibw_before_build.sh "${PWD}"
export PKG_CONFIG_PATH
pip install build auditwheel
python -m build -w "${@}"
if grep -q Ubuntu /etc/os-release; then
	# tag updating needs to be updated for variants
	set -- dist/*.whl
	old_name=${1#*/}
	# strip variant label to avoid issues with auditwheel
	mv "${1}" "${1%-*}.whl"
	auditwheel repair dist/*.whl
	mv wheelhouse/*.whl "wheelhouse/${old_name}"
else
	# quick hack to make workflows simpler
	mv dist wheelhouse
fi
