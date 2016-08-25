file(REMOVE ${LevelDB_source}/build_detect_platform)

configure_file(
  ${LevelDB_patch}/build_detect_platform.in
  ${LevelDB_source}/build_detect_platform
  @ONLY
  )
