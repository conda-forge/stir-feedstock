mkdir build
cd build

:: Configure using the CMakeFiles

set CTEST_EXCLUDES="test_priors"
:: exclude tests using parallelproj GPU
if NOT "%cuda_compiler_version%"=="None" (
  set CTEST_EXCLUDES="%CTEST_EXCLUDES%|parallelproj|test_blocks_on_cylindrical_projectors"
)

echo "Excluding run-time tests %EXTRA_CTEST_EXCLUDES%

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

:: Test
ctest -C Release -E %CTEST_EXCLUDES% --output-on-failure
if errorlevel 1 exit 1

setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    copy %RECIPE_DIR%\%%F.ps1 %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.ps1
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
