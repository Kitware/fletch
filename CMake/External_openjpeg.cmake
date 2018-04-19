
# libpng
add_package_dependency(
  PACKAGE openjpeg
  PACKAGE_DEPENDENCY PNG
  )
if (fletch_ENABLE_PNG)
  set(PNG_INCLUDE_DIR "${fletch_BUILD_INSTALL_PREFIX}/include")
endif()

list (APPEND openjpeg_DEPS
  -DPNG_PNG_INCLUDE_DIR:PATH=${PNG_INCLUDE_DIR}
  -DPNG_LIBRARY_RELEASE:FILEPATH=${PNG_LIBRARY}
  )

# libtiff
add_package_dependency(
  PACKAGE openjpeg
  PACKAGE_DEPENDENCY libtiff
  PACKAGE_DEPENDENCY_ALIAS TIFF
  )
if (fletch_ENABLE_libtiff)
  set(TIFF_INCLUDE_DIR "${fletch_BUILD_INSTALL_PREFIX}/include")
endif()

if (DEFINED TIFF_LIBRARY)
  list (APPEND openjpeg_DEPS
    -DTIFF_INCLUDE_DIR:PATH=${TIFF_INCLUDE_DIR}
    -DTIFF_LIBRARY_RELEASE:FILEPATH=${TIFF_LIBRARY}
    )
endif()

ExternalProject_Add(openjpeg
  URL ${openjpeg_url}
  URL_MD5 ${openjpeg_md5}
  DEPENDS ${openjpeg_DEPENDS}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}

  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}

  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    ${openjpeg_DEPS}
    ${COMMON_CMAKE_ARGS}
  )


set(openjpeg_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# openjpeg
################################
set(openjpeg_ROOT \${fletch_ROOT})
set(fletch_ENABLED_openjpeg TRUE)
")
