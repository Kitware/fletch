ExternalProject_Add(GFlags
  URL ${GFlags_url}
  URL_MD5 ${GFlags_md5}
  DOWNLOAD_NAME ${GFlags_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DGFlags_patch:PATH=${fletch_SOURCE_DIR}/Patches/GFlags
    -DGFlags_source:PATH=${fletch_BUILD_PREFIX}/src/GFlags
    -P ${fletch_SOURCE_DIR}/Patches/GFlags/Patch.cmake

  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=ON
  )

fletch_external_project_force_install(PACKAGE GFlags)

set(GFlags_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

get_system_library_name( gflags gflags_libname )

set(GFlags_INCLUDE_DIR "${fletch_BUILD_INSTALL_PREFIX}/include")
set(GFlags_LIBRARY "${fletch_BUILD_INSTALL_PREFIX}/lib/${gflags_libname}")

file(APPEND ${fletch_CONFIG_INPUT} "
#######################################
# GFlags
#######################################
set(GFlags_ROOT \${fletch_ROOT})
")
