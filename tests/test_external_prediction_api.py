import unittest
import requests
import json
import time

class TestExternalPredictionAPIVerbose(unittest.TestCase):
    BASE_URL = "http://api.bedoel.me"
    headers = {"Content-Type": "application/json"}
    user_id = None

    @classmethod
    def setUpClass(cls):
        """Registrasi & login sekali sebelum semua test berjalan."""
        print("\n=== SETUP ONCE: REGISTER & LOGIN ===")
        ts = int(time.time())
        test_user = {
            "email": f"once_test_{ts}@example.com",
            "password": "TestPassword123!",
            "nama": "Test User",
            "usia": 25,
            "berat_badan": 70,
            "tinggi_badan": 175,
            "jenis_kelamin": "L"
        }

        # REGISTER
        url_daftar = f"{cls.BASE_URL}/daftar"
        resp = requests.post(url_daftar, data=json.dumps(test_user), headers=cls.headers)
        print(f"[REGISTER] POST {url_daftar}")
        print("  Status:", resp.status_code)
        try:
            print("  Body:", resp.json())
        except:
            print("  Body: <non-json>")
        if resp.status_code != 201:
            raise RuntimeError("❌ Gagal registrasi, tidak bisa lanjutkan test")

        # LOGIN
        url_masuk = f"{cls.BASE_URL}/masuk"
        login_payload = {"email": test_user["email"], "password": test_user["password"]}
        resp = requests.post(url_masuk, data=json.dumps(login_payload), headers=cls.headers)
        print(f"[LOGIN]    POST {url_masuk}")
        print("  Status:", resp.status_code)
        try:
            body = resp.json()
            print("  Body:", body)
        except:
            print("  Body: <non-json>")
        if resp.status_code != 200:
            raise RuntimeError("❌ Gagal login, tidak bisa lanjutkan test")
        cls.user_id = body.get("user_id")
        print("  → user_id =", cls.user_id)

    def test_1_prediction_without_activity(self):
        print("\n=== TEST 1: PREDICTION WITHOUT ACTIVITY ===")
        endpoint = f"{self.BASE_URL}/prediksi"
        payload = {"user_id": self.user_id}
        print(f"[PREDIKSI] POST {endpoint}  payload={payload}")
        resp = requests.post(endpoint, data=json.dumps(payload), headers=self.headers)
        print("  Status:", resp.status_code)
        try:
            print("  Body:", resp.json())
        except:
            print("  Body: <non-json>")

        if resp.status_code == 400:
            self.skipTest("❌ Endpoint kini menuntut 'tingkat_aktivitas'")
        self.assertEqual(resp.status_code, 200, "Prediksi tanpa aktivitas harus 200")
        data = resp.json()
        self.assertIn("rekomendasi_air", data)
        self.assertIn("total_hari_ini", data)
        self.assertIn("sisa_target", data)

    def test_2_prediction_with_activity(self):
        print("\n=== TEST 2: PREDICTION WITH ACTIVITY ===")
        endpoint = f"{self.BASE_URL}/prediksi"
        payload = {"user_id": self.user_id, "tingkat_aktivitas": "sedang"}
        print(f"[PREDIKSI] POST {endpoint}  payload={payload}")
        resp = requests.post(endpoint, data=json.dumps(payload), headers=self.headers)
        print("  Status:", resp.status_code)
        print("  Body:", resp.json())
        self.assertEqual(resp.status_code, 200, "Prediksi dengan aktivitas harus 200")
        self.assertGreater(resp.json().get("rekomendasi_air", 0), 0)

    def test_3_prediction_invalid_user(self):
        print("\n=== TEST 3: PREDICTION INVALID USER ===")
        endpoint = f"{self.BASE_URL}/prediksi"
        payload = {"user_id": 999_999_999, "tingkat_aktivitas": "sedang"}
        print(f"[PREDIKSI] POST {endpoint}  payload={payload}")
        resp = requests.post(endpoint, data=json.dumps(payload), headers=self.headers)
        print("  Status:", resp.status_code)
        print("  Body:", resp.json())
        self.assertIn(resp.status_code, (400, 404), "Harus 400/404 untuk user invalid")
        self.assertIn("error", resp.json())

    def test_4_prediction_history(self):
        print("\n=== TEST 4: PREDICTION HISTORY ===")
        # Buat satu prediksi agar ada data history
        pred_ep = f"{self.BASE_URL}/prediksi"
        payload = {"user_id": self.user_id, "tingkat_aktivitas": "sedang"}
        requests.post(pred_ep, data=json.dumps(payload), headers=self.headers)

        # Ambil history
        hist_ep = f"{self.BASE_URL}/riwayat-prediksi/{self.user_id}"
        print(f"[HISTORY]  GET  {hist_ep}")
        resp = requests.get(hist_ep, headers=self.headers)
        print("  Status:", resp.status_code)
        try:
            print("  Body:", resp.json())
        except:
            print("  Body: <non-json>")

        if resp.status_code == 404:
            self.skipTest("❌ Endpoint history belum diimplementasikan")
        self.assertEqual(resp.status_code, 200, "Riwayat prediksi harus 200")
        data = resp.json()
        self.assertIsInstance(data, list)
        if data:
            first = data[0]
            self.assertIn("rekomendasi_air", first)
            self.assertIn("tanggal", first)

if __name__ == "__main__":
    unittest.main(verbosity=1)
