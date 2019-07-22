#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake to fix a minor ffmpeg find flag
#-

message("Patching VXL in ${VXL_source}")

file(COPY ${VXL_patch}//vidl_ffmpeg_ostream_v56.hxx
  DESTINATION ${VXL_source}/core/vidl/
)
