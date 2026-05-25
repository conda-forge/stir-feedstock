# verbose shell output
set -xv

EXTRA_OPTS="-DDISABLE_HDF5:BOOL=OFF"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # see https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
    CXXFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY"
    export CXXFLAGS
fi

# disable HDF5 on osx_arm64 as it is bigendian, and STIR doesn't know how to handle that for GEHDF5
if [[ "$CONDA_TOOLCHAIN_HOST" == "arm"* ]]; then
  # sadly currently also need to disable ITK due to UCL/STIR#1165
  echo "Disabling HDF5 and ITK support in STIR"
  EXTRA_OPTS="-DDISABLE_HDF5:BOOL=ON -DDISABLE_ITK:BOOL=ON"
fi

# exclude more tests when using parallelproj with CUDA
if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  CTEST_EXCLUDES="${CTEST_EXCLUDES}|parallelproj|test_blocks_on_cylindrical_projectors"
fi

echo "Excluding run-time tests ${CTEST_EXCLUDES}"

python_exec=`which python`
mkdir build && cd build

cmake ${CMAKE_ARGS} \
      -G "Ninja" \
      -D PYTHON_DEST=$SP_DIR \
      -D BUILD_SWIG_PYTHON:BOOL=ON \
      -D Python_EXECUTABLE=${python_exec} \
      -D CMAKE_BUILD_TYPE=Release \
      -D STIR_OPENMP=ON \
      -D GRAPHICS=None \
      $EXTRA_OPTS $SRC_DIR

cmake --build . --config Release

cmake --build . --target install --config Release

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest -C Release -E "(${CTEST_EXCLUDES})" --output-on-failure
fi

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in activate deactivate
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    for e in sh fish csh; do
        cp "${RECIPE_DIR}/${CHANGE}.$e" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.$e"
    done
done
