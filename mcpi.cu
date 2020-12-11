//Author: Harindranath Ambalampitiya, PhD(Theoretical atomic and molecular physics)
//
#include <iostream>
#include<math.h>
#include<stdio.h>
#include<ctime>
#include<cstdlib>
#include <chrono> 
#include<curand_kernel.h>

using namespace std;
using namespace std::chrono;

// initialize random_number generator on the device
//each thread gets the same seed,but different sequence
__global__ void rng_init(curandState *state,int seed,int n)
{
	int id=blockIdx.x*blockDim.x+threadIdx.x;
	if(id<n)
	{
		curand_init(seed, id, 0, &state[id]);
	}
} 

//Let's calculate pi on the device
__global__ void mcpiKernel(curandState *state,int *a, int NSW,float r)
{		
	//Monte carlo region
	float xmin=-r,xmax=r,ymin=-r,ymax=r;
	int idx=blockIdx.x*blockDim.x+threadIdx.x;
	//copy state to local memory
	curandState localState = state[idx];
	
    int sum_in=0;
	for(int i=1;i<=NSW;i++)
	{
		//generate random numbers in the uniform grid (0,1]
		//for both x and y coordinates
		float ran0 = curand_uniform(&localState);
		float ran1 = curand_uniform(&localState);
		float x=xmin+(xmax-xmin)*ran0;
		float y=ymin+(ymax-ymin)*ran1;
		float d=sqrt(x*x+y*y);
		//printf("x,y: %f \t %f \n",x,y);
		if(d<=r)
			sum_in=sum_in+1;
	}
	//copy local memory to global
	state[idx] = localState;
	a[idx]=sum_in;
	//printf("inside: %i \n",sum_in);
}



float cudaPi(int N)
{
	// number of threads and blocks
	int block_size=256;
	int n_blocks=128;
	int n_procs=n_blocks*block_size;
	//memory allocation in the host and device
	
	size_t size=n_procs *sizeof(int);
	int* a_h=(int*)malloc(size);
	int* a_d;
	cudaMalloc((void **) &a_d, size);
	//random_states
	curandState *devStates;
	cudaMalloc((void **) &devStates, n_procs *sizeof(curandState));
	
	
	//number of sweeps that each graphic processor gets
	int nsw=N/n_procs+(N%n_procs==0 ? 0:1);
	
	//initialize the random numbers
	int s=12345;//seed
	rng_init<<<n_blocks,block_size>>>(devStates, s, n_procs);
	
	//pass it to parallel processing
	//each parallel unit counts how many points lie inside the circle
	float r=0.5;//circle radius
	
	mcpiKernel<<<n_blocks,block_size>>>(devStates,a_d,nsw,r);
	
	cudaMemcpy(a_h,a_d, sizeof(int)*n_procs,cudaMemcpyDeviceToHost);
	
	//number of points inside/outsie the circle
	float sum_in=0.;
	float sum_out=nsw*n_procs;
	
	for(int i=0;i<n_procs;i++)sum_in +=(float)a_h[i];
	
	//printf("sum in is %f \n sum out is %f \n",sum_in,sum_out);
	
	float pii=4.0f*(sum_in/sum_out);
	//now free-up the space
	free(a_h);
	cudaFree(a_d);
	
	return pii;
}

int main()
{
	auto start = high_resolution_clock::now();
	int N=10000000;
	float pii=cudaPi(N);
	auto stop = high_resolution_clock::now(); 
	auto duration = duration_cast<milliseconds>(stop - start);	
	printf("Pi value is: %f \n ",pii);	
	cout<<"Duration (ms)"<<"\t"<<duration.count()<<endl;
}