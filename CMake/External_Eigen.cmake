
ExternalProject_Add(Eigen
  URL ${Eigen_url}
  URL_MD5 ${Eigen_md5}
  DOWNLOAD_NAME ${Eigen_dlname}
  PREFIX  ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR  ${fletch_BUILD_INSTALL_PREFIX}
  BUILD_IN_SOURCE 0
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DEigen_patch:PATH=${fletch_SOURCE_DIR}/Patches/Eigen
    -DEigen_source:PATH=${fletch_BUILD_PREFIX}/src/Eigen
    -P ${fletch_SOURCE_DIR}/Patches/Eigen/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DEIGEN_BUILD_PKGCONFIG:BOOL=False
)

set(EIGEN_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(EIGEN_INCLUDE_DIR ${EIGEN_ROOT}/include/eigen3 CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# EIGEN
########################################
set(EIGEN_ROOT    @EIGEN_ROOT@)
set(EIGEN3_ROOT    @EIGEN_ROOT@)
set(EIGEN_INCLUDE_DIR @EIGEN_INCLUDE_DIR@)
set(fletch_ENABLED_Eigen TRUE)
")
