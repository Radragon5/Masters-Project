# Clear global environment
rm(list=ls())

# Define all paths
vcf_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/common_all_20180423 - Smaller.tsv"
snp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP Within 500kb.csv"
tmp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/Temp.csv"

# Read in the snps file
snps <- data.table::fread(snp_path, header = TRUE, stringsAsFactors = FALSE)

# Read in the vcf file
vcf <- data.table::fread(vcf_path, header = TRUE, stringsAsFactors = FALSE)
head(vcf)

# Create the SNP column in the vcf data
vcf$SNP <- paste(vcf$CHROM, vcf$POS, vcf$REF, vcf$ALT, sep = ":")
head(vcf)

# Select only the SNP and rsid columns
vcf_selected <- vcf[, c("SNP", "ID")]
head(vcf_selected)
colnames(vcf_selected) <- c("SNP", "rsid")
head(vcf_selected)
head(snps)

# Merge the snps data with the bim data
merged_data <- merge(snps, vcf_selected, by = "SNP", all.x = TRUE)
head(merged_data)
write.table(merged_data, file=tmp_path, quote=FALSE, sep=',', row.names = FALSE)