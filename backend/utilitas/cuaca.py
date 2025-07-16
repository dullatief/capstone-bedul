import requests
from config import WEATHER_API_KEY

def get_current_temperature(city):
    url = f"https://api.weatherbit.io/v2.0/current?city={city}&key={WEATHER_API_KEY}"
    try:
        response = requests.get(url)
        data = response.json()
        if response.status_code == 200 and 'data' in data:
            temperature = data['data'][0]['temp'] 
            return temperature
        else:
            return None
    except Exception as e:
        print(f"Error fetching weather data: {e}")
        return None

def koreksi_suhu_berbasis_jurnal(suhu):
    if suhu <= 20:
        return 0
    return round((suhu - 20) * 0.04, 2)

def get_tabel_koreksi_suhu():
    return [
        {"suhu": 21, "koreksi": 0.04, "penjelasan": "Tambahan dari baseline 20°C (1°C × 0.04 L)"},
        {"suhu": 23, "koreksi": 0.12, "penjelasan": "3°C × 0.04 L"},
        {"suhu": 25, "koreksi": 0.20, "penjelasan": "5°C × 0.04 L"},
        {"suhu": 27, "koreksi": 0.28, "penjelasan": "7°C × 0.04 L"},
        {"suhu": 30, "koreksi": 0.40, "penjelasan": "10°C × 0.04 L"},
        {"suhu": 32, "koreksi": 0.48, "penjelasan": "12°C × 0.04 L"},
    ]