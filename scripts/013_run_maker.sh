#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=maker
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=50
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_maker_mpi_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_maker_mpi_%j.e

# load modules for step 3
module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker
CONTAINER_SIF=/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
REPEATMASKER_DIR=/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker

export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"


# create directory if not available and enter it
mkdir -p $OUT_DIR && cd $OUT_DIR

# step 1
# run maker
#apptainer exec\
# --bind $WORK_DIR\
#  $CONTAINER_SIF\
# maker -CTL

# step 2
# edit control file
  

# step 3
# run maker with mpi
mpiexec --oversubscribe -n 50\
 apptainer exec\
  --bind $SCRATCH:/TMP\
  --bind $COURSEDIR\
   --bind $AUGUSTUS_CONFIG_PATH\
    --bind $REPEATMASKER_DIR\
    $CONTAINER_SIF\
    maker\
     -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl