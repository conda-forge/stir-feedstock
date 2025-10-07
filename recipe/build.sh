# verbose shell output
set -xv

OS=`uname`
case $OS in
  'Darwin')
    EXTRA_OPTS="-DDISABLE_HDF5:BOOL=OFF"
    # see https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk 
    CXXFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY"
    export CXXFLAGS
    ;;
  *)
    EXTRA_OPTS="-DDISABLE_HDF5:BOOL=OFF"
    ;;
esac
# disable HDF5 on osx_arm64 as it is bigendian, and STIR doesn't know how to handle that for GEHDF5
if [[ "$CONDA_TOOLCHAIN_HOST" == "arm"* ]]; then
  # sadly currently also need to disable ITK due to UCL/STIR#1165
  echo "Disabling HDF5 and ITK support in STIR"
  EXTRA_OPTS="-DDISABLE_HDF5:BOOL=ON -DDISABLE_ITK:BOOL=ON"
fi

# exclude any tests that are known to fail (none at the moment)
# CTEST_EXCLUDES=test_priors
# exclude more tests when using parallelproj with CUDA
if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  CTEST_EXCLUDES="${CTEST_EXCLUDES}|parallelproj|test_blocks_on_cylindrical_projectors"
fi

echo "Excluding run-time tests ${CTEST_EXCLUDES}"

python_exec=`which python`
mkdir build && cd build

# Run CMake
# Addition of CMAKE_ARGS is recommended on https://conda-forge.org/blog/posts/2020-10-29-macos-arm64/#how-to-add-a-osx-arm64-build-to-a-feedstock
cmake ${CMAKE_ARGS} \
      -G "Ninja" \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D PYTHON_DEST=$SP_DIR \
      -D BUILD_SWIG_PYTHON:BOOL=ON \
      -D Python_EXECUTABLE=${python_exec} \
      -D CMAKE_BUILD_TYPE=Release \
      -D STIR_OPENMP=ON \
      -D GRAPHICS=None \
      $EXTRA_OPTS $SRC_DIR

# Build.
cmake --build . --config Release

# Install
cmake --build . --target install --config Release

# Test, but only if not cross-compiling (e.g. on osx_arm64)
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

