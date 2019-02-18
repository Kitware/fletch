cmake_minimum_required(VERSION 2.8)

PROJECT(ZLIB)

SET(ZLIB_MANGLE_PREFIX "" CACHE STRING "Mangle prefix. For example 'cm_zlib_', 'z_', ...")

SET(ZLIB_VERSION_MAJOR "1")
SET(ZLIB_VERSION_MINOR "2")
SET(ZLIB_VERSION_PATCH "9")

INCLUDE_DIRECTORIES(
  "${ZLIB_SOURCE_DIR}"
  "${ZLIB_SOURCE_DIR}"
  "${ZLIB_BINARY_DIR}"
  )

# source files for zlib
SET(ZLIB_SRCS
  adler32.c  compress.c  crc32.c  deflate.c  gzio.c   inffast.c
  inflate.c  inftrees.c  trees.c  uncompr.c  zutil.c
  )

# for windows add the .def and .rc files to the source list
# if building shared libs
IF(WIN32)
  IF(BUILD_SHARED_LIBS)
    SET(ZLIB_DLL 1)
    IF(NOT UNIX)
      IF(NOT BORLAND)
        IF(NOT MINGW)
          CONFIGURE_FILE(zlib.def.in ${ZLIB_BINARY_DIR}/zlib.def)
          SET(ZLIB_SRCS ${ZLIB_SRCS} ${ZLIB_BINARY_DIR}/zlib.def zlib.rc)
        ENDIF(NOT MINGW)
      ENDIF(NOT BORLAND) 
    ENDIF(NOT UNIX)   
  ENDIF(BUILD_SHARED_LIBS)
ENDIF(WIN32)

CONFIGURE_FILE(${ZLIB_SOURCE_DIR}/.NoDartCoverage
  ${ZLIB_BINARY_DIR}/.NoDartCoverage)
CONFIGURE_FILE(${ZLIB_SOURCE_DIR}/zlibDllConfig.h.in
  ${ZLIB_BINARY_DIR}/zlibDllConfig.h)
CONFIGURE_FILE(${ZLIB_SOURCE_DIR}/zlib_mangle.h.in
  ${ZLIB_BINARY_DIR}/zlib_mangle.h)
    
FOREACH(name zlib zconf)
  CONFIGURE_FILE(${ZLIB_SOURCE_DIR}/${name}.h
    ${ZLIB_BINARY_DIR}/${name}.h COPYONLY)
ENDFOREACH(name)

ADD_LIBRARY(zlib ${ZLIB_SRCS})

# To fix compilation problem: relocation R_X86_64_32 against `a local symbol' can not be
# used when making a shared object; recompile with -fPIC
# See http://www.cmake.org/pipermail/cmake/2007-May/014350.html
#
IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  SET_TARGET_PROPERTIES(zlib PROPERTIES COMPILE_FLAGS "-fPIC")
ENDIF()

# Configure install locations.  This allows parent projects to modify
# the install location.
IF(NOT ZLIB_INSTALL_BIN_DIR)
  SET(ZLIB_INSTALL_BIN_DIR bin)
ENDIF()

IF(NOT ZLIB_INSTALL_INCLUDE_DIR)
  SET(ZLIB_INSTALL_INCLUDE_DIR include)
ENDIF()

IF(NOT ZLIB_INSTALL_LIB_DIR)
  SET(ZLIB_INSTALL_LIB_DIR lib)
ENDIF()

IF(NOT ZLIB_INSTALL_DOC_DIR)
  SET(ZLIB_INSTALL_DOC_DIR
    doc/zlib-${ZLIB_VERSION_MAJOR}.${ZLIB_VERSION_MINOR}.${ZLIB_VERSION_PATCH}
    )
ENDIF()

# Install library
INSTALL(TARGETS zlib
  RUNTIME DESTINATION ${ZLIB_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
  LIBRARY DESTINATION ${ZLIB_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
  ARCHIVE DESTINATION ${ZLIB_INSTALL_LIB_DIR} COMPONENT Development
  )

# Install public headers
INSTALL(FILES
  zlib.h
  zconf.h
  ${ZLIB_BINARY_DIR}/zlib_mangle.h
  ${ZLIB_BINARY_DIR}/zlibDllConfig.h
  DESTINATION ${ZLIB_INSTALL_INCLUDE_DIR} COMPONENT Development
  )

INSTALL(FILES Copyright.txt DESTINATION ${ZLIB_INSTALL_DOC_DIR} COMPONENT RuntimeLibraries)
