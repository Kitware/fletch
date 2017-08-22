set(the_description "2D Features Framework")
ocv_define_module(features2d opencv_imgproc opencv_flann OPTIONAL opencv_highgui)



####
#   Correcting for a bug for gcc 4.1
#   Optimizations cause a compilation error, so turn them off under specific circumstances.
####
string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE)
if (CMAKE_COMPILER_IS_GNUCC AND CMAKE_BUILD_TYPE STREQUAL "release" )
  if ( ${CMAKE_GCC_REGEX_VERSION} VERSION_LESS 4.2)
    foreach(flags CMAKE_CXX_FLAGS_RELEASE)
      string(REPLACE "-O3" "-O0" ${flags} "${${flags}}")
    endforeach()
  endif()
endif()
