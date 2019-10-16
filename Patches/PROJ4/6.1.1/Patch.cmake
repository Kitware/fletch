#+
# This file is called as CMake -P script for the patch step of
# External_PROJ4.cmake
#+


file(COPY ${PROJ4_patch}/FindSqlite3.cmake
  DESTINATION ${PROJ4_source}/cmake
  )
