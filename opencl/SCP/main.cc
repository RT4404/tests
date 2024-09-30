#include <CL/cl.h>
#include <stdio.h>
#include <stdlib.h>

#define ACCUM_N 1024

// Error checking macro
#define CHECK_ERROR(err, msg) \
    if (err != CL_SUCCESS) { \
        printf("Error: %s (%d)\n", msg, err); \
        exit(EXIT_FAILURE); \
    }

int main() {
    // Vector and element dimensions
    int vectorN = 4;
    int elementN = 4;

    // OpenCL setup
    cl_platform_id platform;
    cl_device_id device;
    cl_context context;
    cl_command_queue queue;
    cl_program program;
    cl_kernel kernel;
    cl_int err;

    // Allocate host memory
    size_t size_A = vectorN * elementN * sizeof(float);
    size_t size_B = vectorN * elementN * sizeof(float);
    size_t size_C = vectorN * sizeof(float);

    float *h_A = (float *)malloc(size_A);
    float *h_B = (float *)malloc(size_B);
    float *h_C = (float *)malloc(size_C);

    // Initialize input data
    for (int i = 0; i < vectorN * elementN; i++) {
        h_A[i] = (float)(i % 10);
        h_B[i] = (float)(i % 5);
    }

    // Set up OpenCL platform, device, and context
    err = clGetPlatformIDs(1, &platform, NULL);
    CHECK_ERROR(err, "Failed to get platform");

    err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, NULL);
    CHECK_ERROR(err, "Failed to get device");

    context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);
    CHECK_ERROR(err, "Failed to create context");

    queue = clCreateCommandQueue(context, device, 0, &err);
    CHECK_ERROR(err, "Failed to create command queue");

    // Load kernel source code from file
    FILE *kernelFile = fopen("kernel.cl", "r");
    fseek(kernelFile, 0, SEEK_END);
    size_t kernel_size = ftell(kernelFile);
    rewind(kernelFile);

    char *kernel_source = (char *)malloc(kernel_size + 1);
    fread(kernel_source, 1, kernel_size, kernelFile);
    kernel_source[kernel_size] = '\0';
    fclose(kernelFile);

    // Create program from kernel source
    program = clCreateProgramWithSource(context, 1, (const char **)&kernel_source, &kernel_size, &err);
    CHECK_ERROR(err, "Failed to create program");

    // Build the OpenCL program
    err = clBuildProgram(program, 1, &device, NULL, NULL, NULL);
    if (err != CL_SUCCESS) {
        size_t log_size;
        clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, 0, NULL, &log_size);
        char *log = (char *)malloc(log_size);
        clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, log_size, log, NULL);
        printf("Build log:\n%s\n", log);
        free(log);
        exit(EXIT_FAILURE);
    }

    // Create the OpenCL kernel
    kernel = clCreateKernel(program, "scalarProdGPU", &err);
    CHECK_ERROR(err, "Failed to create kernel");

    // Create device buffers
    cl_mem d_A = clCreateBuffer(context, CL_MEM_READ_ONLY, size_A, NULL, &err);
    CHECK_ERROR(err, "Failed to create buffer d_A");

    cl_mem d_B = clCreateBuffer(context, CL_MEM_READ_ONLY, size_B, NULL, &err);
    CHECK_ERROR(err, "Failed to create buffer d_B");

    cl_mem d_C = clCreateBuffer(context, CL_MEM_WRITE_ONLY, size_C, NULL, &err);
    CHECK_ERROR(err, "Failed to create buffer d_C");

    // Write input data to device
    err = clEnqueueWriteBuffer(queue, d_A, CL_TRUE, 0, size_A, h_A, 0, NULL, NULL);
    CHECK_ERROR(err, "Failed to write buffer d_A");

    err = clEnqueueWriteBuffer(queue, d_B, CL_TRUE, 0, size_B, h_B, 0, NULL, NULL);
    CHECK_ERROR(err, "Failed to write buffer d_B");

    // Query max local memory size
    cl_ulong local_mem_size;
    clGetDeviceInfo(device, CL_DEVICE_LOCAL_MEM_SIZE, sizeof(cl_ulong), &local_mem_size, NULL);
    printf("Max local memory size: %lu bytes\n", local_mem_size);

    // Set kernel arguments
    clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_C);
    clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_A);
    clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_B);
    clSetKernelArg(kernel, 3, sizeof(int), &vectorN);
    clSetKernelArg(kernel, 4, sizeof(int), &elementN);
    clSetKernelArg(kernel, 5, sizeof(float) * 16, NULL);  // Pass local memory for 16 floats

    // Query max workgroup size
    size_t max_workgroup_size;
    clGetDeviceInfo(device, CL_DEVICE_MAX_WORK_GROUP_SIZE, sizeof(size_t), &max_workgroup_size, NULL);
    printf("Max workgroup size: %zu\n", max_workgroup_size);

    // Set work sizes
    size_t global_size = 16;  // This should match the problem size
    size_t local_size = 16;   // Adjusted to fit within the max workgroup size

    // Ensure the local work size does not exceed max workgroup size
    if (local_size > max_workgroup_size) {
        printf("Error: Local work size exceeds device's maximum workgroup size\n");
        exit(EXIT_FAILURE);
    }

    // Execute the kernel
    err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL);
    CHECK_ERROR(err, "Failed to enqueue kernel");

    // Read the result back to host
    err = clEnqueueReadBuffer(queue, d_C, CL_TRUE, 0, size_C, h_C, 0, NULL, NULL);
    CHECK_ERROR(err, "Failed to read buffer d_C");

    // Print result
    printf("Scalar product results:\n");
    for (int i = 0; i < vectorN; i++) {
        printf("C[%d] = %f\n", i, h_C[i]);
    }

    // Cleanup
    clReleaseMemObject(d_A);
    clReleaseMemObject(d_B);
    clReleaseMemObject(d_C);
    clReleaseKernel(kernel);
    clReleaseProgram(program);
    clReleaseCommandQueue(queue);
    clReleaseContext(context);

    free(h_A);
    free(h_B);
    free(h_C);
    free(kernel_source);

    return 0;
}

