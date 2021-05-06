rule target:
    input:
        "temp/live/predict_genes/Vibrio.cholerae_nt.fasta"

rule predict_genes:
    input:
        "input/genomes/Vibrio.cholerae.fna"
    output:
        amino_acid = "temp/live/predict_genes/Vibrio.cholerae_aa.fasta",
        nucleotide = "temp/live/predict_genes/Vibrio.cholerae_nt.fasta"
    conda:
        "envs/prodigal.yaml"
    shell:
        "prodigal -i {input} -a {output.amino_acid} -d {output.nucleotide} -q"
