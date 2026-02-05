message("Running CPython install")

function( CopyFiles _inRegex _outDir )
  file( GLOB FILES_TO_COPY ${_inRegex} )
  if( FILES_TO_COPY )
    file( COPY ${FILES_TO_COPY} DESTINATION ${_outDir} )
  endif()
endfunction()

CopyFiles( ${CPYTHON_BUILD_LOC}/Include/* ${fletch_BUILD_INSTALL_PREFIX}/include )
CopyFiles( ${CPYTHON_BUILD_LOC}/PC/*.h ${fletch_BUILD_INSTALL_PREFIX}/include )
CopyFiles( ${CPYTHON_BUILD_LOC}/PCbuild/*/*.exe ${fletch_BUILD_INSTALL_PREFIX}/bin )
CopyFiles( ${CPYTHON_BUILD_LOC}/PCbuild/*/*.dll ${fletch_BUILD_INSTALL_PREFIX}/bin )
CopyFiles( ${CPYTHON_BUILD_LOC}/PCbuild/*/*.lib ${fletch_BUILD_INSTALL_PREFIX}/lib )
CopyFiles( ${CPYTHON_BUILD_LOC}/PCbuild/*/*.pyd ${PYTHON_BASEPATH} )
CopyFiles( ${CPYTHON_BUILD_LOC}/Lib/* ${PYTHON_BASEPATH} )

# Create python3XX._pth file for Python's module search paths.
# Paths in ._pth files are resolved relative to the file's directory (bin/).
# We use relative paths so the install is relocatable. During the build,
# sitecustomize.py (below) restores PYTHONPATH so absolute paths from CMake
# configure steps still work.
get_filename_component( PYTHON_VER_DIR "${PYTHON_BASEPATH}" NAME )
string( REGEX REPLACE "python([0-9]+)\\.([0-9]+)" "\\1\\2" PYTHON_VER_NUM "${PYTHON_VER_DIR}" )
set( PYTHON_PTH_FILE "${fletch_BUILD_INSTALL_PREFIX}/bin/python${PYTHON_VER_NUM}._pth" )

file( WRITE "${PYTHON_PTH_FILE}"
"..\\lib\\${PYTHON_VER_DIR}
..\\lib\\${PYTHON_VER_DIR}\\site-packages
..\\lib\\${PYTHON_VER_DIR}\\dist-packages
..\\configs
.
..\\DLLs
import site
" )
message( "Created ${PYTHON_PTH_FILE} for Python path configuration" )

# Create sitecustomize.py to re-enable PYTHONPATH processing.
# When a ._pth file is present, Python ignores PYTHONPATH. But packages like
# PyTorch rely on PYTHONPATH during their build to find source modules
# (torchgen, tools). The sitecustomize.py runs via "import site" in the ._pth
# file and restores the standard PYTHONPATH behavior.
file( WRITE "${PYTHON_BASEPATH}/sitecustomize.py"
"import os, sys
_pp = os.environ.get('PYTHONPATH', '')
if _pp:
    for _p in reversed(_pp.split(os.pathsep)):
        if _p and _p not in sys.path:
            sys.path.insert(0, _p)
" )
message( "Created ${PYTHON_BASEPATH}/sitecustomize.py for PYTHONPATH support" )
