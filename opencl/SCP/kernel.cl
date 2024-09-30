__kernel void scalarProdGPU(
    __global float *d_C,
    __global float *d_A,
    __global float *d_B,
    int vectorN,
    int elementN,
    __local float *accumResult)  // Pass local memory as a kernel argument
{
    int global_id = get_global_id(0);  // Global thread ID
    int local_id = get_local_id(0);    // Local thread ID
    int group_id = get_group_id(0);    // Workgroup ID
    int group_size = get_local_size(0);  // Number of threads in workgroup

    // Loop over vectors
    for (int vec = group_id; vec < vectorN; vec += get_num_groups(0)) {
        int vectorBase = vec * elementN;
        int vectorEnd = vectorBase + elementN;

        // Each accumulator cycles through vectors
        for (int iAccum = local_id; iAccum < group_size; iAccum += group_size) {
            float sum = 0;

            // Sum element-wise products for the current accumulator
            for (int pos = vectorBase + iAccum; pos < vectorEnd; pos += group_size) {
                sum += d_A[pos] * d_B[pos];
            }

            accumResult[iAccum] = sum;
        }

        // Perform tree-like reduction of accumulators' results
        for (int stride = group_size / 2; stride > 0; stride >>= 1) {
            barrier(CLK_LOCAL_MEM_FENCE);

            if (local_id < stride) {
                accumResult[local_id] += accumResult[local_id + stride];
            }
        }

        // Write the result to global memory
        if (local_id == 0) {
            d_C[vec] = accumResult[0];
        }
    }
}

