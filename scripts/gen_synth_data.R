library(SpiecEasi)

args <- commandArgs(trailingOnly=TRUE)
if ( length(args) == 0 ){
    stop("Must provide topology!")
}

data_loc <- args[1]
out_dir <- args[2]
out_name <- args[3]
topology <- args[4]

print(args)

#setwd("/home/grahman/projects/rpca_cooc_benchmarking/scripts")
source("../rpca_cooc_benchmarking/R/synthesize_count_data.R")

dir.create(paste(out_dir, topology, sep="/"), recursive=T)
data <- read.csv(data_loc, header=T, row.names=1)
sample_names <- rownames(data)
feature_names <- colnames(data)
data.norm <- normalize_data(as.matrix(data))

create_dataset <- function(data, feature_names, e, topology){
    # data: normalized dataset
    # e: number of edges
    # topology: topology with which to create graph

    d <- ncol(data)
    set.seed(42)
    graph <- SpiecEasi::make_graph(topology, d, e)

    adj_list <- graph_to_adj_list(as.matrix(graph))

    synth_data <- synthesize_data(
        data,
        graph,
        distr="zinegbin"
    )

    return(list(synth_data=synth_data, adj_list=adj_list))
}

d <- ncol(data.norm)
count <- 0
for ( e in round(seq(d/2 + 1, d, length.out=10)) ){
    print(paste0("Number of edges: ", e))

    out_base <- paste0(
        out_dir,
        topology,
        "/",
        out_name,
        "_",
        topology,
        "_",
        count
    )

    out_data <- paste0(out_base, "_sim_data.csv")
    out_adj_list <- paste0(out_base, "_sim_adj_list.csv")

    current_time <- proc.time()

    synth_output <- create_dataset(data.norm, feature_names, e, topology)
    synth_data <- as.data.frame(synth_output$synth_data)
    rownames(synth_data) <- paste0("V", rownames(synth_data))
    adj_list <- synth_output$adj_list

    write.csv(
        synth_data,
        out_data,
        row.names=T
    )

    write.csv(
        adj_list,
        out_adj_list,
        row.names=F
    )

    print(proc.time() - current_time)
    count <- count + 1
}
