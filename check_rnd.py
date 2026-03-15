import os
import signal
import numpy as np

print("numpy from:", np.__file__)

def do_nothing(*args):
    pass

signal.signal(signal.SIGUSR1, do_nothing)
os.kill(os.getpid(), signal.SIGUSR1)

x = np.random.binomial(2**62, 2**(-58))
print("result:", x)
