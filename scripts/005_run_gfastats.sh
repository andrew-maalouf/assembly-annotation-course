#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=run_gfastats
#SBATCH --time=1-00:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=8
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_gfastats_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_gfastats_%j.e

# load modules


# set variables
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly/assembly.fasta
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly/assembly.fasta
ASSEMBLY_TRINITY=/data/users/amaalouf/transcriptome_assembly/assemblies/trinity_assembly/final_output/trinity_assembly.Trinity.fasta
GFASTATS_CONTAINER=/containers/apptainer/gfastats_1.3.7.sif
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/gfastats

# create directory if not available
mkdir -p $OUT_DIR

cd $OUT_DIR

# run the container
# -t sets the number of CPUs in use
# -o specifies the prefix of output files 
   apptainer exec\
 --bind $OUT_DIR\
  $GFASTATS_CONTAINER\
   gfastats $ASSEMBLY_LJA > $OUT_DIR/gfastats_lja.txt

   apptainer exec\
 --bind $OUT_DIR\
  $GFASTATS_CONTAINER\
   gfastats $ASSEMBLY_HIFIASM > $OUT_DIR/gfastats_hifiasm.txt

   apptainer exec\
 --bind $OUT_DIR\
  $GFASTATS_CONTAINER\
   gfastats $ASSEMBLY_FLYE > $OUT_DIR/gfastats_flye.txt

   apptainer exec\
 --bind $OUT_DIR\
  $GFASTATS_CONTAINER\
   gfastats $ASSEMBLY_TRINITY > $OUT_DIR/gfastats_trinity.txt