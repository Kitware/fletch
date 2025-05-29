cmake_minimum_required(VERSION 2.8)
project(pq)

set(postgresql_SOURCE_DIR ${pq_SOURCE_DIR}/../../..)

# add sources from different places in the source tree
# takes a place in the tree, and a list of sources
macro(add_sources dir)
  foreach(src ${ARGN})
    list(APPEND pq_SOURCES ${dir}/${src})
  endforeach(src)
endmacro(add_sources)

set(pq_SOURCES)

# add sources from port dir
add_sources(../../port
  getaddrinfo.c
  pgstrcasecmp.c
  pqsignal.c
  thread.c
  inet_aton.c
  crypt.c
  noblock.c
  chklocale.c
  inet_net_ntop.c
  snprintf.c
  strlcpy.c
  dirent.c
  dirmod.c
  pgsleep.c
  open.c
  system.c
  win32error.c
  win32setlocale.c
  )

#add sources from backend dir
if(EXISTS ../../backend/libpq/md5.c)
  # PostgreSQL 9
  add_sources(../../backend/libpq
    md5.c
    ip.c)
else()
  # PostgreSQL 10
  add_sources(../../common
    md5.c
    ip.c)
endif()

#add sources from backend dir
add_sources(../../common/
  fe_memutils.c
  )

# add sources from backend utils mb
add_sources(../../backend/utils/mb
  wchar.c
  encnames.c)

# create .def file
file(READ ${pq_SOURCE_DIR}/libpqdll.def DEF_FILE)
string(REPLACE "LIBRARY LIBPQ" "LIBRARY PQ" DEF_FILE "${DEF_FILE}")
file(WRITE ${pq_BINARY_DIR}/pgdll.def "${DEF_FILE}")


# add sources in this directory
list(APPEND pq_SOURCES
  win32.c
  fe-auth.c
  fe-protocol2.c
  fe-protocol3.c
  fe-connect.c
  fe-exec.c
  fe-lobj.c
  fe-misc.c
  fe-print.c
  fe-secure.c
  libpq-events.c
  pqexpbuffer.c
  pthread-win32.c
  ${pq_BINARY_DIR}/pgdll.def
  )

configure_file(${pq_SOURCE_DIR}/../../include/pg_config.h.win32
  ${pq_BINARY_DIR}/pg_config.h)
configure_file(${pq_SOURCE_DIR}/../../include/pg_config_ext.h.win32
  ${pq_BINARY_DIR}/pg_config_ext.h)
configure_file(${pq_SOURCE_DIR}/../../include/port/win32.h
  ${pq_BINARY_DIR}/pg_config_os.h)
file(WRITE ${pq_BINARY_DIR}/pg_config_paths.h
  "#define SYSCONFDIR \"\"")

add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -DFRONTEND -DWIN32)


include_directories(${pq_BINARY_DIR}
  ${pq_SOURCE_DIR}/../../../src/port
  ${pq_SOURCE_DIR}/../../include
  ${pq_SOURCE_DIR}/../../include/utils
  ${pq_SOURCE_DIR}/../../include/port/win32
  ${pq_SOURCE_DIR}/../../include/port
  ${pq_SOURCE_DIR}/../../include/port/win32_msvc)

add_library(pq ${pq_SOURCES})
if(WIN32)
  set_target_properties(pq PROPERTIES ARCHIVE_OUTPUT_NAME libpq)
endif()
target_link_libraries(pq ws2_32 Secur32)

install(TARGETS pq
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

#
# The include installs were derived by examining CopyIncludeFiles
# in Install.pm in the PostgreSQL distribution.  Server include
# files were ignored.
#
install(FILES
  ${pq_BINARY_DIR}/pg_config.h
  ${pq_BINARY_DIR}/pg_config_os.h
  ${pq_BINARY_DIR}/pg_config_ext.h
  DESTINATION include
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/include/postgres_ext.h
  ${postgresql_SOURCE_DIR}/src/include/pg_config_manual.h
  DESTINATION include
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/include/libpq/libpq-fs.h
  DESTINATION include/libpq
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/interfaces/libpq/libpq-fe.h
  ${postgresql_SOURCE_DIR}/src/interfaces/libpq/libpq-events.h
  DESTINATION include
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/interfaces/libpq/libpq-int.h
  ${postgresql_SOURCE_DIR}/src/interfaces/libpq/pqexpbuffer.h
  DESTINATION include/libpq/internal
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/include/c.h
  ${postgresql_SOURCE_DIR}/src/include/port.h
  ${postgresql_SOURCE_DIR}/src/include/postgres_fe.h
  DESTINATION include/libpq/internal
  )

install(FILES
  ${postgresql_SOURCE_DIR}/src/include/libpq/pqcomm.h
  DESTINATION include/libpq/internal
  )

install(DIRECTORY ${postgresql_SOURCE_DIR}/src/include/catalog
  DESTINATION include/postgresql/server PATTERN "*.h"
  )
