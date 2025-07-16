import pandas as pd
from sklearn.preprocessing import LabelEncoder

df = pd.read_csv('water_dataset.csv')

print("Missing values sebelum ditangani:\n", df.isnull().sum())

df.dropna(inplace=True)

df.drop_duplicates(inplace=True)

df['Age'] = df['Age'].astype(int)
df['Weight (kg)'] = df['Weight (kg)'].astype(float)
df['Height (cm)'] = df['Height (cm)'].astype(int)
df['Water Requirement (liters/day)'] = df['Water Requirement (liters/day)'].astype(float)

le_gender = LabelEncoder()
df['Gender'] = le_gender.fit_transform(df['Gender'])

le_activity = LabelEncoder()
df['Activity Level'] = le_activity.fit_transform(df['Activity Level'])

df.rename(columns={
    'Name': 'Nama',
    'Age': 'Usia',
    'Weight (kg)': 'Berat Badan (kg)',
    'Height (cm)': 'Tinggi Badan (cm)',
    'Activity Level': 'Tingkat Aktivitas',
    'Gender': 'Jenis Kelamin',
    'Water Requirement (liters/day)': 'Kebutuhan Air (liter/hari)'
}, inplace=True)

df['Jenis Kelamin'] = df['Jenis Kelamin'].map({0: 'Female', 1: 'Male'}).map({
    'Female': 'Perempuan',
    'Male': 'Laki-laki'
})

df['Tingkat Aktivitas'] = df['Tingkat Aktivitas'].map({0: 'High', 1: 'Low', 2: 'Moderate'}).map({
    'Low': 'Rendah',
    'Moderate': 'Sedang',
    'High': 'Tinggi'
})

df.to_csv('dataset.csv', index=False)
print("Preprocessing selesai. Dataset disimpan sebagai 'dataset.csv'")
