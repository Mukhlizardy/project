# Aplikasi Grocery

Aplikasi belanja groceries berbasis Flutter yang memungkinkan pengguna untuk menjelajahi produk, mengelola keranjang belanja, dan melihat riwayat pembelian. Aplikasi ini terintegrasi dengan FakeStore API untuk mengambil data produk dan menyediakan pengalaman berbelanja yang lengkap.

## Fitur Utama

### 🔐 Autentikasi

- Sistem login sederhana dengan kredensial yang sudah ditentukan
- Status login persisten menggunakan SharedPreferences
- Manajemen sesi yang aman

### 🛍️ Manajemen Produk

- Jelajahi produk yang diambil dari FakeStore API
- Lihat detail produk termasuk judul, deskripsi, harga, dan gambar
- Tambahkan produk ke keranjang dengan pengelolaan kuantitas
- Sinkronisasi data produk secara real-time

### 🛒 Keranjang Belanja

- Tambah/hapus produk dari keranjang
- Perbarui kuantitas produk
- Lihat item keranjang dengan kalkulasi total
- Manajemen keranjang lokal dengan penyimpanan in-memory

### 📊 Riwayat Pembelian

- Lacak riwayat keranjang menggunakan penyimpanan lokal
- Lihat pembelian sebelumnya
- Riwayat persisten di seluruh sesi aplikasi

### 🎨 Antarmuka Pengguna

- Antarmuka Material Design yang bersih dan intuitif
- Layout responsif untuk berbagai ukuran layar
- Navigasi berkode warna dengan tombol bertema
- Loading states dan umpan balik pengguna

## Struktur Proyek

```
lib/
├── api/
│   ├── cart_api.dart          # Manajemen keranjang lokal
│   ├── fakestore_api.dart     # Integrasi API eksternal
│   ├── local_auth.dart        # Manajemen autentikasi
│   └── local_database.dart    # Persistensi data lokal
├── models/
│   ├── cart.dart              # Model data keranjang
│   ├── cart_item.dart         # Model data item keranjang
│   └── product.dart           # Model data produk
├── screens/
│   ├── login_screen.dart      # Halaman autentikasi pengguna
│   ├── home_screen.dart       # Dashboard utama
│   ├── product_screen.dart    # Halaman browsing produk
│   ├── cart_screen.dart       # Halaman manajemen keranjang
│   └── history_screen.dart    # Halaman riwayat pembelian
└── main.dart                  # Entry point aplikasi
```

## Implementasi Teknis

### Integrasi API

- **FakeStore API**: API REST eksternal untuk data produk
- **HTTP Client**: Package http Flutter untuk komunikasi API
- **JSON Serialization**: Kelas model khusus dengan metode fromJson/toJson

### Manajemen State

- **StatefulWidget**: Manajemen state lokal untuk setiap layar
- **setState()**: Update UI dan sinkronisasi data
- **Future/async**: Panggilan API asinkron dan operasi data

### Persistensi Data

- **SharedPreferences**: Penyimpanan lokal untuk autentikasi pengguna dan riwayat keranjang
- **In-Memory Storage**: Item keranjang disimpan dalam list statis untuk persistensi sesi

### Navigasi

- **Named Routes**: Sistem navigasi yang terorganisir
- **Route Management**: Pemisahan yang jelas antara route yang terautentikasi dan publik

## Memulai

### Prasyarat

- Flutter SDK (>=2.0.0)
- Dart SDK
- Android Studio atau VS Code
- Emulator Android/iOS atau perangkat fisik

### Instalasi

1. Clone repository:

```bash
git clone <repository-url>
cd grocery-app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Jalankan aplikasi:

```bash
flutter run
```

### Kredensial Login

```
Username: admin
Password: admin123
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  shared_preferences: ^2.0.15

dev_dependencies:
  flutter_test:
    sdk: flutter
```

## Endpoint API

Aplikasi ini terintegrasi dengan FakeStore API:

### Produk

- `GET /products` - Ambil semua produk
- `GET /products/{id}` - Ambil produk tunggal
- `POST /products` - Buat produk baru
- `PUT /products/{id}` - Update produk
- `DELETE /products/{id}` - Hapus produk

### Keranjang

- `GET /carts` - Ambil semua keranjang
- `GET /carts/{id}` - Ambil keranjang tunggal
- `POST /carts` - Buat keranjang baru
- `PUT /carts/{id}` - Update keranjang
- `DELETE /carts/{id}` - Hapus keranjang

## Alur Aplikasi

1. **Login**: Pengguna melakukan autentikasi dengan kredensial
2. **Beranda**: Dashboard dengan opsi navigasi
3. **Produk**: Jelajahi dan tambahkan item ke keranjang
4. **Keranjang**: Kelola item dan kuantitas keranjang
5. **Riwayat**: Lihat pembelian sebelumnya
6. **Logout**: Hapus sesi dan kembali ke login

## Komponen Utama

### Model

- **Product**: Merepresentasikan produk toko dengan id, judul, deskripsi, harga, dan gambar
- **Cart**: Merepresentasikan data keranjang dari API
- **CartItem**: Item keranjang lokal dengan produk dan kuantitas

### Layanan API

- **FakeStoreApi**: Menangani semua komunikasi API eksternal
- **CartApi**: Mengelola operasi keranjang lokal
- **LocalAuth**: Menangani status autentikasi
- **LocalDatabase**: Mengelola persistensi data lokal

## Detail Fitur

### Manajemen Keranjang

- Penambahan kuantitas otomatis untuk produk yang sudah ada
- Update keranjang secara real-time
- Penyimpanan lokal untuk persistensi keranjang
- Integrasi dengan API keranjang eksternal

### Alur Autentikasi

- Validasi kredensial sederhana
- Status login persisten
- Navigasi otomatis berdasarkan status autentikasi
- Fungsi logout yang aman

### Sinkronisasi Data

- Pengambilan produk secara real-time
- Keranjang lokal dengan sinkronisasi API
- Pelacakan riwayat dengan penyimpanan lokal
- Penanganan error untuk operasi jaringan

## Pengembangan Masa Depan

- [ ] Registrasi pengguna dan manajemen profil
- [ ] Pencarian dan filter produk
- [ ] Kategori dan organisasi produk
- [ ] Integrasi pembayaran
- [ ] Pelacakan pesanan
- [ ] Notifikasi push
- [ ] Dukungan mode offline
- [ ] Review dan rating produk

## Kontribusi

1. Fork repository
2. Buat feature branch
3. Lakukan perubahan
4. Tambahkan test jika diperlukan
5. Submit pull request

## Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file LICENSE untuk detail.

## Dukungan

Untuk dukungan dan pertanyaan, silakan buka issue di repository atau hubungi tim pengembang.

---

**Catatan**: Aplikasi ini menggunakan FakeStore API untuk tujuan demonstrasi. Dalam lingkungan produksi, Anda akan mengintegrasikan dengan backend e-commerce yang sesungguhnya dengan autentikasi dan langkah-langkah keamanan yang tepat.
