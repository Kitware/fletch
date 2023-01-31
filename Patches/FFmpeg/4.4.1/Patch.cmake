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

# Add patch to read KLV profile from descriptors.
configure_file(
  ${FFmpeg_patch}/mpegts.c
  ${FFmpeg_source}/libavformat/
  COPYONLY
 )

# Add patch to write unregistered SEI user data.
configure_file(
  ${FFmpeg_patch}/libx264.c
  ${FFmpeg_source}/libavcodec/
  COPYONLY
)
configure_file(
  ${FFmpeg_patch}/libx265.c
  ${FFmpeg_source}/libavcodec/
  COPYONLY
)
configure_file(
  ${FFmpeg_patch}/nvenc.c
  ${FFmpeg_source}/libavcodec/
  COPYONLY
)
configure_file(
  ${FFmpeg_patch}/nvenc.h
  ${FFmpeg_source}/libavcodec/
  COPYONLY
)
