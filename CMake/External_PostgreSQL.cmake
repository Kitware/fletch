
if(WIN32)
  set(_PostgreSQL_BUILD_IN_SOURCE_ARG)
  set(ARG
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${fletch_BUILD_INSTALL_PREFIX}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    )
  set(_PostgreSQL_BUILD_INSTALL_ARG)
else()
  set(_PostgreSQL_ARGS_LIBXML2 --without-libxml)

  find_package(Readline)
  if(NOT Readline_FOUND)
    message(WARNING "Can't find readline headers, building PostgreSQL without readline support.\n")
    set(_PostgreSQL_ARGS_READLINE --without-readline)
  endif()

  set(_PostgreSQL_BUILD_IN_SOURCE_ARG BUILD_IN_SOURCE 1)
  set(_PostgreSQL_CONFIGURE_ARG CONFIGURE_COMMAND
    ./configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    ${_PostgreSQL_ARGS_LIBXML2}
    ${_PostgreSQL_ARGS_READLINE}
    )
  set(_PostgreSQL_BUILD_INSTALL_ARG
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )

  option(fletch_BUILD_POSTGRESQL_CONTRIB "Build and install the PostgreSQL contrib modules" off)
endif()

#Always try the patch, it contains the WIN32 logic
set(_PostgreSQL_PATCH_ARG PATCH_COMMAND
  ${CMAKE_COMMAND}
  -DPostgreSQL_patch:PATH=${fletch_SOURCE_DIR}/Patches/PostgreSQL
  -DPostgreSQL_source:PATH=${fletch_BUILD_PREFIX}/src/PostgreSQL
  -DPostgreSQL_MAJOR_VERSION:STRING=${PostgreSQL_MAJOR_VERSION}
  -DBUILD_POSTGRESQL_CONTRIB:BOOL=${BUILD_POSTGRESQL_CONTRIB}
  -P ${fletch_SOURCE_DIR}/Patches/PostgreSQL/Patch.cmake
  )

ExternalProject_Add(PostgreSQL
  URL ${PostgreSQL_url}
  URL_MD5 ${PostgreSQL_md5}
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
  INSTALL_DIR ${fletch_BUILD_INSTALL_PREFIX}
  ${_PostgreSQL_BUILD_IN_SOURCE_ARG}
  ${_PostgreSQL_PATCH_ARG}
  ${_PostgreSQL_CONFIGURE_ARG}
  ${_PostgreSQL_BUILD_INSTALL_ARG}
  ${ARG}
)

if (NOT WIN32)
  if (BUILD_POSTGRESQL_CONTRIB)
    VisionTPL_Require_Make()
    ExternalProject_Add_Step(PostgreSQL build_contrib
      COMMENT "Build the PostgreSQL contrib modules"
      DEPENDEES build
      WORKING_DIRECTORY "${fletch_BUILD_PREFIX}/src/PostgreSQL/contrib"
      COMMAND ${MAKE_EXECUTABLE} && ${MAKE_EXECUTABLE} install
      )
  endif()
endif()

set(PostgreSQL_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)

file(APPEND ${fletch_CONFIG_INPUT} "
########################################
# PostgreSQL
########################################
set(PostgreSQL_ROOT @PostgreSQL_ROOT@)
set(PostgreSQL_MAJOR_VERSION @PostgreSQL_MAJOR_VERSION@)
")

