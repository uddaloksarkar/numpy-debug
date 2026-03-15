# NumPy Debug Build and Testing Setup

This guide explains how to clone NumPy, build it with debug symbols, run tests, and debug the C code using `gdb`.

## 1. Setup
#### Create a Python Virtual Environment

If Python 3.12 is not already available in your environment, load it first:

```bash
module load python/3.12.14
```

Create and activate a virtual environment:

```bash
python3.12 -m venv numpy-debug312
source numpy-debug312/bin/activate
```

#### Set Up the Debug Environment

Using `spin`:

```bash
./setup.sh --spin
```

Without `spin` (**recommended**):

```bash
./setup.sh
```

If the arguments are provided correctly, the script will automatically:

* create the required Python virtual environment,
* install all necessary dependencies,
* configure the development environment,
* and build NumPy with the appropriate debug configuration.

After the script finishes successfully, the environment will be ready for building, running tests, and debugging.
 

#### Install Additional Packages (if Required)

```bash
python3.12 -m pip install matplotlib
```

## 2. Debugging with GDB

#### Start GDB with Python

```bash
gdb python3.12
```

#### Stop when shared libraries are loaded

For example, if you are debugging the `legacy_random_binomial_original` you might need to look for a shared library `_generator.cpython-312-x86_64-linux-gnu.so` by continuing.
```gdb
(gdb) set stop-on-solib-events 1
(gdb) run check_rnd.py
(gdb) continue
```

#### Alternatively, set breakpoints directly in NumPy C code 

```gdb
(gdb) set breakpoint pending on
(gdb) break legacy_random_binomial_original
(gdb) run check_rnd.py
(gdb) continue
```

---

## Notes

* NumPy must be compiled with debug flags (`-O0 -g`) for effective debugging (look inside `setup.sh`)
* Breakpoints can be set directly in NumPy C functions once the shared libraries are loaded.
