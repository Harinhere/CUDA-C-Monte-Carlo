# CUDA-C-Monte-Carlo with CuRand

Make your laptop a Super computer!

In this project, a parallel Monte Carlo code was created to numerically compute the value of pi up to two decimal places.
The parallel code was implemented using NVIDIA GeForce 940mx graphic processor with CUDA programming. The serial C++ code (mcpi.cc) took
840 ms to finish (with N=10e7 random samples) while the parallel code (mcpi.cu) took only about 260 ms (with same N and 128*256 number of parallel threads).

The Monte Carlo approach to compute pi is straight forward and is commented on the code.

To run mcpi.cc, Use: g++ mpci.cc 
and for mcpi.cu, Use : nvcc mpci.cu

In both cases, an executable file "a.exe" will be created.


The parallel code is transparent and can be easily modified to run more complicated calculations inlvolving Monte Carlo simulations (especially in atomic and molecular physics problems).

