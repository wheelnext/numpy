#!/bin/sh

set -ex

export INSTALL_OPENBLAS=false
case ${BLAS:-openblas} in
	openblas)
		export INSTALL_OPENBLAS=true
		;;
	mkl)
		pip install mkl-devel
		export PKG_CONFIG_PATH=$(python -c 'import sysconfig; print(sysconfig.get_path("purelib"))')/lib/pkgconfig
		ls "$PKG_CONFIG_PATH"
		;;
esac

if [[ -n ${CPU} ]]; then
	if [[ ${BLAS} == accelerate ]]; then
		BLAS=accel  # to fit in label
	fi
	set -- "${@}" -Cvariant-label=${CPU}_${BLAS}
fi

. tools/wheels/cibw_before_build.sh "${PWD}"
export PKG_CONFIG_PATH
pip install build auditwheel delocate
python -m build -w "${@}"
mkdir wheelhouse

# tag updating needs to be updated for variants
set -- dist/*.whl
old_name=${1#*/}
# strip variant label to avoid issues with auditwheel
mv "${1}" "${1%-*}.whl"

if grep -q Ubuntu /etc/os-release; then
	auditwheel repair dist/*.whl
	mv wheelhouse/*.whl "wheelhouse/${old_name}"
else
	delocate-wheel -w wheelhouse dist/*.whl
	mv wheelhouse/*.whl "wheelhouse/${old_name}"
fi
