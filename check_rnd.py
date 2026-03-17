import os
import signal
import numpy as np
import sys

print("numpy from:", np.__file__)


def do_nothing(*args):
    pass

# signal.signal(signal.SIGUSR1, do_nothing)
# os.kill(os.getpid(), signal.SIGUSR1)

n = int(sys.argv[1]) if len(sys.argv) > 1 else 62
p = float(sys.argv[2]) if len(sys.argv) > 2 else 57

n = 2**n
p = 2**(-p)

x = np.random.binomial(n, p, size=40)
print("np :", n * p)
print("result:", x)
