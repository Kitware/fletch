
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
    set(Gtest_CXX_STANDARD_ARGS "-DCMAKE_CXX_STANDARD:STRING=98")
  else()
    set(Gtest_CXX_STANDARD_ARGS "-DCMAKE_CXX_STANDARD:STRING=11")
  endif()
endif()

ExternalProject_Add(GTest
  URL ${GTest_url}
  URL_MD5 ${GTest_md5}
  DOWNLOAD_NAME ${GTest_dlname}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${Gtest_CXX_STANDARD_ARGS}
  )

set(GTEST_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# GTest
########################################
set(GTEST_ROOT \${fletch_ROOT})
set(fletch_ENABLED_GTest TRUE)
")
