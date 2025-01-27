library(GENESPACE)
args <- commandArgs(trailingOnly = TRUE)
# get the folder where the genespace files are
gpar <- init_genespace(wd = '/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace/genespace', path2mcscanx = "/usr/local/bin", nCores = 20, verbose = TRUE)
out <- run_genespace(gpar, overwrite = TRUE)
