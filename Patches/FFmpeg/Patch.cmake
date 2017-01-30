#+
# This file is called as CMake -P script for the patch step of
# External_FFMpeg.cmake.
#-


configure_file(
  ${FFmpeg_patch}/common.h
  ${FFmpeg_source}/libavutil/common.h
  COPYONLY
)
