#+
# This file is called as CMake -P script for the patch step of
# External_FFmpeg.cmake.
#-

# Add patch to write KLV descriptors as required by MISB 1402.
configure_file(
  ${FFmpeg_patch}/mpegtsenc.c
  ${FFmpeg_source}/libavformat/
  COPYONLY
)
