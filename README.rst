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

Fletch uses CMake (www.cmake.org) for easy cross-platform compilation. The
minimum required version of CMake is 2.8.12, but newer versions are strongly
recommended.

Currently, a compiler with at C++11 support is expected (e.g. GCC 4.8, Visual
Studio 2015) is required.  KWIVER requires C++11; however, Fletch may compile
with older compilers.


Running CMake
-------------

We recommend building Fletch out of the source directory to prevent mixing
source files with compiled products.  Create a build directory in parallel
with the Fletch source directory.  From the command line, enter the
empty build directory and run::

    $ ccmake /path/to/fletch/source

where the path above is the location of your Fletch source tree.  The ccmake
tool allows for interactive selection of CMake options.  Alternatively, using
the CMake GUI you can set the source and build directories accordingly and
press the "Configure" button.


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

CMake Configuration
-------------------

The recommended CMake configuration is to enable all packages and, if desired, python :

If you are using ccmake or the CMake GUI, simply check the option for fletch_ENABLE_ALL_PACKAGES and, if desired, fletch_ENABLE_PYTHON

If you are running from a shell or cmd window,

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
mkdir fletch
cd fletch
# Pull the source into a subfolder 'src'
git clone https://github.com/Kitware/fletch.git src
# Create a folder to build in
mkdir build
cd build
# Feel free to make subfolders here, like debug or release
# Generate a make file/msvc solution from the desired subfolder 
# Note you need to provide cmake the source directory at the end (relative or absolute)
# Run CMake (it will use the system default compiler if you don't provide options or use the CMake GUI)
# Also, if using visual studio, you do no need to provide the build type
cmake -DCMAKE_BUILD_TYPE=Release -Dfletch_ENABLE_ALL_PACKAGES=ON -Dfletch_ENABLE_PYTHON=ON ../src
# Again, python very popular option, but is optional

# Execute make on Linux/OSX/MinGW 
make 

# For MSVC
# Open the generated fletch.sln and build the project in the desired configuration.
# Note you should only build one configuration, if you need multiple configurations
# you should create multiple subfolders and repeat the above insturctions for each configuration
# Also If you enable Python, please ensure that python is on your Windows PATH 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



Getting Help
============

Fletch is a component of Kitware_'s collection of open source tools. 
Please join the `fletch-users <http://public.kitware.com/mailman/listinfo/fletch-users>`_
mailing list to discuss Fletch or to ask for help with using Fletch.



.. Appendix I: References
.. ======================

.. _CMake: http://www.cmake.org/
.. _`KWIVER Project`: http://www.kwiver.org/
.. _KWIVER: https://github.com/Kitware/kwiver
.. _Kitware: http://www.kitware.com/
