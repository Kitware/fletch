# Install rules for FFmpeg
#
# This file is specific to the windows FFMPEG installation step
#

if(NOT WIN32)
  message(FATAL_ERROR "Install step specific to WIN32")
endif()

file(GLOB ffmpeg_dev_files ${FFmpeg_dev_SOURCE}/*)
file(GLOB ffmpeg_shared_files ${FFmpeg_shared_SOURCE}/*)
file(COPY
  ${ffmpeg_dev_files}
  ${ffmpeg_shared_files}
  DESTINATION ${FFmpeg_INSTALL}
)

# Also copy the *.lib files to /bin
file(GLOB_RECURSE ffmpeg_lib_files ${FFmpeg_dev_SOURCE}/*.lib)
file(COPY
  ${ffmpeg_lib_files}
  DESTINATION ${FFmpeg_INSTALL}/bin
)

file(COPY
  ${FFmpeg_PATCH}/inttypes.h
  DESTINATION ${FFmpeg_INSTALL}/include
)
