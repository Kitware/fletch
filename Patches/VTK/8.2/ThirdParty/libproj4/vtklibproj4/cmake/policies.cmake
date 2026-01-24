# Policies patched for CMake 4 compatibility
# CMP0022: INTERFACE_LINK_LIBRARIES defines the link interface
# CMake 4 no longer supports setting this to OLD, so we set it to NEW
if(POLICY CMP0022)
  cmake_policy(SET CMP0022 NEW)
endif()
