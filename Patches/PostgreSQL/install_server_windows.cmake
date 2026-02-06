#
# Download and install pre-built PostgreSQL server binaries on Windows.
#
# The fletch PostgreSQL build only compiles libpq (client library).
# This script downloads the official EDB binary distribution and installs
# the server tools (initdb, pg_ctl, psql, createuser, postgres) along with
# their required DLLs and share files into lib/postgresql/.
#
# Required variables:
#   PostgreSQL_binaries_url  - URL to the EDB binary zip
#   PostgreSQL_binaries_md5  - Expected MD5 of the zip
#   INSTALL_PREFIX           - Destination install prefix
#   DOWNLOAD_DIR             - Directory for temporary downloads
#

message(STATUS "Downloading PostgreSQL server binaries...")

set(PG_ZIP "${DOWNLOAD_DIR}/postgresql-windows-x64-binaries.zip")
set(PG_DEST "${INSTALL_PREFIX}/lib/postgresql")

if(NOT EXISTS "${PG_ZIP}")
  file(DOWNLOAD
    "${PostgreSQL_binaries_url}"
    "${PG_ZIP}"
    EXPECTED_MD5 "${PostgreSQL_binaries_md5}"
    SHOW_PROGRESS
  )
endif()

message(STATUS "Extracting PostgreSQL server binaries to ${PG_DEST}...")

# Extract bin/, share/, and lib/ from the zip (skip pgAdmin, docs, etc.)
file(ARCHIVE_EXTRACT
  INPUT "${PG_ZIP}"
  DESTINATION "${DOWNLOAD_DIR}/pg_extract"
)

# Copy the needed directories, preserving structure
foreach(subdir bin share lib)
  if(EXISTS "${DOWNLOAD_DIR}/pg_extract/pgsql/${subdir}")
    file(COPY "${DOWNLOAD_DIR}/pg_extract/pgsql/${subdir}"
      DESTINATION "${PG_DEST}"
    )
  endif()
endforeach()

# Install VC++ 2013 runtime DLLs (msvcr120.dll, msvcp120.dll) required by
# the EDB PostgreSQL 10 binaries. These are extracted from the official
# Microsoft Visual C++ 2013 Redistributable.
set(VCREDIST_URL "https://aka.ms/highdpimfc2013x64enu")
set(VCREDIST_EXE "${DOWNLOAD_DIR}/vcredist_x64_2013.exe")

if(NOT EXISTS "${PG_DEST}/bin/msvcr120.dll")
  if(NOT EXISTS "${VCREDIST_EXE}")
    message(STATUS "Downloading VC++ 2013 Redistributable...")
    file(DOWNLOAD "${VCREDIST_URL}" "${VCREDIST_EXE}" SHOW_PROGRESS)
  endif()

  message(STATUS "Extracting VC++ 2013 runtime DLLs...")

  # The vcredist is a WiX Burn bundle. Extract the outer cab, then find the
  # runtime minimum cab inside the attached container and extract the DLLs.
  find_program(SEVEN_ZIP_EXE NAMES 7z 7za
    PATHS "C:/Program Files/7-Zip" "C:/Program Files (x86)/7-Zip"
  )

  if(SEVEN_ZIP_EXE)
    # First extraction: get the bootstrap cab
    set(VC_EXTRACT_DIR "${DOWNLOAD_DIR}/vc2013_extract")
    file(MAKE_DIRECTORY "${VC_EXTRACT_DIR}")
    execute_process(
      COMMAND "${SEVEN_ZIP_EXE}" x "${VCREDIST_EXE}" -o${VC_EXTRACT_DIR} -y
      OUTPUT_QUIET ERROR_QUIET
    )

    # The attached container with MSI/cab payloads is after the initial cab.
    # Read the Burn manifest to find the payload offsets, or use known offsets.
    # For vcredist_x64 2013 12.0.40664: initial cab at 380416, size 69580
    file(READ "${VCREDIST_EXE}" VCREDIST_DATA OFFSET 449996 LIMIT 6750748 HEX)
    # Convert hex to binary and write as container
    set(VC_CONTAINER "${DOWNLOAD_DIR}/vc2013_container.bin")
    file(SIZE "${VCREDIST_EXE}" VCREDIST_SIZE)
    # Use a Python helper to extract the container and cab
    find_program(PYTHON_EXE NAMES python3 python
      PATHS "${INSTALL_PREFIX}/bin" "${INSTALL_PREFIX}/Scripts"
    )

    if(PYTHON_EXE)
      execute_process(
        COMMAND "${PYTHON_EXE}" -c "
import struct, os, sys, zipfile, subprocess

vcredist = sys.argv[1]
pg_bin = sys.argv[2]
seven_zip = sys.argv[3]
tmp_dir = sys.argv[4]

# Extract the attached WiX container (after the bootstrap cab)
# The bootstrap cab starts at offset 380416 with size 69580
with open(vcredist, 'rb') as f:
    data = f.read()

# Find the attached container by looking for the cab signature after the bootstrap
bootstrap_end = 380416 + 69580
container = data[bootstrap_end:]
container_path = os.path.join(tmp_dir, 'container.bin')
with open(container_path, 'wb') as f:
    f.write(container)

# Extract the container (contains a0=msi, a1=msi, a2=runtime_min.cab, a3=runtime_add.cab)
payloads_dir = os.path.join(tmp_dir, 'payloads')
os.makedirs(payloads_dir, exist_ok=True)
subprocess.run([seven_zip, 'x', container_path, '-o' + payloads_dir, '-y'],
    capture_output=True)

# Extract a2 (vcRuntimeMinimum cab containing msvcr120.dll and msvcp120.dll)
min_cab = os.path.join(payloads_dir, 'a2')
if os.path.exists(min_cab):
    min_dir = os.path.join(tmp_dir, 'minimum')
    os.makedirs(min_dir, exist_ok=True)
    subprocess.run([seven_zip, 'x', min_cab, '-o' + min_dir, '-y'],
        capture_output=True)
    # Copy the runtime DLLs (they have internal names like F_CENTRAL_msvcr120_x64)
    for f in os.listdir(min_dir):
        if 'msvcr120' in f.lower():
            src = os.path.join(min_dir, f)
            dst = os.path.join(pg_bin, 'msvcr120.dll')
            with open(src, 'rb') as s, open(dst, 'wb') as d:
                d.write(s.read())
            print(f'Installed msvcr120.dll')
        elif 'msvcp120' in f.lower():
            src = os.path.join(min_dir, f)
            dst = os.path.join(pg_bin, 'msvcp120.dll')
            with open(src, 'rb') as s, open(dst, 'wb') as d:
                d.write(s.read())
            print(f'Installed msvcp120.dll')
" "${VCREDIST_EXE}" "${PG_DEST}/bin" "${SEVEN_ZIP_EXE}" "${DOWNLOAD_DIR}/vc2013_work"
        RESULT_VARIABLE VC_RESULT
      )
      if(NOT VC_RESULT EQUAL 0)
        message(WARNING "Failed to extract VC++ 2013 runtime DLLs")
      endif()
    else()
      message(WARNING "Python not found, cannot extract VC++ 2013 runtime DLLs")
    endif()
  else()
    message(WARNING "7-Zip not found, cannot extract VC++ 2013 runtime DLLs. "
      "PostgreSQL server tools may not work without msvcr120.dll.")
  endif()
endif()

# Clean up extraction directory
file(REMOVE_RECURSE "${DOWNLOAD_DIR}/pg_extract")

message(STATUS "PostgreSQL server binaries installed to ${PG_DEST}")
