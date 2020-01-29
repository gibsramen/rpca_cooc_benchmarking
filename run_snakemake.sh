# Script to run on barnacle

RULE=$1
J=$2
EXTRA_PARAMS=$3

if [ -z "$RULE" ]
then
    echo "Must input a rule!"
    exit 1
fi

if [ -z "$J" ]
then
    J=10
fi

snakemake \
    $RULE \
    -j $J \
    $EXTRA_PARAMS \
    --latency-wait 60 \
    --use-conda \
    --cluster-config config/cluster.yaml \
    --cluster "qsub -V -l pmem={cluster.pmem} -l vmem={cluster.vmem} -l walltime={cluster.time} -l nodes={cluster.nodes} -j oe -o {cluster.out} -N {cluster.name} -m abe -M grahman@eng.ucsd.edu"


