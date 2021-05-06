from collections import Counter

strains = glob_wildcards("input/genomes/{strain}.fna").strain

def get_prots():
    _prots = []
    with open("input/ribo_prots.hmm", "r") as f:
        for line in f:
            if line[0:4] == "NAME":
                _prots.append(line.split()[1])
    return _prots

prots = get_prots()

rule run_raxml:
    input:
        "temp/live/phylo_tree/reference.ribo.mafft.concat.fasta"
    output:
        "temp/live/phylo_tree/vibrio_ribo_tree.tre"
    conda:
        "envs/raxml.yaml"
    threads:
        16
    shadow:
      "minimal"
    shell:
        """
        raxmlHPC-PTHREADS -f a -x 26789416 -m GTRGAMMAX -p 218957 -# 4 -o Escherichia.coli -T {threads} -s {input} -n reference_tree;
        mv RAxML_bestTree.reference_tree temp/live/phylo_tree/vibrio_ribo_tree.tre;
        rm RAxML_*;
        """

rule concatenate_alignment:
    input:
        aligned_files = expand("temp/live/phylo_tree/ribo_aligned/{prot_name}_aligned.fasta", prot_name=prots),
        singletons = "temp/live/phylo_tree/hmmer_out/reference_singletons.txt"
    output:
        "temp/live/phylo_tree/reference.ribo.mafft.concat.fasta"
    conda:
        "envs/biopython.yaml"
    shell:
        "python scripts/make_phylo_tree/concatenate_alignment.py -m 0.5 -s {input.singletons} -o {output}"

rule align_prots:
    input:
        "temp/live/phylo_tree/ribo_unaligned/dummy_file.txt"
    output:
        "temp/live/phylo_tree/ribo_aligned/{prot_name}_aligned.fasta"
    conda:
        "envs/mafft.yaml"
    shell:
        "mafft-linsi temp/live/phylo_tree/ribo_unaligned/{wildcards.prot_name}_unaligned.fasta > {output}"

rule make_ribo_files:
    input:
        singletons = "temp/live/phylo_tree/hmmer_out/reference_singletons.txt",
        concatenated_orfs = "temp/live/phylo_tree/reference_concatenated_orf.nt.fasta"
    output:
        "temp/live/phylo_tree/ribo_unaligned/dummy_file.txt"
    conda:
        "envs/biopython.yaml"
    shell:
        "python scripts/make_phylo_tree/make_ribo_files.py -m {input[singletons]} -c {input[concatenated_orfs]} -o temp/live/phylo_tree/ribo_unaligned/ -d {output} "

rule filter_hmm_results:
    input:
        "temp/live/phylo_tree/hmmer_out/reference_hmmer_result.tbl"
    output:
        "temp/live/phylo_tree/hmmer_out/reference_singletons.txt"
    conda:
        "envs/biopython.yaml"
    shell:
        "python scripts/make_phylo_tree/check_hmmsearch.py -i {input} -s {output}"

rule hmmsearch:
    input:
        concatenated_orfs = "temp/live/phylo_tree/reference_concatenated_orf.aa.fasta",
        hmmfile = "input/ribo_prots.hmm"
    output:
        text = "temp/live/phylo_tree/hmmer_out/reference_hmmer_result.txt",
        table = "temp/live/phylo_tree/hmmer_out/reference_hmmer_result.tbl",
        domains = "temp/live/phylo_tree/hmmer_out/reference_hmmer_result.dom.tbl"
    conda:
        "envs/hmmer.yaml"
    shell:
        "hmmsearch -o {output[text]} --tblout {output[table]} --domtblout {output[domains]} {input[hmmfile]} {input[concatenated_orfs]}"

rule make_concatenated_orf_file:
    input:
        aa = expand("temp/live/predict_genes/{strain}_aa.fasta", strain=strains),
        nt = expand("temp/live/predict_genes/{strain}_nt.fasta", strain=strains)
    output:
        aa = "temp/live/phylo_tree/reference_concatenated_orf.aa.fasta",
        nt = "temp/live/phylo_tree/reference_concatenated_orf.nt.fasta",
    shell:
        "cat {input[aa]} > {output[aa]}; cat {input[nt]} > {output[nt]}"
