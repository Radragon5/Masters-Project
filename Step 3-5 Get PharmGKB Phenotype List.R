library(dplyr)
library(tidyr)

# Clear global environment
rm(list=ls())

# Define all paths
pharm1_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/PharmGKB Variant Assnotation Summary/var_pheno_ann.tsv"
pharm2_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/PharmGKB Variant Assnotation Summary/var_drug_ann.tsv"
results_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/PharGKB Phenotypes.csv"

# Read in the pharm1 file and wrangle
pharm1 <- data.table::fread(pharm1_file, header = TRUE, stringsAsFactors = FALSE)
pharm1 <- pharm1[,c("Variant/Haplotypes","Phenotype")]
pharm1$Source <- "PharmGKB Pheno"

# Read in the pharm2 file and wrangle
pharm2 <- data.table::fread(pharm2_file, header = TRUE, stringsAsFactors = FALSE)
pharm2 <- pharm2[,c("Variant/Haplotypes","Population Phenotypes or diseases")]
colnames(pharm2) <- c("Variant/Haplotypes", "Phenotype")
pharm2$Source <- "PharmGKB Drug"

# Combine pharm1 and pharm2
pharm <- rbind(pharm1,pharm2)

#Select rows for selected phenotype
pattern <- "Type 2 diabetes|Diabetes Mellitus|Hypertension|Obesity|atherosclerosis"
extras <- pharm[grepl(pattern,pharm$Phenotype,ignore.case=TRUE)==TRUE]

# Format columns
extras$SNP <- ""
extras$RSID <- extras$"Variant/Haplotypes"
extras$Causal_SNP <- 0
extras$Drugable_SNP <- 1
results <- extras[,c("SNP","Source","RSID","Causal_SNP","Drugable_SNP")]

# Remove unwanted rows of data
pattern <- "CYP|NAT2|UGT"
results <- subset(results,!grepl(pattern,results$RSID) )
results <- distinct(results)

# Select columns and write Results File
print(nrow(extras))
head(results)
write.table(results, file=results_file, quote=FALSE, sep=",", row.names = FALSE)