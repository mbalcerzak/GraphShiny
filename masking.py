# file to maks true values of clinical datasets
# to ensure maximal data protection
# I am using Python because it's more suited for that task than # REVIEW:

import pandas as pd

# read in file that has secret codes ;) for all the datasets
df = pd.read_csv('masking.csv')

# the file has two columns: "x" (true name) and "code"
dict_ = dict(zip(df['x'],df['code']))

# read in original file with nodes and edges
dataframe = pd.read_csv('dataframe.csv')
unique = pd.read_csv('unique_names.csv')

def mask(x):
    if x in dict_:
        return dict_[x]

dataframe_masked = pd.DataFrame()
unique_masked = unique.copy()

for cols in ['from','to']:
    dataframe_masked[cols] = dataframe[cols].apply(lambda x: mask(x))

unique_masked['id'] =  unique['id'].apply(lambda x: mask(x))

# save the masked version that can be published
dataframe_masked.to_csv('dataframe_masked.csv', index = False)
unique_masked.to_csv('unique_masked.csv', index = False)

print("Masked files are ready")