# Masters-Project
Queen Mary University of London

Bioinformatics Research Project
Module code: BIO702P

Machine Learning to Predict Causal and Druggable Cardiovascular Disease Variants Following Genome-wide Association Study

Master of Science (MSc) Bioinformatics

August 2025


Code Availability
All code used in the project has been deposited in GitHub and can be found in at https://github.com/Radragon5/Masters-Project

Table 2 - Summary of Programs Used in this Project

Abbreviated	Programming	Full
Name		Language	Name

Step 1-1	R			Step 1-1 Find Lead SNPs

Step 1-2	R			Step 1-2 Find SNPs Within 500kb
Step 2-1	R			Step 2-1 Get ClinVar Phenotype List
Step 3-1	R			Step 3-1 Get RSIDs From Biomart
Step 3-2	R			Step 3-2 Get RSIDs from BIM files
Step 3-3	R			Step 3-3 Split VCF files into smaller chunks
Step 3-4	R			Step 3-4 Get RSIDs From VCF file
Step 3-5	R			Step 3-5 Get PharmGKB Phenotype List
Step 4-1	R			Step 4-1 Get Causal and Druggable Mappings
Step 5-1	R			Step 5-1 VEP Model Parameters before Cleaning
Step 5-2	R			Step 5-2 Create VCF Files for DeepSEA
Step 5-3	R			Step 5-3 Recombine Results Files
Step 5-4	R			Step 5-4 Collapse VEP Results to single lines
Step 5-5	R			Step 5-5 VEP Model Parameters before Cleaning
Step 5-6	R			Step 5-6 Create REVEL relationships file
Step 5-7	R			Step 5-7 Create VCF File Chunks CADD
Step 5-8	R			Step 5-8 Recombine VCF File Chunks
Step 5-9	R			Step 5-9 Reformat CADD Results
Step 5-10	R			Step 5-10 Combine resources
Step 6-1	R			Step 6-1 Pairwise Analysis
Step 6-2	R			Step 6-2 Missingness Analysis
Step 6-3	Python		Step 6-3 Impute KNN
Step 7-1	R			Step 7-1 Skewness and Kurtosis
Step 7-2	Python		Step 7-2 PCA
Step 8		Python		Step 8 ML Model
Step 9-1	R			Step 9-1 Annotate SNPs to Genes
Step 9-2	R			Step 9-2 Analyse variant scores
Step 9-3	Python		Step 9-3 Compare Model to GWAS

Abbreviated	Programming	Full
Name		Language	Name

Step 1-1	R			Step 1-1 Find Lead SNPs
Step 1-2	R			Step 1-2 Find SNPs Within 500kb
Step 2-1	R			Step 2-1 Get ClinVar Phenotype List
Step 3-1	R			Step 3-1 Get RSIDs From Biomart
Step 3-2	R			Step 3-2 Get RSIDs from BIM files
Step 3-3	R			Step 3-3 Split VCF files into smaller chunks
Step 3-4	R			Step 3-4 Get RSIDs From VCF file
Step 3-5	R			Step 3-5 Get PharmGKB Phenotype List
Step 4-1	R			Step 4-1 Get Causal and Druggable Mappings
Step 5-1	R			Step 5-1 VEP Model Parameters before Cleaning
Step 5-2	R			Step 5-2 Create VCF Files for DeepSEA
Step 5-3	R			Step 5-3 Recombine Results Files
Step 5-4	R			Step 5-4 Collapse VEP Results to single lines
Step 5-5	R			Step 5-5 VEP Model Parameters before Cleaning
Step 5-6	R			Step 5-6 Create REVEL relationships file
Step 5-7	R			Step 5-7 Create VCF File Chunks CADD
Step 5-8	R			Step 5-8 Recombine VCF File Chunks
Step 5-9	R			Step 5-9 Reformat CADD Results
Step 5-10	R			Step 5-10 Combine resources
Step 6-1	R			Step 6-1 Pairwise Analysis
Step 6-2	R			Step 6-2 Missingness Analysis
Step 6-3	Python		Step 6-3 Impute KNN
Step 7-1	R			Step 7-1 Skewness and Kurtosis
Step 7-2	Python		Step 7-2 PCA
Step 8		Python		Step 8 ML Model
Step 9-1	R			Step 9-1 Annotate SNPs to Genes
Step 9-2	R			Step 9-2 Analyse variant scores
Step 9-3	Python		Step 9-3 Compare Model to GWAS

All programs used in this project listed above are available in GitHub at the indicated URL. Each program is prefixed by Step x-y, indicating their logical grouping (x) and order of usage (y).
