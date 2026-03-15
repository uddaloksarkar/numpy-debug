# !/bin/bash

# clone the numpy repository and initialize submodules
git clone git@github.com:uddaloksarkar/numpy.git
cd numpy
git submodule update --init --recursive

# install testing dependencies
python3.12 -m pip install pytest
python3.12 -m pip install hypothesis

if [ "$1" = "spin" ]; then
    # build numpy using spin and run tests
    python3.12 -m pip install spin
    spin build --clean -- -Dbuildtype=debug -Ddisable-optimization=true
    spin test -v
    spin test numpy/random  # to run the tests in a specific module
    spin test -v -t numpy/_core/tests/test_nditer.py::test_iter_c_order
    spin test -p auto # to run tests in parallel threads using pytest-run-parallel
else
    # without using spin, build and install numpy in the venv using pip
    python3.12 -m pip install meson meson-python ninja cython pytest setuptools
    CFLAGS="-O0 -g" python3.12 -m pip install -e . --no-build-isolation
fi

# # TO run lldb we need to copy the interpreter to the current venv directory
# cp /Library/Frameworks/Python.framework/Versions/3.12/bin/python3.12 numpy-debug312/bin/python3.12

# #often used for building:
# pip uninstall numpy -y

# CFLAGS="-O0 -g" \
# CXXFLAGS="-O0 -g" \
# /Users/uddalok/Documents/PHD/scratch/numpy-debug/numpy-debug312/bin/python3.12 \
#     -m pip install -e . \
#     --no-build-isolation \
#     --config-settings=setup-args="-Dbuildtype=debug" \
#     --config-settings=setup-args="-Doptimization=0"
