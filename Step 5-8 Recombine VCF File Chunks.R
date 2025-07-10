library(dplyr)
library(data.table)

# Clear global environment
rm(list=ls())

# Define Parameters
number_of_files = 30
Chunk_File <- "CADD Results/Results Chunk xxx.tsv"
vep_output_path <- "CADD Results/CADD Results.csv"

# Combine files
for (i in 1:number_of_files) {
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