############################################
                   Fletch
############################################

Fletch is component of Kitware_'s computer vision `KWIVER Project`_.
Its purpose is to make it a little easier to obtain, configure, and build
various open source projects that are KWIVER_ dependencies.  Fletch is a
pure CMake_ project.  It does not provide any actual functionality beyond
encoding the knowledge of how to obtain, configure, and build a large
collection of external projects.  Fletch bootstraps a computer vision software
development environment by configuring various external projects to all work
together nicely.  Futhermore it provides this environment in a standard way
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

For a complete and updated list of packages see `<CMake/fletch-tarballs.cmake>`_.


Motivation
==========
When building large and complex projects it can be difficult to obtain all
the required dependent libraries and get them to build and work together.
Many of the projects in the first list above depend on many of the projects
in the second list above.  If you naively build OpevCV and VXL, for example,
each may provide its own copy of libjpeg, libtiff, etc.  This is not a problem
for the individual projects, but when you try to build a project, like KWIVER,
against both of them you end up with conflicts from linking to multiple
versions of the same library.

These same problems are addressed by package managers in Linux distributions
and projects like MacPorts and Brew on MacOS.  However, each package manager has
its own versions of each of the packages and these are specific to the package
manager and to the operating system.  If we make KWIVER build against Ubuntu
16.04 packages it might not build against the packaged versions provided by RHEL
or even another version of Ubuntu.  Futhermore, building on Windows with
Visual Studio is a challenge because there is no standard package manager
for Windows.

Fletch solves the above problem for KWIVER using CMake.  It provides a
cross-platform way to get a standardized collection of open source projects
working together with the same versions on any OS.  Fletch is not quite
a cross-platform package manager, but it aims to fill that role for a
specific set of C++ and Python packages commonly used in Computer Vision.


Overview of Directories
=======================

============= ==================================================================
``CMake``     contains the CMake code to obtain and configure the projects
``Patches``   contains the patches to apply to the downloaded source code
============= ==================================================================


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

Fletch uses CMake (www.cmake.org) for easy cross-platform compilation. The
minimum required version of CMake is 2.8.12, but newer versions are strongly
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

============================== =================================================
``CMAKE_BUILD_TYPE``           The compiler mode, usually ``Debug`` or ``Release``
``fletch_ENABLE_ALL_PACKAGES`` Turn all packages on
                               (you can turn some back off later)
``fletch_BUILD_WITH_PYTHON``   Build all the packages with Python support
``fletch_BUILD_CXX11``         Build using C++11 compiler options.
                               This is required for KWIVER.
``fletch_DOWNLOAD_DIR``        This is where Fletch will cache downloaded source
                               source code tarballs
``fletch_ENABLE_`` *package*   Enables the named *package* for building
============================== =================================================

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

NOTES
-----
Windows users, there is a known issue in Qt that will cause a build error if you name a build folder 'release' or 'debug'.  

Linux users who build FFmpeg and OpenCV together might experience an issue linking to libavcodec. To allow OpenCV to link to FFmpeg, export LD_LIBRARY_PATH to include fletch's install/lib directory, e.g. export LD_LIBRARY_PATH=/home/user1/fletch/bld/install/lib/:$LD_LIBRARY_PATH  

The recommended CMake configuration is to enable all packages and, if desired, python.

If you are using ccmake or the CMake GUI,
* Set the source and build locations
* Check the option for fletch_ENABLE_ALL_PACKAGES and, if desired, fletch_ENABLE_PYTHON
* Configure
* Generate the build files

Running from a shell or cmd window::

  mkdir fletch
  cd fletch
  # Pull the source into a subfolder 'src'
  git clone https://github.com/Kitware/fletch.git src
  # Create a folder to build in
  mkdir build/rel
  cd build/rel
  # Note you need to provide cmake the source directory at the end (relative or absolute)
  # Run CMake (it will use the system default compiler if you don't provide options or use the CMake GUI)
  # Also, if using visual studio, you do no need to provide the build type
  cmake -DCMAKE_BUILD_TYPE=Release -Dfletch_ENABLE_ALL_PACKAGES=ON -Dfletch_ENABLE_PYTHON=ON ../../src
  # Again, python very popular option, but is optional
  
On Linux/OSX/MinGW, execute make
  
For MSVC users, open the generated fletch.sln and build the project in the configuration associated with the build folder.
Even though MSVC supports building multiple configurations, you should only build one configuration per build folder.
If you need multiple configurations you should create multiple subfolders and repeat the above instructions for each configuration.
Also If you enable Python, please ensure that python is on your Windows PATH 

Getting Help
============

Fletch is a component of Kitware_'s collection of open source tools. 
Please join the `fletch-users <http://public.kitware.com/mailman/listinfo/kwiver-users>`_
mailing list to discuss Fletch or to ask for help with using Fletch.

If you experience a build failure, please create an issue on `GitHub <https://github.com/Kitware/fletch/issues>`_ and include the following information

1. Your operating system with exact version.
2. Your compiler's exact version.
3. The CMake version you are using.
3. The complete build log, preferably run with a single core after the build has failed.
4. Details of exactly which CMake options were changed from the default.


.. Appendix I: References
.. ======================

.. _CMake: http://www.cmake.org/
.. _`KWIVER Project`: http://www.kwiver.org/
.. _KWIVER: https://github.com/Kitware/kwiver
.. _Kitware: http://www.kitware.com/
