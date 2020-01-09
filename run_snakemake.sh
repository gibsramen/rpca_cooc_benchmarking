#!/bin/bash
# Script to run on barnacle

snakemake \
    -j 5 \
    --latency-wait 60 \
    --use-conda \
    --cluster-config cluster.yaml \
    --cluster "qsub -V -l pmem={cluster.pmem} -l vmem={cluster.vmem} -l walltime={cluster.time} -l nodes={cluster.nodes} -j oe -o {cluster.out} -N {cluster.name} -m abe -M grahman@eng.ucsd.edu"


