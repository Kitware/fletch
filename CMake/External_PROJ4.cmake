
# Version 6 requires sqlite now.
if (PROJ4_SELECT_VERSION STRGREATER "6")
  if(fletch_ENABLE_SQLite3)
    #If we're building libz, then use it.
    list(APPEND PROJ_DEPENDS SQLite3)
    set(PROJ_ARGS_SQLITE3 -DSQLITE3_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/share/cmake)
  else()
    find_package(SQLite3 REQUIRED)
    set(PROJ_ARGS_SQLITE3 -DSQLITE3_INCLUDE_DIR:PATH=${SQLi)
  endif()
endif()

ExternalProject_Add(PROJ4
  URL ${PROJ4_file}
  URL_MD5 ${PROJ4_md5}
  DEPENDS ${PROJ_DEPENDS}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DPROJ_LIB_SUBDIR:STRING=lib
    -DPROJ_INCLUDE_SUBDIR:STRING=include
    -DDATADIR:STRING=share/proj
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_LIBPROJ_SHARED:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
    -DPROJ_TESTS:BOOL=OFF
    -DPROJ4_ENABLE_TESTS:BOOL=OFF
  )

fletch_external_project_force_install(PACKAGE PROJ4)

set(PROJ4_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(PROJ4_INCLUDE_DIR "${PROJ4_ROOT}/include" CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# PROJ4
########################################
set(PROJ4_ROOT \${fletch_ROOT})
set(PROJ4_INCLUDE_DIR \${fletch_ROOT}/include)
set(PROJ_INCLUDE_DIR \${fletch_ROOT}/include)

set(fletch_ENABLED_PROJ4 TRUE)
")
