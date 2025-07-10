# Import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches   
from sklearn.decomposition import PCA 
from sklearn.preprocessing import StandardScaler
from mpl_toolkits.mplot3d import Axes3D

# Set base path
#data_path = '/data/home/bt24981/pca/2025-05-13'
data_path = 'C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/HPC/pca/2025-06-30'

# set file paths
input_file  = f'{data_path}/model_data.csv'
output_file = f'{data_path}/pca_loadings.csv'

# Get data
df = pd.read_csv(input_file, sep=',', na_values='NA')

# Create a colour index
samplecolours = df.apply(lambda row: 'Red' if row['Causal_SNP'] == 1 or row['Drugable_SNP'] == 1 else 'Blue', axis=1).tolist()

# Combine Cauual and druggable columns and remove unimportant
#df.insert(0, 'Causal', df['Causal_SNP'] | df['Drugable_SNP'])
sample_names = df['SNP'].tolist()
df = df.drop(['SNP', 'RSID', 'Source', 'Causal_SNP', 'Drugable_SNP'], axis=1)

# Standardise the features
scaler = StandardScaler()
dfscalar = scaler.fit_transform(df)

# perform PCA using sklearn
n_components = 10
pca = PCA(n_components)
pca.fit(dfscalar) 
print('Proportion of variance captured by each PC:')
print(pca.explained_variance_ratio_)

# Create a DataFrame showing the component loadings
loadings = pd.DataFrame(
    pca.components_.T,  # transpose so rows = features
    index=df.columns,   # use original feature names
    columns=[f'PC{i+1}' for i in range(pca.n_components_)]
)
print('PC Loadings:')
print(loadings)
print(loadings[['PC1', 'PC2', 'PC3']])

# Save Loadings
loadings.to_csv(output_file, sep=',', index=True)

# Plot PCA Results
plt.plot(range(1,11),pca.explained_variance_ratio_)
plt.xlabel('Principal component')
plt.ylabel('Explained variance')
plt.xticks(np.arange(1, 11, 1))
#plt.title('Principal Components Analysis')
plt.savefig('pca_variance.png')

# generate scores matrix
X_scores = pd.DataFrame(pca.transform((df)), index=sample_names)
print(X_scores)

# Draw a scatter diagram of the PCA scores
plt.scatter(X_scores[0], X_scores[1], c=samplecolours)
plt.xlabel('PC1 ('+str(round(pca.explained_variance_ratio_[0]*100))+'%)')
plt.ylabel('PC2 ('+str(round(pca.explained_variance_ratio_[1]*100))+'%)')
ctrlpatch = mpatches.Patch(color='red',label='Causable')
crohnspatch = mpatches.Patch(color='blue',label='Non-Causable')
plt.legend(handles=[ctrlpatch,crohnspatch],loc='upper right',ncol=2)
#plt.title('First and Second Principal Components')
plt.savefig('pca_1and2.png')

# Draw a 3-D scatter diagram
fig = plt.figure(figsize=(8, 6))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(X_scores[0], X_scores[1], X_scores[2], c=samplecolours)
ax.set_xlabel('PC1 ('+str(round(pca.explained_variance_ratio_[0]*100))+'%)')
ax.set_ylabel('PC2 ('+str(round(pca.explained_variance_ratio_[1]*100))+'%)')
ax.set_zlabel('PC3 ('+str(round(pca.explained_variance_ratio_[2]*100))+'%)')
ctrlpatch = mpatches.Patch(color='red',label='Causable')
crohnspatch = mpatches.Patch(color='blue',label='Non-Causable')
plt.legend(handles=[ctrlpatch,crohnspatch],loc='upper right',ncol=2)
#plt.title('First, Second and Third Principal Components')
plt.savefig('pca_1and2and3.png')