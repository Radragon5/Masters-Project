import numpy as np
import pandas as pd
from sklearn.impute import KNNImputer

# Set base path
data_path = "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Combined Result"

# set file paths
input_file  = f'{data_path}/Combined Model Parameters After Missingness Test.csv'
output_file = f'{data_path}/Combined Model Parameters After KNN.csv'

# Get data
df = pd.read_csv(input_file, sep=',', na_values='NA')

# drop non-numerical columns
features = df.drop (columns=['SNP','RSID','Source','Causal_SNP','Drugable_SNP']) 
features.replace(["", " ", "N/A", "null","NA"], np.nan, inplace=True)
features = features.apply(pd.to_numeric, errors='coerce')

# Apply KNN imputer
imputer = KNNImputer(n_neighbors=172,missing_values=np.nan)
imputed_data = imputer.fit_transform(features)

# Recombine with SNP column
df_imputed = pd.concat([df[['SNP','SNP','RSID','Source','Causal_SNP','Drugable_SNP']], pd.DataFrame(imputed_data, columns=features.columns)], axis=1)

# Save
df_imputed.to_csv(output_file, sep=',', index=False)