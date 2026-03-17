# NumPy Debug Build and Testing Setup

This guide explains how to clone NumPy, build it with debug symbols, run tests, and debug the C code using `gdb`.

## 1. Setup

Run the following bash file to build the debug environment.
```bash
./setup.sh
```

You can also use `spin` to build the environment as mentioned in the [official website](https://numpy.org/doc/stable/building/index.html). I prefer the *vanilla* approach.

```bash
./setup.sh --spin
```


If the arguments are provided correctly, the script will automatically:

* create the required Python virtual environment,
* install all necessary dependencies,
* configure the development environment,
* and build NumPy with the appropriate debug configuration.

After the script finishes successfully, the environment will be ready for building, running tests, and debugging.
 

## 2. Debugging with GDB

#### Start Virtual Enviroment and GDB with Python

```bash
source numpy-debug312/bin/activate
gdb python3.14
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

## 3. Debugging with LLDB

You can follow the exact similar procedure as above to load the environment. The `lldb` commands are highlighted.

```bash
source numpy-debug312/bin/activate
lldb -- python3.14
```

```lldb
(lldb) breakpoint set --name legacy_random_binomial_original
(lldb) run check_rnd.py
(lldb) continue
```


---

## Notes

* NumPy must be compiled with debug flags (`-O0 -g`) for effective debugging (look inside `setup.sh`)
* Breakpoints can be set directly in NumPy C functions once the shared libraries are loaded.
* When probing into the `random` module keep it in mind that the actual distributions used are in the **legacy directory**. Fit breakpoints accordingly in `numpy/numpy/lib/random/src/legacy/legacy-distributions.c`.
