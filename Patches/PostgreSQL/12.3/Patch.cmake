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
  file(COPY ${PostgreSQL_patch}/pg_config.h.win32
    DESTINATION ${PostgreSQL_source}/src/include/
    )
  # file(COPY ${PostgreSQL_patch}/chklocale.c
  #   DESTINATION  ${PostgreSQL_source}/src/port
  #   )
else()
  # These are affectively install targets
  file(COPY ${PostgreSQL_source}/src/backend/catalog/pg_tablespace_d.h
    DESTINATION ${PostgreSQL_source}/src/include/catalog/
    )
  file(COPY ${PostgreSQL_source}/src/backend/catalog/pg_publication_d.h
    DESTINATION ${PostgreSQL_source}/src/include/catalog/
    )
  file(COPY ${PostgreSQL_source}/src/backend/catalog/pg_attribute_d.h
    DESTINATION ${PostgreSQL_source}/src/include/catalog/
    )
  file(COPY ${PostgreSQL_source}/src/backend/utils/errcodes.h
    DESTINATION ${PostgreSQL_source}/src/include/utils/
    )
  file(COPY ${PostgreSQL_source}/src/backend/storage/lmgr/lwlocknames.h
    DESTINATION ${PostgreSQL_source}/src/include/storage/
    )
  file(COPY ${PostgreSQL_source}/src/backend/parser/gram.h
    DESTINATION ${PostgreSQL_source}/src/include/parser/
    )
endif()
