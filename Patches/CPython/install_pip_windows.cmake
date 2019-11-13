message("Running CPython-pip install")

function( CopyFiles _inRegex _outDir )
  file( GLOB FILES_TO_COPY ${_inRegex} )
  if( FILES_TO_COPY )
    file( COPY ${FILES_TO_COPY} DESTINATION ${_outDir} )
  endif()
endfunction()

set( OUTPUT_LIB_DIR ${INSTALL_DIRECTORY}/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages )

CopyFiles( ${SOURCE_DIRECTORY}/Scripts/*.exe ${INSTALL_DIRECTORY}/bin )
CopyFiles( ${SOURCE_DIRECTORY}/Lib/site-packages/* ${OUTPUT_LIB_DIR} )
