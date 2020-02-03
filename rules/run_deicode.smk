import biom
import pandas as pd
import skbio

from deicode.rpca import auto_rpca
import rpca_cooc_benchmarking as rcb


def load_biom(feature_csv):
    df = pd.read_csv(feature_csv, index_col=0)
    samples = list(df.index)
    features = list(df.columns)
    b = biom.table.Table(df.T.values, features, samples)
    return b

rule get_feature_matrix:
    input:
        SIM + (
            "{qiita_id}/{topology}/{qiita_id}_{topology}_{num}"
            "_sim_data.csv"
        )
    output:
        RES + (
            "{qiita_id}/{topology}/rpca_feature_matrices/"
            "{qiita_id}_{topology}_{num}_rpca_feat_mat.csv"
        )
    run:
        ordination, samp_mat, feat_mat = auto_rpca(
            table=load_biom(input[0]),
        )
        feat_mat_df = feat_mat.to_data_frame()
        feat_mat_df.to_csv(output[0], index=True)

rule create_roc:
    input:
        adj_list= SIM + (
            "{qiita_id}/{topology}/{qiita_id}_{topology}_{num}"
            "_sim_adj_list.csv"
        ),
        feat_mat = RES + (
            "{qiita_id}/{topology}/rpca_feature_matrices/"
            "{qiita_id}_{topology}_{num}_rpca_feat_mat.csv"
        )
    output:
        RES + (
            "{qiita_id}/{topology}/roc/{qiita_id}_{topology}_{num}_roc.png"
        )
    run:
        adj_df = pd.read_csv(input.adj_list)
        feat_mat = pd.read_csv(input.feat_mat, index_col=0)
        fpr, tpr, thresholds, auc = rcb.get_roc_curve(
            adj_df,
            feat_mat,
            feat_mat.shape[0],
        )
        rcb.plot_roc(fpr, tpr, thresholds, auc, output[0])
