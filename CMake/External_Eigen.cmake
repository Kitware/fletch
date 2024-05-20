
ExternalProject_Add(Eigen
  URL ${Eigen_url}
  URL_MD5 ${Eigen_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DEigen_patch:PATH=${fletch_SOURCE_DIR}/Patches/Eigen
    -DEigen_source:PATH=${fletch_BUILD_PREFIX}/src/Eigen
    -P ${fletch_SOURCE_DIR}/Patches/Eigen/Patch.cmake
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DEIGEN_BUILD_PKGCONFIG:BOOL=False
)

fletch_external_project_force_install(PACKAGE Eigen)

set(EIGEN_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
set(EIGEN_INCLUDE_DIR ${EIGEN_ROOT}/include/eigen3 CACHE STRING "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# EIGEN
########################################
set(Eigen3_DIR \${fletch_ROOT}/share/eigen3/cmake)
set(fletch_ENABLED_Eigen TRUE)
")
