#!/usr/bin/env Rscript
library(optparse)

R_FILE_DIR <- "../rpca_cooc_benchmarking/R/"
source(paste0(R_FILE_DIR, "synthesize_count_data.R"))

option_list <- list(
    make_option(
        c("-c", "--counts"),
        type = "character",
        help = "Feature count matrix file"
    ),
    make_option(
        c("-t", "--topology"),
        type = "character",
        help = "Target graph topology (cluster/band/scale-free)"
    ),
    make_option(
        c("-d", "--distribution"),
        type = "character",
        default = "zinegbin",
        help = "Target univariate distribution"
    ),
    make_option(
        c("-e", "--edge_proportion"),
        type = "numeric",
        default = 1,
        help = "Proportion of edges to include relative to number of nodes"
    ),
    make_option(
        c("-o", "--output"),
        type = "character",
        help = "Output file"
    )
)

opt.parser = OptionParser(option_list=option_list)
opt = parse_args(opt.parser)
print(opt)

if (!is.null(opt$counts)) {
    data <- read.csv(opt$counts)
    sample_names <- rownames(data)
    feature_names <- colnames(data)
    data <- as.matrix(data)
    data.norm <- normalize_data(data)
} else {
    data <- amgut1.filt
    sample_names <- rownames(data)
    feature_names <- colnames(data)
    data.norm <- normalize_data(amgut1.filt)
}

d <- ncol(data.norm)
if (opt$edge_proportion < 0.5){
    stop("Edge proportion must be at least 0.5")
}
graph <- make_graph(opt$topology, d, opt$edge_proportion*d)

synth_data <- synthesize_data(
    data.norm,
    graph,
    distr=opt$distribution
)

synth_data <- as.data.frame(synth_data)
rownames(synth_data) <- sample_names
colnames(synth_data) <- feature_names

write.csv(synth_data, opt$output)
