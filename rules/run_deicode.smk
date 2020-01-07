import biom
import pandas as pd
import skbio

from deicode.rpca import rpca


def load_biom(feature_csv):
    df = pd.read_csv(feature_csv, index_col=0)
    samples = list(df.index)
    features = list(df.columns)
    b = biom.table.Table(df.T.values, features, samples)
    return biom

rule make_feature_matrix_dirs:
    output:
        directory(
            expand(
                RES + "{qiita_id}/{topology}/rpca_feature_matrices",
                qiita_id=ALL_IDS,
                topology=config["topologies"],
            ),
        )
    shell:
        "mkdir {output}"

rule get_feature_matrix:
    input:
        expand(
            SIM + (
                "{qiita_id}/{topology}/{qiita_id}_{topology}_{num}"
                "_sim_data.csv"
            ),
            qiita_id=ALL_IDS,
            topology=config["topologies"],
            num=range(0, config["num_synth_datasets"]),
        )
    output:
        expand(
            RES + (
                "{qiita_id}/{topology}/rpca_feature_matrices/"
                "{qiita_id}_{topology}_{num}_rpca_feat_mat.csv"
            ),
            qiita_id=ALL_IDS,
            topology=config["topologies"],
            num=range(0, config["num_synth_datasets"]),
        )
    run:
        ordination, samp_mat, feat_mat = rpca(
            table=load_biom("{input}"),
            n_components=2,
        )
        feat_mat_df = feat_mat.to_data_frame()
        feat_mat_df.write_csv("{output}", index=True)
