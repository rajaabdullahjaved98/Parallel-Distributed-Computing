#include <stdio.h>
#include <omp.h>
#include "Timer.h"

// CUDA kernel for matrix multiplication
__global__ void matrixMultiplication(int *A, int *B, int *C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < N && col < N) {
        int sum = 0;
        for (int k = 0; k < N; k++) {
            sum += A[row * N + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}

int main() {

    Timer gpuMulTime, cpuTime;
    initTimer(&gpuMulTime, "GPU Multiplication Time");
    initTimer(&cpuTime, "CPU Time for Initialization and Allocation: ");
    int N = 1024; // Size of the matrices

    int *h_A, *h_B, *h_C; // Host matrices
    int *d_A, *d_B, *d_C; // Device matrices

    //OMP Section for Host Memory Allocation and Data Initialization
    startTimer(&cpuTime);
    #pragma omp parallel sections
    {
    	#pragma omp section
    	{	
    		// Allocate host memory
    		h_A = (int*)malloc(N * N * sizeof(int));
    		h_B = (int*)malloc(N * N * sizeof(int));
    		h_C = (int*)malloc(N * N * sizeof(int));
    	}
    	
    	#pragma omp section
    	{
    		// Initialize host matrices with some values
    		for (int i = 0; i < N * N; i++) 
    		{
        		h_A[i] = i;
        		h_B[i] = i;
    		}		
    	}
    }	
    stopTimer(&cpuTime);

    // Allocate device memory
    cudaMalloc((void**)&d_A, N * N * sizeof(int));
    cudaMalloc((void**)&d_B, N * N * sizeof(int));
    cudaMalloc((void**)&d_C, N * N * sizeof(int));

    // Copy host matrices to device
    cudaMemcpy(d_A, h_A, N * N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, N * N * sizeof(int), cudaMemcpyHostToDevice);

    // Define block and grid dimensions
    dim3 blockSize(16, 16);
    dim3 gridSize((N + blockSize.x - 1) / blockSize.x, (N + blockSize.y - 1) / blockSize.y);

    // Launch kernel
    startTimer(&gpuMulTime);
    matrixMultiplication<<<gridSize, blockSize>>>(d_A, d_B, d_C, N);
    stopTimer(&gpuMulTime);

    // Copy result back to host
    cudaMemcpy(h_C, d_C, N * N * sizeof(int), cudaMemcpyDeviceToHost);

    // Print result (optional)
    /*for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", h_C[i * N + j]);
        }
        printf("\n");
    }*/

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    printTimer(gpuMulTime);
    printTimer(cpuTime);

    return 0;
}