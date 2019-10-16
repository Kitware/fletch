# The SQLite external project for fletch

ExternalProject_Add(SQLite
  URL ${SQLite_file}
  URL_MD5 ${SQLite_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DSQLite_patch:PATH=${fletch_SOURCE_DIR}/Patches/SQLite
    -DSQLite_source:PATH=${fletch_BUILD_PREFIX}/src/SQLite
    -P ${fletch_SOURCE_DIR}/Patches/SQLite/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DSQLite_ENABLE_RTREE:BOOL=True
    -DSQLite_ENABLE_COLUMN_METADATA:BOOL=True
    -DSQLite_ENABLE_LOAD_EXTENSIONS:BOOL=True
)

set(SQLite_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# SQLite
########################################
set(SQLite_ROOT @SQLite_ROOT@)
")
