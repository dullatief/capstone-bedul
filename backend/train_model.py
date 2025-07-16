import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestRegressor
import joblib
import os

df = pd.read_csv('dataset.csv')

df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace(r'\(.*\)', '', regex=True)

print(df.columns)

le_gender = LabelEncoder()
le_activity = LabelEncoder()

df['jenis_kelamin'] = df['jenis_kelamin'].replace({'Laki-laki': 'L', 'Perempuan': 'P'})
df['tingkat_aktivitas'] = df['tingkat_aktivitas'].replace({'Rendah': 'rendah', 'Sedang': 'sedang', 'Tinggi': 'tinggi'})

df['jenis_kelamin'] = le_gender.fit_transform(df['jenis_kelamin'])
df['tingkat_aktivitas'] = le_activity.fit_transform(df['tingkat_aktivitas'])

X = df[['usia', 'berat_badan_', 'tinggi_badan_', 'tingkat_aktivitas', 'jenis_kelamin']]
y = df['kebutuhan_air_']

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
from sklearn.metrics import mean_squared_error, r2_score
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print("Mean Squared Error:", mse)
print("R^2 Score:", r2)

if not os.path.exists('model'):
    os.makedirs('model')

joblib.dump(model, 'model/model.pkl')
joblib.dump(le_gender, 'model/le_gender.pkl')
joblib.dump(le_activity, 'model/le_activity.pkl')

print("✅ Model berhasil dilatih dan disimpan.")
