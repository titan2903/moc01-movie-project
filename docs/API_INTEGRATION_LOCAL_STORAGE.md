# TMDB API Integration & Local Storage Fallback Walkthrough

Implementasi fitur integrasi TMDB API beserta _local storage fallback_ menggunakan library populer dan arsitektur BLoC untuk daftar film (*Movie List*) dan detail film (*Movie Detail*).

## Changes Made

### 1. Penambahan Dependencies
Menambahkan *library* berikut pada `pubspec.yaml`:
- `dio`: Untuk memanggil HTTP request ke TMDB API.
- `flutter_dotenv`: Untuk membaca rahasia `API_KEY` dari file `.env`.
- `shared_preferences`: Untuk menyimpan _cache_ JSON dari respons TMDB API ke _local storage_ agar dapat dibaca ketika sedang _offline_.
- `connectivity_plus`: Mengecek apakah ada akses internet atau tidak sebelum memanggil API.
- `cached_network_image`: Mengunduh dan melakukan penyimpanan otomatis (_caching_) pada gambar poster film.

### 2. Modifikasi File Existing
Modifikasi dilakukan pada file existing:
- **`lib/main.dart`**:
  - Mengubah struktur kelas `Movie` agar memiliki properti seperti `id`, `posterPath`, `runtime`, `genres`, `tagline` serta fungsi `fromJson` dan `toJson`.
  - Mengubah _placeholder_ gambar abu-abu pada `MovieProjectScreen` dan `MovieDetailScreen` menjadi widget `CachedNetworkImage` agar dapat memuat gambar poster secara aktual dari internet.
  - Memodifikasi `_MovieProjectScreenState` yang semula menggunakan `FutureBuilder` menjadi `BlocBuilder<MovieBloc, MovieState>`.
  - Memodifikasi `MovieDetailScreen` menggunakan `BlocProvider` lokal dan `BlocBuilder<MovieDetailBloc, MovieDetailState>` untuk memanggil dan menampilkan data detail film secara dinamis.

### 3. Implementasi BLoC Pattern Baru
- **`lib/bloc/movie_event.dart` & `lib/bloc/movie_state.dart`**: Menangani state pemuatan daftar film.
- **`lib/bloc/movie_bloc.dart`**:
  - Cek Koneksi (menggunakan `connectivity_plus`).
  - **Online**: Memanggil `/movie/now_playing` menggunakan `dio`, melakukan cache JSON ke `shared_preferences` dengan key `cached_movies`, lalu emit `MovieLoaded`.
  - **Offline**: Membaca key `cached_movies` dari `shared_preferences`, lalu emit `MovieLoaded` dengan data cache tersebut.
- **`lib/bloc/movie_detail_event.dart` & `lib/bloc/movie_detail_state.dart`**: Menangani state pemuatan detail film spesifik berdasarkan ID.
- **`lib/bloc/movie_detail_bloc.dart`**:
  - Cek Koneksi (menggunakan `connectivity_plus`).
  - **Online**: Memanggil `/movie/{movie_id}` menggunakan `dio`, melakukan cache JSON detail ke `shared_preferences` dengan key `cached_movie_detail_{movie_id}`, lalu emit `MovieDetailLoaded`.
  - **Offline**: Membaca key `cached_movie_detail_{movie_id}` dari `shared_preferences`, lalu emit `MovieDetailLoaded` dengan data cache tersebut.

## Verification
Untuk memverifikasinya, silakan lakukan langkah berikut pada _emulator_ / perangkat Anda (jika aplikasi sedang berjalan, silakan lakukan `Hot Restart` atau tekan `R`):

1. **Test Online**: Jalankan aplikasi saat ada koneksi internet. Daftar film dan detail film lengkap beserta poster aslinya akan sukses dimuat dari TMDB.
2. **Test Offline**: Nyalakan **Mode Pesawat (Airplane Mode)** pada *emulator/device* untuk mematikan internet, kemudian jalankan kembali atau lakukan _hot restart_ aplikasinya. Baik daftar film maupun halaman detail yang pernah dibuka sebelumnya akan tetap termuat cepat karena membaca dari _Local Storage_ (`shared_preferences`).
3. **Test Offline Tanpa Cache**: Buka halaman detail film yang belum pernah dikunjungi saat offline. Halaman detail akan memunculkan pesan error "No internet connection and no cached data available" yang rapi.
4. **Test Reload Cepat (Hot Reload)**: Fitur favorit tetap dapat digunakan pada list screen dan sinkron dengan detail screen, persis seperti implementasi yang ada sebelumnya.

> [!TIP]  
> Jika mengalami masalah di _build_, cobalah hentikan aplikasi, ketik `flutter clean`, lalu jalankan kembali dengan `flutter run`. Hal ini seringkali diperlukan setelah ada banyak library Native Android yang baru diinstal (seperti `shared_preferences` dan `connectivity_plus`).
