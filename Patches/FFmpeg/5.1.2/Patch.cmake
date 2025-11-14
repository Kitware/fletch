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

# Add patch to adapt to changing Vulkan API.
configure_file(
  ${FFmpeg_patch}/hwcontext_vulkan.c
  ${FFmpeg_source}/libavutil/
  COPYONLY
 )

# Add patch to allow prevent errors related to AVIO_FLAG_NONBLOCKING
configure_file(
  ${FFmpeg_patch}/aviobuf.c
  ${FFmpeg_source}/libavformat/
  COPYONLY
 )
configure_file(
  ${FFmpeg_patch}/format.c
  ${FFmpeg_source}/libavformat/
  COPYONLY
 )
