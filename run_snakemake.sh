#!/bin/bash
# Script to run on barnacle

snakemake \
    -j 5 \
    --use-conda \
    --cluster-config cluster.yaml \
    --cluster "qsub -d scripts/ -V -l pmem={cluster.pmem} -l vmem={cluster.vmem} -l time={cluster.time} -l nodes={cluster.nodes} -j oe -o {cluster.out}"


