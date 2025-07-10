library(data.table)
library(dplyr)

# Clear global environment
rm(list=ls())

# Define all paths
clinvar_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/NLM Clinvar Variant Summary/variant_summary.txt"
results_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/Clinvar Phenotypes.csv"

# Read in the clinvar file and wrangle
clinvar <- data.table::fread(clinvar_file, header = TRUE, stringsAsFactors = FALSE)
pattern <- "Type 2 diabetes|Diabetes Mellitus|Hypertension|Obesity|atherosclerosis"
#extras <- clinvar[grepl(pattern,clinvar$PhenotypeList,ignore.case=TRUE)==TRUE]
extras <- clinvar[grepl(pattern, clinvar$PhenotypeList, ignore.case = TRUE) &
    grepl("Pathogenic", clinvar$ClinicalSignificance, ignore.case = TRUE) &
    grepl("multiple submitters", clinvar$ReviewStatus, ignore.case = TRUE) &
    grepl("no conflicts", clinvar$ReviewStatus, ignore.case = TRUE)
]
print(nrow(extras))

# Format columns
extras$SNP <- paste(extras$Chromosome, extras$PositionVCF, extras$ReferenceAlleleVCF, extras$AlternateAlleleVCF , sep = ":")
extras$RSID <- paste("rs", extras$"RS# (dbSNP)", sep="")
extras$RSID <- ifelse(extras$RSID=="rs-1", "", extras$RSID)
extras$Source <- "Clinvar"
extras$Causal_SNP <- 1
extras$Drugable_SNP <- 0
results <- extras[,c("SNP","Source","RSID","Causal_SNP","Drugable_SNP")]
results <- subset(results,!grepl("na:na",results$SNP) )

# Remove unwanted rows of data
pattern <- "na:na|X:|Y:|MT:"
results <- subset(results,!grepl(pattern,results$SNP) )
results <- distinct(results)
newresults <- results %>% group_by(SNP,Source,Causal_SNP,Drugable_SNP) %>% reframe(RSID=paste(RSID,collapse=";"))
head(newresults)

# Select columns and write Results File
library(dplyr)

# Clear global environment
rm(list=ls())

# Define all paths
clinvar_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/NLM Clinvar Variant Summary/variant_summary.txt"
results_file  <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/Clinvar Phenotypes.csv"

# Read in the clinvar file and wrangle
clinvar <- data.table::fread(clinvar_file, header = TRUE, stringsAsFactors = FALSE)
pattern <- "Type 2 diabetes|Diabetes Mellitus|Hypertension|Obesity|atherosclerosis"
#extras <- clinvar[grepl(pattern,clinvar$PhenotypeList,ignore.case=TRUE)==TRUE]
extras <- clinvar[grepl(pattern, clinvar$PhenotypeList, ignore.case = TRUE) &
    grepl("Pathogenic", clinvar$ClinicalSignificance, ignore.case = TRUE) &
    grepl("multiple submitters", clinvar$ReviewStatus, ignore.case = TRUE) &
    grepl("no conflicts", clinvar$ReviewStatus, ignore.case = TRUE)
]
print(nrow(extras))

# Format columns
extras$SNP <- paste(extras$Chromosome, extras$PositionVCF, extras$ReferenceAlleleVCF, extras$AlternateAlleleVCF , sep = ":")
extras$RSID <- paste("rs", extras$"RS# (dbSNP)", sep="")
extras$RSID <- ifelse(extras$RSID=="rs-1", "", extras$RSID)
extras$Source <- "Clinvar"
extras$Causal_SNP <- 1
extras$Drugable_SNP <- 0
results <- extras[,c("SNP","Source","RSID","Causal_SNP","Drugable_SNP")]
results <- subset(results,!grepl("na:na",results$SNP) )

# Remove unwanted rows of data
pattern <- "na:na|X:|Y:|MT:"
results <- subset(results,!grepl(pattern,results$SNP) )
results <- distinct(results)
newresults <- results %>% group_by(SNP,Source,Causal_SNP,Drugable_SNP) %>% reframe(RSID=paste(RSID,collapse=";"))
head(newresults)

# Select columns and write Results File
write.table(newresults, file=results_file, quote=FALSE, sep=",", row.names = FALSE)

