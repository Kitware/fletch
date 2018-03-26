# The CppDB external project
if(fletch_ENABLE_PostgreSQL)
  set(_CppDB_ARGS_PostgreSQL -DPostgreSQL_ROOT=${PostgreSQL_ROOT})
  list(APPEND _CppDB_DEPENDS PostgreSQL)
else()
  find_package(PostgreSQL)
  if(NOT PostgreSQL_FOUND)
    message(STATUS "Unable to find a suitable PostgreSQL.")
  else()
    set(_CppDB_ARGS_PostgreSQL
      -DPostgreSQL_INCLUDE_DIR=${PostgreSQL_INCLUDE_DIR}
      -DPostgreSQL_TYPE_INCLUDE_DIR=${PostgreSQL_TYPE_INCLUDE_DIR}
      -DPostgreSQL_LIBRARY=${PostgreSQL_LIBRARY}
      )
  endif()
endif()

ExternalProject_Add(CppDB
  DEPENDS ${_CppDB_DEPENDS}
  URL ${CppDB_url}
  URL_MD5 ${CppDB_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  PATCH_COMMAND ${CMAKE_COMMAND}
    -DCppDB_patch=${fletch_SOURCE_DIR}/Patches/CppDB
    -DCppDB_source=${fletch_BUILD_PREFIX}/src/CppDB
    -P ${fletch_SOURCE_DIR}/Patches/CppDB/Patch.cmake
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${fletch_BUILD_INSTALL_PREFIX}
    ${_CppDB_ARGS_PostgreSQL}
)

set(CppDB_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# CppDB
########################################
set(CppDB_ROOT @CppDB_ROOT@)
")

