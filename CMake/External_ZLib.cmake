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
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
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

set(ZLIB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# ZLib
########################################
set(ZLIB_ROOT @ZLIB_ROOT@)
")
