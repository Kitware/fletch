include_guard(GLOBAL)

if(WIN32)
  set (msys_patch "${fletch_SOURCE_DIR}/Patches/msys2")

  set(msys_bash ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/bash.exe)
  set(msys_make ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/make.exe)
  set(msys_env ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/env.exe)
  # Keep mingw_prefix for any legacy usage, but we now use MSVC toolchain
  set(mingw_prefix ${msys_env} MSYSTEM=MINGW64 PATH=/mingw64/bin:/usr/local/bin:/usr/bin:/bin)
  # MSYS prefix for MSVC toolchain builds (bash + make only, no MinGW compiler)
  set(msys_prefix_cmd ${msys_env} MSYSTEM=MSYS PATH=/usr/local/bin:/usr/bin:/bin)
  file(TO_CMAKE_PATH "${fletch_BUILD_INSTALL_PREFIX}" msys_prefix)

  ExternalProject_Add(msys2
	  URL ${msys2_url}
	  URL_MD5 ${msys2_md5}
	  ${COMMON_EP_ARGS}
	  PATCH_COMMAND
	  ${msys_prefix_cmd} ${msys_bash} -c "sed -i 's|\"\${postinst}\"$|& \\&>/dev/null|g' /etc/profile"
	  CONFIGURE_COMMAND
	  ${msys_prefix_cmd} ${msys_bash} -l -c "pacman -Syyuq --noconfirm"
	  BUILD_COMMAND
	  ${msys_prefix_cmd} ${msys_bash} -l -c "pacman -Syyq --noconfirm make diffutils yasm nasm git pkgconf"
	  INSTALL_COMMAND ""
  )
  fletch_external_project_force_install(PACKAGE msys2)

  set(msys2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
endif()
