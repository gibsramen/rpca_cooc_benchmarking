import glob
import re

from snakemake.utils import validate

# ---------------Configuration---------------
configfile: "config.yaml"

DATA = config["data"]
PROC = config["proc"]
RAW = config["raw"]
SIM = config["sim"]
RES = config["res"]
# -------------------------------------------

# process all raw bioms and save to processed data subdirectory
ALL_BIOMS = glob.glob("data/raw/*/*.biom")
ALL_IDS = [re.search(r"qiita\d*", x).group() for x in ALL_BIOMS]

include: "rules/process_raw_data.smk"
include: "rules/run_deicode.smk"

localrules: process_raw_data

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

rule synthesize_data:
    input:
        expand(
            PROC + "{qiita_id}/{qiita_id}_filt.csv",
            qiita_id=ALL_IDS,
        )
    output:
        expand(
           SIM + (
               "{qiita_id}/{topology}/{qiita_id}_{topology}_{num}"
               "_sim_{sim_type}.csv"
           ),
           qiita_id=ALL_IDS,
           topology=config["topologies"],
           num=range(0, config["num_synth_datasets"]),
           sim_type=["data", "adj_list"],
        )
    params:
        this_script = "scripts/gen_synth_data.R",
        out_dir = SIM + "{qiita_id}/"
    shell:
        "Rscript {params.this_script} {input} {params.out_dir} {qiita_id} {topology}"

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
