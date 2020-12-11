//Author: Harindranath Ambalampitiya, PhD(Theoretical atomic and molecular physics)
// c++ program to estimate pi (Serial version)
#include<iostream>
#include<math.h>
#include<ctime>
#include<cstdlib>
#include <chrono> 
using namespace std;
using namespace std::chrono;
auto start = high_resolution_clock::now();
float r=0.5;
float xmin=-r,xmax=r,ymin=-r,ymax=r;
//total number of sweeps
int N=10000000;
int N_in=0;
int main()
{
	srand(time(0));
	for (int i=1;i<N;i++)
	{
		float xi=xmin+(xmax-xmin)*(float)rand()/RAND_MAX;
		float yi=ymin+(ymax-ymin)*(float)rand()/RAND_MAX;
		float d=sqrt(xi*xi+yi*yi);
		if(d<=r)
			N_in=N_in+1;
	}
	
	float pii=4.*(float)N_in/(float)N;
	auto stop = high_resolution_clock::now(); 
	auto duration = duration_cast<milliseconds>(stop - start);
	
	printf("Pi value is: %f \n ",pii);
	
	cout<<"Duration (ms)"<<"\t"<<duration.count()<<endl;
	
	return 0;
}
