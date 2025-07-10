library(dplyr)

# Clear global environment
rm(list=ls())

# Define all paths
snp_file      <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP to RSid Mapppings.csv"
pharma1_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/PharmGKB Variant Assnotation Summary/var_drug_ann.tsv"
pharma2_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/PharmGKB Variant Assnotation Summary/var_pheno_ann.tsv"
clinvar_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/NLM Clinvar Variant Summary/variant_summary.txt"
results_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP Causal and Drug Relationahips.csv"

# Read in the snps file
snps <- data.table::fread(snp_file, header = TRUE, stringsAsFactors = FALSE)

# Read in the pharma1 file and wrangle
pharma <- data.table::fread(pharma1_file, header = TRUE, stringsAsFactors = FALSE)
pharma <- pharma[,c("Variant/Haplotypes")]

# Create Column with 1 if SNP exists, 0 otherwise
pharma$Drugable1_SNP <- 1
results <- merge(x=snps, y=pharma, by.x="RSID", by.y="Variant/Haplotypes", all.x=TRUE)
results$Drugable1_SNP <-replace(results$Drugable1_SNP, is.na(results$Drugable1_SNP), 0) 

# Read in the pharma2 file and wrangle
pharma <- data.table::fread(pharma2_file, header = TRUE, stringsAsFactors = FALSE)
pharma <- pharma[,c("Variant/Haplotypes")]

# Create Column with 1 if SNP exists, 0 otherwise
pharma$Drugable2_SNP <- 1
results <- merge(x=results, y=pharma, by.x="RSID", by.y="Variant/Haplotypes", all.x=TRUE)
results$Drugable2_SNP <-replace(results$Drugable2_SNP, is.na(results$Drugable2_SNP), 0) 

# Merge The two drugable columns
results$Drugable_SNP <- ifelse(results$Drugable1_SNP | results$Drugable2_SNP, 1, 0)

# Read in the clinvar file and wrangle
clinvar <- data.table::fread(clinvar_file, header = TRUE, stringsAsFactors = FALSE)
clinvar$SNP <- paste(clinvar$Chromosome, clinvar$PositionVCF, clinvar$ReferenceAlleleVCF, clinvar$AlternateAlleleVCF, sep = ":")
clinvar <- clinvar[,c("SNP")]

# Create Column with 1 if SNP exists, 0 otherwise
clinvar$Causal_SNP <- 1
results <- merge(x=results, y=clinvar, by.x="SNP", by.y="SNP", all.x=TRUE)
results$Causal_SNP <-replace(results$Causal_SNP, is.na(results$Causal_SNP), 0) 

# Select columns and write Results File
results <- results[,c("SNP","RSID","Causal_SNP","Drugable_SNP")]
results <- distinct(results)
write.table(results, file=results_file, quote=FALSE, sep=',', row.names = FALSE)