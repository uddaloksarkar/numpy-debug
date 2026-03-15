#!/usr/bin/env bash
set -e

USE_SPIN=false

# parse arguments
for arg in "$@"; do
    case $arg in
        --spin)
            USE_SPIN=true
            shift
            ;;
    esac
done

echo "Checking for Python 3.12..."

if command -v python3.12 >/dev/null 2>&1; then
    PYTHON=python3.12
else
    echo "Python 3.12 not found. Attempting to load module..."
    
    if command -v module >/dev/null 2>&1; then
        module load python/3.12.14 || true
    fi

    if command -v python3.12 >/dev/null 2>&1; then
        PYTHON=python3.12
    else
        echo "Error: Python 3.12 is required but was not found."
        exit 1
    fi
fi

echo "Using $PYTHON"

# create virtual environment if it does not exist
if [ ! -d "numpy-debug312" ]; then
    echo "Creating virtual environment..."
    $PYTHON -m venv numpy-debug312
fi

echo "Activating virtual environment..."
source numpy-debug312/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing dependencies..."
pip install meson meson-python ninja cython pytest setuptools hypothesis matplotlib

if [ "$USE_SPIN" = true ]; then
    echo "Installing spin..."
    pip install spin

    echo "Building NumPy using spin (debug build)..."
    spin build --clean -- -Dbuildtype=debug -Ddisable-optimization=true
else
    echo "Building NumPy without spin..."
    CFLAGS="-O0 -g" pip install -e . --no-build-isolation
fi

echo "Setup complete."
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
