#!/bin/bash

#SBATCH -n 1
#SBATCH -p newnodes,sched_mit_hill,sched_mit_chisholm
#SBATCH --mem=32GB

snakemake --use-conda -s 5.smk --cluster-config cluster.yaml --cluster "sbatch -p {cluster.partition} -N {cluster.nodes} -n {cluster.cores} --mem={cluster.mem} --time={cluster.time} -o 'slurm-%x_%j'" --jobname {rulename}.{jobid} --jobs 300 --keep-going
