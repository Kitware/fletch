
if(fletch_ENABLE_SQLite3)
  set(PROJ_ARGS_SQLite3
    -DSQLite3_DIR:PATH=${fletch_BUILD_INSTALL_PREFIX}/share/cmake
    -DEXE_SQLITE3:PATH=${fletch_BUILD_INSTALL_PREFIX}/bin/sqlite3_exe
    )
  list(APPEND PROJ_DEPENDS SQLite3)
else()
  find_package(SQLite3 REQUIRED)
endif()

# Latest version of PROJ requires libtiff
if (PROJ_version VERSION_EQUAL 9.6.2)
  if(fletch_ENABLE_libtiff)
    message(STATUS "PROJ depending on internal libtiff")
    list(APPEND PROJ_DEPENDS libtiff)
  else()
    find_package(TIFF REQUIRED)
  endif()
endif()

ExternalProject_Add(PROJ
  DEPENDS ${PROJ_DEPENDS}
  URL ${PROJ_file}
  URL_MD5 ${PROJ_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    ${PROJ_ARGS_SQLite3}
    -DCMAKE_INSTALL_RPATH:PATH=<INSTALL_DIR>/lib
    -DPROJ_LIB_SUBDIR:STRING=lib
    -DPROJ_INCLUDE_SUBDIR:STRING=include
    -DDATADIR:STRING=share/proj
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_LIBPROJ_SHARED:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
    -DPROJ_TESTS:BOOL=OFF
  )

fletch_external_project_force_install(PACKAGE PROJ)

set(PROJ_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(PROJ4_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
set(PROJ_INCLUDE_DIR "${PROJ4_ROOT}/include" CACHE PATH "")
set(PROJ4_INCLUDE_DIR "${PROJ4_ROOT}/include" CACHE PATH "")

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# PROJ4
########################################
set(PROJ4_ROOT \${fletch_ROOT})
set(PROJ_ROOT \${fletch_ROOT})
set(PROJ4_INCLUDE_DIR \${fletch_ROOT}/include)
set(PROJ_INCLUDE_DIR \${fletch_ROOT}/include)

set(fletch_ENABLED_PROJ TRUE)
")
