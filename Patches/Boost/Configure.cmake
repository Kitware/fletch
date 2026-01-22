include(${CMAKE_CURRENT_LIST_DIR}/Common.cmake)

message("Boost.Configure: Using toolset=${BOOST_TOOLSET}")

message("Boost.Configure: Creating custom user-config.jam")
if(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
  # For MSVC, we need to tell Boost.Build exactly where to find the compiler
  # since it may not recognize newer VS versions (like VS 2026)
  # Extract the version number from BOOST_TOOLSET (e.g., "msvc-14.3" -> "14.3")
  string(REGEX REPLACE "msvc-" "" MSVC_VERSION_FOR_JAM "${BOOST_TOOLSET}")
  # Get the Visual Studio installation directory
  # Compiler is at: .../VC/Tools/MSVC/version/bin/Hostx64/x64/cl.exe
  # vcvarsall.bat is at: .../VC/Auxiliary/Build/vcvarsall.bat
  get_filename_component(MSVC_BIN_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
  get_filename_component(VC_DIR_FOR_JAM "${MSVC_BIN_DIR}/../../../../../../" ABSOLUTE)
  set(VCVARSALL_BAT "${VC_DIR_FOR_JAM}/Auxiliary/Build/vcvarsall.bat")
  if(EXISTS "${VCVARSALL_BAT}")
    message("Boost.Configure: Found vcvarsall.bat at ${VCVARSALL_BAT}")
    # Create user-config.jam to use the current MSVC compiler
    file(WRITE ${Boost_SOURCE_DIR}/tools/build/v2/user-config.jam "
using msvc : ${MSVC_VERSION_FOR_JAM} : \"${CMAKE_CXX_COMPILER}\" ;
"
    )
  else()
    message("Boost.Configure: Could not find vcvarsall.bat, trying alternative configuration")
    # Alternative: just specify the compiler path directly
    file(WRITE ${Boost_SOURCE_DIR}/tools/build/v2/user-config.jam "
using msvc : ${MSVC_VERSION_FOR_JAM} : \"${CMAKE_CXX_COMPILER}\" ;
"
    )
  endif()
else()
  file(WRITE ${Boost_SOURCE_DIR}/tools/build/v2/user-config.jam "
using ${BOOST_TOOLSET} : : \"${CMAKE_CXX_COMPILER}\" ;
"
  )
endif()

if(WIN32)
  set(BOOTSTRAP ${Boost_SOURCE_DIR}/bootstrap.bat)
  # Specify toolset for bootstrap on Windows to handle newer VS versions
  # that Boost's auto-detection may not recognize
  if(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.50)
      # VS 2026 and beyond - use vc143 for bootstrap (the engine just needs to compile)
      # We'll use vc143 for bootstrap since it's compatible with newer compilers
      set(BOOTSTRAP_ARGS vc143)
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.30)
      set(BOOTSTRAP_ARGS vc143)
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.20)
      set(BOOTSTRAP_ARGS vc142)
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
      set(BOOTSTRAP_ARGS vc141)
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19)
      set(BOOTSTRAP_ARGS vc14)
    endif()
  endif()

  # Patch bootstrap.bat to pass toolset to inner build.bat for b2 engine compilation
  if(BOOTSTRAP_ARGS)
    set(BOOTSTRAP_BAT ${Boost_SOURCE_DIR}/bootstrap.bat)
    if(EXISTS ${BOOTSTRAP_BAT})
      file(READ ${BOOTSTRAP_BAT} BOOTSTRAP_CONTENT)
      # Check if we've already patched it (avoid double patching)
      string(FIND "${BOOTSTRAP_CONTENT}" "build.bat ${BOOTSTRAP_ARGS}" ALREADY_PATCHED)
      if(ALREADY_PATCHED EQUAL -1)
        # Patch bootstrap.bat to pass the toolset to build.bat
        # This avoids the toolset detection in build.bat which fails for newer VS versions
        string(REPLACE
          "call .\\build.bat"
          "call .\\build.bat ${BOOTSTRAP_ARGS}"
          BOOTSTRAP_CONTENT "${BOOTSTRAP_CONTENT}")
        file(WRITE ${BOOTSTRAP_BAT} "${BOOTSTRAP_CONTENT}")
        message("Boost.Configure: Patched bootstrap.bat to pass toolset ${BOOTSTRAP_ARGS} to build.bat")
      endif()
    endif()
  endif()

  # Patch build.bat to use explicit paths for internal script calls
  # This fixes issues where config_toolset.bat and guess_toolset.bat aren't found
  set(BUILD_BAT ${Boost_SOURCE_DIR}/tools/build/src/engine/build.bat)
  if(EXISTS ${BUILD_BAT})
    file(READ ${BUILD_BAT} BUILD_CONTENT)
    string(FIND "${BUILD_CONTENT}" "call .\\config_toolset.bat" BUILD_ALREADY_PATCHED)
    if(BUILD_ALREADY_PATCHED EQUAL -1)
      # Add explicit .\ prefix to config_toolset.bat call
      string(REPLACE
        "call config_toolset.bat"
        "call .\\config_toolset.bat"
        BUILD_CONTENT "${BUILD_CONTENT}")
      # Add explicit .\ prefix to guess_toolset.bat call
      string(REPLACE
        "call guess_toolset.bat"
        "call .\\guess_toolset.bat"
        BUILD_CONTENT "${BUILD_CONTENT}")
      file(WRITE ${BUILD_BAT} "${BUILD_CONTENT}")
      message("Boost.Configure: Patched build.bat to use explicit paths for script calls")
    endif()
  endif()

  # Patch msvc.jam to make 14.3 toolset detect VS 2026 installations
  # This is simpler than adding a new 14.5 version since we just extend 14.3 path detection
  set(MSVC_JAM ${Boost_SOURCE_DIR}/tools/build/src/tools/msvc.jam)
  if(EXISTS ${MSVC_JAM})
    file(READ ${MSVC_JAM} MSVC_JAM_CONTENT)
    # Check if VS 2026 path is already in msvc.jam
    string(FIND "${MSVC_JAM_CONTENT}" "Visual Studio/2026" MSVC_JAM_PATCHED)
    if(MSVC_JAM_PATCHED EQUAL -1)
      # First remove any incomplete 14.5 entries from previous patch attempts
      # Use regex to remove lines containing .version-14.5
      string(REGEX REPLACE "[^\n]*\\.version-14\\.5[^\n]*\n?" "" MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Remove any triple+ blank lines
      string(REGEX REPLACE "\n\n\n+" "\n\n" MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Add VS 2026 path to 14.3's path detection - look for the full 14.3 path block
      string(REPLACE
        "\"Microsoft Visual Studio/2022/*/VC/Tools/MSVC/*/bin/Host*/*\"\n    ;\n.version-14.3-env"
        "\"Microsoft Visual Studio/2022/*/VC/Tools/MSVC/*/bin/Host*/*\"\n    \"Microsoft Visual Studio/2026/*/VC/Tools/MSVC/*/bin/Host*/*\"\n    ;\n.version-14.3-env"
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Make MSVC path version detection also recognize 14.5x tool paths as 14.3
      string(REPLACE
        "if [ MATCH \"(MSVC\\\\\\\\14.3)\" : \$(command) ]"
        "if [ MATCH \"(MSVC\\\\\\\\14.[35])\" : \$(command) ]"
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Also handle the version setup check for 14.3/14.5
      string(REPLACE
        "if [ MATCH \"(14.3)\" : \$(version) ]"
        "if [ MATCH \"(14.3)\" : \$(version) ] || [ MATCH \"(14.5)\" : \$(version) ]"
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Remove 14.5 from known-versions list since we treat it as 14.3
      string(REPLACE
        ".known-versions = 14.5 14.3"
        ".known-versions = 14.3"
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Remove 14.5 from vswhere version check
      string(REPLACE
        "if \$(version) in 14.1 14.2 14.3 14.5 default"
        "if \$(version) in 14.1 14.2 14.3 default"
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      # Extend vswhere version range for 14.3 to include VS 2026 (version 18.x)
      string(REPLACE
        "limit = \"-version \\\"[17.0,18.0)\\\" -prerelease\""
        "limit = \"-version \\\"[17.0,19.0)\\\" -prerelease\""
        MSVC_JAM_CONTENT "${MSVC_JAM_CONTENT}")
      file(WRITE ${MSVC_JAM} "${MSVC_JAM_CONTENT}")
      message("Boost.Configure: Patched msvc.jam to detect VS 2026 (added to 14.3 paths)")
    endif()
  endif()
else()
  set(BOOTSTRAP ${Boost_SOURCE_DIR}/bootstrap.sh)
endif()
execute_command_wrapper(
  "Boost.Configure.Bootstrap"
  ${Boost_SOURCE_DIR}
  ${BOOTSTRAP} ${BOOTSTRAP_ARGS}
)

# After bootstrap, patch project-config.jam to use the correct toolset version and compiler path
# This is necessary because bootstrap generates a project-config.jam that uses
# auto-detection which doesn't work for newer VS versions (like VS 2026)
if(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
  set(PROJECT_CONFIG_JAM ${Boost_SOURCE_DIR}/project-config.jam)
  if(EXISTS ${PROJECT_CONFIG_JAM})
    file(READ ${PROJECT_CONFIG_JAM} PROJECT_CONFIG_CONTENT)
    # Extract the version number from BOOST_TOOLSET (e.g., "msvc-14.5" -> "14.5")
    string(REGEX REPLACE "msvc-" "" MSVC_VERSION_NUM "${BOOST_TOOLSET}")
    # Replace the msvc declaration entirely with the correct version and compiler path
    # Bootstrap may have set it to 14.3 (from vc143), but we need our target version
    string(REGEX REPLACE
      "using msvc : [0-9.]+ ;"
      "using msvc : ${MSVC_VERSION_NUM} : \"${CMAKE_CXX_COMPILER}\" ;"
      PROJECT_CONFIG_CONTENT "${PROJECT_CONFIG_CONTENT}")
    # Also handle case where it might already have a path
    string(REGEX REPLACE
      "using msvc : [0-9.]+ : \"[^\"]+\" ;"
      "using msvc : ${MSVC_VERSION_NUM} : \"${CMAKE_CXX_COMPILER}\" ;"
      PROJECT_CONFIG_CONTENT "${PROJECT_CONFIG_CONTENT}")
    file(WRITE ${PROJECT_CONFIG_JAM} "${PROJECT_CONFIG_CONTENT}")
    message("Boost.Configure: Patched project-config.jam to use msvc ${MSVC_VERSION_NUM} with compiler: ${CMAKE_CXX_COMPILER}")
  endif()
endif()

string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE)
if(NOT CMAKE_BUILD_TYPE STREQUAL "debug") # adjust for relwithdebinfo
  set(CMAKE_BUILD_TYPE "release")
endif()
message("Boost.Configure.BCP.Build: Using variant=${CMAKE_BUILD_TYPE}")

# Note: BCP has known issues with some msvc release builds so we always build
# it in debug.

# For MSVC on Windows, we need to run b2 from within a VS Developer environment
# Create a wrapper script that calls vcvarsall.bat before running b2
if(WIN32 AND CMAKE_CXX_COMPILER_ID MATCHES MSVC)
  # Find vcvarsall.bat from the compiler path
  # Compiler is at: .../VC/Tools/MSVC/version/bin/Hostx64/x64/cl.exe
  # vcvarsall.bat is at: .../VC/Auxiliary/Build/vcvarsall.bat
  # So we need to go from bin/Hostx64/x64 -> up 6 levels to VC
  get_filename_component(MSVC_BIN_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
  get_filename_component(VC_DIR "${MSVC_BIN_DIR}/../../../../../../" ABSOLUTE)
  set(VCVARSALL_BAT "${VC_DIR}/Auxiliary/Build/vcvarsall.bat")

  if(EXISTS "${VCVARSALL_BAT}")
    message("Boost.Configure: Found vcvarsall.bat at ${VCVARSALL_BAT}")
    # Create a wrapper batch script to set up the environment and run b2
    string(REPLACE ";" " " B2_ARGS_STR "${B2_ARGS}")
    set(B2_WRAPPER ${CMAKE_BINARY_DIR}/run_b2.bat)
    # Add vswhere.exe path to PATH - Boost.Build's msvc.jam needs it
    # Also create the msvc-setup.nup stamp file to skip Boost.Build's MSVC setup
    # since we already set up the environment via vcvarsall.bat
    string(REGEX REPLACE "msvc-" "" MSVC_VER_NUM "${BOOST_TOOLSET}")
    file(WRITE ${B2_WRAPPER}
"@echo off
set \"PATH=C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer;%PATH%\"
call \"${VCVARSALL_BAT}\" x64
cd /d \"${Boost_SOURCE_DIR}/tools/bcp\"
rem Create the msvc-setup stamp file to indicate the MSVC environment is ready
if not exist \"${Boost_SOURCE_DIR}\\bin.v2\\standalone\\msvc\\msvc-${MSVC_VER_NUM}\" mkdir \"${Boost_SOURCE_DIR}\\bin.v2\\standalone\\msvc\\msvc-${MSVC_VER_NUM}\"
echo. > \"${Boost_SOURCE_DIR}\\bin.v2\\standalone\\msvc\\msvc-${MSVC_VER_NUM}\\msvc-setup.nup\"
\"${Boost_SOURCE_DIR}/b2.exe\" variant=${CMAKE_BUILD_TYPE} ${B2_ARGS_STR}
")
    execute_command_wrapper(
      "Boost.Configure.BCP.Build"
      ${Boost_SOURCE_DIR}/tools/bcp
      cmd /c "${B2_WRAPPER}"
    )
  else()
    message("Boost.Configure: vcvarsall.bat not found at ${VCVARSALL_BAT}, trying direct b2 call")
    execute_command_wrapper(
      "Boost.Configure.BCP.Build"
      ${Boost_SOURCE_DIR}/tools/bcp
      ${Boost_SOURCE_DIR}/b2${CMAKE_EXECUTABLE_SUFFIX}
      variant=${CMAKE_BUILD_TYPE} ${B2_ARGS}
    )
  endif()
else()
  execute_command_wrapper(
    "Boost.Configure.BCP.Build"
    ${Boost_SOURCE_DIR}/tools/bcp
    ${Boost_SOURCE_DIR}/b2${CMAKE_EXECUTABLE_SUFFIX}
    variant=${CMAKE_BUILD_TYPE} ${B2_ARGS}
  )
endif()

execute_command_wrapper(
  "Boost.Configure.BCP.Exec"
  ${Boost_SOURCE_DIR}
  ${Boost_SOURCE_DIR}/dist/bin/bcp${CMAKE_EXECUTABLE_SUFFIX}
  --boost=${Boost_SOURCE_DIR} build config
  # Components used by KWIVER/VIAME/VIVIA:
  # - Built libraries: chrono date_time filesystem iostreams program_options regex system thread
  # - Header-only: algorithm assign graph integer lexical_cast property_tree ptr_container smart_ptr
  lexical_cast smart_ptr assign algorithm
  iostreams ptr_container
  date_time thread filesystem regex chrono system program_options
  integer property_tree graph ${Boost_EXTRA_LIBS}
  ${Boost_BUILD_DIR}
)

# Copy all Boost header files to the build tree.
file(COPY        "${Boost_SOURCE_DIR}/boost/"
     DESTINATION "${Boost_BUILD_DIR}/boost/"
     USE_SOURCE_PERMISSIONS)
