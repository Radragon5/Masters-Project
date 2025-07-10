library(dplyr)
library(data.table)

# Clear global environment
rm(list=ls())

# Define Parameters
number_of_files = 3
Chunk_File <- "VCF Results/DeepSEA_Upload_File_chunk_xxx_FEATURE_seqclass.tsv"
vep_output_path <- "VCF Results/DeepSEA_Upload_File_FEATURE_seqclass.csv"

# Combine files
for (i in 1:32) {
  inputfilename = gsub("xxx", sprintf("%03d", i), Chunk_File)
  print(inputfilename)
  if ( i == 1 )
    {
    results <- data.table::fread(inputfilename, header = TRUE, stringsAsFactors = FALSE)
    }
  else
    {
    nextresult <- data.table::fread(inputfilename, header = TRUE, stringsAsFactors = FALSE)
    results <- rbind(results,setcolorder(nextresult,names(results))) 
    }
}

# Change any "," in column names to "_" so that we can use a csv file for output
setnames(results, gsub(",", "_", names(results)))

# Write result
print (nrow(results))
write.table(results, file=vep_output_path, quote=FALSE, sep=',', row.names = FALSE)