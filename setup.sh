# download numpy
git clone git@github.com:uddaloksarkar/numpy.git 
cd numpy
git submodule update --init --recursive    

# setup venv and install spin (a developer tool for numpy)
cd ..
module load python/3.12.14 # if running on cluster
python3.12 -m venv numpy-debug312
source numpy-debug312/bin/activate
cd numpy

# install testing dependencies
python3.12 -m pip install pytest
python3.12 -m pip install hypothesis

# build numpy using spin and run tests
python3.12 -m pip install spin
spin build --clean -- -Dbuildtype=debug -Ddisable-optimization=true
spin test -v
spin test numpy/random  # to run the tests in a specific module
spin test -v -t numpy/_core/tests/test_nditer.py::test_iter_c_order
spin test -p auto # to run tests in parallel threads using pytest-run-parallel



# without using spin, we can also build and install numpy in the venv using pip
python3.12 -m pip install meson meson-python ninja cython pytest setuptools
CFLAGS="-O0 -g" python3.12 -m pip install -e . --no-build-isolation

# get other required packages
python3.12 -m pip install matplotlib 

# TO run lldb we need to copy the interpreter to the current venv directory
cp /Library/Frameworks/Python.framework/Versions/3.12/bin/python3.12 numpy-debug312/bin/python3.12

#often used for building:
pip uninstall numpy -y

CFLAGS="-O0 -g" \
CXXFLAGS="-O0 -g" \
/Users/uddalok/Documents/PHD/scratch/numpy-debug/numpy-debug312/bin/python3.12 \
    -m pip install -e . \
    --no-build-isolation \
    --config-settings=setup-args="-Dbuildtype=debug" \
    --config-settings=setup-args="-Doptimization=0"


# How to debug with gdb:

# 1. Build numpy with debug symbols (as shown above).
# 2. Start gdb with the Python interpreter:
gdb python3.12

# 3. Set the stop-on-solib-events to 1 to stop when shared libraries are loaded:
(gdb) set stop-on-solib-events 1
(gdb) run check_rnd.py

# 4. wihtout stop-on-solib-events, we can also set a breakpoint in the numpy C code and run the test script:
(gdb) set breakpoint pending on
(gdb) break legacy_random_binomial_original
(gdb) run check_rnd.py