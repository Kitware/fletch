cmake_minimum_required(VERSION 2.8)
project(cppzmq)

# Installing to two locations as some things want one or the other for
# whatever reason.
install(FILES zmq.hpp
  DESTINATION include
)
install(FILES zmq.hpp
  DESTINATION include/zeromq
)
