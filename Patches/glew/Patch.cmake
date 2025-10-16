#+
# This file is called as CMake -P script for the patch step of
# External_glew to fix redefinition of sampler functions
#


file(COPY ${glew_patch}/blacklist
  DESTINATION ${glew_source}/auto
  )

file(COPY ${glew_patch}/filter_gl_ext.sh
  DESTINATION ${glew_source}/auto/bin
  )
