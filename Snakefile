import glob
import re

# process all raw bioms and save to processed data subdirectory
ALL_BIOMS = glob.glob("data/raw/*/*.biom")
ALL_IDS = [re.search(r"qiita\d*", x).group() for x in ALL_BIOMS]

include: "rules/process_raw_data.smk"

rule process_raw_data:
    input:
        qza = expand(
            "data/processed/{qiita_id}/{qiita_id}_filt.qza",
            qiita_id=ALL_IDS,
        ),
        csv = expand(
            "data/processed/{qiita_id}/{qiita_id}_filt.csv",
            qiita_id=ALL_IDS,
        )
