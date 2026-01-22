#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

message(STATUS "Patching VXL in ${VXL_SOURCE_DIR}")

file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)

# Fix CMake 4.x compatibility: cmake_minimum_required version too old
file(COPY ${VXL_PATCH_DIR}/config/cmake/config/vxl_shared_link_test/CMakeLists.txt
  DESTINATION ${VXL_SOURCE_DIR}/config/cmake/config/vxl_shared_link_test/
)

# Fix C++17 compatibility: replace deprecated std::bind2nd with lambda
file(COPY ${VXL_PATCH_DIR}/core/vil/algo/vil_gauss_filter.cxx
  DESTINATION ${VXL_SOURCE_DIR}/core/vil/algo/
)

# fixes an issue with duplicate definition of lrintf() on Windows
file(COPY ${VXL_PATCH_DIR}/v3p/openjpeg2/opj_includes.h
  DESTINATION ${VXL_SOURCE_DIR}/v3p/openjpeg2/
)

# Apply FFmpeg 5.x compatibility patches for vidl_ffmpeg
# Only applied when VXL_APPLY_FFMPEG5_PATCH is set (FFmpeg >= 5.0 is enabled)
if(VXL_APPLY_FFMPEG5_PATCH AND EXISTS ${VXL_PATCH_DIR}/core/vidl)
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
