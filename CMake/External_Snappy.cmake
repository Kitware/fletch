if (WIN32)

  # Build option for windows not yet generated
  message( FATAL_ERROR "SNAPPY on windows not yet supported" )

else()
  ExternalProject_Add(Snappy
    URL ${Snappy_url}
    URL_MD5 ${Snappy_md5}
    PREFIX ${fletch_BUILD_PREFIX}
    DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
    INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
    PATCH_COMMAND ${CMAKE_COMMAND}
      -DSnappy_patch:PATH=${fletch_SOURCE_DIR}/Patches/Snappy
      -DSnappy_source:PATH=${fletch_BUILD_PREFIX}/src/Snappy
      -P ${fletch_SOURCE_DIR}/Patches/Snappy/Patch.cmake
    CMAKE_COMMAND
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      )
endif()

set(SNAPPY_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Snappy
########################################
set(SNAPPY_ROOT    @SNAPPY_ROOT@)
")
