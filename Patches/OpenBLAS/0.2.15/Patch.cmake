#+
# This file is called as CMake -P script for the patch step of
# External_OpenBLAS to fix build error with GCC 4.4
# This patch will be included in version 0.2.16 and can be removed here.
# Patch via https://github.com/xianyi/OpenBLAS/commit/11ac4665c835a27a097e5021074cbf366bcb9765
#-

file(COPY ${OpenBLAS_patch}/driver/others/memory.c
  DESTINATION ${OpenBLAS_source}/driver/others/
  )
