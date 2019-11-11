message("Running CPython install")

function( CopyFiles _inRegex _outDir )
  file( GLOB FILES_TO_COPY ${_inRegex} )
  if( FILES_TO_COPY )
    file( COPY ${FILES_TO_COPY} DESTINATION ${_outDir} )
  endif()
endfunction()

CopyFiles( ${CPYTHON_BUILD_LOC}/*/*.exe ${fletch_BUILD_INSTALL_PREFIX}/bin )
CopyFiles( ${CPYTHON_BUILD_LOC}/*/*.dll ${fletch_BUILD_INSTALL_PREFIX}/bin )
CopyFiles( ${CPYTHON_BUILD_LOC}/*/*.lib ${fletch_BUILD_INSTALL_PREFIX}/lib )
CopyFiles( ${CPYTHON_BUILD_LOC}/*/*.pyd ${PYTHON_BASEPATH} )
