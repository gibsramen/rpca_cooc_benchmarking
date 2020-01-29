import biom
import pandas as pd
import skbio

from deicode.rpca import auto_rpca


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
