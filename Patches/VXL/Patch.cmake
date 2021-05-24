#+
# This file is called as CMake -P script for the patch step of
# External_VXL.cmake for VXL
#-

# fixes a Fortify 'detect' regarding a possible buffer overflow
file(COPY ${VXL_PATCH_DIR}/core/vbl/vbl_array_2d.h
  DESTINATION ${VXL_SOURCE_DIR}/core/vbl/
  )

# fixes an issue with duplicate definition of lrintf() on Windows
if (WIN32)
  file(COPY ${VXL_PATCH_DIR}/core/vnl/io/CMakeLists.txt
    DESTINATION ${VXL_SOURCE_DIR}/core/vnl/io/
    )
  file(COPY ${VXL_PATCH_DIR}/core/vsl/Templates/vsl_vector_io+char-.cxx
    DESTINATION ${VXL_SOURCE_DIR}/core/vsl/Templates/
    )
endif()
