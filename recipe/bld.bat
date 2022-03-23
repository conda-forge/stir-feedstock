mkdir build
cd build

echo Start Windows build
:: Configure.
cmake -G "Ninja" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D DISABLE_HDF5:BOOL=ON ^
      -D PYTHON_DEST=%SP_DIR% ^
      -D BUILD_SWIG_PYTHON:BOOL=ON ^
      -D Python_EXECUTABLE=%PYTHON% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D STIR_OPENMP=ON ^
      -D GRAPHICS=None ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --target install --config Release
if errorlevel 1 exit 1

