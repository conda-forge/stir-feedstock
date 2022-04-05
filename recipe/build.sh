OS=`uname`
# disable HDF5 currently on all systems due to conflicts
case $OS in
  'Darwin')
    EXTRA_OPTS="-DDISABLE_HDF5:BOOL=ON"
    ;;
  *)
    EXTRA_OPTS="-DDISABLE_HDF5:BOOL=ON"
    ;;
esac

python_exec=`which python`
mkdir build && cd build
cmake -G "Ninja" \
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
