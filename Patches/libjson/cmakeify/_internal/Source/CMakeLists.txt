include_directories(JSONDefs)

add_library(json
  JSONAllocator.h     JSONAllocator.cpp
  JSONChildren.h      JSONChildren.cpp
  JSONDebug.h         JSONDebug.cpp
  JSONDefs.h
  JSONGlobals.h
                      JSONIterators.cpp
  JSONMemory.h        JSONMemory.cpp
  JSONMemoryPool.h
  JSONNode.h          JSONNode.cpp
                      JSONNode_Mutex.cpp
  JSONPreparse.h      JSONPreparse.cpp
  JSONSharedString.h
  JSONSingleton.h
  JSONStream.h        JSONStream.cpp
  JSONValidator.h     JSONValidator.cpp
  JSONWorker.h        JSONWorker.cpp
                      JSONWriter.cpp
  JSON_Base64.h
  NumberToString.h

  internalJSONNode.h  internalJSONNode.cpp

  libjson.cpp
)
set_target_properties(json PROPERTIES
  OUTPUT_NAME  "${JSON_LIBNAME}"
  VERSION      "${libjson_VERSION}"
  SOVERSION    "${libjson_VERSION}"
)
install(TARGETS json
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
)
file(GLOB JSON_HEADERS *.h)
install(FILES ${JSON_HEADERS} DESTINATION include/${JSON_LIBNAME}/_internal/Source)
install(DIRECTORY JSONDefs DESTINATION include/${JSON_LIBNAME}/_internal/Source)
install(DIRECTORY ../Dependencies DESTINATION include/${JSON_LIBNAME}/_internal)
