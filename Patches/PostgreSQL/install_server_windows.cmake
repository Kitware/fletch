#
# Download and install pre-built PostgreSQL server binaries on Windows.
#
# The fletch PostgreSQL build only compiles libpq (client library).
# This script downloads the official EDB binary distribution and installs:
#   - Server EXEs + runtime DLLs (from pgsql/bin/) into INSTALL_PREFIX/bin/
#   - Extension DLLs (from pgsql/lib/) into INSTALL_PREFIX/lib/  ($libdir)
#   - Share files (from pgsql/share/) into INSTALL_PREFIX/share/
#
# Required variables:
#   PostgreSQL_binaries_url  - URL to the EDB binary zip
#   PostgreSQL_binaries_md5  - Expected MD5 of the zip
#   INSTALL_PREFIX           - Destination install prefix
#   DOWNLOAD_DIR             - Directory for temporary downloads
#

message(STATUS "Downloading PostgreSQL server binaries...")

set(PG_ZIP "${DOWNLOAD_DIR}/postgresql-windows-x64-binaries.zip")

if(NOT EXISTS "${PG_ZIP}")
  file(DOWNLOAD
    "${PostgreSQL_binaries_url}"
    "${PG_ZIP}"
    EXPECTED_MD5 "${PostgreSQL_binaries_md5}"
    SHOW_PROGRESS
  )
endif()

message(STATUS "Extracting PostgreSQL server binaries...")

file(ARCHIVE_EXTRACT
  INPUT "${PG_ZIP}"
  DESTINATION "${DOWNLOAD_DIR}/pg_extract"
)

# Copy bin/ contents (EXEs and runtime DLLs) into INSTALL_PREFIX/bin/
# Only copy files that don't already exist to avoid overwriting VIAME's own files
set(PG_BIN_SRC "${DOWNLOAD_DIR}/pg_extract/pgsql/bin")
if(EXISTS "${PG_BIN_SRC}")
  file(GLOB PG_BIN_FILES "${PG_BIN_SRC}/*")
  foreach(src_file ${PG_BIN_FILES})
    get_filename_component(fname "${src_file}" NAME)
    set(dst_file "${INSTALL_PREFIX}/bin/${fname}")
    if(NOT EXISTS "${dst_file}")
      file(COPY "${src_file}" DESTINATION "${INSTALL_PREFIX}/bin")
    endif()
  endforeach()
endif()

# Copy lib/ contents (extension DLLs for $libdir) into INSTALL_PREFIX/lib/
# PostgreSQL server loads extensions from $libdir which is INSTALL_PREFIX/lib/
set(PG_LIB_SRC "${DOWNLOAD_DIR}/pg_extract/pgsql/lib")
if(EXISTS "${PG_LIB_SRC}")
  file(GLOB PG_LIB_FILES "${PG_LIB_SRC}/*")
  foreach(src_file ${PG_LIB_FILES})
    get_filename_component(fname "${src_file}" NAME)
    set(dst_file "${INSTALL_PREFIX}/lib/${fname}")
    if(NOT EXISTS "${dst_file}")
      file(COPY "${src_file}" DESTINATION "${INSTALL_PREFIX}/lib")
    endif()
  endforeach()
endif()

# Copy share/ contents into INSTALL_PREFIX/share/
# (initdb looks for share/ at ../share/ relative to its binary location)
set(PG_SHARE_SRC "${DOWNLOAD_DIR}/pg_extract/pgsql/share")
if(EXISTS "${PG_SHARE_SRC}")
  file(COPY "${PG_SHARE_SRC}/" DESTINATION "${INSTALL_PREFIX}/share")
endif()

# Clean up extraction directory
file(REMOVE_RECURSE "${DOWNLOAD_DIR}/pg_extract")

message(STATUS "PostgreSQL server binaries installed to ${INSTALL_PREFIX}")
