import numpy as np

# -----------------------------
# INPUT MATRIX
# -----------------------------

n = int(input("Enter matrix size n: "))

print("Enter the matrix row by row:")

A = np.zeros((n, n))

for i in range(n):
    row = list(map(float, input(f"Row {i+1}: ").split()))
    A[i, :] = row

# -----------------------------
# INITIALIZATION
# -----------------------------

Ak = A.copy()
Q_total = np.eye(n)

tol = 1e-8
k = 0

# -----------------------------
# QR ITERATION LOOP
# -----------------------------

while True:

    # --------------------------------
    # CONVERGENCE CHECK
    # --------------------------------

    subdiag_max = 0

    for i in range(1, n):
        subdiag_max = max(subdiag_max, abs(Ak[i, i-1]))

    if subdiag_max < tol:
        break

    # --------------------------------
    # SIMPLE SHIFT
    # --------------------------------

    mu = Ak[n-1, n-1]

    B = Ak - mu*np.eye(n)

    # --------------------------------
    # GRAM–SCHMIDT QR
    # --------------------------------

    Q = np.zeros((n, n))
    R = np.zeros((n, n))

    for j in range(n):

        u = B[:, j].copy()

        for i in range(j):

            r = np.dot(Q[:, i], B[:, j])
            R[i, j] = r
            u = u - r * Q[:, i]

        norm = np.sqrt(np.sum(u**2))
        R[j, j] = norm

        # FIX: avoid division by zero
        if norm > 1e-12:
            Q[:, j] = u / norm
        else:
            Q[:, j] = 0

    # --------------------------------
    # RQ UPDATE
    # --------------------------------

    Ak = R @ Q + mu*np.eye(n)

    # --------------------------------
    # ACCUMULATE EIGENVECTORS
    # --------------------------------

    Q_total = Q_total @ Q

    k += 1


# -----------------------------
# OUTPUT
# -----------------------------

eigenvalues = np.diag(Ak)

print("\nFinal Matrix (Nearly Upper Triangular):")
print(np.round(Ak,6))

print("\nEigenvalues:")
print(np.round(eigenvalues,6))

print("\nEigenvectors (columns):")
print(np.round(Q_total,6))

print("\nTotal iterations required:",k)