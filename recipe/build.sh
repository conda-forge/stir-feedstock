mkdir build && cd build
debugbuild=true

#if $debugbuild; then
echo HIER
    which python
    find $PREFIX -name Python.h
    find $PREFIX -name libpython\*

    find /home/conda/feedstock_root/build_artifacts/  -name Python.h
    find /home/conda/feedstock_root/build_artifacts/  -name libpy\*
#fi
exit 1
cmake -D CMAKE_FIND_DEBUG_MODE=$debugbuild \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D PYTHON_DEST=$SP_DIR \
      -D BUILD_SWIG_PYTHON:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      -D STIR_OPENMP=ON \
      -D GRAPHICS=None \
      $SRC_DIR
make -j${CPU_COUNT}
make install
