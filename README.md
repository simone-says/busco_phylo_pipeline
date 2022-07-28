Michael Byars (michael.byars@nau.edu)
Simone Gable (smg655@nau.edu)
Tollis Lab

Based off of: https://bioinformaticsworkbook.org/dataAnalysis/phylogenetics/reconstructing-species-phylogenetic-tree-with-busco-genes-using-maximum-liklihood-method.html#gsc.tab=0

# Software Dependencies

BUSCO (version 5.2)
MAFFT: https://mafft.cbrc.jp/alignment/software/
IQ-Tree: http://www.iqtree.org/
TrimAL: https://github.com/scapella/trimal
ASTRAL: https://github.com/smirarab/ASTRAL

# Installation Instructions

## 1.) Clone github repository

## 2.) Create Conda environments using the bioconda recipes for the following programs
MAFFT: https://mafft.cbrc.jp/alignment/software/
IQ-Tree: https://bioconda.github.io/recipes/iqtree/README.html
TrimAL: https://github.com/scapella/trimal

## 3.) Export .yaml files for each environment into the folder /YOUR_WORKING_DIR/busco_phylo_pipeline/conda_yamls

## 4.) Conda .yaml files should have the following names to work with snakake pipeline:
amas.yml
mafft.yml
iqtree.yml
trimal.yml

## 5.) Download and install astral into the tools/ directory
*Note: If you are using a different version of ASTRAL you will have to correct the name in the Snakemake pipeline*

## 6.) Extract nucleotide sequences for each BUSCO, place in the data/busco_nt_merged/ directory

*Helper Scripts have been placed in the scripts/ directory to help automate this process. 
* NOTE: Newer versions of BUSCO (inlcuding version 5) no longer output FASTA files of nucleotide sequence. The developers have added an annotation file of all BUSCOs from each run in the form of a TSV file. We are currently working on scripts that will automate extracting complete & single-copy BUSCOs from each genome using the annotation file provided. Once this step is done, the following scripts can be used to make concatenated multi-FASTA files of each complete BUSCO. *
Run busco_multiseq_generator.sh in the base directory of your BUSCO output directory to extract and collate the sequences into one file containing the sequences from every species for each BUSCO. If you have transcriptome mode output from BUSCO there is a script called trans_extract_sequences.sh that you will need to run on each transcriptome mode run before running busco_multiseq_generator.sh.*

## Run the Snakemake Pipeline use this command (or similar) after requesting resources in a screen session if using an HPCC.
```
snakemake --cores 4 --use-conda --keep-going
```

# You can also use a batch script and Snakemake will submit all jobs for you. We are working on an example job script and will upload soon with the size of dataset used, amount of resources requested & used, and reccomendations for running the pipeline remotely.
