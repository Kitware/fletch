#+
# This file is called as CMake -P script for the patch step of
# External_GLog to fix OSX build error
#
# Patch via https://trac.macports.org/browser/trunk/dports/devel/google-glog/files/patch-libc%2B%2B.diff
#-

if (APPLE)

  message("Patching GLog in ${GLog_source}")

  file(COPY ${GLog_patch}/stl_logging.h.in
    DESTINATION ${GLog_source}/src/glog
    )

endif()
