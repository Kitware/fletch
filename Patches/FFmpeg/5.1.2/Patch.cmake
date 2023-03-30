#+
# This file is called as CMake -P script for the patch step of
# External_FFmpeg.cmake.
#-

# Add patch to read KLV profile from descriptors.
configure_file(
  ${FFmpeg_patch}/mpegts.c
  ${FFmpeg_source}/libavformat/
  COPYONLY
 )
