-- ============================================================
--  DATABASE: Sistem Informasi Tracer Study & Bursa Kerja
--  SMK BINA BHAKTI MEKARMUKTI
-- ============================================================
--  Dibuat untuk kebutuhan Skripsi
--  Teknologi: PostgreSQL
--  ORM: Prisma
--  Dibuat pada: 2026-10-11
-- ============================================================


-- ============================================================
-- 0. PERSIAPAN: DROP TABEL (urutan terbalik untuk menghindari
--    error FK violation)
-- ============================================================
DROP TABLE IF EXISTS "PasswordResetToken" CASCADE;
DROP TABLE IF EXISTS "Pengaturan"         CASCADE;
DROP TABLE IF EXISTS "Portofolio"         CASCADE;
DROP TABLE IF EXISTS "Lamaran"            CASCADE;
DROP TABLE IF EXISTS "Lowongan"           CASCADE;
DROP TABLE IF EXISTS "TracerStudy"        CASCADE;
DROP TABLE IF EXISTS "Perusahaan"         CASCADE;
DROP TABLE IF EXISTS "Lulusan"            CASCADE;
DROP TABLE IF EXISTS "Jurusan"            CASCADE;
DROP TABLE IF EXISTS "User"               CASCADE;

-- ============================================================
-- 1. DROP & CREATE ENUM TYPES
-- ============================================================
DROP TYPE IF EXISTS "Role"          CASCADE;
DROP TYPE IF EXISTS "StatusLulusan" CASCADE;

CREATE TYPE "Role" AS ENUM (
    'ADMIN',
    'LULUSAN',
    'PERUSAHAAN',
    'KEPALA_SEKOLAH'
);

CREATE TYPE "StatusLulusan" AS ENUM (
    'BEKERJA',
    'KULIAH',
    'WIRAUSAHA',
    'BELUM_BEKERJA'
);


-- ============================================================
-- 2. TABEL User
--    Menyimpan data autentikasi seluruh pengguna sistem.
-- ============================================================
CREATE TABLE "User" (
    "id"        VARCHAR         NOT NULL,
    "nomorId"   SERIAL          NOT NULL,
    "email"     VARCHAR         NOT NULL,
    "password"  VARCHAR         NOT NULL,
    "role"      "Role"          NOT NULL,
    "nama"      VARCHAR,
    "noHp"      VARCHAR,
    "alamat"    TEXT,
    "createdAt" TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- Index unik pada email
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");


-- ============================================================
-- 3. TABEL Jurusan
--    Master data program keahlian / jurusan di sekolah.
-- ============================================================
CREATE TABLE "Jurusan" (
    "id"      VARCHAR     NOT NULL,
    "nomorId" SERIAL      NOT NULL,
    "kode"    VARCHAR     NOT NULL,
    "nama"    VARCHAR     NOT NULL,

    CONSTRAINT "Jurusan_pkey" PRIMARY KEY ("id")
);

-- Index unik kode dan nama jurusan
CREATE UNIQUE INDEX "Jurusan_kode_key" ON "Jurusan"("kode");
CREATE UNIQUE INDEX "Jurusan_nama_key" ON "Jurusan"("nama");


-- ============================================================
-- 4. TABEL Lulusan
--    Biodata alumni dan relasi ke akun login serta jurusan.
-- ============================================================
CREATE TABLE "Lulusan" (
    "id"          VARCHAR         NOT NULL,
    "userId"      VARCHAR         NOT NULL,
    "nis"         VARCHAR,
    "nama"        VARCHAR         NOT NULL,
    "jenisKelamin" VARCHAR,
    "jurusanId"   VARCHAR,
    "tahunMasuk"  INTEGER,
    "tahunLulus"  INTEGER,
    "noHp"        VARCHAR,
    "alamat"      TEXT,
    "createdAt"   TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Lulusan_pkey"   PRIMARY KEY ("id"),
    CONSTRAINT "Lulusan_userId_fkey" FOREIGN KEY ("userId")
        REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Lulusan_jurusanId_fkey" FOREIGN KEY ("jurusanId")
        REFERENCES "Jurusan"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- Index unik
CREATE UNIQUE INDEX "Lulusan_userId_key" ON "Lulusan"("userId");
CREATE UNIQUE INDEX "Lulusan_nis_key"    ON "Lulusan"("nis");


-- ============================================================
-- 5. TABEL TracerStudy
--    Mencatat status keterserapan / studi lanjutan alumni.
-- ============================================================
CREATE TABLE "TracerStudy" (
    "id"                    VARCHAR         NOT NULL,
    "lulusanId"             VARCHAR         NOT NULL,
    "status"                "StatusLulusan" NOT NULL,

    -- Data Pekerjaan (Bekerja)
    "pernahMelamar"         VARCHAR,
    "jenisPekerjaan"        VARCHAR,
    "namaPerusahaan"        VARCHAR,
    "alamatInstansi"        VARCHAR,
    "jabatan"               VARCHAR,
    "deskripsiPekerjaan"    TEXT,
    "masaKerja"             VARCHAR,
    "mulaiKerja"            VARCHAR,
    "sesuaiKeahlian"        VARCHAR,
    "masaTunggu"            VARCHAR,
    "gaji"                  VARCHAR,
    "lokasiKerja"           VARCHAR,
    "latitude"              FLOAT,
    "longitude"             FLOAT,

    -- Data Kuliah (Melanjutkan Pendidikan)
    "namaKampus"            VARCHAR,
    "alamatUniversitas"     VARCHAR,
    "jurusanStudi"          VARCHAR,
    "bulanTahunStudi"       VARCHAR,

    -- Data Wirausaha
    "namaUsaha"             VARCHAR,
    "bidangUsaha"           VARCHAR,
    "omsetUsaha"            VARCHAR,  -- contoh: "< Rp 1 Juta" | "Rp 1-3 Juta" | "Rp 3-5 Juta" | "> Rp 5 Juta"
    "linkUsaha"             VARCHAR,  -- URL media sosial / e-commerce

    -- Data Belum Bekerja
    "terakhirBekerja"       VARCHAR,
    "belumPernahBekerja"    VARCHAR,  -- "Ya" jika belum pernah bekerja sama sekali
    "kegiatanSaatIni"       TEXT,
    "alasanBelumBekerja"    VARCHAR,
    "aktifMencariKerja"     VARCHAR,
    "saluranPencarianKerja" VARCHAR,
    "upayaPeningkatan"      VARCHAR,

    -- Data Sertifikat
    "pemilikSertifikat"     VARCHAR,  -- "Ya" | "Tidak"
    "jenisSertifikat"       TEXT,     -- JSON array: ["SMK","PEMERINTAH","LEMBAGA_KURSUS"]

    -- Keterangan Umum
    "keterangan"            TEXT,

    "updatedAt"             TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt"             TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TracerStudy_pkey"       PRIMARY KEY ("id"),
    CONSTRAINT "TracerStudy_lulusanId_fkey" FOREIGN KEY ("lulusanId")
        REFERENCES "Lulusan"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index unik (satu lulusan hanya punya satu record tracer study)
CREATE UNIQUE INDEX "TracerStudy_lulusanId_key" ON "TracerStudy"("lulusanId");


-- ============================================================
-- 6. TABEL Perusahaan
--    Profil entitas Mitra DUDI (Dunia Usaha / Dunia Industri).
-- ============================================================
CREATE TABLE "Perusahaan" (
    "id"        VARCHAR         NOT NULL,
    "userId"    VARCHAR         NOT NULL,
    "nama"      VARCHAR         NOT NULL,
    "bidang"    VARCHAR,
    "alamat"    TEXT,
    "kota"      VARCHAR,
    "telepon"   VARCHAR,
    "website"   VARCHAR,
    "deskripsi" TEXT,
    "latitude"  FLOAT,
    "longitude" FLOAT,
    "createdAt" TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Perusahaan_pkey"   PRIMARY KEY ("id"),
    CONSTRAINT "Perusahaan_userId_fkey" FOREIGN KEY ("userId")
        REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index unik
CREATE UNIQUE INDEX "Perusahaan_userId_key" ON "Perusahaan"("userId");


-- ============================================================
-- 7. TABEL Lowongan
--    Bursa lowongan kerja yang diposting oleh Perusahaan/Admin.
-- ============================================================
CREATE TABLE "Lowongan" (
    "id"           VARCHAR         NOT NULL,
    "perusahaanId" VARCHAR         NOT NULL,
    "jurusanId"    VARCHAR,
    "judul"        VARCHAR         NOT NULL,
    "deskripsi"    TEXT            NOT NULL,
    "persyaratan"  TEXT,
    "gaji"         VARCHAR,
    "deadline"     TIMESTAMP(3),
    "isActive"     BOOLEAN         NOT NULL DEFAULT TRUE,
    "createdAt"    TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Lowongan_pkey"           PRIMARY KEY ("id"),
    CONSTRAINT "Lowongan_perusahaanId_fkey" FOREIGN KEY ("perusahaanId")
        REFERENCES "Perusahaan"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Lowongan_jurusanId_fkey" FOREIGN KEY ("jurusanId")
        REFERENCES "Jurusan"("id") ON DELETE SET NULL ON UPDATE CASCADE
);


-- ============================================================
-- 8. TABEL Lamaran
--    Tabel pivot yang merekam jejak pelamaran Lulusan ke Lowongan.
-- ============================================================
CREATE TABLE "Lamaran" (
    "id"         VARCHAR         NOT NULL,
    "lulusanId"  VARCHAR         NOT NULL,
    "lowonganId" VARCHAR         NOT NULL,
    "status"     VARCHAR         NOT NULL DEFAULT 'MENUNGGU',
    "createdAt"  TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Lamaran_pkey"          PRIMARY KEY ("id"),
    CONSTRAINT "Lamaran_lulusanId_fkey" FOREIGN KEY ("lulusanId")
        REFERENCES "Lulusan"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Lamaran_lowonganId_fkey" FOREIGN KEY ("lowonganId")
        REFERENCES "Lowongan"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- Constraint: satu lulusan tidak bisa melamar ke lowongan yang sama dua kali
CREATE UNIQUE INDEX "Lamaran_lulusanId_lowonganId_key"
    ON "Lamaran"("lulusanId", "lowonganId");


-- ============================================================
-- 9. TABEL Portofolio
--    Menyimpan dokumen / karya yang diunggah oleh lulusan.
-- ============================================================
CREATE TABLE "Portofolio" (
    "id"        VARCHAR         NOT NULL,
    "lulusanId" VARCHAR         NOT NULL,
    "judul"     VARCHAR         NOT NULL,
    "kategori"  VARCHAR         NOT NULL,  -- Proyek | Sertifikat | Prestasi | Pengalaman | Karya Tulis | Lainnya
    "deskripsi" TEXT,
    "fileUrl"   VARCHAR,    -- path file: /uploads/portofolio/xxx.pdf
    "namaFile"  VARCHAR,    -- nama asli file
    "tipeFile"  VARCHAR,    -- mime type: application/pdf | image/jpeg | image/png
    "keahlian"  VARCHAR,    -- comma-separated: "Desain, Komunikasi, Komputer"
    "tahun"     INTEGER,
    "createdAt" TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Portofolio_pkey"        PRIMARY KEY ("id"),
    CONSTRAINT "Portofolio_lulusanId_fkey" FOREIGN KEY ("lulusanId")
        REFERENCES "Lulusan"("id") ON DELETE CASCADE ON UPDATE CASCADE
);


-- ============================================================
-- 10. TABEL Pengaturan
--     Metadata statis sistem (konfigurasi landing page BKK).
--     Hanya boleh ada 1 record dengan id = '1'.
-- ============================================================
CREATE TABLE "Pengaturan" (
    "id"         VARCHAR NOT NULL DEFAULT '1',
    "alamat"     TEXT    DEFAULT 'Jl. Contoh No. 1, Mekarmukti',
    "email"      VARCHAR DEFAULT 'bkk@smkbinabhakti.sch.id',
    "whatsapp"   VARCHAR DEFAULT '6281234567890',
    "telepon"    VARCHAR DEFAULT '022-1234567',
    "logoUrl"    VARCHAR DEFAULT '/logo_smk.png',
    "heroTitle"  VARCHAR DEFAULT 'Sistem Informasi Tracer Study & Bursa Kerja',
    "heroDesc"   TEXT    DEFAULT 'Platform digital resmi SMK Bina Bhakti Mekarmukti untuk tracer study lulusan, pengelolaan lowongan kerja, dan analitik karir lulusan.',

    CONSTRAINT "Pengaturan_pkey" PRIMARY KEY ("id")
);


-- ============================================================
-- 11. TABEL PasswordResetToken
--     Token sementara untuk fitur lupa / reset password.
-- ============================================================
CREATE TABLE "PasswordResetToken" (
    "id"        VARCHAR         NOT NULL,
    "email"     VARCHAR         NOT NULL,
    "token"     VARCHAR         NOT NULL,
    "expiresAt" TIMESTAMP(3)    NOT NULL,
    "createdAt" TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY ("id")
);

-- Index unik token
CREATE UNIQUE INDEX "PasswordResetToken_token_key" ON "PasswordResetToken"("token");


-- ============================================================
-- 12. DATA AWAL (SEED DATA)
--     Berisi data default untuk keperluan demonstrasi sistem.
-- ============================================================

-- 12.1 Jurusan
INSERT INTO "Jurusan" ("id", "kode", "nama") VALUES
    ('jurusan_tkj_001', 'TKJ', 'Teknik Komputer dan Jaringan'),
    ('jurusan_ak_001',  'AK',  'Akuntansi'),
    ('jurusan_ap_001',  'AP',  'Administrasi Perkantoran'),
    ('jurusan_pm_001',  'PM',  'Pemasaran');


-- 12.2 User: Admin
-- Password: admin123 (bcrypt hash $2a$10$...)
INSERT INTO "User" ("id", "email", "password", "role") VALUES
    ('user_admin_001',
     'admin@smkbinabhakti.sch.id',
     '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',  -- ganti dengan hash bcrypt asli
     'ADMIN');

-- 12.3 User: Kepala Sekolah
-- Password: kepsek123
INSERT INTO "User" ("id", "email", "password", "role") VALUES
    ('user_kepsek_001',
     'kepsek@smkbinabhakti.sch.id',
     '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',  -- ganti dengan hash bcrypt asli
     'KEPALA_SEKOLAH');

-- 12.4 User: Perusahaan (Mitra DUDI)
-- Password: perusahaan123
INSERT INTO "User" ("id", "email", "password", "role") VALUES
    ('user_perusahaan_001',
     'pt.maju@example.com',
     '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',  -- ganti dengan hash bcrypt asli
     'PERUSAHAAN');

-- Profile Perusahaan
INSERT INTO "Perusahaan" ("id", "userId", "nama", "bidang", "alamat", "kota", "telepon", "latitude", "longitude") VALUES
    ('perusahaan_001',
     'user_perusahaan_001',
     'PT Maju Bersama',
     'Teknologi Informasi',
     'Jl. Raya Cikarang No. 10',
     'Bekasi',
     '021-12345678',
     -6.3,
     107.1);

-- 12.5 Lowongan dari PT Maju Bersama
INSERT INTO "Lowongan" ("id", "perusahaanId", "jurusanId", "judul", "deskripsi", "persyaratan", "gaji", "deadline", "isActive") VALUES
    ('lowongan_001',
     'perusahaan_001',
     'jurusan_tkj_001',
     'Teknisi Jaringan',
     'Dibutuhkan teknisi jaringan berpengalaman untuk mengelola infrastruktur IT perusahaan.',
     'Lulusan TKJ, mampu konfigurasi router dan switch, pengalaman min 1 tahun',
     'Rp 3.000.000 - Rp 4.000.000',
     '2026-12-31 00:00:00',
     TRUE);

-- 12.6 User: Lulusan
-- Password: lulusan123
INSERT INTO "User" ("id", "email", "password", "role") VALUES
    ('user_lulusan_001',
     'budi.santoso@lulusan.com',
     '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',  -- ganti dengan hash bcrypt asli
     'LULUSAN');

-- Profile Lulusan
INSERT INTO "Lulusan" ("id", "userId", "nis", "nama", "jurusanId", "tahunLulus", "noHp", "alamat") VALUES
    ('lulusan_001',
     'user_lulusan_001',
     '1234567890',
     'Budi Santoso',
     'jurusan_tkj_001',
     2024,
     '081234567890',
     'Jl. Mekarmukti No. 5, Cikarang Utara');


-- 12.7 Pengaturan sistem (record tunggal)
INSERT INTO "Pengaturan" ("id", "alamat", "email", "whatsapp", "telepon", "logoUrl", "heroTitle", "heroDesc") VALUES
    ('1',
     'Jl. Contoh No. 1, Mekarmukti',
     'bkk@smkbinabhakti.sch.id',
     '6281234567890',
     '022-1234567',
     '/logo_smk.png',
     'Sistem Informasi Tracer Study & Bursa Kerja',
     'Platform digital resmi SMK Bina Bhakti Mekarmukti untuk tracer study lulusan, pengelolaan lowongan kerja, dan analitik karir lulusan.');


-- ============================================================
-- CATATAN PENTING:
-- 1. Hash bcrypt pada kolom "password" di atas adalah contoh.
--    Ganti dengan hash bcrypt yang sesuai menggunakan:
--    admin123    => hash bcrypt anda sendiri
--    kepsek123   => hash bcrypt anda sendiri
--    perusahaan123 => hash bcrypt anda sendiri
--    lulusan123  => hash bcrypt anda sendiri
--
-- 2. Untuk generate hash bcrypt di Node.js:
--    const bcrypt = require('bcryptjs');
--    bcrypt.hash('passwordanda', 10).then(console.log);
--
-- 3. Kolom "id" menggunakan format CUID yang dihasilkan Prisma
--    secara otomatis. Pada file SQL ini nilai ID diganti dengan
--    string deskriptif untuk kemudahan keterbacaan.
--
-- 4. File ini cocok dijalankan di PostgreSQL 14+.
--    Untuk menjalankan: psql -U postgres -d nama_database -f database_smk_bkk.sql
-- ============================================================
