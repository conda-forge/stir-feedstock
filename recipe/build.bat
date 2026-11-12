mkdir build
cd build

:: Configure using the CMakeFiles

:: exclude more tests when using parallelproj with CUDA
if NOT "%cuda_compiler_version%"=="None" (
  set CTEST_EXCLUDES="%CTEST_EXCLUDES%|parallelproj|test_blocks_on_cylindrical_projectors"
)
:: note: need extra quotes to prevent CMD to interpret the |
echo "Excluding run-time tests "%CTEST_EXCLUDES%""

echo Start Windows build
:: Configure.
cmake %CMAKE_ARGS% -G "Ninja" ^
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
if defined CTEST_EXCLUDES (
    ctest -C Release -E %CTEST_EXCLUDES% --output-on-failure
) else (
    ctest -C Release --output-on-failure
)
if errorlevel 1 exit 1

:: Point STIR to its installed config and doc dirs via conda's env_vars.d.
:: The directory names use the major.minor version, as in STIR's CMakeLists.txt.
for /f "tokens=1,2 delims=." %%a in ("%PKG_VERSION%") do set "STIR_VERSION_MM=STIR-%%a.%%b"
if not exist "%LIBRARY_PREFIX%\share\%STIR_VERSION_MM%\config" exit 1
if not exist "%PREFIX%\etc\conda\env_vars.d" mkdir "%PREFIX%\etc\conda\env_vars.d"
echo {"STIR_CONFIG_DIR": "%PREFIX:\=/%/Library/share/%STIR_VERSION_MM%/config", "STIR_DOC_DIR": "%PREFIX:\=/%/Library/share/doc/%STIR_VERSION_MM%"}> "%PREFIX%\etc\conda\env_vars.d\%PKG_NAME%.json"
if errorlevel 1 exit 1
