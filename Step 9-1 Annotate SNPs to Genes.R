library(dplyr)
library(magrittr)
library(tidyverse)
library(vautils)

# Clear global environment
rm(list=ls())

# Define files
input_file  <- "model_results_expanded_snp.csv"
output_file_all <- "all_variants_annotated_to_genes.csv"
output_file_known <- "known_variants_annotated_to_genes.csv"
output_file_novel <- "novel_variants_annotated_to_genes.csv"

# Read GWAS file
gwas <- data.table::fread(input_file)

# Find nearest gene
geneN <- find_nearest_gene(gwas, flanking = 500, build = "hg19", collapse = FALSE, snp = "SNP", chr = "Chromosome", bp = "Position")
# flanking 500 identifies the nearest gene within 500kb of the SNP
geneN <- geneN %>% rename(SNP = rsid)

# Update 'distance' column
geneN <- geneN %<>% mutate(distance = ifelse(distance == 'intergenic', 0, distance))

# Merge and select columns
gwas <- merge(subset(geneN[order(geneN$SNP, abs(as.numeric(geneN$distance))), ], !duplicated(SNP))[, c("SNP", "GENE")], gwas, by = "SNP") %>%
  dplyr::select(Gene_Symbol = GENE, everything())

# rename SNP column that was changed to SNP2 in the input file to avoid a clash with Vautils
names(gwas)[names(gwas) == "RSID2"] <- "RSID"

# Create data frames for novel and known SNPs
known_gwas <- gwas[gwas$Casual_Drugable_SNP == 1, ]
novel_gwas <- gwas[gwas$Casual_Drugable_SNP == 0, ]

# Write to output files
data.table::fwrite(gwas, file = output_file_all, sep = ",", row.names = FALSE)
data.table::fwrite(known_gwas, file = output_file_known, sep = ",", row.names = FALSE)
data.table::fwrite(novel_gwas, file = output_file_novel, sep = ",", row.names = FALSE)
