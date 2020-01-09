rule synth:
    input:
        PROC + "{qiita_id}/{qiita_id}_filt.csv"
    output:
        expand(
            SIM + (
                "{{qiita_id}}/{{topology}}/{{qiita_id}}_{{topology}}_{num}"
                "_sim_{sim_type}.csv"
            ),
            num=range(0, config["num_synth_datasets"]),
            sim_type=["adj_list", "data"],
        )
    params:
        this_script = "scripts/gen_synth_data.R",
        out_dir = lambda wildcards: SIM + wildcards.qiita_id + "/"
    conda:
        "../environment.yaml"
    shell:
         "R --slave -e $'library(devtools); install_github(\"zdk123/SpiecEasi\")'; \
          Rscript --vanilla \
            {params.this_script} \
            {input} \
            {params.out_dir} \
            {wildcards.qiita_id} \
            {wildcards.topology}"

