# The SQLite external project for fletch

ExternalProject_Add(SQLite3
  URL ${SQLite3_file}
  URL_MD5 ${SQLite3_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DSQLite3_patch:PATH=${fletch_SOURCE_DIR}/Patches/SQLite3
    -DSQLite3_source:PATH=${fletch_BUILD_PREFIX}/src/SQLite3
    -P ${fletch_SOURCE_DIR}/Patches/SQLite3/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DSQLite3_ENABLE_RTREE:BOOL=True
    -DSQLite3_ENABLE_COLUMN_METADATA:BOOL=True
    -DSQLite3_ENABLE_LOAD_EXTENSIONS:BOOL=True
)

set(SQLite3_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# SQLite3
########################################
set(SQLite3_ROOT \${fletch_ROOT})
")
