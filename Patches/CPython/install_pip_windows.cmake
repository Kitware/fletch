message("Running CPython-pip install")

function( CopyFiles _inFolder _inRegex _outDir )
  if( EXISTS "${_inFolder}" )
    file( GLOB FILES_TO_COPY ${_inFolder}/${_inRegex} )
    if( FILES_TO_COPY )
      file( COPY ${FILES_TO_COPY} DESTINATION ${_outDir} )
    endif()
  endif()
endfunction()

set( PYTHON_SUBDIR lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages )
set( OUTPUT_LIB_DIR ${INSTALL_DIRECTORY}/${PYTHON_SUBDIR} )

CopyFiles( "${SOURCE_DIRECTORY}/bin" "*.exe" "${INSTALL_DIRECTORY}/bin" )
CopyFiles( "${SOURCE_DIRECTORY}/Scripts" "*.exe" "${INSTALL_DIRECTORY}/bin" )

CopyFiles( "${SOURCE_DIRECTORY}/${PYTHON_SUBDIR}" "*" "${OUTPUT_LIB_DIR}" )
CopyFiles( "${SOURCE_DIRECTORY}/Lib/site-packages" "*" "${OUTPUT_LIB_DIR}" )

# Patch setuptools to look for Python libraries in ../lib instead of libs
# This is needed because Python executable is in bin/ while libs are in lib/
set( SETUPTOOLS_BUILD_EXT "${OUTPUT_LIB_DIR}/setuptools/_distutils/command/build_ext.py" )
if( EXISTS "${SETUPTOOLS_BUILD_EXT}" )
  file( READ "${SETUPTOOLS_BUILD_EXT}" BUILD_EXT_CONTENT )
  string( REPLACE
    "os.path.join(sys.exec_prefix, 'libs')"
    "os.path.join(sys.exec_prefix, '..', 'lib')"
    BUILD_EXT_CONTENT "${BUILD_EXT_CONTENT}" )
  string( REPLACE
    "os.path.join(sys.base_exec_prefix, 'libs')"
    "os.path.join(sys.base_exec_prefix, '..', 'lib')"
    BUILD_EXT_CONTENT "${BUILD_EXT_CONTENT}" )
  file( WRITE "${SETUPTOOLS_BUILD_EXT}" "${BUILD_EXT_CONTENT}" )
  message( "Patched setuptools build_ext.py for library paths" )
endif()
