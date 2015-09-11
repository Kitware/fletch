string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE)

option(JSON_STRICT "" OFF)
mark_as_advanced(JSON_STRICT)

if(CMAKE_BUILD_TYPE STREQUAL "debug")
  option(JSON_DEBUG "" ON)
else()
  option(JSON_DEBUG "" OFF)
endif()
mark_as_advanced(JSON_DEBUG)

option(JSON_ISO_STRICT "" OFF)
mark_as_advanced(JSON_ISO_STRICT)

option(JSON_SAFE "" ON)
mark_as_advanced(JSON_SAFE)

option(JSON_STDERROR "" OFF)
mark_as_advanced(JSON_STDERROR)

option(JSON_PREPARSE "" OFF)
mark_as_advanced(JSON_PREPARSE)

if(CMAKE_BUILD_TYPE STREQUAL "minsizerel")
  option(JSON_LESS_MEMORY "" ON)
else()
  option(JSON_LESS_MEMORY "" OFF)
endif()
mark_as_advanced(JSON_LESS_MEMORY)

option(JSON_UNICODE "" OFF)
mark_as_advanced(JSON_UNICODE)

option(JSON_REF_COUNT "" ON)
mark_as_advanced(JSON_REF_COUNT)

option(JSON_BINARY "" ON)
mark_as_advanced(JSON_BINARY)

option(JSON_EXPOSE_BASE64 "" ON)
mark_as_advanced(JSON_EXPOSE_BASE64)

option(JSON_ITERATORS "" ON)
mark_as_advanced(JSON_ITERATORS)

option(JSON_STREAM "" ON)
mark_as_advanced(JSON_STREAM)

option(JSON_MEMORY_CALLBACKS "" OFF)
mark_as_advanced(JSON_MEMORY_CALLBACKS)

option(JSON_MEMORY_MANAGE "" OFF)
mark_as_advanced(JSON_MEMORY_MANAGE)

option(JSON_MUTEX_CALLBACKS "" OFF)
mark_as_advanced(JSON_MUTEX_CALLBACKS)

option(JSON_MUTEX_MANAGE "" OFF)
mark_as_advanced(JSON_MUTEX_MANAGE)

option(JSON_NO_C_CONSTS "" OFF)
mark_as_advanced(JSON_NO_C_CONSTS)

option(JSON_OCTAL "" OFF)
mark_as_advanced(JSON_OCTAL)

set(JSON_WRITE_PRIORITY "MED" CACHE STRING "")
mark_as_advanced(JSON_WRITE_PRIORITY)

set(JSON_READ_PRIORITY "HIGH" CACHE STRING "")
mark_as_advanced(JSON_READ_PRIORITY)

if(WIN32)
  set(JSON_NEWLINE "\\r\\n" CACHE STRING "")
else()
  set(JSON_NEWLINE "\\n" CACHE STRING "")
endif()
mark_as_advanced(JSON_NEWLINE)

option(JSON_ESCAPE_WRITES "" ON)
mark_as_advanced(JSON_ESCAPE_WRITES)

option(JSON_COMMENTS "" ON)
mark_as_advanced(JSON_COMMENTS)

option(JSON_WRITE_BASH_COMMENTS "" OFF)
mark_as_advanced(JSON_WRITE_BASH_COMMENTS)

option(JSON_WRITE_SINGLE_LINE_COMMENTS "" OFF)
mark_as_advanced(JSON_WRITE_SINGLE_LINE_COMMENTS)

option(JSON_VALIDATE "" ON)
mark_as_advanced(JSON_VALIDATE)

option(JSON_CASE_INSENSITIVE_FUNCTIONS "" ON)
mark_as_advanced(JSON_CASE_INSENSITIVE_FUNCTIONS)

set(JSON_INDEX_TYPE "unsigned int" CACHE STRING "")
mark_as_advanced(JSON_INDEX_TYPE)

set(JSON_BOOL_TYPE "char" CACHE STRING "")
mark_as_advanced(JSON_BOOL_TYPE)

set(JSON_NUMBER_TYPE "double" CACHE STRING "")
mark_as_advanced(JSON_NUMBER_TYPE)

option(JSON_UNIT_TEST "" OFF)
mark_as_advanced(JSON_UNIT_TEST)

option(JSON_NO_EXCEPTIONS "" OFF)
mark_as_advanced(JSON_NO_EXCEPTIONS)

option(JSON_CASTABLE "" ON)
mark_as_advanced(JSON_CASTABLE)

set(JSON_SECURITY_MAX_NEST_LEVEL "128" CACHE STRING "")
mark_as_advanced(JSON_SECURITY_MAX_NEST_LEVEL)

set(JSON_SECURITY_MAX_STRING_LENGTH "33554432" CACHE STRING "")
mark_as_advanced(JSON_SECURITY_MAX_STRING_LENGTH)

set(JSON_SECURITY_MAX_STREAM_OBJECTS "128" CACHE STRING "")
mark_as_advanced(JSON_SECURITY_MAX_STREAM_OBJECTS)

