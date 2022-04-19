message("Running CPython-pip install")

function( CopyFiles _inRegex _outDir )
  file( GLOB FILES_TO_COPY ${_inRegex} )
  if( FILES_TO_COPY )
    file( COPY ${FILES_TO_COPY} DESTINATION ${_outDir} )
  endif()
endfunction()

set( PYTHON_SUBDIR lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages )
set( OUTPUT_LIB_DIR ${INSTALL_DIRECTORY}/${PYTHON_SUBDIR} )

CopyFiles( ${SOURCE_DIRECTORY}/bin/*.exe ${INSTALL_DIRECTORY}/bin )
CopyFiles( ${SOURCE_DIRECTORY}/${PYTHON_SUBDIR}/* ${OUTPUT_LIB_DIR} )
