# PNG External project

# ZLIB
add_package_dependency(
  PACKAGE PNG
  PACKAGE_DEPENDENCY ZLib
  PACKAGE_DEPENDENCY_ALIAS ZLIB
)
if(NOT ZLIB_FOUND)
  set(ZLIB_INCLUDE_DIRS ${fletch_BUILD_INSTALL_PREFIX}/include)
  get_system_library_name(zlib zlib_lib)
  set(ZLIB_LIBRARIES ${fletch_BUILD_INSTALL_PREFIX}/lib/${zlib_lib})
endif()
set(png_cmake_args ${png_cmake_args}
  -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIRS}
  -DZLIB_LIBRARY:PATH=${ZLIB_LIBRARIES}
  )


ExternalProject_Add(PNG
  DEPENDS ${PNG_DEPENDS}
  URL ${PNG_url}
  URL_MD5 ${PNG_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy
    ${fletch_SOURCE_DIR}/Patches/PNG/CMakeLists.txt
    ${fletch_BUILD_PREFIX}/src/PNG/CMakeLists.txt
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    ${png_cmake_args}
  )

set(PNG_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
if (WIN32)
  set(PNG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/libpng.lib)
elseif(APPLE)
  set(PNG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/libpng.dylib)
else()
  set(PNG_LIBRARY ${fletch_BUILD_INSTALL_PREFIX}/lib/libpng.so)
endif()

file(APPEND ${fletch_CONFIG_INPUT} "
################################
# PNG
################################
set(PNG_ROOT @PNG_ROOT@)
set(PNG_LIBRARY @PNG_LIBRARY@)
set(fletch_ENABLED_PNG TRUE)
")
