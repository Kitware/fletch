.. image:: Doc/fletch_title.png
   :alt: Fletch

Fletch is component of Kitware_'s computer vision `KWIVER Project`_.
Its purpose is to make it a little easier to use the
various open source projects that are KWIVER_ dependencies.  Fletch is a
pure CMake_ project.  It does not provide any actual functionality beyond
encoding the knowledge of how to obtain, configure, and build a large
collection of external projects.  Fletch bootstraps a computer vision software
development environment by configuring various external projects to all work
together nicely.  Furthermore it provides this environment in a standard way
across platforms: Linux, MacOS, and Windows.

Some of the bigger projects that Fletch builds are

 - Caffe
 - OpenCV
 - VXL
 - VTK
 - Qt
 - Ceres Solver
 - Boost
 - Eigen

Additionally Fletch builds other projects required by the above like

 - libpng
 - libtiff
 - libjpeg
 - HDF5
 - FFmpeg
 - GLog
 - GFlags
 - SuiteSparse

For a complete and up to date list of packages see `<CMake/fletch-tarballs.cmake>`_.


Motivation
==========

When building large and complex projects it can be difficult to obtain all
the required dependent libraries and get them to build and work together.
Many of the projects in the first list above depend on many of the projects
in the second list above.  If you naively build OpenCV and VXL, for example,
each may provide its own copy of libjpeg, libtiff, etc.  This is not a problem
for the individual projects, but when you try to build a project, like KWIVER,
against both of them you end up with conflicts from linking to multiple
versions of the same library.

These same problems are addressed by package managers in Linux distributions
and projects like `MacPorts <https://www.macports.org/>`_ and `Homebrew <https://brew.sh/>`_
on MacOS.  However, each package manager has
its own versions of each of the packages and these are specific to the package
manager and to the operating system.  If we make KWIVER build against Ubuntu
16.04 packages it might not build against the packaged versions provided by RHEL
or even another version of Ubuntu.  Furthermore, building on Windows with
Visual Studio is a challenge because there is no standard package manager
for Windows.

Fletch solves the above problem for KWIVER using CMake.  It provides a
cross-platform way to get a standardized collection of open source projects
working together with the same versions on any OS.  Fletch is not quite
a cross-platform package manager, but it aims to fill that role for a
specific set of C++ and Python packages commonly used in Computer Vision.
To do this, the Fletch CMake system makes heavy use of CMake's
`ExternalProject <https://cmake.org/cmake/help/latest/module/ExternalProject.html>`_ module.

Overview of Directories
=======================

============= ==================================================================
``CMake``     contains the CMake code to obtain and configure the projects
``Patches``   contains the patches to apply to the downloaded source code
``Downloads`` contains downloaded tarballs of Fletch supported projects
============= ==================================================================

Using the Fletch Docker Image
=============================

Kitware maintains a `Docker <https://www.docker.com/>`_ image with Fletch prebuilt.
The Dockerfile used to build the image can be found `here <dockerfile>`_

Pull the image from Dockerhub::

 "docker pull kitware/fletch:latest" (master)
                or
 "docker pull kitware/fletch:v1.4.1" (release version)

(`https://hub.docker.com/r/kitware/fletch <https://hub.docker.com/r/kitware/fletch>`_)

or build the Fletch image using the dockerfile::

 "docker build -t fletch:tagname ."


Building Fletch
===============

Dependencies
------------

On Linux systems, Install the following packages before building Fletch::

  # The following example uses the Ubuntu apt-get package manager
  # These command may differ depending on your Linux flavor and package manager
  sudo apt-get install build-essential libgl1-mesa-dev
  sudo apt-get install libexpat1-dev
  sudo apt-get install libgtk2.0-dev
  sudo apt-get install liblapack-dev
  sudo apt-get install python2.7-dev

  # If you are using a RHEL-based system, e.g. RedHat, CentOS or Fedora
  # and enabling GDAL you might need to install redhat-rpm-config.
  {dnf|yum} install redhat-rpm-config

Fletch uses CMake for easy cross-platform compilation. The
minimum required version of CMake is 3.3.0, but newer versions are strongly
recommended.

Currently, a compiler with at C++11 support is expected (e.g. GCC 4.8, Visual
Studio 2015) is required.  KWIVER requires C++11; however, Fletch may compile
with older compilers.

CMake Options
-------------

Fletch provides CMake options to individually enable each project you build.
Some projects will require other projects to be enabled.  Unless you are looking
for a minimal build, the best way to get started is to set
``fletch_ENABLE_ALL_PACKAGES`` to ``ON`` and run the CMake configure step to
enable all packages.  You can then individually turn off packages you don't
want.  It is also useful to enable ``fletch_BUILD_WITH_PYTHON`` unless you only
want the C++ libraries built.

============================== ====================================================
``CMAKE_BUILD_TYPE``           The compiler mode, usually ``Debug`` or ``Release``
``fletch_ENABLE_ALL_PACKAGES`` Turn all packages on
                               (you can turn some back off later)
``fletch_BUILD_WITH_PYTHON``   Build all the packages with Python support
``fletch_BUILD_CXX11``         Build using C++11 compiler options.
                               This is required for KWIVER.
``fletch_DOWNLOAD_DIR``        This is where Fletch will cache downloaded source
                               source code tarballs (default is ``src/Downloads``)
``fletch_BUILD_WITH_CUDA``     Build projects that support it with `CUDA <https://www.geforce.com/hardware/technology/cuda>`_
``fletch_ENABLE_`` *package*   Enables the named *package* for building
============================== ====================================================

Running CMake
-------------

You may run cmake directly from a shell or cmd window.
On unix systems, the ccmake tool allows for interactive selection of CMake options.
Available for all platforms, the CMake GUI can set the source and build directories, options,
"Configure" and "Generate" the build files all with the click of a few button.
When running the cmake gui, we also recommend to select the 'Grouped' and 'Advanced' options
to better organize the options available.

We recommend building Fletch out of the source directory to prevent mixing
source files with compiled products.  Create a build directory in parallel
with the Fletch source directory for each desired configuration. For example :

========================== ===================================================================
``\fletch\src``             contains the code from the git repository
``\fletch\build\rel``       contains the built files for the release configuration
``\fletch\build\deb``       contains the built files for the debug configuration
========================== ===================================================================


.. note::
   Windows users, there is a known issue in Qt that will cause a build error if you name a build folder 'release' or 'debug'.
   Also, when building Qt5 on Windows, if the path to the QT base directory is 63 or more characters, a build error will occur.

   Linux users who build FFmpeg and OpenCV together might experience an issue linking to libavcodec.
   To allow OpenCV to link to FFmpeg, export LD_LIBRARY_PATH to include Fletch's install/lib directory,
   e.g. export LD_LIBRARY_PATH=/home/user1/fletch/bld/install/lib/:$LD_LIBRARY_PATH

   Linux users building QT 5 should also se the LD_LIBRARY_PATH directory this way so that the Qt build tools work properly.

The recommended CMake configuration is to enable all packages and, if desired, python.

If you are using ``ccmake`` or the CMake GUI,
* Set the source and build locations
* Check the option for ``fletch_ENABLE_ALL_PACKAGES`` and, if desired, ``fletch_BUILD_WITH_PYTHON``
* Configure
* Generate the build files

Running from a shell or cmd window::

  mkdir fletch
  cd fletch

  # Pull the source into a sub-folder 'src'
  git clone https://github.com/Kitware/fletch.git src

  # Create a folder to build in
  mkdir build/rel
  cd build/rel

  # Note you need to provide cmake the source directory at the end (relative or absolute)
  # Run CMake (it will use the system default compiler if you don't provide options or use the CMake GUI)
  # Also, if using visual studio, you do no need to provide the build type
  cmake -DCMAKE_BUILD_TYPE=Release -Dfletch_ENABLE_ALL_PACKAGES=ON -Dfletch_BUILD_WITH_PYTHON=ON ../../src

  # Again, python is very popular option, but is optional

  # If you wish to turn off a package, for example VTK you would do it this way
  cmake -Dfletch_ENABLE_VTK=OFF ../../src

On Linux/OSX/MinGW, execute make

For MSVC users, open the generated fletch.sln and build the project in the configuration associated with the build folder.
Even though MSVC supports building multiple configurations, you should only build one configuration per build folder.
If you need multiple configurations you should create multiple sub-folders and repeat the above instructions for each configuration.
Also If you enable Python, please ensure that python is on your Windows PATH

Getting Help
============

Fletch is a component of Kitware_'s collection of open source tools.
Please join the `fletch-users <http://public.kitware.com/mailman/listinfo/kwiver-users>`_
mailing list to discuss Fletch or to ask for help with using Fletch.

If you experience a build failure, please create an issue on
`GitHub <https://github.com/Kitware/fletch/issues>`_ and include the following information

1. Your operating system with exact version.
2. Your compiler's exact version.
3. The CMake version you are using.
4. The complete build log, preferably run with a single core after the build has failed.
5. Details of exactly which CMake options were changed from the default.


Troubleshooting
============

1. MSVC users may experience build issues with Boost after upgrading their version of Visual Studio.
   When a Boost build fails, one will find the file ``Boost.Configure.BCP.Build_out.txt`` in the build directory.
   The symptoms of this issue involve output in that file like ``'cl' is not recognized as an internal or external command,
   operable program or batch file``. The issue comes from Boost caching its version of b2_msvc_*_vcvars*.cmd.
   To resolve this issue, you will need to delete those files which are typically located in ``C:\Users\%USERNAME%\AppData\Local\Temp``.
   Any file named b2_msvc* should be moved out of the way so Boost can generate a new version based on the updated Visual Studio version.
   Once those files have regenerated and Boost successfully builds, it is safe to delete those files.



.. Appendix I: References
.. ======================

.. _CMake: http://www.cmake.org/
.. _`KWIVER Project`: http://www.kwiver.org/
.. _KWIVER: https://github.com/Kitware/kwiver
.. _Kitware: http://www.kitware.com/
