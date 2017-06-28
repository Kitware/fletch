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

For a complete and updated list of packages see CMake/fletch-tarballs.cmake.


Motivation
==========
When building large and complex projects it can be difficult to obtain all
the required dependent libraries and get them to build and work together.
Many of the projects in the first list above depend on many of the projects
in the second list above.  If you naively build OpevCV and VXL, for example,
each may provide its own copy of libjpeg, libtiff, etc.  This is not a problem
for the individual projects, but when you try to build a project, like KWIVER,
against both of them you end up with conflicts from linking to multiple
versions of the same project.

These same problems are address by package managers in Linux distributions and
projects like MacPorts and Brew on MacOS.  However, each package manager has
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
``CMAKE_INSTALL_PREFIX``       The path to where you want MAP-Tk to install

``fletch_ENABLE_ALL_PACKAGES`` Turn all packages on
                               (you can turn some back off later)
``fletch_BUILD_WITH_PYTHON``   Build all the packages with Python support
``fletch_BUILD_CXX11``         Build using C++11 compiler options.
                               This is required for KWIVER.
``fletch_DOWNLOAD_DIR``        This is where Fletch will cache downloaded source
                               source code tarballs
``fletch_ENABLE_`` Package     Enables the named packaged for building
============================== =================================================

Getting Help
============

MAP-Tk is a component of Kitware_'s collection of open source computer vision
tools known as KWIVER_. Please join the
`kwiver-users <http://public.kitware.com/mailman/listinfo/kwiver-users>`_
mailing list to discuss Fletch or to ask for help with using Fletch.
For less frequent announcements about Fletch and other KWIVER components,
please join the
`kwiver-announce <http://public.kitware.com/mailman/listinfo/kwiver-announce>`_
mailing list.


.. Appendix I: References
.. ======================

.. _CMake: http://www.cmake.org/
.. _`KWIVER Project`: http://www.kwiver.org/
.. _KWIVER: https://github.com/Kitware/kwiver
.. _Kitware: http://www.kitware.com/
