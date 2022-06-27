if(WIN32)
  set (msys_patch "${fletch_SOURCE_DIR}/Patches/msys2")

  set(msys_bash ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/bash.exe)
  set(msys_make ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/make.exe)
  set(msys_env ${fletch_BUILD_PREFIX}/src/msys2/usr/bin/env.exe)
  set(mingw_prefix ${msys_env} MSYSTEM=MINGW64 PATH=/mingw64/bin:/usr/local/bin:/usr/bin:/bin)

  ExternalProject_Add(msys2
	  URL ${msys2_url}
	  URL_MD5 ${msys2_md5}
	  ${COMMON_EP_ARGS}
	  PATCH_COMMAND
	  ${mingw_prefix} ${msys_bash} -c "sed -i 's|\"\${postinst}\"$|& \\&>/dev/null|g' /etc/profile"
	  CONFIGURE_COMMAND
	  ${mingw_prefix} ${msys_bash} -l -c "pacman -Syyuq --noconfirm"
	  BUILD_COMMAND ""
	  ${mingw_prefix} ${msys_bash} -l -c "pacman -Syyq --noconfirm make gcc diffutils yasm nasm git pkgconf mingw-w64-x86_64-nasm mingw-w64-x86_64-gcc mingw-w64-x86_64-SDL2 mingw-w64-x86_64-binutils"
	  INSTALL_COMMAND
	  ${mingw_prefix} ${msys_bash} -l -c "cp /mingw64/bin/*.dll ${fletch_BUILD_INSTALL_PREFIX}/bin"
  )
  fletch_external_project_force_install(PACKAGE msys2)

  set(msys2_ROOT ${fletch_BUILD_INSTALL_PREFIX} CACHE PATH "" FORCE)
endif()
