#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
)

# fixes an issue with duplicate definition of lrintf() on Windows
file(COPY ${VXL_PATCH_DIR}/v3p/openjpeg2/opj_includes.h
  DESTINATION ${VXL_SOURCE_DIR}/v3p/openjpeg2/
)

# Fix C++17 compatibility: replace deprecated std::bind2nd with lambda
if(fletch_BUILD_CXX17)
  file(COPY ${VXL_PATCH_DIR}/core/vil/algo/vil_gauss_filter.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vil/algo/
  )
endif()
