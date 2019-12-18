#!/home/grahman/.conda/envs/rpca_cooc/bin/Rscript

#PBS -V
#PBS -N test_gen_synthetic_data
#PBS -m abe
#PBS -M grahman@eng.ucsd.edu
#PBS -l pmem=8gb
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=4
#PBS -j oe
#PBS -o out/

library(SpiecEasi)

setwd("/home/grahman/projects/rpca_cooc_benchmarking/scripts")
source("../rpca_cooc_benchmarking/R/synthesize_count_data.R")
data <- read.csv("../data/processed/qiita103/88_soils_filt.csv", header=T, row.names=1)
sample_names <- rownames(data)
feature_names <- colnames(data)
data.norm <- normalize_data(as.matrix(data))

d <- ncol(data.norm)
e <- d

set.seed(42)
graph <- make_graph("cluster", d, e)

ptm <- proc.time()
synth_data <- synthesize_data(
    data.norm,
    graph,
    distr="zinegbin"
)

t <- proc.time() - ptm
print(t)

rownames(synth_data) <- sample_names
colnames(synth_data) <- feature_names

write.csv(synth_data, "../data/simulated/qiita103/88_soils_filt_sim2.csv", row.names=T)
