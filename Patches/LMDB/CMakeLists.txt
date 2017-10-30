cmake_minimum_required(VERSION 2.8)
project(LMDB C)

set(lmdb_include libraries/liblmdb/lmdb.h)
set(lmdb_source
  libraries/liblmdb/mdb.c
  libraries/liblmdb/midl.h
  libraries/liblmdb/midl.c
  )

add_library(lmdb SHARED ${lmdb_include} ${lmdb_source})

install(FILES ${lmdb_include} DESTINATION include)

install( TARGETS lmdb
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
