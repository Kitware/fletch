#+
# This file is called as CMake -P script for the patch step of
# External_Protobuf

# Expand the supported architectures
file(COPY ${Protobuf_PATCH_DIR}/platform_macros.h
  DESTINATION ${Protobuf_SOURCE_DIR}/src/google/protobuf/stubs/
  )

file(COPY ${Protobuf_PATCH_DIR}/atomicops.h
  DESTINATION ${Protobuf_SOURCE_DIR}/src/google/protobuf/stubs/
  )


file(COPY ${Protobuf_PATCH_DIR}/atomicops_internals_arm_gcc.h
  DESTINATION ${Protobuf_SOURCE_DIR}/src/google/protobuf/stubs/
  )

file(COPY ${Protobuf_PATCH_DIR}/atomicops_internals_arm64_gcc.h
  DESTINATION ${Protobuf_SOURCE_DIR}/src/google/protobuf/stubs/
  )
