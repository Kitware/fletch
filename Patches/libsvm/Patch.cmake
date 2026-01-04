#+
# This file is called as CMake -P script for the patch step of
# External_libsvm.cmake.
# libsvm_patch and libsvm_source are defined on the command line along with the
# call.
#
# This patch adds custom kernel types (HISTOGRAM and NMI) for
# Histogram Intersection Kernel support, matching the smqtk custom libsvm.
#-

message("Patching libsvm with HIK (Histogram Intersection Kernel) support")

file(COPY ${libsvm_patch}/svm.h DESTINATION ${libsvm_source})
file(COPY ${libsvm_patch}/svm.cpp DESTINATION ${libsvm_source})
