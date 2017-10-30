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
  # NOTE: inttypes.h is part of the C standard library and not part of FFmpeg
  # This patch provides FFmpeg with a windows port of the the inttypes header
  # References:
  #   https://en.wikipedia.org/wiki/C_data_types#inttypes.h
  #   http://www.nongnu.org/avr-libc/user-manual/group__avr__inttypes.html
  #   https://code.google.com/archive/p/msinttypes/
  #   https://github.com/chemeris/msinttypes
  ${FFmpeg_PATCH}/inttypes.h
  DESTINATION ${FFmpeg_INSTALL}/include
)
