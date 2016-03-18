cmake_minimum_required(VERSION 2.8)
project(Snappy)

set(snappy_include
  snappy.h
  snappy-sinksource.h
  snappy-stubs-public.h
  snappy-c.h)
set(snappy_source
  snappy-internal.h
  snappy-stubs-internal.h
  snappy-test.h
  snappy.cc
  snappy-sinksource.cc
  snappy-stubs-internal.cc
  snappy-c.cc)

add_library(snappy SHARED ${snappy_include} ${snappy_source})

install(FILES ${snappy_include} DESTINATION include)

install( TARGETS snappy
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
