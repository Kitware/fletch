#+
# This file is called as CMake -P script for the patch step of
# External_GEOS.cmake.
# GEOS_patch and GEOS_source are defined on the command line along with the
# call.
#-
message("Patching geos")

# Fix the version number to not contain "dev" and add a SOVERSION
# for the public C API
#file(COPY ${GEOS_patch}/CMakeLists.txt DESTINATION ${GEOS_source})

# Fix ambiguous call to std::log(int) for VS2010
#file(COPY ${GEOS_patch}/BufferOp.cpp DESTINATION ${GEOS_source}/src/operation/buffer)

# Create a geos-config for installation to support pkgconfig builds
#file(COPY ${GEOS_patch}/geos-config.in DESTINATION ${GEOS_source}/cmake)

#file(COPY ${GEOS_patch}/Info.plist.in DESTINATION ${GEOS_source}/src)
# Fix the horribly broken capi/CMakeLists.txt in GEOG 3.3.2 by using the one
# from GEOS 3.4.2.
file(COPY ${GEOS_patch}/capi/CMakeLists.txt DESTINATION ${GEOS_source}/capi)

#file(COPY ${GEOS_patch}/LineIntersector.cpp DESTINATION ${GEOS_source}/src/algorithm)
#file(COPY ${GEOS_patch}/WKTWriter.cpp DESTINATION ${GEOS_source}/src/io)
#file(COPY ${GEOS_patch}/OffsetCurveSetBuilder.cpp DESTINATION ${GEOS_source}/src/operation/buffer)

file(COPY
  ${GEOS_patch}/GenerateSourceGroups.cmake
  DESTINATION
  ${GEOS_source}/cmake/modules/
  )
