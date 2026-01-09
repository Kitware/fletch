#+
# This file is called as CMake -P script for the patch step of
# External_libsvm.cmake.
# libsvm_patch and libsvm_source are defined on the command line along with the
# call.
#
# This patch adds:
# - CMakeLists.txt for cross-platform CMake builds
# - Custom kernel types (HISTOGRAM and NMI) for Histogram Intersection Kernel
#   support, matching the smqtk custom libsvm (when libsvm_apply_hik_patch is set)
#-

message("Patching libsvm with CMake build support")

# Always copy CMakeLists.txt for cross-platform build support
file(COPY ${libsvm_patch}/CMakeLists.txt DESTINATION ${libsvm_source})

# Copy HIK-patched source files if requested
if(libsvm_apply_hik_patch)
  message("Patching libsvm with HIK (Histogram Intersection Kernel) support")
  file(COPY ${libsvm_patch}/svm.h DESTINATION ${libsvm_source})
  file(COPY ${libsvm_patch}/svm.cpp DESTINATION ${libsvm_source})
endif()
