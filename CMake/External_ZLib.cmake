# The ZLib external project for fletch

ExternalProject_Add(ZLib
  URL ${ZLib_file}
  URL_MD5 ${zlib_md5}
  DOWNLOAD_NAME ${zlib_dlname}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=ON
)

if(WIN32)
  # Copy zlib to zdll for Qt
  ExternalProject_Add_Step(ZLib fixup-install
    COMMAND ${CMAKE_COMMAND} -E copy
      ${fletch_BUILD_INSTALL_PREFIX}/lib/zlib.lib
      ${fletch_BUILD_INSTALL_PREFIX}/lib/zdll.lib
    DEPENDEES install
    )
elseif(NOT APPLE)
  # For Linux machines
  ExternalProject_Add_Step(ZLib fixup-install
    COMMAND ${CMAKE_COMMAND} -E copy
      ${fletch_BUILD_INSTALL_PREFIX}/lib/libzlib.so
      ${fletch_BUILD_INSTALL_PREFIX}/lib/libz.so
    DEPENDEES install
    )
endif()

fletch_external_project_force_install(PACKAGE ZLib STEP_NAMES install fixup-install)

set(ZLIB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# ZLib
########################################
set(ZLIB_ROOT \${fletch_ROOT})

set(fletch_ENABLED_ZLib TRUE)
")
