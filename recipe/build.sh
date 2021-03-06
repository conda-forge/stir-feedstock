mkdir build && cd build
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D PYTHON_DEST=$SP_DIR \
      -D BUILD_SWIG_PYTHON:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      -D STIR_OPENMP=ON \
      -D GRAPHICS=None \
      $SRC_DIR
make -j${CPU_COUNT}
make install
