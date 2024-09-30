#include <CL/cl.h>
#include <stdio.h>
#include <stdlib.h>

// Helper function to load the OpenCL kernel source code
const char* loadKernelSource(const char* filePath, size_t* kernelSize) {
    FILE* fp = fopen(filePath, "r");
    if (!fp) {
        printf("Error: Failed to open kernel file: %s\n", filePath);
        exit(1);
    }

    fseek(fp, 0, SEEK_END);
    *kernelSize = ftell(fp);
    rewind(fp);

    char* source = (char*)malloc(*kernelSize + 1);
    source[*kernelSize] = '\0';  // Null-terminate the source string
    fread(source, 1, *kernelSize, fp);  // Warning ignored as per previous conversation
    fclose(fp);

    return source;
}

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: %s -n <matrix_size>\n", argv[0]);
        return 1;
    }

    int matrixSize = atoi(argv[2]);
    printf("Matrix size passed: %d\n", matrixSize);

    if (matrixSize <= 0) {
        printf("Invalid matrix size: %d. Matrix size must be greater than 0.\n", matrixSize);
        return 1;
    }

    // Define OpenCL variables
    cl_platform_id platformId;
    cl_device_id deviceId;
    cl_context context;
    cl_command_queue commandQueue;
    cl_program program;
    cl_kernel kernel;
    cl_int err;

    // Get platform and device
    err = clGetPlatformIDs(1, &platformId, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clGetPlatformIDs failed\n");
        return 1;
    }

    err = clGetDeviceIDs(platformId, CL_DEVICE_TYPE_GPU, 1, &deviceId, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clGetDeviceIDs failed\n");
        return 1;
    }

    // Create context and command queue
    context = clCreateContext(NULL, 1, &deviceId, NULL, NULL, &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateContext failed\n");
        return 1;
    }

    commandQueue = clCreateCommandQueue(context, deviceId, 0, &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateCommandQueue failed\n");
        return 1;
    }

    // Load the kernel source
    size_t kernelSize;
    const char* kernelSource = loadKernelSource("kernel.cl", &kernelSize);

    // Create and build program
    program = clCreateProgramWithSource(context, 1, &kernelSource, &kernelSize, &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateProgramWithSource failed\n");
        return 1;
    }

    err = clBuildProgram(program, 1, &deviceId, NULL, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clBuildProgram failed\n");
        return 1;
    }

    // Create kernel
    kernel = clCreateKernel(program, "jacobi", &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateKernel!\n");
        return 1;
    }

    // Define the matrix and buffers
    size_t dataSize = matrixSize * matrixSize * sizeof(float);
    float* inputMatrix = (float*)malloc(dataSize);
    float* outputMatrix = (float*)malloc(dataSize);

    cl_mem inputBuffer = clCreateBuffer(context, CL_MEM_READ_WRITE, dataSize, NULL, &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateBuffer (input) failed\n");
        return 1;
    }

    cl_mem outputBuffer = clCreateBuffer(context, CL_MEM_READ_WRITE, dataSize, NULL, &err);
    if (err != CL_SUCCESS) {
        printf("Error: clCreateBuffer (output) failed\n");
        return 1;
    }

    // Initialize input matrix
    for (int i = 0; i < matrixSize * matrixSize; i++) {
        inputMatrix[i] = (float)(i % matrixSize);
    }

    // Copy input matrix to device
    err = clEnqueueWriteBuffer(commandQueue, inputBuffer, CL_TRUE, 0, dataSize, inputMatrix, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clEnqueueWriteBuffer (input) failed\n");
        return 1;
    }

    // Set kernel arguments
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &inputBuffer);
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &outputBuffer);
    err |= clSetKernelArg(kernel, 2, sizeof(int), &matrixSize);
    if (err != CL_SUCCESS) {
        printf("Error: clSetKernelArg failed\n");
        return 1;
    }

    // Define global and local work sizes
    size_t globalWorkSize[2] = {matrixSize, matrixSize};
    size_t localWorkSize[2] = {4, 4};  // Ensure this fits within Vortex's 16 work items limit

    printf("Launching kernel with globalWorkSize: %zu, %zu and localWorkSize: %zu, %zu\n", 
           globalWorkSize[0], globalWorkSize[1], localWorkSize[0], localWorkSize[1]);

    // Execute the kernel
    err = clEnqueueNDRangeKernel(commandQueue, kernel, 2, NULL, globalWorkSize, localWorkSize, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clEnqueueNDRangeKernel failed with code %d\n", err);
        return 1;
    }

    // Wait for the kernel to finish
    err = clFinish(commandQueue);
    if (err != CL_SUCCESS) {
        printf("Error: clFinish failed\n");
        return 1;
    }

    // Read the output matrix back to host
    err = clEnqueueReadBuffer(commandQueue, outputBuffer, CL_TRUE, 0, dataSize, outputMatrix, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clEnqueueReadBuffer (output) failed\n");
        return 1;
    }

    // Print the output matrix (for debugging purposes)
    printf("Jacobi result matrix:\n");
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            printf("%f ", outputMatrix[i * matrixSize + j]);
        }
        printf("\n");
    }

    // Clean up
    clReleaseMemObject(inputBuffer);
    clReleaseMemObject(outputBuffer);
    clReleaseKernel(kernel);
    clReleaseProgram(program);
    clReleaseCommandQueue(commandQueue);
    clReleaseContext(context);
    free(inputMatrix);
    free(outputMatrix);
    free((void*)kernelSource);

    return 0;
}

