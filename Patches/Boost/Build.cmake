include(${CMAKE_CURRENT_LIST_DIR}/Common.cmake)

message("Boost.Build: Using toolset=${BOOST_TOOLSET}")

if(WIN32)
  set(BOOTSTRAP ${Boost_BUILD_DIR}/bootstrap.bat)
else()
  set(BOOTSTRAP ${Boost_BUILD_DIR}/bootstrap.sh)
endif()

if(fletch_BUILD_WITH_PYTHON AND NOT WIN32)
  set(BOOTSTRAP_ARGS "--with-python=${PYTHON_EXECUTABLE}")
endif()

execute_command_wrapper(
  "Boost.Build.Bootstrap"
  ${Boost_BUILD_DIR}
  ${BOOTSTRAP} ${BOOTSTRAP_ARGS}
)

if(fletch_BUILD_WITH_PYTHON)
  set(B2_PYTHON_ARGS "include=${PYTHON_INCLUDE_DIR}")
endif()

# Determine debug / release
string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE)
if(NOT CMAKE_BUILD_TYPE STREQUAL "debug") # adjust for relwithdebinfo
  set(CMAKE_BUILD_TYPE "release")
endif()
message("Boost.Build.B2: Using variant=${CMAKE_BUILD_TYPE}")

execute_command_wrapper(
  "Boost.Build.B2"
  ${Boost_BUILD_DIR}
  ${Boost_BUILD_DIR}/b2${CMAKE_EXECUTABLE_SUFFIX}
  variant=${CMAKE_BUILD_TYPE} ${B2_ARGS} ${B2_PYTHON_ARGS}
)
