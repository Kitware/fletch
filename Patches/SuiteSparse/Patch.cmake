#+
# This file is called as CMake -P script for the patch step of
# External_SuiteSparse.cmake.  It fixes the CMakeLists.txt to use find modules
#-

if (BUILD_CXSPARSE_ONLY)
  file(COPY ${SuiteSparse_patch}/CMakeLists.txt
    DESTINATION ${SuiteSparse_source}
    )
else()
  configure_file(
    ${SuiteSparse_patch}/SuiteSparse_config.mk
    ${SuiteSparse_source}/SuiteSparse_config
    @ONLY
    )
endif()

file( COPY ${SuiteSparse_patch}/CHOLMOD/Makefile
  DESTINATION ${SuiteSparse_source}/CHOLMOD/Lib
  )
file( COPY ${SuiteSparse_patch}/Makefile
  DESTINATION ${SuiteSparse_source}
  )
