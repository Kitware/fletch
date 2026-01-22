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

# Create python310._pth file to specify absolute paths for Python's module search
# This is required because when Python is run from a different working directory
# (like during CMake configure steps), relative paths in sys.path don't resolve correctly.
# The ._pth file tells Python to use these explicit paths instead of auto-detection.
# Extract Python version from PYTHON_BASEPATH (e.g., /lib/python3.10 -> 310)
get_filename_component( PYTHON_VER_DIR "${PYTHON_BASEPATH}" NAME )
string( REGEX REPLACE "python([0-9]+)\\.([0-9]+)" "\\1\\2" PYTHON_VER_NUM "${PYTHON_VER_DIR}" )
set( PYTHON_PTH_FILE "${fletch_BUILD_INSTALL_PREFIX}/bin/python${PYTHON_VER_NUM}._pth" )

# Convert paths to use Windows backslashes for the ._pth file
string( REPLACE "/" "\\" WIN_PYTHON_BASEPATH "${PYTHON_BASEPATH}" )
string( REPLACE "/" "\\" WIN_INSTALL_PREFIX "${fletch_BUILD_INSTALL_PREFIX}" )

# Write the ._pth file with absolute paths
# The "import site" line enables site-packages processing
file( WRITE "${PYTHON_PTH_FILE}"
"${WIN_PYTHON_BASEPATH}
${WIN_PYTHON_BASEPATH}\\site-packages
${WIN_PYTHON_BASEPATH}\\dist-packages
${WIN_INSTALL_PREFIX}\\bin
${WIN_INSTALL_PREFIX}\\DLLs
import site
" )
message( "Created ${PYTHON_PTH_FILE} for Python path configuration" )
