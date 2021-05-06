SPECIES = ["Vibrio.cholerae", "Vibrio.natriegens"]

rule target:
    input:
        expand("temp/live/predict_genes/{species}_nt.fasta", species=SPECIES)

rule predict_genes:
    input:
        "input/genomes/{species}.fna"
    output:
        amino_acid = "temp/live/predict_genes/{species}_aa.fasta",
        nucleotide = "temp/live/predict_genes/{species}_nt.fasta"
    conda:
        "envs/prodigal.yaml"
    shell:
        "prodigal -i {input} -a {output.amino_acid} -d {output.nucleotide} -q"
