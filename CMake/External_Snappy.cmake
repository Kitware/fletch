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
      ${COMMON_CMAKE_ARGS}
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      )
endif()

fletch_external_project_force_install(PACKAGE Snappy)

set(SNAPPY_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Snappy
########################################
set(SNAPPY_ROOT    \$\{fletch_ROOT\})
")
