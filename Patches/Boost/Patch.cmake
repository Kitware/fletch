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

file(COPY ${Boost_patch}/add_path.cpp
  DESTINATION ${Boost_source}/tools/bcp/
)


#file(COPY ${Boost_patch}/cas128strong.hpp ${Boost_patch}/gcc-atomic.hpp
#  DESTINATION ${Boost_source}/boost/atomic/detail
#  )

#file(COPY ${Boost_patch}/transform_width.hpp
#  DESTINATION ${Boost_source}/boost/archive/iterators/
#  )

#file(COPY ${Boost_patch}/named_slot_map.hpp
#  DESTINATION ${Boost_source}/boost/signals/detail/
#  )

#file(COPY ${Boost_patch}/named_slot_map.cpp
#  DESTINATION ${Boost_source}/libs/signals/src/
#  )

# Following 3 patches fix compile errors for gcc5.2
# https://svn.boost.org/trac/boost/ticket/10125
#file(COPY ${Boost_patch}/pthread/once_atomic.hpp ${Boost_patch}/pthread/once.hpp
#  DESTINATION ${Boost_source}/boost/thread/pthread/
#  )

#file(COPY ${Boost_patch}/win32/once.hpp
#  DESTINATION ${Boost_source}/boost/thread/win32/
#  )


#file(COPY ${Boost_patch}/build.bat
#  DESTINATION ${Boost_source}/tools/build/v2/engine
#  )
#file(COPY ${Boost_patch}/build.jam
#  DESTINATION ${Boost_source}/tools/build/v2/engine
#  )
#file(COPY ${Boost_patch}/msvc.jam
#  DESTINATION ${Boost_source}/tools/build/v2/tools
#  )
