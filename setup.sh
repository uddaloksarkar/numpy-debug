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

echo "Checking for Python >= 3.12..."

python_is_ge_312() {
    "$1" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)' \
        >/dev/null 2>&1
}

find_python_ge_312() {
    local candidate

    for candidate in python3 python3.12 python3.13 python3.14 python3.15 python; do
        if command -v "$candidate" >/dev/null 2>&1 && python_is_ge_312 "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    while IFS= read -r candidate; do
        if command -v "$candidate" >/dev/null 2>&1 && python_is_ge_312 "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done < <(compgen -c | grep -E '^python3(\.[0-9]+)?$|^python$' | sort -u)

    return 1
}

if PYTHON="$(find_python_ge_312)"; then
    :
else
    echo "Python >= 3.12 not found. Attempting to load module..."

    if command -v module >/dev/null 2>&1; then
        module load python/3.12 || true
    fi

    if ! PYTHON="$(find_python_ge_312)"; then
        echo "Error: Python >= 3.12 is required but was not found."
        exit 1
    fi
fi

echo "Using $PYTHON"

PYTHON_VERSION="$("$PYTHON" -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
VENV_DIR="numpy-debug${PYTHON_VERSION}"

echo "Using virtual environment: $VENV_DIR"

# create virtual environment if it does not exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    "$PYTHON" -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing dependencies..."
pip install meson meson-python ninja cython pytest setuptools hypothesis matplotlib

# clone numpy if it does not exist
if [ ! -d "numpy" ]; then
    echo "Cloning NumPy repository..."
    git clone git@github.com:uddaloksarkar/numpy.git
    cd numpy
    git submodule update --init --recursive
else
    echo "NumPy repository already exists. Skipping clone."
    cd numpy
    git pull
    git submodule update --init --recursive
fi

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
# cp /Library/Frameworks/Python.framework/Versions/3.12/bin/python3.12 "$VENV_DIR/bin/python3.12"

# #often used for building:
# pip uninstall numpy -y

# CFLAGS="-O0 -g" \
# CXXFLAGS="-O0 -g" \
# /Users/uddalok/Documents/PHD/scratch/numpy-debug/$VENV_DIR/bin/python3.12 \
#     -m pip install -e . \
#     --no-build-isolation \
#     --config-settings=setup-args="-Dbuildtype=debug" \
#     --config-settings=setup-args="-Doptimization=0"
