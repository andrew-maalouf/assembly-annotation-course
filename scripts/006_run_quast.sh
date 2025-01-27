#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=quast
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_quast_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_quast_%j.e

# load modules


# set variables
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly/assembly.fasta
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly/assembly.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/quast
CONTAINER_SIF=/containers/apptainer/quast_5.2.0.sif
REF_FEATURE=/data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff
REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/hifiasm $OUT_DIR/flye $OUT_DIR/lja $OUT_DIR/noref_hifiasm $OUT_DIR/noref_flye $OUT_DIR/noref_lja

# run quast
# -o <output_dir>: output directory
# -r <path>: reference genome file. Optional. Many metrics can't be evaluated without a reference. If this is omitted, QUAST will only report the metrics that can be evaluated without a reference.
# --features (or -g) <path>: file with genomic feature positions in the reference genome
# --threads (or -t) <int>: maximum number of threads. The default value is 25% of all available CPUs but not less than 1
# -L: take assembly names from their parent directory names
# --eukaryote (or -e): genome is eukaryotic. Affects gene finding, conserved orthologs finding and contig alignment
# --large: genome is large (typically > 100 Mbp). Use optimal parameters for evaluation of large genomes. Affects speed and accuracy. In particular, imposes --eukaryote --min-contig 3000 --min-alignment 500 --extensive-mis-size 7000
# --est-ref-size <int>: estimated reference genome size (in bp) for computing NGx statistics. This value will be used only if a reference genome file is not specified
# --pacbio <path>: file with PacBio SMRT reads in FASTQ format (files compressed with gzip are allowed)
# --no-sv: do not run structural variant calling and processing (make sense only if reads are specified)
# --labels (or -l) <label,label...>: Human-readable assembly names. Those names will be used in reports, plots and logs.


# run without reference
apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  quast.py -o $OUT_DIR/without_reference\
  --threads 6\
  -L \
  --est-ref-size 140000000\
  --eukaryote\
  --large\
  --no-sv\
  $ASSEMBLY_HIFIASM $ASSEMBLY_FLYE $ASSEMBLY_LJA


# run with reference
apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  quast.py -o $OUT_DIR/with_reference\
  -r $REF\
  --features $REF_FEATURE\
  --threads 6\
  -L \
  --eukaryote\
  --large\
  --no-sv\
  $ASSEMBLY_HIFIASM $ASSEMBLY_FLYE $ASSEMBLY_LJA