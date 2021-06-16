BUSCO_IDs, = glob_wildcards("data/busco_nt_merged/{busco_id}_nt.fasta")

## Run this script using the command: snakemake --cores 4 --use-conda --keep-going --printshellcmds

rule all:
	input:
		"results/astral/astral_species_tree.tre",
		"results/iq_tree_gcf/concord.cf.tree.nex",
		"results/amas/trimmed_alignment_summary.txt",
		"results/amas/raw_alignment_summary.txt"


#MAFFT -> Create an alignment for every BUSCO
rule mafft_allignment:
	input:
		"data/busco_nt_merged/{busco_id}_nt.fasta"
	output:
		"results/mafft/{busco_id}.mafft.fa"
	conda:
		"conda_yamls/mafft.yml"
	shell:
		"mafft --auto {input} > {output}"

# Remove Special Characters from FASTA headers (RAxML will choke on |'s)
rule clean_fasta_header:
	input:
		"results/mafft/{busco_id}.mafft.fa"
	output:
		"results/mafft/{busco_id}.cleaned"
	shell:
		"sed 's/|.*//g' {input} > {output}"

# Trim the mafft alignments
rule trimal_trimming:
	input:
		"results/mafft/{busco_id}.cleaned"
	output:
		"results/trimal/{busco_id}.trim"
	conda:
		"conda_yamls/trimal.yml"
	shell:
		"trimal -in {input} -out {output} -automated1"

# Create summary statistics for both trimmed and untrimmed alignments
rule amas_summaries:
	input:
		trimmed_alignments = expand("results/trimal/{busco_id}.trim", busco_id=BUSCO_IDs),
		raw_alignments = expand("results/mafft/{busco_id}.cleaned", busco_id=BUSCO_IDs)
	output:
		trimmed_alignment_summary = "results/amas/trimmed_alignment_summary.txt",
		raw_alignment_summary = "results/amas/raw_alignment_summary.txt"
	conda:
		"conda_yamls/amas.yml"
	shell:
		'''
		AMAS.py summary -c 2 -f fasta -d dna -i results/trimal/*trim -o {output.trimmed_alignment_summary}
		AMAS.py summary -c 2 -f fasta -d dna -i results/mafft/*cleaned -o {output.raw_alignment_summary}
		'''

# Create Gene Trees for every trimmed alignment using RAxML
rule raxml_gene_trees:
	input:
		"results/trimal/{busco_id}.trim"
	output:
		"results/raxml/RAxML_bestTree.{busco_id}"
	conda:
		"conda_yamls/raxml.yml"
	shell:
		"raxmlHPC -f a -m GTRGAMMA -# 100 -p 12345 -x 12345 -s {input} -w ${{PWD}}/results/raxml -n {wildcards.busco_id}"

# Create a species tree from the RAxML gene trees
rule astral_species_tree:
	input:
		expand("results/raxml/RAxML_bestTree.{busco_id}", busco_id=BUSCO_IDs)
	output:
		species_tree = "results/astral/astral_species_tree.tre",
		concat_gene_trees = "results/astral/astral_input.tre"
	log:
		"logs/astral.log"
	shell:
		'''
		cat results/raxml/RAxML_bestTree.* >> results/astral/astral_input.tre
		java -jar tools/Astral/astral.5.7.5.jar -i results/astral/astral_input.tre -o {output.species_tree}
		'''

# Use IQ-TREE to calculate gene-concordance-factors and site-concordance-factors for the RAxML gene trees
rule gene_concordance_factors:
	input:
		species_tree = "results/astral/astral_species_tree.tre",
		concat_gene_trees = "results/astral/astral_input.tre"
	output:
		"results/iq_tree_gcf/concord.cf.tree.nex",
		"results/iq_tree_gcf/concord.cf.stat_loci",
		"results/iq_tree_gcf/concord.cf.stat_tree",
		"results/iq_tree_gcf/concord.cf.tree"

	conda:
		"conda_yamls/iqtree.yml"
	shell:
		'''
		iqtree -t {input.species_tree} --gcf {input.concat_gene_trees} -p results/trimal/ --scf 100 -pre results/iq_tree_gcf/concord -T 6 --df-tree --cf-verbose
		'''

######################################################################
# Fill in the below for a rule to calculate site concordance factors #
######################################################################

# rule site_concordance_factors:
#   	input:
# 		""
# 	output:
# 		""
# 	conda:
# 		"conda_yamls/iqtree.yml"
# 	shell:
# 		'''
#
# 		'''
##############################################

###############################
# Rules to remove bad Taxa    #
###############################

#
# rule prune_taxa:
# 	input:
# 		"data/busco_nt_merged/{busco_id}_nt.fasta"
# 	output:
# 		"{busco_id}_nt.fasta-out.fas"
# 	conda:
# 		"conda_yamls/amas.yml"
# 	shell:
# 		"AMAS.py remove -x xantus pinoys triJac agaPic sceOcc sauAte leiCar chaMad anoCri anoEqu -d dna -f fasta -i {input} -u fasta -g ''"
#
# rule move_buscos:
# 	input:
# 		"{busco_id}_nt.fasta-out.fas"
# 	output:
# 		"results/busco_pruned/{busco_id}_nt.fasta-out.fas"
# 	shell:
# 		"mv {input} results/busco_pruned/"
#
# rule clean_pruned_files:
# 	input:
# 		"results/busco_pruned/{busco_id}_nt.fasta-out.fas"
# 	output:
# 		"results/busco_pruned/{busco_id}_nt.fasta"
# 	shell:
# 		"rename -- -out.fas '' {input}"

###############################
# THE GRAVEYARD FOR DEAD CODE #
###############################

# Rule summary_plots:
# 	Input:
#

# DiscoVista: https://github.com/esayyari/DiscoVista
#singularity pull docker://esayyari/discovista
#
# rule DiscoVista:
# 	input:
#
# 	output:
#
# 	container:
#


# rule subset_by_taxa_number

# rule iq_tree_gcf_concordance_factors

# rule iq_tree_gcf_concat_alignment
