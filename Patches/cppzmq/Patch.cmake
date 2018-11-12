#+
# This file is called as CMake -P script for the patch step of
# External_cppzmq.cmake to create a nested directory location for the zmq.hpp
# header file.
#-

file(COPY ${cppzmq_patch}/CMakeLists.txt
  DESTINATION ${cppzmq_source}
)
