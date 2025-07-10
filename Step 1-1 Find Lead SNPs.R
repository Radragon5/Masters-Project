library(data.table)

# Clear global environment
rm(list=ls())

# Define Paths for Input gwas file and Output Lead SNP File
gwasdata_path <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/GCST90002247 MAGIC/MAGIC1000G_HbA1c_TA.tsv"
leadsnps_path <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/Lead SNPs.csv"

# Read GWAS File
gwasdata <- fread(gwasdata_path)
head(gwasdata)

# Build Lead SNP file
leadSNP <- subset(gwasdata, het_p_value<5E-8)                           # Only rows where p-value is <5E-8
leadSNP <- subset(leadSNP, chromosome!="X")                             # Remove chromosome X
leadSNP <- subset(leadSNP, chromosome!="Y")                             # Remove chromosome Y
leadSNP <- subset(leadSNP, select=c("chromosome","base_pair_location")) # Select just columns for Chromosome and location
head(leadSNP)

# Rename columns and sort numerically
colnames(leadSNP) <- c("chromosome","position")
leadSNP <- leadSNP[order(as.numeric(leadSNP$chromosome),as.numeric(leadSNP$position))]
head(leadSNP)

# Write Lead SNP File
write.table(leadSNP, file=leadsnps_path, quote=FALSE, sep=',', row.names = FALSE)
