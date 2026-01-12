#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

message(STATUS "Patching VXL in ${VXL_SOURCE_DIR}")

file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)

# fixes an issue with duplicate definition of lrintf() on Windows
file(COPY ${VXL_PATCH_DIR}/v3p/openjpeg2/opj_includes.h
  DESTINATION ${VXL_SOURCE_DIR}/v3p/openjpeg2/
)

# Apply FFmpeg 5.x compatibility patches for vidl_ffmpeg
if(EXISTS ${VXL_PATCH_DIR}/core/vidl)
  message(STATUS "Applying FFmpeg 5.x compatibility patches for vidl")

  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_init.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/
  )

  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_convert.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/
  )

  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_istream_v56.hxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/
  )

  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_ostream_v56.hxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/
  )

  file(COPY ${VXL_PATCH_DIR}/core/vidl/vidl_ffmpeg_ostream_params.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vidl/
  )
endif()
