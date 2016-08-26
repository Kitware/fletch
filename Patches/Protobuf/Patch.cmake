#+
# This file is called as CMake -P script for the patch step of
# External_Protobuf to fix a broken URL
#-

message ("Patching Protobuf in ${Protobuf_source}")

file(COPY ${Protobuf_patch}/autogen.sh
  DESTINATION ${Protobuf_source}/autogen.sh
)

