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

file(COPY ${VXL_patch}//vnl_transpose.h
  DESTINATION ${VXL_source}/core/vnl/
)

file(COPY ${VXL_patch}//vnl_bignum.cxx
  DESTINATION ${VXL_source}/core/vnl/
)

file(COPY ${VXL_patch}//vnl_io_matrix.hxx
  DESTINATION ${VXL_source}/core/vnl/io/
)

# Cherry-pick commits onto c3fd279:
# - 1e8a027fc2 "BUG: fixing absolute path which slips into install location"
# - d0ff9f7266 "COMP: Missing file for install of vxl"
file(COPY ${VXL_patch}//vcl/CMakeLists.txt
  DESTINATION ${VXL_source}/vcl/
)

# fixes an issue with duplicate definition of lrintf() on Windows
file(COPY ${VXL_patch}/v3p/openjpeg2/opj_includes.h
  DESTINATION ${VXL_source}/v3p/openjpeg2/
)
