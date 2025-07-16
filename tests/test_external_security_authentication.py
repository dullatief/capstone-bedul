import unittest
import requests
import json
import time
import random
import string

class TestKeamananAutentikasiAPI(unittest.TestCase):
    BASE_URL = "http://api.bedoel.me"
    headers = {"Content-Type": "application/json"}
    user_test = None
    user_id = None
    data_login = None

    @classmethod
    def setUpClass(cls):
        print("\n=== SETUP SEKALI: DAFTAR & MASUK ===")
        ts = int(time.time())
        suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
        cls.user_test = {
            "email": f"test_keamanan_{suffix}@example.com",
            "password": "Str0ngP@ssw0rd123!",
            "nama": "Pengguna Tes",
            "usia": 25,
            "berat_badan": 70,
            "tinggi_badan": 175,
            "jenis_kelamin": "L"
        }

        # 1) DAFTAR
        url_daftar = f"{cls.BASE_URL}/daftar"
        resp = requests.post(url_daftar,
                             data=json.dumps(cls.user_test),
                             headers=cls.headers)
        print(f"[DAFTAR] POST {url_daftar}")
        print("  Status:", resp.status_code)
        try:
            print("  Isi    :", resp.json())
        except:
            print("  Isi    : <bukan JSON>")
        if resp.status_code not in (201, 409):
            raise RuntimeError("❌ Gagal daftar, hentikan pengujian")

        # 2) MASUK
        url_masuk = f"{cls.BASE_URL}/masuk"
        payload_masuk = {
            "email": cls.user_test["email"],
            "password": cls.user_test["password"]
        }
        resp = requests.post(url_masuk,
                             data=json.dumps(payload_masuk),
                             headers=cls.headers)
        print(f"[MASUK ] POST {url_masuk}")
        print("  Status:", resp.status_code)
        try:
            cls.data_login = resp.json()
            print("  Isi    :", cls.data_login)
        except:
            print("  Isi    : <bukan JSON>")
        if resp.status_code != 200:
            raise RuntimeError("❌ Gagal masuk, hentikan pengujian")
        cls.user_id = cls.data_login.get("user_id")
        print("  → user_id =", cls.user_id)

    def test_a_validasi_kekuatan_sandi(self):
        """A: Validasi kekuatan sandi (weak vs strong)."""
        print("\n=== TEST A: VALIDASI KEKUATAN SANDI ===")
        endpoint = f"{self.BASE_URL}/daftar"

        # a.1) Sandi lemah
        weak = self.user_test.copy()
        weak["email"] = f"weak_{int(time.time())}@example.com"
        weak["password"] = "short"
        print(f"[LEMAH ] POST {endpoint}")
        resp = requests.post(endpoint, data=json.dumps(weak), headers=self.headers)
        print("  Status:", resp.status_code)
        try:
            print("  Isi    :", resp.json())
        except:
            print("  Isi    : <bukan JSON>")
        if resp.status_code == 400:
            self.assertIn("error", resp.json())
        else:
            print("⚠️  API menerima sandi lemah, pertimbangkan validasi tambahan")

        # a.2) Sandi kuat
        strong = weak.copy()
        strong["email"] = f"strong_{int(time.time())}@example.com"
        strong["password"] = "Str0ngP@ssw0rd!"
        print(f"[KUAT  ] POST {endpoint}")
        resp = requests.post(endpoint, data=json.dumps(strong), headers=self.headers)
        print("  Status:", resp.status_code)
        try:
            print("  Isi    :", resp.json())
        except:
            print("  Isi    : <bukan JSON>")
        self.assertEqual(resp.status_code, 201, "Sandi kuat harus diterima (201)")

    def test_b_sql_injection(self):
        """B: Proteksi terhadap SQL Injection pada login."""
        print("\n=== TEST B: SQL INJECTION ===")
        endpoint = f"{self.BASE_URL}/masuk"
        injeksi_list = [
            {"email": "' OR '1'='1", "password": "apa saja"},
            {"email": "admin@example.com' --", "password": "apa saja"},
            {"email": f"{self.user_test['email']}' OR '1'='1", "password": "salah"}
        ]
        for inj in injeksi_list:
            print(f"[INJEKSI] POST {endpoint} payload={inj}")
            resp = requests.post(endpoint, data=json.dumps(inj), headers=self.headers)
            print("  Status:", resp.status_code)
            try:
                print("  Isi    :", resp.json())
            except:
                print("  Isi    : <bukan JSON>")
            self.assertEqual(resp.status_code, 401, f"SQL injection mungkin berhasil: {inj['email']}")

    def test_c_brute_force(self):
        """C: Proteksi terhadap serangan brute force."""
        print("\n=== TEST C: BRUTE FORCE ===")
        endpoint = f"{self.BASE_URL}/masuk"
        maks_attempt = 10
        for i in range(maks_attempt):
            kred = {"email": self.user_test["email"], "password": f"salah_{i}"}
            print(f"[BRUTE ] Percobaan {i+1}/{maks_attempt}: POST {endpoint} payload={kred}")
            resp = requests.post(endpoint, data=json.dumps(kred), headers=self.headers)
            print("  Status:", resp.status_code)
            if resp.status_code in (429, 403):
                print(f"🔒 Terdeteksi rate limiting setelah {i+1} percobaan")
                break
            self.assertEqual(resp.status_code, 401, "Harus 401 untuk login gagal")

        # Setelah gagal, coba login benar
        benar = {"email": self.user_test["email"], "password": self.user_test["password"]}
        print(f"[BRUTE ] Login benar: POST {endpoint} payload={benar}")
        resp = requests.post(endpoint, data=json.dumps(benar), headers=self.headers)
        print("  Status:", resp.status_code)
        if resp.status_code in (429, 403):
            print("🔒 Rate limiting masih berlaku untuk kredensial benar")
        else:
            self.assertEqual(resp.status_code, 200, "Login berhasil setelah brute force")

    def test_d_validasi_input(self):
        """D: Validasi input pada endpoint daftar."""
        print("\n=== TEST D: VALIDASI INPUT ===")
        endpoint = f"{self.BASE_URL}/daftar"

        # d.1) JSON rusak
        print(f"[RUSAK ] POST {endpoint} payload='Not JSON'")
        resp = requests.post(endpoint, data="Not JSON", headers=self.headers)
        print("  Status:", resp.status_code)
        self.assertNotEqual(resp.status_code, 500, "Tidak boleh 500 untuk JSON rusak")

        # d.2) Field hilang
        tidak_lengkap = {"email": self.user_test["email"]}
        print(f"[KURANG] POST {endpoint} payload={tidak_lengkap}")
        resp = requests.post(endpoint, data=json.dumps(tidak_lengkap), headers=self.headers)
        print("  Status:", resp.status_code)
        self.assertEqual(resp.status_code, 400, "Harus 400 untuk data tidak lengkap")

        # d.3) Email tidak valid
        invalid = self.user_test.copy()
        invalid["email"] = "bukan_email"
        print(f"[SALAH ] POST {endpoint} email={invalid['email']}")
        resp = requests.post(endpoint, data=json.dumps(invalid), headers=self.headers)
        print("  Status:", resp.status_code)
        self.assertEqual(resp.status_code, 400, "Harus 400 untuk format email salah")

    def test_e_deteksi_token_csrf(self):
        """E: Deteksi CSRF token dalam respons login."""
        print("\n=== TEST E: DETEKSI TOKEN CSRF ===")
        data = self.data_login
        ada_token = any("token" in k.lower() or "csrf" in k.lower() for k in data.keys())
        if ada_token:
            print("✔️  Ditemukan token CSRF dalam respons login")
        else:
            print("⚠️  Tidak ada token CSRF terdeteksi dalam respons login")

    def test_f_header_keamanan(self):
        """F: Pemeriksaan header keamanan pada respons login."""
        print("\n=== TEST F: HEADER KEAMANAN ===")
        headers_res = self.data_login and self.data_login.get("headers", {}) or {}
        # Jika login_response.headers tersedia, gunakan itu:
        try:
            headers_res = unittest.mock._sentinel if False else self.data_login  # placeholder
        except:
            headers_res = {}

        # Daftar header penting dan nilai yang diharapkan
        daftar_header = {
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': ['DENY', 'SAMEORIGIN'],
            'Content-Security-Policy': True,
            'Strict-Transport-Security': True,
            'X-XSS-Protection': '1; mode=block'
        }

        # Gunakan response terakhir dari login:
        # Untuk kesederhanaan, ulang panggil endpoint masuk:
        resp = requests.post(f"{self.BASE_URL}/masuk",
                             data=json.dumps({"email": self.user_test["email"], "password": self.user_test["password"]}),
                             headers=self.headers)
        hdrs = resp.headers

        for nama, ekspektasi in daftar_header.items():
            if nama in hdrs:
                nilai = hdrs[nama]
                if isinstance(ekspektasi, bool) and ekspektasi:
                    print(f"✔️  Header keamanan ada: {nama}")
                elif isinstance(ekspektasi, list) and nilai in ekspektasi:
                    print(f"✔️  Header {nama} bernilai benar: {nilai}")
                elif nilai == ekspektasi:
                    print(f"✔️  Header {nama} bernilai benar: {nilai}")
                else:
                    print(f"⚠️  Header {nama} nilai tak terduga: {nilai}")
            else:
                print(f"⚠️  Header keamanan tidak ada: {nama}")

if __name__ == "__main__":
    unittest.main(verbosity=1)
