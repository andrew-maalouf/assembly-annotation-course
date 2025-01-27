#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=assemblies_comparison
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_comparison_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_comparison_%j.e

# load modules


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly/assembly.fasta
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly/assembly.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_comparison
CONTAINER_SIF=/containers/apptainer/mummer4_gnuplot.sif
REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
DELTA_FILE=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_comparison/comparing_assemblies.delta

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/flye $OUT_DIR/hifiasm $OUT_DIR/lja


# run nucmer
# nucmer [options] <reference> <query>
#                  <reference> specifies the multi-FastA sequence file that contains the reference sequences, to be aligned with the queries.
#                              <query> specifies the multi-FastA sequence file that contains the query sequences, to be aligned with the references.
# --mum: Use anchor matches that are unique in both the reference and query (false)
# --maxmatch: Use all anchor matches regardless of their uniqueness (false)
# -b, --breaklen=uint32: Set the distance an alignment extension will attempt to extend poor scoring regions before giving up (200)
# -c, --mincluster=uint32: Sets the minimum length of a cluster of matches (65)
# -g, --maxgap=uint32: Set the maximum gap between two adjacent matches in a cluster (90)
# -l, --minmatch=uint32: Set the minimum length of a single exact match (20)
# -L, --minalign=uint32: Minimum length of an alignment, after clustering and extension (0)
#     --nooptimize: No alignment score optimization, i.e. if an alignment extension reaches the end of a sequence, it will not backtrack to optimize the alignment score and instead terminate the alignment at the end of the sequence (false)
# -r, --reverse: Use only the reverse complement of the Query sequences (false)
#     --nosimplify: Don't simplify alignments by removing shadowed clusters. Use this option when aligning a sequence to itself to look for repeats (false)
# -p, --prefix=PREFIX: Write output to PREFIX.delta (out)
#     --delta=PATH: Output delta file to PATH (instead of PREFIX.delta)
# -t, --threads=NUM: Use NUM threads (# of cores)

# compare each of the assemblies against a common reference
apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  nucmer \
  --threads 6\
  --mincluster 1000\
  --breaklen 1000\
  --delta $OUT_DIR/flye/comparing_assemblies.delta\
  $REF\
  $ASSEMBLY_FLYE

apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  nucmer \
  --threads 6\
  --mincluster 1000\
  --breaklen 1000\
  --delta $OUT_DIR/hifiasm/comparing_assemblies.delta\
  $REF\
  $ASSEMBLY_HIFIASM

apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  nucmer \
  --threads 6\
  --mincluster 1000\
  --breaklen 1000\
  --delta $OUT_DIR/lja/comparing_assemblies.delta\
  $REF\
  $ASSEMBLY_LJA

# run mummer to draw a dotplot from the generated .delta file
# USAGE: mummerplot  [options]  <match file>
# MANDATORY:
#       match file: Set the alignment input to 'match file'
#  OPTIONS:
#       -b|breaklen: Highlight alignments with breakpoints further than breaklen nucleotides from the nearest sequence end
#       -f,   --filter: Only display .delta alignments which represent the "best" hit to any particular spot on either sequence, i.e. a one-to-one mapping of reference and query subsequences
#       -l,   --layout: Layout a .delta multiplot in an intelligible fashion, this option requires the -R -Q options
#       --fat: Layout sequences using fattest alignment only
#       -R|Rfile: Plot an ordered set of reference sequences from Rfile
#       -Q|Qfile: Plot an ordered set of query sequences from Qfile file/Qfile Can either be the original DNA multi-FastA files or lists of sequence IDs, lens and dirs [ /+/-]


apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  mummerplot -R $REF\
  -Q $ASSEMBLY_FLYE \
  --fat \
  --layout \
  --filter \
  -breaklen 1000\
  -t png\
  --large \
  -p $OUT_DIR/mummerplot_output\
  $OUT_DIR/flye/comparing_assemblies.delta

apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  mummerplot -R $REF\
  -Q $ASSEMBLY_HIFIASM \
  --fat \
  --layout \
  --filter \
  -breaklen 1000\
  -t png\
  --large \
  -p $OUT_DIR/hifiasm/mummerplot_output\
  $OUT_DIR/hifiasm/comparing_assemblies.delta

apptainer exec\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
  mummerplot -R $REF\
  -Q $ASSEMBLY_LJA \
  --fat \
  --layout \
  --filter \
  -breaklen 1000\
  -t png\
  --large \
  -p $OUT_DIR/lja/mummerplot_output\
  $OUT_DIR/lja/comparing_assemblies.delta