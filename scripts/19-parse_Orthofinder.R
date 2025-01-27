library(tidyverse)
library(data.table)



dat <- fread("/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace/genespace/orthofinder/Results_Dec05/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv", header = T, fill = TRUE)
genomes <- names(dat)[names(dat) != "V1"]

dat <- dat %>% pivot_longer(cols = -V1, names_to = "species", values_to = "perc")
ortho_ratio <- dat %>%
    filter(V1 %in% c(
        "Number of genes", "Number of genes in orthogroups", "Number of unassigned genes",
        "Number of orthogroups containing species", "Number of species-specific orthogroups", "Number of genes in species-specific orthogroups"
    ))

ortho_percent <- dat %>%
    filter(V1 %in% c(
        "Percentage of genes in orthogroups", "Percentage of unassigned genes", "Percentage of orthogroups containing species",
        "Percentage of genes in species-specific orthogroups"
    ))

# convert perc column to numeric because y labels looked weird and not sorted
ortho_ratio$perc <- as.numeric(as.character(ortho_ratio$perc))
ortho_percent$perc <- as.numeric(as.character(ortho_percent$perc))


p <- ggplot(ortho_ratio, aes(x = V1, y = perc, fill = species)) +
    geom_col(position = "dodge") +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count") +
    scale_y_continuous(
        breaks = seq(0, max(ortho_ratio$perc, na.rm = TRUE), by = 5000),  # major ticks every 5000
        minor_breaks = seq(0, max(ortho_ratio$perc, na.rm = TRUE), by = 1000)  # minor ticks every 1000
    ) +
    theme(
        panel.grid.major.y = element_line(color = "grey90"),  # major grid lines (visible, light grey)
        panel.grid.minor.y = element_line(color = "grey95", linetype = "dashed")  # minor grid lines (visible, dashed)
    )

ggsave("Plots/orthogroup_plot.pdf")


p <- ggplot(ortho_percent, aes(x = V1, y = as.numeric(perc), fill = species)) +
    geom_col(position = "dodge") +
    ylim(c(0, 100)) +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count")
ggsave("Plots/orthogroup_percent_plot.pdf")


library(UpSetR)


orthogroups <- fread("/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace/genespace/orthofinder/Results_Dec05/Orthogroups/Orthogroups.GeneCount.tsv")
orthogroups <- orthogroups %>%
    select(-Total)
ogroups_presence_absence <- orthogroups
rownames(ogroups_presence_absence) <- ogroups_presence_absence$Orthogroup

# convert the gene counts to presence/absence
ogroups_presence_absence[ogroups_presence_absence > 0] <- 1
ogroups_presence_absence$Orthogroup <- rownames(ogroups_presence_absence)

str(ogroups_presence_absence)

ogroups_presence_absence <- ogroups_presence_absence %>%
    rowwise() %>%
    mutate(SUM = sum(c_across(!ends_with("Orthogroup"))))



ogroups_presence_absence <- data.frame(ogroups_presence_absence)
ogroups_presence_absence[genomes] <- ogroups_presence_absence[genomes] == 1

# ComplexUpset library is missing so install to lovcal library
# define local library path
local_lib <- "~/Rlibs"

# create the local library directory if it does not exist
if (!dir.exists(local_lib)) dir.create(local_lib, recursive = TRUE)

# install ComplexUpset locally
if (!requireNamespace("ComplexUpset", quietly = TRUE)) {
    install.packages("ComplexUpset", lib = local_lib, repos = "http://cran.us.r-project.org")
}

# load the library from the local path
# use ComplexUpset package to make an upset plot with a subset of the data
library(ComplexUpset, lib.loc = local_lib)


pdf("Plots/one-to-one_orthogroups_plot.complexupset.pdf", height = 5, width = 10, useDingbats = FALSE)

upset(ogroups_presence_absence, genomes, name = "genre", width_ratio = 0.1, wrap = TRUE, set_sizes = FALSE)
dev.off()
