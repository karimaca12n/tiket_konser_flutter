# SoraiFest - Retro Minimal Concert Ticketing App

SoraiFest adalah platform manajemen dan pemesanan tiket konser dengan estetika **"Retro Minimal + Comic Accent"** (Zine/Neubrutalism aesthetic). Aplikasi ini dibangun menggunakan Flutter dengan fokus pada pengalaman pengguna yang unik, kontras tinggi, dan fungsionalitas penuh baik untuk sisi User maupun Administrator.

## 🎨 Design Philosophy
- **Aesthetic**: Retro Zine / Comic Style / Neubrutalism.
- **Color Palette**: 
  - Background: Off-White (`#FDFDFD`)
  - Primary Accent: Comic Red (`#FF4D4D`)
  - Secondary Accent: Comic Yellow (`#FFD166`)
  - Success/Approved: Comic Green (`#06D6A0`)
  - Border/Shadow: Strong Black (`#1A1A1A`)
- **Styling**: Bold borders (2px-3px), 4x4 offset shadows (hard shadows), dan penggunaan font pixelated (**Press Start 2P**) dikombinasikan dengan **Inter**.

## 🚀 Key Features

### 1. User Side (Customer)
- **Splash Screen**: Animasi pembuka bertema retro dengan branding SoraiFest.
- **Authentication**: Registrasi dan Login akun pembeli (Security via JWT/Auth Provider).
- **Concert Discovery**: Mencari konser berdasarkan nama atau lokasi dengan fitur search yang responsif.
- **Concert Detail & Live Stock**: 
    - Deskripsi lengkap acara.
    - **Live Stock**: Menampilkan sisa tiket yang tersedia (`jumlah_bed`).
    - **Smart Validation**: Tombol beli otomatis berubah menjadi "SOLD OUT" jika stok habis, atau "EXPIRED" jika tanggal konser sudah lewat.
- **Payment Flow (QRIS Simulation)**: 
    - Integrasi alur pembayaran menggunakan simulasi QRIS.
    - Transisi otomatis dari reservasi ke halaman pembayaran.
- **My Tickets (Orders)**: 
    - Daftar riwayat pemesanan dengan badge status kontras tinggi (`PENDING`, `PAID`, `REJECTED`).
    - **Download/Cetak Tiket**: Fitur untuk mengunduh tiket dalam format PDF melalui API.
- **Profile & Support**: Pengaturan profil dan informasi bantuan "About SoraiFest" via email support.

### 2. Admin Side (Management)
- **Order Dashboard**: Mengelola dan memantau semua pesanan masuk secara tersentralisasi.
- **Status Management**: Otoritas penuh untuk melakukan verifikasi pembayaran manual:
    - **Approve**: Mengonfirmasi pembayaran (Status: `paid`).
    - **Reject**: Menolak pesanan (Status: `rejected`).
- **Concert CRUD (Inventory Control)**:
    - **Create**: Menambah konser baru lengkap dengan upload gambar promo.
    - **Update**: Mengedit detail konser (Nama, Lokasi, Harga, Deskripsi).
    - **Stock Management**: Update jumlah ketersediaan tiket melalui field `jumlah_bed`.
    - **Delete**: Menghapus data konser dari sistem.
- **User Management**: Melihat daftar pengguna yang terdaftar di sistem.

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider (Auth, Concert, & Order Providers)
- **Routing**: GoRouter
- **HTTP Client**: Dio (Koneksi ke backend API di `localhost:8081`)
- **Fonts**: Google Fonts (Press Start 2P, Inter)

## 🧪 SQA (Software Quality Assurance) & Testing Strategy

### 1. Test Matrix (Requirement Traceability)
Matriks ini digunakan untuk memastikan seluruh fitur utama telah teruji melalui skenario spesifik.

| ID | Module | Scenario Description | Expected Result | Priority |
|:---|:---|:---|:---|:---|
| **TM_01** | **Entry** | Cold start & Splash Screen duration check. | Redirect ke `/home` otomatis dalam 2.5 detik. | High |
| **TM_02** | **Security** | Akses manual URL `/admin/*` tanpa login. | Redirect paksa ke `/login` (Unauthorized access). | Critical |
| **TM_03** | **Auth** | Login menggunakan akun dengan role `admin`. | Masuk ke Admin Dashboard, bukan Home user. | High |
| **TM_04** | **Inventory**| Set `jumlah_bed` = 0 via database/admin. | Tombol detail berubah menjadi "SOLD OUT" & disabled. | Critical |
| **TM_05** | **Inventory**| Set `date` konser ke masa lampau (Yesterday). | Tombol detail berubah menjadi "EXPIRED". | High |
| **TM_06** | **Search** | Input keyword yang tidak terdaftar di search bar. | Muncul state "NO CONCERTS FOUND". | Medium |
| **TM_07** | **Order** | Klik "Pay Now" pada konser aktif. | Entry baru di database dengan status `pending`. | Critical |
| **TM_08** | **Admin** | Klik "Confirm" pada pesanan user. | Status berubah menjadi `paid` & tiket muncul di User. | High |
| **TM_09** | **PDF** | Klik "Download PDF" pada tiket berstatus `paid`. | Membuka browser eksternal ke URL API download. | Medium |

### 2. Relevant Test Metrics
Parameter kuantitatif untuk mengukur kualitas aplikasi SoraiFest:

- **Test Case Pass Rate**: 
    - *Target*: > 95% (Fitur kritikal/pembayaran harus 100% Pass).
    - *Rumus*: `(Total Pass / Total Test Cases) * 100`.
- **Defect Density**: 
    - Mengukur jumlah bug per modul (fokus pada modul Admin & Order).
- **UI/UX Fidelity Score**: 
    - Konsistensi desain Neubrutalism (Border 3px, Shadow Offset 8x8) pada 100% komponen kartu.
- **API Latency**: 
    - Rata-rata waktu muat list konser (Target: < 500ms pada koneksi lokal).
- **Critical Failure Frequency**: 
    - Jumlah *Force Close* saat melakukan transaksi atau upload gambar besar.

### 3. Testing Techniques Implemented
- **Black Box Testing**: Validasi alur user (Login -> Search -> Book -> Pay).
- **Boundary Value Analysis (BVA)**: Pengujian limit pada stok tiket (`jumlah_bed`).
- **State Transition Testing**: Verifikasi siklus status order: `pending` → `paid` (Approve) atau `pending` → `rejected` (Reject).
- **Negative Testing**: Simulasi akses ilegal ke dashboard admin dan input data tidak valid.

### 4. Risks to SoraiFest Application
- **Race Condition**: Potensi double-booking jika stok sisa 1 dan diakses 2 user bersamaan.
- **Data Desync**: State Provider tidak terupdate jika koneksi API terputus tiba-tiba.
- **Platform Inconsistency**: Perbedaan handling download PDF antara Web dan Android.

---
*Developed as part of the Modern Retro UI Restoration project.*
