#+
# This file is called as CMake -P script for the patch step of
# External_FFmpeg.cmake.
#-


# Adds patch to define __STDC_CONSTANT_MACROS and include <stdint.h>
# This patch is for non-windows systems
configure_file(
  ${FFmpeg_patch}/common.h
  ${FFmpeg_source}/libavutil/common.h
  COPYONLY
)

# Adds patch to fix invalid regex
# This patch is needed on newer compilers
configure_file(
  ${FFmpeg_patch}/texi2pod.pl
  ${FFmpeg_source}/doc/
  COPYONLY
)
