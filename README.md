# Assembly and Annotation of Arabidopsis thaliana Accession Lu-1


Arabidopsis thaliana, a widely used model organism, offers insights into genome evolution and structural variation. This report investigates the genomic features of the Lu-1 accession, a dataset excluded from the recent study by Lian et al. (2024) due to heterozygosity concerns. Using PacBio HiFi sequencing, the genome was assembled with three tools: LJA, Flye, and Hifiasm, selecting Hifiasm for downstream analyses based on different metrics and its ability to produce a non-redundant, streamlined assembly for annotation. Transposable elements (TEs), constituting 12.86% of the Lu-1 genome, were annotated with EDTA. LTR retrotransposons, particularly the Gypsy and Copia superfamilies, dominated, with Gypsy elements comprising 2.07% of the genome. By estimating the insertion times, we found that most of the TEs across the genome expanded within the last 3 or 17 million years: this indicates either an ancient insertion from a distant ancestor or a highly conserved TE preserved through evolutionary time. The annotation pipeline using MAKER resulted in the identification of 38,431 protein-coding genes which decreased to 35,572 after filtering for high-confidence annotations (AED ≤ 0.5), which is higher than the 27,416 genes annotated in the reference sequence. Comparative analyses with GENESPACE identified 19,744 orthogroups shared across some accessions, while structural variations between different accessions and TAIR10 were visualized through synteny and riparian plots. Despite the limitations posed by heterozygosity in Lu-1, this report has assembled and annotated the Lu-1 genome, leveraging the strengths of Hifiasm to preserve genetic diversity and heterozygosity. Several additional enhancements to improve the current analysis, especially the structural contiguity and incomplete annotation, are presented in the discussion.


## Workflow for Genome and Transcriptome Analysis

### 1. Reads and Quality Check
- **FastQC**: Assess raw read quality for PacBio HiFi and Illumina RNA-seq.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/001_run_QC.sh)

- **Fastp**: Clean RNA-seq reads, remove low-quality reads (score < 15).
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/002_run_fastp.sh)

- **Jellyfish**: Perform k-mer counting for Lu-1 genome size estimation.
- **GenomeScope**: Analyze heterozygosity using k-mer data.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/003_count_kmers.sh)
    
![Results](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig1.PNG)

### 2. Genome Assembly
- Use **LJA**, **Flye**, and **Hifiasm** for Lu-1 de novo genome assembly. 
  - [Link to LJA script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/004_LJA_assembly.sh)
  - [Link to Flye script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/004_flye_assembly.sh)
  - [Link to Hifiasm script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/004_hifiasm_assembly.sh)
- Selected **Hifiasm output** for further assembly and downstream analysis.

### 3. Transcriptome Assembly
- Use **Trinity** for transcriptome assembly of Sha accession from RNA-seq data.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/004_trinity_assembly.sh)

### 4. Assembly Evaluation
- **BUSCO**: Assess genome and transcriptome completeness.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/006_run_busco.sh)
- **QUAST**: Evaluate genome quality against A. thaliana reference.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/006_run_quast.sh)
- **gfastats**: Basic assembly statistics.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/005_run_gfastats.sh)
- **Merqury**: Analyze assembly quality using k-mer comparison.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/006_run_merqury.sh)
  ![Results](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig2.PNG)
- **Nucmer** & **Mummerplot**: Align assemblies to the reference genome and visualize differences.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/007_assemblies_comparison.sh)
  - ![Mummerplot Results](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig3.PNG)
### 5. Transposable Element (TE) Annotation Using EDTA
- **EDTA**: Annotate TEs in Lu-1 genome with TAIR10 coding sequence to prevent misclassification.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/008_run_EDTA_conda.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/009_parse_to_plot_EDTA.sh)
- **TEsorter**: Classify LTR-RTs into clades using rexdb-plant database.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/011_TEsorter.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/011_TEsorter_abundance.sh)
- ![TE Distribution](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig4.PNG)
### 6. Visualizing and Comparing TE Annotations
- Use **circlize** in R to visualize TE distribution on the top 10 scaffolds.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/03-annotation_circlize.R)
- Compare TE content between accessions.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/011_TEsorter_abundance.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/02-tesorter_compare.R)
![TE Distribution](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig5.PNG)
### 7. Refining TE Classification with TEsorter
- Focus on **Class I LTR-RTs** and refine clade classification, including **Gypsy** and **Copia** superfamilies.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/011_TEsorter.sh)

### 8. TE Age Estimation
- Use **RepeatMasker** output and **parseRM.pl** (BioPerl) to calculate TE divergence and estimate insertion age.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/012_TE_age_est.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/06-plot_div.R)
  - ![TE Divergence](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig6.PNG)

### 9. Phylogenetic Analysis of TEs
- Perform phylogenetic analysis of **Gypsy** and **Copia** families using **Clustal Omega**, **FastTree**, and **iTOL** for tree visualization.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/015_TE_phylogenetic_analysis.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/016_filtering_refining_annotation.sh)
  - [Link to script 3](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/017_itol_prep.sh)
  - [Link to script 4](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/018_prot_length.sh)
  - ![Phylogenetic Tree 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig11.PNG)
  - ![Phylogenetic Tree 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig12.PNG)

### 10. Homology-Based Genome Annotation with MAKER
- Use **MAKER** for genome annotation combining ab initio predictions, RNA-Seq evidence, and protein homology.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/013_run_maker.sh)
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/014_maker_out_manip.sh)
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/014_2_all_manip_maker.sh)
- Annotate protein sequences using **InterProScan** for functional domains.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/016_filtering_refining_annotation.sh)

### 11. Quality Assessment of Gene Annotations
- **BUSCO**: Assess annotation completeness on protein and transcript sequences.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/018_prot_length.sh)
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/019_busco_anno.sh)
  - ![BUSCO Gene Annotation](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig7.PNG)
- Align protein sequences to **UniProt Viridiplantae** using **blastp** for homology.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/020_homology.sh)

### 12. Orthology-Based Gene Annotation Quality Check Using OMArk
- Use **OMArk** to evaluate gene set quality via hierarchical orthologous groups (HOGs).
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/021_omark.sh)
- Improve annotation by retrieving missing gene sequences for HOGs.
  - [Link to script](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/023_miniprot.sh)

### 13. Comparative Genomics Using GENESPACE and OrthoFinder
- Use **GENESPACE** to identify orthogroups across accessions (Lu-1, Kar-1, Altai-5).
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/022_run_genespace.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/16-create_Genespace_folders.R)
  - [Link to script 3](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/17-Genespace.R)
  - ![Orthogroup Distribution](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig8.PNG)
- Visualize orthogroup distribution and synteny with **dotplots** and **riparian plots** for structural rearrangements.
  - [Link to script 1](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/024_run_parse_Orthofinder.sh)
  - [Link to script 2](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/scripts/19-parse_Orthofinder.R)
  - ![Plot](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig9.PNG)
  - ![Plot](https://github.com/andrew-maalouf/assembly-annotation-course/blob/main/figures/fig13.PNG)
