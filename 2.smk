import csv

GENOMES = ["Vibrio.cholerae", "Vibrio.natriegens"]

with open("input/t6ss_genes.csv", "r") as f:
    recs = list(csv.DictReader(f))
    HMM_URL_MAP = {rec["hmm_accession"]: rec["url"] for rec in recs}
    HMMS = HMM_URL_MAP.keys()

rule target:
    input:
        "temp/live/hmms/t6ss_genes_concat.hmm"

rule predict_genes:
    input:
        "input/genomes/{genome}.fna"
    output:
        amino_acid = "temp/live/predict_genes/{genome}_aa.fasta",
        nucleotide = "temp/live/predict_genes/{genome}_nt.fasta"
    conda:
        "envs/prodigal.yaml"
    shell:
        "prodigal -i {input} -a {output.amino_acid} -d {output.nucleotide} -q"

rule download_query:
    output:
        "temp/live/hmms/{hmm_accession}.hmm"
    params:
        url = lambda wildcards: HMM_URL_MAP[wildcards.hmm_accession]
    shell:
        "wget -O {output} {params.url}"

rule concatenate_queries:
    input:
        expand("temp/live/hmms/{hmm_accession}.hmm", hmm_accession = HMMS)
    output:
        "temp/live/hmms/t6ss_genes_concat.hmm"
    shell:
        "cat {input} > {output}"
