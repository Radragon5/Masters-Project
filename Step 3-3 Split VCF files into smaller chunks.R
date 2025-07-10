# Clear global environment
rm(list=ls())

# Define all paths
vcf_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/NLM-SNP-Human-GRcH37/common_all_20180423 - Copy.txt"
tmp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/common_all_20180423 - Smaller.tsv"

# Read in the vcf file
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=0, nrows=5000000)
head(vcf)

# Just select the first 5 columns to reduce file size
vcf_smaller <- vcf[, c("V1","V2","V3","V4","V5")]

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=5000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=10000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=15000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=20000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=25000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=30000000, nrows=5000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Read next 5000000 rows
vcf <- data.table::fread(vcf_path, header = FALSE, stringsAsFactors = FALSE, skip=35000000)
vcf_reduced <- vcf[, c("V1","V2","V3","V4","V5")]
vcf_smaller = rbind(vcf_smaller,vcf_reduced)

# Create smaller file
write.table(vcf_smaller, file=tmp_path, quote=FALSE, sep='\t', row.names = FALSE)