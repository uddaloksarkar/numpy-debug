import numpy as np

import matplotlib.pyplot as plt

# Parameters
n = 2**62
p = 2**(-58)
num_samples = 10000

# Generate samples from binomial distribution
samples = {}
for i in range(num_samples):
    k = np.random.binomial(n, p)
    samples[k] = samples.get(k, 0) + 1

print(samples)

# Create histogram
fig, ax = plt.subplots(figsize=(15, 6))
plt.bar(samples.keys(), samples.values(), width=0.8, color='gray', alpha=0.7)
plt.xlabel('k')
plt.ylabel('Frequency')
plt.xticks(range(0, 45))
plt.xticks(range(0, 45, 5))
plt.xlabel('k', fontsize=20)
plt.ylabel('Frequency', fontsize=20)
plt.title('Binomial Distribution Samples', fontsize=23)
plt.show()