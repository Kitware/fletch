#+
# This file is called as CMake -P script for the patch step of
# External_PostgreSQL.cmake on Windows platforms.  On Windows, for now,
# we're only interested in building the PostgreSQL client library libpq.  To
# faciliate this (since the PostgreSQL build for just libpq is somewhat
# complex) we copy a CMakeLists.txt into the correct directory and build with
# that.
#
# PostgreSQL_patch and PostgreSQL_source are defined on the command line along
# with the call.
#-

if(WIN32)
  file(WRITE ${PostgreSQL_source}/CMakeLists.txt "
add_subdirectory(src)
")
  file(WRITE ${PostgreSQL_source}/src/CMakeLists.txt "
add_subdirectory(interfaces)
")
  file(WRITE ${PostgreSQL_source}/src/interfaces/CMakeLists.txt "
add_subdirectory(libpq)
")
  file(COPY ${PostgreSQL_patch}/CMakeLists.txt
    DESTINATION ${PostgreSQL_source}/src/interfaces/libpq
    )
  file(COPY ${PostgreSQL_patch}/chklocale.c
    DESTINATION  ${PostgreSQL_source}/src/port
    )
else()
  if (PostgreSQL_MAJOR_VERSION STREQUAL "9.5" AND BUILD_POSTGRESQL_CONTRIB)
    file(REMOVE_RECURSE ${PostgreSQL_source}/contrib/cube)
    file(COPY ${PostgreSQL_patch}/cube DESTINATION ${PostgreSQL_source}/contrib/)
  endif()
endif()

#This patch is valid for any version of PostgreSQL through 2018-04-19
file(COPY
  ${PostgreSQL_patch}/src/bin/pg_rewind/copy_fetch.c
  DESTINATION
  ${PostgreSQL_source}/src/bin/pg_rewind/
  )
