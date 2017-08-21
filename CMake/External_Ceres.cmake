
# Set Eigen dependency
if (fletch_ENABLE_Eigen)
  message(STATUS "Ceres depending on internal Eigen")
  list(APPEND Ceres_DEPENDS Eigen)
else()
  message(FATAL_ERROR "Eigen is required for Ceres Solver, please enable")
endif()

# Set SuiteSparse dependency
if (fletch_ENABLE_SuiteSparse)
  message(STATUS "Ceres depending on internal SuiteSparse")
  list(APPEND Ceres_DEPENDS SuiteSparse)
else()
  message(FATAL_ERROR "SuiteSparse is required for Ceres Solver, please enable")
endif()

if (fletch_ENABLE_GLog)
  list(APPEND Ceres_DEPENDS GLog)
  get_system_library_name( glog glog_libname )
  list(APPEND Ceres_EXTRA_BUILD_FLAGS
         -DGLOG_INCLUDE_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/include
         -DGLOG_LIBRARY:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/${glog_libname}
      )
else()
  list(APPEND Ceres_EXTRA_BUILD_FLAGS -DMINIGLOG:BOOL=ON)
endif()

set (Ceres_PATCH_DIR ${fletch_SOURCE_DIR}/Patches/Ceres/${Ceres_version})
if (EXISTS ${Ceres_PATCH_DIR})
  set (Ceres_PATCH_COMMAND ${CMAKE_COMMAND}
    -DCeres_patch=${Ceres_PATCH_DIR}
    -DCeres_source=${fletch_BUILD_PREFIX}/src/Ceres
    -P ${Ceres_PATCH_DIR}/Patch.cmake)
else()
  set (Ceres_PATCH_COMMAND "")
endif()

ExternalProject_Add(Ceres
  DEPENDS ${Ceres_DEPENDS}
  URL ${Ceres_file}
  URL_MD5 ${Ceres_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  PATCH_COMMAND ${Ceres_PATCH_COMMAND}

  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
    -DBUILD_EXAMPLES:BOOL=OFF
    -DEIGEN_INCLUDE_DIR=${EIGEN_INCLUDE_DIR}
    -DCXSPARSE_INCLUDE_DIR=${SuiteSparse_INCLUDE_DIR}
    -DCXSPARSE_LIBRARY_DIR_HINTS=${SuiteSparse_ROOT}/lib
    -DLIB_SUFFIX:STRING=
    ${Ceres_EXTRA_BUILD_FLAGS}
  )

fletch_external_project_force_install(PACKAGE Ceres)

set(Ceres_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
if(WIN32)
  set(Ceres_DIR "${Ceres_ROOT}/CMake" CACHE PATH "" FORCE)
else()
  set(Ceres_DIR "${Ceres_ROOT}/lib/cmake/Ceres" CACHE PATH "" FORCE)
endif()



file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Ceres
########################################
set(Ceres_ROOT \${fletch_ROOT})
if(WIN32)
  set(Ceres_DIR \${fletch_ROOT}/CMake)
else()
  set(Ceres_DIR \${fletch_ROOT}/lib/cmake/Ceres)
endif()

set(fletch_ENABLED_Ceres TRUE)
")
