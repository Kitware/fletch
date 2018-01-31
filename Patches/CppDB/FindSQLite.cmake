#ckwg +4
# Copyright 2012 by Kitware, Inc. All Rights Reserved. Please refer to
# KITWARE_LICENSE.TXT for licensing information, or contact General Counsel,
# Kitware, Inc., 28 Corporate Drive, Clifton Park, NY 12065.

# Locate the system installed SQLite
#
# The following variables will guide the build:
#
# SQLite_ROOT        - Set to the install prefix of the SQLite library
#
# The following variables will be set:
#
# SQLite_FOUND       - Set to true if SQLite can be found
# SQLite_INCLUDE_DIR - The path to the SQLite header files
# SQLite_LIBRARY     - The full path to the SQLite library
# SQLite_LIBRARIES   - SQLite library and it's link dependencies
# SQLite_HAS_COLUMN_METADATA - Whether the column metadata API is available
# SQLite_HAS_RTREE           - Whether the sqlite library has rtree support

if( SQLite_DIR )
  if( SQLite_FIND_VERSION )
    find_package( SQLite ${SQLite_FIND_VERSION} NO_MODULE)
  else()
    find_package( SQLite NO_MODULE)
  endif()
elseif( NOT SQLite_FOUND )

  # Backup the previous root path
  if(SQLite_ROOT)
    set(_CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})
    set(CMAKE_FIND_ROOT_PATH ${SQLite_ROOT})
    set(_SQLite_ROOT_OPTS ONLY_CMAKE_FIND_ROOT_PATH)
  endif()

  find_path( SQLite_INCLUDE_DIR sqlite3.h ${_SQLite_ROOT_OPTS} )
  find_library( SQLite_LIBRARY sqlite3 ${_SQLite_ROOT_OPTS})

  # Restore the original root path
  if(SQLite_ROOT)
    set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})
  endif()

  include( FindPackageHandleStandardArgs )
  FIND_PACKAGE_HANDLE_STANDARD_ARGS( SQLite SQLite_INCLUDE_DIR SQLite_LIBRARY )

  # Process the version information
  if( SQLITE_FOUND )
    # Determine the SQLite version found
    file( READ ${SQLite_INCLUDE_DIR}/sqlite3.h SQLite_INCLUDE_FILE )
    string( REGEX REPLACE
      ".*# *define *SQLITE_VERSION *\\\"([0-9\\.]+)\\\".*" "\\1"
      SQLite_VERSION "${SQLite_INCLUDE_FILE}" )
    string( REGEX REPLACE 
      "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" 
      SQLite_VERSION_MAJOR "${SQLite_VERSION}" )
    string( REGEX REPLACE 
      "[0-9]+\\.([0-9]+)\\.[0-9]+" "\\1" 
      SQLite_VERSION_MINOR "${SQLite_VERSION}" )
    string( REGEX REPLACE 
      "[0-9]+\\.[0-9]+\\.([0-9])+" "\\1" 
      SQLite_VERSION_PATCH "${SQLite_VERSION}" )

    # Determine version compatibility
    if( SQLite_FIND_VERSION )
      if( SQLite_FIND_VERSION_EXACT )
        if( SQLite_FIND_VERSION VERSION_EQUAL SQLite_VERSION )
          message( STATUS "SQLite version: ${SQLite_VERSION}" )
          set( SQLite_FOUND TRUE )
        endif()
      else()
        if( (SQLite_FIND_VERSION VERSION_LESS  SQLite_VERSION) OR
            (SQLite_FIND_VERSION VERSION_EQUAL SQLite_VERSION) )
            message( STATUS "SQLite version: ${SQLite_VERSION}" )
          set( SQLite_FOUND TRUE )
        endif()
      endif()
    else()
      message( STATUS "SQLite version: ${SQLite_VERSION}" )
      set( SQLite_FOUND TRUE )
    endif()
    unset( SQLITE_FOUND )

    find_package(Threads REQUIRED)
    set(SQLite_LIBRARIES ${SQLite_LIBRARY} ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})

    include(CheckFunctionExists)
    set(CMAKE_REQUIRED_LIBRARIES ${SQLite_LIBRARIES})
    CHECK_FUNCTION_EXISTS("sqlite3_column_database_name"    SQLite_HAS_COLUMN_METADATA)
    CHECK_FUNCTION_EXISTS("sqlite3_rtree_geometry_callback" SQLite_HAS_RTREE)
    unset(CMAKE_REQUIRED_LIBRARIES)

  endif()
endif()
