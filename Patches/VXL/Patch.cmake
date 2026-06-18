#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

message(STATUS "Patching VXL in ${VXL_SOURCE_DIR}")

# Guard vbl_array_2d against integer overflow in its m*n allocation.
# (Not upstream as of VXL v3.5.0; the former C++17/CMake-4/openjpeg patches are
#  now upstream and have been dropped.)
file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)

# Provide real FFmpeg 5.x/6.x support for vidl_ffmpeg. Upstream VXL (through
# v3.5.0) only supports up to libavcodec 56 (FFmpeg ~2.8); its "_v56" files
# still call APIs removed in FFmpeg 5.0 (av_free_packet, avcodec_decode_video2,
# AVPicture, ...). These replacements use the modern send_packet/receive_frame
# API. Applied only when FFmpeg >= 5 is enabled.
if(VXL_APPLY_FFMPEG5_PATCH AND EXISTS ${VXL_PATCH_DIR}/core/vidl)
  message(STATUS "Applying FFmpeg 5.x compatibility patches for vidl")
  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_init.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/)
  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_convert.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/)
  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_istream_v56.hxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/)
  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_ostream_v56.hxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/)
  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_ostream_params.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/)
endif()
