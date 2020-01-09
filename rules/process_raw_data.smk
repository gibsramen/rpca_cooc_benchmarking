import glob
import os
import re

import pandas as pd
from qiime2 import Artifact
from qiime2.plugins import feature_table

localrules: biom_to_qza, filter_feature_table, save_to_csv

def get_qiita_id(biom_file):
    return DATA_DICT[biom_file]

rule biom_to_qza:
    input:
        lambda wildcards: glob.glob(
            "data/raw/{qiita_id}/*.biom".format(qiita_id=wildcards.qiita_id)
        )
    params:
        this_id = lambda wildcards, input: get_qiita_id(input[0])
    output:
        "data/processed/{qiita_id}/{qiita_id}.qza"
    shell:
        "qiime tools import \
        --input-path {input} \
        --type 'FeatureTable[Frequency]' \
        --output-path data/processed/{params.this_id}/{params.this_id}.qza"

rule filter_feature_table:
    input:
        "data/processed/{qiita_id}/{qiita_id}.qza"
    output:
        "data/processed/{qiita_id}/{qiita_id}_filt.qza"
    shell:
        "qiime feature-table filter-features \
         --i-table {input} \
         --p-min-frequency 10 \
         --o-filtered-table {output}; \
         qiime feature-table filter-samples \
         --i-table {output} \
         --p-min-frequency 500 \
         --o-filtered-table {output}"

rule save_to_csv:
    input:
        "data/processed/{qiita_id}/{qiita_id}_filt.qza"
    output:
        "data/processed/{qiita_id}/{qiita_id}_filt.csv"
    run:
        table = Artifact.load(input[0])
        df = table.view(pd.DataFrame)
        df.to_csv(output[0])
