import glob
import re

# ---------------Configuration---------------
configfile: "config/config.yaml"

DATA = config["data"]
PROC = config["proc"]
RAW = config["raw"]
SIM = config["sim"]
RES = config["res"]
# -------------------------------------------

# ------------Wildcard Constraints-----------
wildcard_constraints:
    qiita_id = "qiita\d+",
    topology = "\w+",
    num = "\d{1}"
# -------------------------------------------

# process all raw bioms and save to processed data subdirectory
ALL_BIOMS = glob.glob("data/raw/*/*.biom")
ALL_IDS = [re.search(r"qiita\d*", x).group() for x in ALL_BIOMS]
DATA_DICT = {b:q_id for b, q_id in zip(ALL_BIOMS, ALL_IDS)}

include: "rules/process_raw_data.smk"
include: "rules/synthesize_data.smk"
include: "rules/run_deicode.smk"

localrules: run_deicode, synthesize_data, process_raw_data, all_rocs

rule all_rocs:
    input:
        expand(
            RES + (
                "{qiita_id}/{topology}/roc/{qiita_id}_{topology}_{num}_roc.png"
            ),
            qiita_id=ALL_IDS,
            topology=config["topologies"],
            num=range(0, config["num_synth_datasets"]),
        )

rule run_deicode:
    input:
        expand(
            RES + (
                "{qiita_id}/{topology}/rpca_feature_matrices/"
                "{qiita_id}_{topology}_{num}_rpca_feat_mat.csv"
            ),
            qiita_id=ALL_IDS,
            topology=config["topologies"],
            num=range(0, config["num_synth_datasets"]),
        )


rule synthesize_data:
    input:
        expand(
            SIM + (
                "{qiita_id}/{topology}/{qiita_id}_{topology}_{num}"
                "_sim_{sim_type}.csv"
            ),
            qiita_id=ALL_IDS,
            topology=config["topologies"],
            num=range(config["num_synth_datasets"]),
            sim_type=["adj_list", "data"],
        ),

rule process_raw_data:
    input:
        qza = expand(
            PROC + "{qiita_id}/{qiita_id}_filt.qza",
            qiita_id=ALL_IDS,
        ),
        csv = expand(
            PROC + "{qiita_id}/{qiita_id}_filt.csv",
            qiita_id=ALL_IDS,
        )
