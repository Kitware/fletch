set(Burnout_DEPENDS)

add_package_dependency(
  PACKAGE Darknet
  PACKAGE_DEPENDENCY OpenCV
  PACKAGE_DEPENDENCY_ALIAS OpenCV
  )

add_package_dependency(
  PACKAGE Darknet
  PACKAGE_DEPENDENCY Caffe
  )


ExternalProject_Add(Burnout
  DEPENDS ${Burnout_DEPENDS}
  URL ${Burnout_url}
  URL_MD5 ${Burnout_md5}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  CMAKE_COMMAND
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}

    -DBUILD_TESTING:BOOL=OFF
    -DVIDTK_BUILD_TESTS:BOOL=OFF
    -DBURNOUT_DISABLE_GDAL:BOOL=TRUE

    -DVIDTK_ENABLE_CAFFE:BOOL=${fletch_ENABLE_CAFFE}

    #-DCaffe_DIR:PATH=${VIAME_BUILD_PREFIX}/src/fletch-build/build/src/Caffe-build
    #-DVXL_DIR:PATH=${VIAME_BUILD_PREFIX}/src/fletch-build/build/src/VXL-build
    #-DOpenCV_DIR:PATH=${VIAME_BUILD_PREFIX}/src/fletch-build/build/src/OpenCV-build
    #${_Boost_DIR_ARGS}
    #-DBoost_LIBRARY_DIR:PATH=${_boost_LIB_DIR}
    #-DCMAKE_CXX_FLAGS:STRING="${CMAKE_CXX_FLAGS} -std=c++0x"
  )

fletch_external_project_force_install(PACKAGE Burnout)

set(Burnout_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE STRING "")
message(STATUS "Burnout_ROOT = ${Burnout_ROOT}")

#set(VIAME_ARGS_burnout
#  -Dburnout_DIR:PATH=${VIAME_BUILD_PREFIX}/src/burnout-build
#  -Dvidtk_DIR:PATH=${VIAME_BUILD_PREFIX}/src/burnout-build
#  )

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# Burnout
########################################
#set(Dvidtk_DIR     \${fletch_ROOT}/share/vxl/burnout)
set(Burnout_ROOT    \${fletch_ROOT})
set(Burnout_DIR     \${fletch_ROOT}/CMake)
set(fletch_ENABLED_Burnout TRUE)
")

