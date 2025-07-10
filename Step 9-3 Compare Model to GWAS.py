# Import libraries
import pandas as pd

# Set base path and input file name
data_path = 'C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Down Stream Processing/Compare Model to GWAS'
gwas_file  = '{}/MAGIC1000G_HbA1c_TA.tsv'.format(data_path)
model_file = '{}/model_results_expanded_snp.csv'.format(data_path)
gwas_rank_file = '{}/gwas_rank_file.csv'.format(data_path)
model_rank_file = '{}/model_rank_file.csv'.format(data_path)
comparison_rank_file = '{}/comparison_rank_file.csv'.format(data_path)

# Get data
gwas_data = pd.read_csv(gwas_file, sep='\t', na_values='NA', low_memory=False)
model_data = pd.read_csv(model_file, sep=',', na_values='NA')

# Drop columns
columns_to_keep = ['chromosome', 'base_pair_location', 'effect_allele', 'other_allele', 'het_p_value']
gwas_data = gwas_data[columns_to_keep]
columns_to_keep = ['SNP', 'Chromosome', 'Position', 'Ref', 'Alt', 'RSID', 'Source', 'Prioritisation', 'Casual_Drugable_SNP', 'Causal_SNP', 'Drugable_SNP']
model_data = model_data[columns_to_keep]

# Add SNP column to GWAS data frame
gwas_data['SNP'] = gwas_data['chromosome'].astype(str) + ':' + \
            gwas_data['base_pair_location'].astype(str) + ':' + \
            gwas_data['other_allele'].astype(str) + ':' + \
            gwas_data['effect_allele'].astype(str)

# Rank the data
gwas_data['gwas_rank'] = gwas_data['het_p_value'].rank(ascending=True, method='min')
model_data['model_rank'] = model_data['Prioritisation'].rank(ascending=False, method='min')

# create comparicon dataframe
model_gwas_comparison = model_data.merge(gwas_data[['SNP', 'gwas_rank', 'het_p_value']], on='SNP', how='left')
model_gwas_comparison = model_gwas_comparison.drop(columns=['Chromosome','Position','Ref', 'Alt','Causal_SNP','Drugable_SNP'])

# Sort
gwas_data = gwas_data.sort_values(by='gwas_rank', ascending=True)
model_data = model_data.sort_values(by='model_rank', ascending=True)
model_gwas_comparison = model_gwas_comparison.sort_values(by='model_rank', ascending=True)

# Reduce number of Rows
gwas_data = gwas_data.head(1000000)
#model_data = model_data.head(100)

# Save
gwas_data.to_csv(gwas_rank_file, index=False)
model_data.to_csv(model_rank_file, index=False)
model_gwas_comparison.to_csv(comparison_rank_file, index=False)