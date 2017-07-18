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
    ${COMMON_CMAKE_ARGS}
    ${png_cmake_args}
  )

fletch_external_project_force_install(PACKAGE PNG)

set(PNG_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# PNG
################################
set(PNG_ROOT \$\{fletch_ROOT\})

set(fletch_ENABLED_PNG TRUE)
")
