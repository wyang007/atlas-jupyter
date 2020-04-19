## Prototype of ATLAS Jupyter in a Singularity container

This is a proof-of-concept prototype of an ATLAS Jupyter environment in a Singularity container. The goal is to find out how we put things together. The real operation envirnoments aren't necessarily inside a Singularity container. It could be a Docker container, or not container at all. 

## What are included or are not included in this prototype

Keep in mind that this is a prototype for the purpose of proof-of-concept. 

### It will include:

* Python3
* JupyterLab (Terminal and Markdown are included)
* PyROOT and C++ ROOT in notebook
* uproot
* TensorFlow
* Keras
* dask
* Available via Terminal, python2.7/python3, gcc/g++, gdb, make, cmake3, xrootd-clients, openssh-client, curl, vi, etc.

#### Compiling ROOT

The integration of PyROOT and C++ ROOT into JupyterLab is done via a bind mount at /mycvmfs (/mycvmfs will be replaced by a real path in the future). ROOT is not installed when the container is first built. Instead, once we have a container, we go inside the container and run compile_root.sh to build and save the ROOT in /mycvmfs - so that we only need to build ROOT once.

/cvmfs is expected to be bind mount as well.

### It will not include:

* Support sites' authenticaion mechanisms (such as LDAP) are not included.
* Not sure whether we can easily include support of the batch submission. This could affect "dask".

## How to build and use

1. Initial build: 

   `sudo -s`

   `export PATH=$PATH:/sbin`
   
   `singularity build mycontainer.img jupyter-prototype.singularity.def`
   
   This will build a compressed image of ~1GB.
   
2. Make sure directory `/dir/mycvmfs` is available. Then run: 

   `singularity exec -B /dir/mycvmfs:/mycvmfs mycontainer.img sh /mycvmfs/compile_root.sh`

   This step take a long time. It will build ROOT, and complete the build process. It will save ~750MB of compiled ROOT to `/dir/mycvmfs/pkgs`.

   In the future one may need to repeat step 1, but as long as python3 and gcc/g++ versions don't have major change in step 1, step 2 doesn't need to be repeated.
   
3. To start the container, run:

   `singularity run -B /dir/mycvmfs:/mycvmfs mycontainer.img`
   
   This will print out a line like this
   
   `http://127.0.0.1:8888/?token=ce196dd742643ff2ff3ffbf228dcb6fa7b6aa68a68f5f62d`
   
4. To access the JupyterLab from desktop/laptop,
   
   a. ssh -L 8888:localhost:8888 host_that_run_singularity
   
   b. Point web browser to `http://127.0.0.1:8888/?token=ce196dd742643ff2ff3ffbf228dcb6fa7b6aa68a68f5f62d`