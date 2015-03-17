# This file is called as CMake -P script for the patch step of
# External_Boost.cmake.
# It fixes:
# include/boost/atomic/detail/gcc-atomic.hpp and
# include/boost/atomic/detail/cas128strong.hpp
# The release does not handle 128 bit correctly and fails in clang >= 3.4
#
# It also fixes:
# boost/archive/iterators/transform_width.hpp
# This file failed to compile with VS12 (VS2013)

file(COPY ${Boost_patch}/cas128strong.hpp ${Boost_patch}/gcc-atomic.hpp
  DESTINATION ${Boost_source}/boost/atomic/detail
)

file(COPY ${Boost_patch}/transform_width.hpp
  DESTINATION ${Boost_source}/boost/archive/iterators/
)
