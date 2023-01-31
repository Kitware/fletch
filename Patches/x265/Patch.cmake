# Add patch to use user-provided UUID instead of hardcoded one when writing SEI
configure_file(
  ${x265_patch}/sei.h
  ${x265_source}/source/encoder/
  COPYONLY
)
