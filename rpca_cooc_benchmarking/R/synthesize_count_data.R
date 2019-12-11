library(SpiecEasi)

normalize_data <- function(data){
    # normalize counts to common scale (min depth)
    #
    # Parameters:
    # -----------
    #     data: matrix of raw count data
    #
    # Returns:
    # --------
    #     data_common_scale: matrix of count data scaled to minimum depth

    depths <- rowSums(data)
    data_norm <- t(apply(data, 1, norm_to_total))
    data_common_scale <- round(data_norm * min(depths))
    return(data_common_scale)
}

synthesize_data <- function(data, graph, distr="zinegbin", ...){
    # synthesize data according to NorTA procedure
    # "fit marginal distributions of count data to parametric statistical model"
    # "specify the underlying graphical model architecture"
    # (1) target correlation matrix, R
    # (2) target univariate marginal distribution, U_i
    # inverse transform sampling
    #
    # Parameters:
    # -----------
    #     data: matrix of count data scaled to minimum depth
    #     graph: adjacency matrix of target network topology
    #     distr: target marginal distribution
    #     ...: additional parameters to pass to synth_comm_from_counts
    #
    # Returns:
    # --------
    #     synth_data: synthesized data

    Prec <- graph2prec(graph)
    Cor <- cov2cor(prec2cov(Prec))

    synth_data <- synth_comm_from_counts(data, distr=distr, Sigma=Cor, ...)
}

