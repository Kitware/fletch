# The jom external project for fletch.
# This external project does not follow the normal pattern for
# fletch.  It is only used by the Qt project and only when
# building on windows. So, the usual enable flags and infrastructure
# for a fletch. Instead this file is directly included
# in External_Qt.cmake.  There is no build, configure or install for this.
# It is downloaded and unziped into ${fletch.exe
# where it is used directly by Qt as a build command.

ExternalProject_Add(jom
  URL ${jom_url}
  URL_MD5 ${jom_md5}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  PREFIX ${fletch_BUILD_PREFIX}
  DOWNLOAD_DIR ${fletch_DOWNLOAD_DIR}
)
