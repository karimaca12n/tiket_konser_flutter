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

### 1. Ideal Test Environment
- **Client**: Android Emulator (API 34+) or Physical Device with `adb reverse tcp:8081 tcp:8081`.
- **Backend**: Local PHP Server (CodeIgniter 4) running at `http://localhost:8081`.
- **Database**: MySQL/MariaDB with `orders` ENUM support (`pending`, `paid`, `rejected`).
- **Tools**: Flutter DevTools for UI inspection, Postman for API validation.

### 2. Testing Techniques Implemented
- **Black Box Testing**: Validating user flows (Login -> Search -> Book -> Pay) without internal code knowledge.
- **Boundary Value Analysis (BVA)**: Testing `jumlah_bed` limits (e.g., buying the 0th or last ticket).
- **Negative Testing**: Inputting invalid prices, booking past-dated concerts, or unauthorized API access.
- **State Transition Testing**: Verifying Order Status flow: `pending` → `paid` (Approve) or `pending` → `rejected` (Reject).

### 3. Testing Tools
- **Flutter Inspector**: Ensuring "Neubrutalism" UI alignment and shadow offsets.
- **Dio Logger**: Intercepting request/response payloads for API integrity.
- **Lints**: Static analysis using `flutter_lints` for modern Dart standards.

### 4. Risks to SoraiFest Application
- **Race Condition**: Multiple simultaneous bookings when stock is at 1.
- **Data Desync**: Local state not reflecting backend changes if `Provider` refresh fails.
- **Platform Inconsistency**: PDF download behavior differences between Web and Android/iOS.
- **Connectivity**: Application failure if the local API server is unreachable.

### 5. Typical Components of Test Plan
- **Test Objective**: Ensure seamless ticket procurement and admin verification.
- **Scope**: Auth, Concert Discovery, Order Management, PDF Generation.
- **Test Cases**: 
    - `TC_01`: Verify "SOLD OUT" state when `jumlah_bed` = 0.
    - `TC_02`: Verify status update to `paid` updates "My Tickets" instantly.
    - `TC_03`: Verify PDF download triggers external browser/viewer.
    - `TC_04`: Verify Splash Screen animation and auto-redirection to Home.
- **Environment**: Development build on Android.

### 6. Relevant Test Metrics
- **Pass/Fail Rate**: Percentage of UI flows that complete without crashes.
- **Defect Density**: Number of bugs identified per module (User vs Admin).
- **API Latency**: Response time for fetching large concert lists.
- **Test Coverage**: Proportion of `ConcertModel` and `OrderModel` fields validated.

---
*Developed as part of the Modern Retro UI Restoration project.*
