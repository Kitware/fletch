if (NOT fletch_BUILD_CXX17)
  message(FATAL_ERROR "Ceres requires C++17 support, please enable fletch_BUILD_CXX17")
endif()

# Set Eigen dependency
if (fletch_ENABLE_Eigen)
  message(STATUS "Ceres depending on internal Eigen")
  list(APPEND Ceres_DEPENDS Eigen)
  list(APPEND Ceres_EXTRA_BUILD_FLAGS -DEIGEN_INCLUDE_DIR_HINTS:PATH=${EIGEN_ROOT})
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

if (fletch_ENABLE_GFlags)
  list(APPEND Ceres_DEPENDS GFlags)
  list(APPEND Ceres_EXTRA_BUILD_FLAGS
         -Dgflags_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/lib/cmake/gflags
      )
endif()

ExternalProject_Add(Ceres
  DEPENDS ${Ceres_DEPENDS}
  URL ${Ceres_file}
  URL_MD5 ${Ceres_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
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

find_package(Ceres @Ceres_version@ REQUIRED)

set(fletch_ENABLED_Ceres TRUE)
")
