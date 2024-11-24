/*
    pybind11/gil.h: RAII helpers for managing the GIL

    Copyright (c) 2016 Wenzel Jakob <wenzel.jakob@epfl.ch>

    All rights reserved. Use of this source code is governed by a
    BSD-style license that can be found in the LICENSE file.
*/

#pragma once

#include "detail/common.h"
#include "detail/internals.h"

PYBIND11_NAMESPACE_BEGIN(PYBIND11_NAMESPACE)


PYBIND11_NAMESPACE_BEGIN(detail)

// forward declarations
PyThreadState *get_thread_state_unchecked();

PYBIND11_NAMESPACE_END(detail)


#if defined(PYPY_VERSION)
class gil_scoped_acquire {
    PyGILState_STATE state;
public:
    gil_scoped_acquire() { state = PyGILState_Ensure(); }
    ~gil_scoped_acquire() { PyGILState_Release(state); }
    void disarm() {}
};

class gil_scoped_release {
    PyThreadState *state;
public:
    gil_scoped_release() { state = PyEval_SaveThread(); }
    ~gil_scoped_release() { PyEval_RestoreThread(state); }
    void disarm() {}
};
#else
class gil_scoped_acquire {
    void disarm() {}
};
class gil_scoped_release {
    void disarm() {}
};
#endif

PYBIND11_NAMESPACE_END(PYBIND11_NAMESPACE)
