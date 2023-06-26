#include <iostream>
#include "Timer.h"
using namespace std;

#define r 500
#define c 100

//Initialize Matrix A
void init1(int mat1[r][c])
{
	for (int i = 0; i < r; ++i)
	{
		for (int j = 0; j < c; ++j)
		{
			mat1[i][j] = rand() % 1024;
		}
	}
}

//Initialize Matrix B
void init2(int mat2[c][r])
{
	for (int i = 0; i < c; ++i)
	{
		for (int j = 0; j < r; ++j)
		{
			mat2[i][j] = rand() % 1024;
		}
	}
}

//Initialize Product Matrix to 0
void init3(int prod[r][r])
{
	for (int i = 0; i < r; ++i)
	{
		for (int j = 0; j < r; ++j)
		{
			prod[i][j] = 0;
		}
	}
}

//Multiply Matrix A and B
void mat_mul(int mat1[r][c], int mat2[c][r], int prod[r][r])
{
	for (int i = 0; i < r; i++)
	{
		for (int j = 0; j < r; ++j)
		{
			for (int k = 0; k < c; ++k)
			{
				prod[i][j] += mat1[i][k] * mat2[k][j];
			}
		}
	}
}

int main()
{
	Timer cpuTime("CPU EXecution Time: ");
	int matA[r][c];
	int matB[c][r];
	int prodMat[r][r];

	init1(matA);
	init2(matB);
	init3(prodMat);

	cpuTime.Start();
	mat_mul(matA, matB, prodMat);
	cpuTime.Stop();

	cpuTime.Print();
	return 0;
}