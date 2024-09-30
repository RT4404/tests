__kernel void jacobi(__global float* A, __global float* B, int n) {
    int i = get_global_id(0);
    int j = get_global_id(1);
    
    if (i > 0 && i < n - 1 && j > 0 && j < n - 1) {
        B[i * n + j] = 0.25f * (A[(i - 1) * n + j] + A[(i + 1) * n + j] + A[i * n + (j - 1)] + A[i * n + (j + 1)]);

        
    }
}


