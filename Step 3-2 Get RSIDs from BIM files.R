# Clear global environment
rm(list=ls())

# Define all paths
bim_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/GRCh37 - 1000 Genomes/1000G_EUR.bim"
snp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP Within 500kb.csv"
tmp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP to RSid Mappping using BIM files.csv"

# Read in the snps file
snps <- data.table::fread(snp_path, header = TRUE, stringsAsFactors = FALSE)

# Read in the bim file
bim <- data.table::fread(bim_path, header = FALSE, stringsAsFactors = FALSE)
head(bim)

# Create the SNP column in the bim data
bim$SNP <- paste(bim$V1, bim$V4, bim$V5, bim$V6, sep = ":")
head(bim)


# Select only the SNP and rsid columns
bim_selected <- bim[, c("SNP", "V2")]
head(bim_selected)

colnames(bim_selected) <- c("SNP", "rsid")
head(bim_selected)
head(snps)

# Merge the snps data with the bim data
merged_data <- merge(snps, bim_selected, by = "SNP", all.x = TRUE)
head(merged_data)
write.table(merged_data, file=tmp_path, quote=FALSE, sep=',', row.names = FALSE)

print(merged_data)