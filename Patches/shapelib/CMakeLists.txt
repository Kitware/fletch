project(shapelib)

cmake_minimum_required( VERSION 2.8 )

set( SHAPELIB_VERSION 1.3.0 )

if( NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY )
  set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${shapelib_BINARY_DIR}/lib )
endif()
if( NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY )
  set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${shapelib_BINARY_DIR}/lib )
endif()
if( NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY )
  set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${shapelib_BINARY_DIR}/bin )
endif()

add_library( shp SHARED
  shapefil.h
  shpopen.c
  shptree.c
  dbfopen.c
  safileio.c
)

set_target_properties( shp PROPERTIES
  DEFINE_SYMBOL SHAPELIB_DLLEXPORT
  VERSION ${SHAPELIB_VERSION} SOVERSION ${SHAPELIB_VERSION}
)
install( TARGETS shp
  # EXPORT vidtk
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )
install( FILES shapefil.h DESTINATION include )

add_executable( shpcreate shpcreate.c )
target_link_libraries( shpcreate shp )
#install( TARGETS shpcreate RUNTIME DESTINATION bin )

add_executable( shpadd shpadd.c )
target_link_libraries( shpadd shp )
#install( TARGETS shpadd RUNTIME DESTINATION bin )

add_executable( shpdump shpdump.c )
target_link_libraries( shpdump shp )
#install( TARGETS shpdump RUNTIME DESTINATION bin )

add_executable( shprewind shprewind.c )
target_link_libraries( shprewind shp )
#install( TARGETS shprewind RUNTIME DESTINATION bin )

add_executable( dbfcreate dbfcreate.c )
target_link_libraries( dbfcreate shp )
#install( TARGETS shprewind RUNTIME DESTINATION bin )

add_executable( dbfadd dbfadd.c )
target_link_libraries( dbfadd shp )
#install( TARGETS dbfadd RUNTIME DESTINATION bin )

add_executable( dbfdump dbfdump )
target_link_libraries( dbfdump shp )
install( TARGETS dbfdump RUNTIME DESTINATION bin )

add_executable( shputils shputils.c )
target_link_libraries( shputils shp )
#install( TARGETS shputils RUNTIME DESTINATION bin )

add_executable( shptreedump shptreedump.c )
target_link_libraries( shptreedump shp )
#install( TARGETS shptreedump RUNTIME DESTINATION bin )

# Configure the internal config
#configure_file(
#  "${shapelib_SOURCE_DIR}/SHAPELIBConfig.cmake.in"
#  "SHAPELIBConfig.cmake"
#)
#set( SHAPELIB_DIR "${CMAKE_CURRENT_BINARY_DIR}"
#     CACHE INTERNAL "Build directory for SHAPELIB" )

# Add to the global export file
#file(APPEND "${VIDTK_EXPORT_FILE}" "
#set( SHAPELIB_FOUND TRUE )
#set( SHAPELIB_INCLUDE_DIR \"${shapelib_SOURCE_DIR}\" )
#set( SHAPELIB_LIBRARY shp )
#")
#export( TARGETS shp APPEND FILE "${VIDTK_EXPORT_FILE}" )

#file(APPEND "${VIDTK_EXPORT_INSTALL_FILE}" "
#set( SHAPELIB_FOUND TRUE )
#set( SHAPELIB_INCLUDE_DIR \"\${_VIDTK_ROOT}/include\" )
#set( SHAPELIB_LIBRARY shp )
#")
