cmake_minimum_required(VERSION 2.8.10)

# Retrieve the list of CMAKE variables
include("${CMAKE_VARS_FILE}")

# Hard code this until we can require a newer cmake version
# cmake_host_system_information(RESULT NCPU QUERY NUMBER_OF_LOGICAL_CORES)
set(NCPU 4)

# Translate between CMake compiler info to Boost.Build toolset info
if(CMAKE_CXX_COMPILER_ID MATCHES Intel)
  set(BOOST_TOOLSET intel)
elseif(CMAKE_CXX_COMPILER_ID MATCHES PathScale)
  set(BOOST_TOOLSET pathscale)
elseif(CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
  set(BOOST_TOOLSET clang-darwin)
elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  if(APPLE)
    set(BOOST_TOOLSET clang-darwin)
  else()
    set(BOOST_TOOLSET clang)
  endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES SunPro)
  set(BOOST_TOOLSET sun)
elseif(CMAKE_CXX_COMPILER_ID MATCHES GNU)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
    set(BOOST_CXX_STANDARD "cxxflags=-std=c++98")
  else()
    set(BOOST_CXX_STANDARD "cxxflags=-std=c++11")
  endif()
  set(BOOST_TOOLSET gcc)
elseif(CMAKE_CXX_COMPILER_ID MATCHES PGI)
  set(BOOST_TOOLSET pgi)
elseif(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.10)
    set(BOOST_TOOLSET msvc-14.1)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19)
    set(BOOST_TOOLSET msvc-14.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 18)
    set(BOOST_TOOLSET msvc-12.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 17)
    set(BOOST_TOOLSET msvc-11.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 16)
    set(BOOST_TOOLSET msvc-10.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 15)
    set(BOOST_TOOLSET msvc-9.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 14)
    set(BOOST_TOOLSET msvc-8.0)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 13.1)
    set(BOOST_TOOLSET msvc-7.1)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 13)
    set(BOOST_TOOLSET msvc-7.0)
  else() #(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 12)
    set(BOOST_TOOLSET msvc-6.0)
  endif()
else()
  message(FATAL_ERROR "Unsupported compiler ${CMAKE_CXX_COMPILER_ID} on ${CMAKE_SYSTEM_NAME}")
endif()

if(${BUILD_SHARED_LIBS})
  list(APPEND B2_FLAVOR_ARGS link=shared)
else()
  list(APPEND B2_FLAVOR_ARGS link=static)
endif()

# 32 or 64 bit
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
  list(APPEND B2_FLAVOR_ARGS address-model=32)
else()
  list(APPEND B2_FLAVOR_ARGS address-model=64)
endif()

# Always build with a shared runtime libraries (libc, etc.)
list(APPEND B2_FLAVOR_ARGS runtime-link=shared)

# Always build with multi-threading support
list(APPEND B2_FLAVOR_ARGS threading=multi)

if (NOT fletch_BUILD_WITH_PYTHON)
  # Keeps BCP from trying to build Python anyway
  set(_fletch_boost_python_arg "--without-python")
endif()

# Compile the complete list of B2 args
set(B2_ARGS
  --abbreviate-paths -j${NCPU} --toolset=${BOOST_TOOLSET} --disable-icu ${_fletch_boost_python_arg}
  -sNO_BZIP2=1 ${BOOST_CXX_STANDARD}
  ${B2_FLAVOR_ARGS}
)

# Wrapper for process execution that provides consistent log and error handling
function(execute_command_wrapper TAG WD CMD)
  message("${TAG}: Running")

  string(REGEX REPLACE ";" " " ARGN_DISPLAY "${ARGN}")
  file(WRITE ${CMAKE_BINARY_DIR}/${TAG}_cmd.txt "
Working Directory: ${WD}
Command: ${CMD} ${ARGN_DISPLAY}
")

  # Needed so MSVC doesn't bail on expected errors
  set(_vsconsoleoutput $ENV{vsconsoleoutput})
  set(_VS_UNICODE_OUTPUT $ENV{VS_UNICODE_OUTPUT})
  set(ENV{vsconsoleoutput} 1)
  set(ENV{VS_UNICODE_OUTPUT})

  execute_process(
    COMMAND ${CMD} ${ARGN}
    WORKING_DIRECTORY ${WD}
    OUTPUT_FILE ${CMAKE_BINARY_DIR}/${TAG}_out.txt
    ERROR_FILE ${CMAKE_BINARY_DIR}/${TAG}_err.txt
    OUTPUT_VARIABLE VAR_OUTPUT
    ERROR_VARIABLE VAR_ERROR
    RESULT_VARIABLE VAR_RESULT
  )

  set(ENV{vsconsoleoutput} ${_vsconsoleoutput})
  set(ENV{VS_UNICODE_OUTPUT} ${_VS_UNICODE_OUTPUT})

  # Dump error messages if appropriate
  if(NOT ${VAR_RESULT} EQUAL 0)
    message("${TAG}:Command: ${CMAKE_BINARY_DIR}/${TAG}_cmd.txt")
    message("${TAG}:Output : ${CMAKE_BINARY_DIR}/${TAG}_out.txt")
    message("${TAG}:Error  : ${CMAKE_BINARY_DIR}/${TAG}_err.txt")
    message(FATAL_ERROR "${TAG}:Failure: Return ${VAR_RETURN}")
  endif()

  # Cleanup if the build didn't fail
  file(REMOVE ${CMAKE_BINARY_DIR}/${TAG}_cmd.txt)
  file(REMOVE ${CMAKE_BINARY_DIR}/${TAG}_out.txt)
  file(REMOVE ${CMAKE_BINARY_DIR}/${TAG}_err.txt)
  message("${TAG}: Complete")
endfunction()
