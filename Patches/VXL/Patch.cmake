#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake to fix a minor ffmpeg find flag
#-

message("Patching VXL in ${VXL_source}")

file(COPY ${VXL_patch}//vidl_ffmpeg_ostream_v56.hxx
  DESTINATION ${VXL_source}/core/vidl/
)

file(COPY ${VXL_patch}//vnl_matrix_fixed.h
  DESTINATION ${VXL_source}/core/vnl/
)

file(COPY ${VXL_patch}//vnl_io_matrix.h
  DESTINATION ${VXL_source}/core/vnl/
)

file(COPY ${VXL_patch}//vnl_io_matrix.hxx
  DESTINATION ${VXL_source}/core/vnl/io/
)
