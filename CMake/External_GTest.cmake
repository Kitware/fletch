ExternalProject_Add(GTest
  URL ${GTest_url}
  URL_MD5 ${GTest_md5}
  DOWNLOAD_NAME ${GTest_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DGTest_patch:PATH=${fletch_SOURCE_DIR}/Patches/GTest
    -DGTest_source:PATH=${fletch_BUILD_PREFIX}/src/GTest
    -P ${fletch_SOURCE_DIR}/Patches/GTest/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
  )

set(GTEST_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GTest
########################################
set(GTEST_ROOT \${fletch_ROOT})
set(fletch_ENABLED_GTest TRUE)
")
