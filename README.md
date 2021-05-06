## Snakemake Workshop 28 April 2021

![Directed Acyclic Graph](https://user-images.githubusercontent.com/2695357/117361202-baa31500-ae87-11eb-89b3-3e83976eb35d.png)

In this example pipeline, you are looking for the presence and absence of a set of genes in a set of genomes. To start with as input you have the genomes as fasta files and a csv file with URLs for the different query genes.

In this repo you will find the following files and folders:


    snakemake_workshop_repo
    ├── dag_diagrams
    │   ├── 0.pdf
    │   ├── ...
    ├── envs
    │   ├── biopython.yaml
    │   ├── ...
    ├── input
    │   ├── genomes
    │   │   ├── Aliivibrio.fischeri.fna
    │   │   ├── ...
    │   ├── ribo_prots.hmm
    │   └── t6ss_genes.csv
    ├── scripts
    │   ├── make_phylo_tree
    │   │   ├── check_hmmsearch.py
    │   │   ├── concatenate_alignment.py
    │   │   └── make_ribo_files.py
    │   ├── parse_hmmer_tblout.py
    │   └── plot_tree_with_genes.R
    ├── cluster.yaml
    ├── 0.smk
    ├── 1.smk
    ├── 2.smk
    ├── 3.smk
    ├── 4.smk
    ├── 5.smk
    ├── make_phylo_tree.smk
    └── submit_to_cluster.sbatch

### explanation of files and directories

    0.smk , 1.smk, 2.smk, etc...
These are snakemake files that start simply and build up to the full desired pipeline.

    make_phylo_tree.smk
This snakemake file gets imported by the last step in the pipeline to make the phylogenetic tree.

    input  
Contains the fasta files of the genomes, a csv file with the URLS for the query genes, and an hmm file which is used to make the species tree.

    envs
Contains .yaml files for each of the conda environments installed by this pipeline.

    scripts
Contains scripts that are run by the pipeline. Check out the R and python scripts to see how to reference snakemake variables inside one of your scripts.

    dag_diagrams
Contains diagrams of the directed acyclic graph that snakemake calculates with each workflow.

    cluster.yaml
The Slurm resource requirements for rules in the final pipeline which is useful if submitting this workflow to a cluster.

    submit_to_cluster.sbatch
an example script for submitting the final workflow to a slurm cluster.

## How to run this pipeline

To run the pipeline:

    # change 0.smk to whichever workflow you'd like to run
    snakemake -s 0.smk --use-conda --cores 4 # most laptops can use 4 threads without issue, change if needed

To submit this pipeline to a Slurm cluster

    # edit submit_to_cluster and cluster.yaml to submit to the appropriate partitions, then run:
    sbatch submit_to_cluster.sbatch

### How to install snakemake, conda, and mamba if needed:


### Install snakemake

To install snakemake:  

    mamba create --name=snakemake -c conda-forge -c bioconda snakemake

### Install mamba


To install mamba:

    conda install -n base -c conda-forge mamba


### Install conda  
To install conda:  

Follow instructions here to install conda:

Most of the time you should opt for the latest version of python for your operating system

https://docs.conda.io/en/latest/miniconda.html

If you are installing miniconda on a cluster, you should install it into your home directory.

After installing conda, run the command:

    conda init bash

or if you use an alternative shell like zsh, run the command for your shell:

    conda init zsh
