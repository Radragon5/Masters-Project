library(biomaRt)
library(tidyr)

#clear global environment
rm(list=ls())

# Define all paths
snp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP Within 500kb Residual 1.csv"
tmp_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP to RSid using Biomart 2.csv"

# Read in the snps file
snps <- data.table::fread(snp_path, header = TRUE, stringsAsFactors = FALSE)
snps <- separate(snps,col="SNP",into=c("CHR","position","ref","alt"),sep=":")
snps <- subset(snps, select=c("CHR","position","position"))

# Define the Mart for BioMart
snp_mart <- useEnsembl(biomart="ENSEMBL_MART_SNP", 
                       host="https://grch37.ensembl.org", 
                       #mirror='www',
                       dataset="hsapiens_snp")

# Define results matrix
allresults <- data.frame(matrix(ncol=3,nrow=0, dimnames=list(NULL, c("CHR", "position", "position"))))

# Set the chunk size for queries. Too small it takes too long. Too large it times out.
chunksize = 1
nchunks = ceiling(nrow(snps) / chunksize )

# Loop through chunks
for (x in 100:nchunks)
  {
  # Message so we know where we are
  print(Sys.time())
  print(x)

  # Create subset to query
  snpssubset = snps[(x-1)*chunksize+1:chunksize,]
  snpssubset <- subset(snpssubset, select=c("CHR","position","position"))
  snpssubset <- apply(snpssubset, 1, paste, collapse = ":")
  
  # query results
  results <- getBM(attributes = c('refsnp_id', 'chr_name', 'chrom_start', 'allele'),
      filters = 'chromosomal_region', 
      values = snpssubset,
      #useCache = FALSE,
      verbose = TRUE,
      mart = snp_mart)
  print(results)
  
  # Add results to the data table
  allresults = rbind(allresults,results)
}

# Reformat Results and output
finalresults <- data.frame(paste0(allresults$chr_name,":",allresults$chrom_start,":",gsub('/',':',allresults$allele)),allresults$refsnp_id)
colnames(finalresults) <- c("SNP","rsID")
write.table(finalresults, file=tmp_path, quote=FALSE, sep=',', row.names = FALSE)