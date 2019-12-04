# PNG External project

# ZLIB
add_package_dependency(
  PACKAGE PNG
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
)
if(NOT ZLIB_FOUND)
  set(ZLIB_INCLUDE_DIRS ${fletch_BUILD_INSTALL_PREFIX}/include)
  get_system_library_name(z zlib_lib)
  set(ZLIB_LIBRARIES ${fletch_BUILD_INSTALL_PREFIX}/lib/${zlib_lib})
endif()
set(png_cmake_args ${png_cmake_args}
  -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIRS}
  -DZLIB_LIBRARY:PATH=${ZLIB_LIBRARIES}
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
  )


ExternalProject_Add(PNG
  DEPENDS ${PNG_DEPENDS}
  URL ${PNG_url}
  URL_MD5 ${PNG_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy
    ${fletch_SOURCE_DIR}/Patches/PNG/CMakeLists.txt
    ${fletch_BUILD_PREFIX}/src/PNG/CMakeLists.txt
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${png_cmake_args}
  )

fletch_external_project_force_install(PACKAGE PNG)
set(PNG_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
get_system_library_name( png png_libname )
if (WIN32)
  set(png_libname "lib${png_libname}")
endif()
set(PNG_LIBRARY "${PNG_ROOT}/lib/${png_libname}" )

file(APPEND ${fletch_CONFIG_INPUT} "
################################_
# PNG
################################
set(PNG_ROOT \${fletch_ROOT})
set(fletch_ENABLED_PNG TRUE)
")
