---
name: crd-procedure
description: >
  Generate CRD (Change Request Document) Implementation Procedure sections.
  Use when the user asks to create a CRD, write deployment procedures, generate
  implementation docs, create rollback plans, or prepare change request documentation.
  Covers: Pre-Implementation, Implementation, Post-Implementation, Success Criteria,
  and Rollback Procedure sections.
disable-model-invocation: true
---

# Generate CRD Implementation Procedure

## Usage
```
/crd-procedure              → interactive mode, ask user for details
/crd-procedure <task-desc>  → generate CRD for the given task description
```

## Language
- All output in **Indonesian**, except for technical terms (keep as-is).

## CRD Form Fields

Berikut adalah field-field yang harus diisi pada form CRD. Gunakan sebagai referensi saat mengumpulkan informasi dan menghasilkan CRD.

### CR Target
Menentukan target yang akan diubah.

Opsi:
- **Application** – Berlaku untuk update aplikasi. Contoh: Enhance performance pada aplikasi
- **DB** – Berlaku ketika CRD hanya untuk perubahan database. Contoh: Penambahan kolom baru pada tabel, Penambahan index pada tabel

Contoh: `Application`

### CR Description
Menjelaskan perubahan yang dilakukan secara singkat. Dapat menggunakan judul dari PB selama dapat menjelaskan perubahan yang dilakukan.

Contoh: `Fixing DRPush Ignore SSL`

### CR Reason
Menjelaskan alasan/tujuan mengapa perubahan perlu dilakukan. Umumnya, tujuan perubahannya tidak sama dengan judul PB.

> **Penting**: CR Reason harus dapat menjelaskan tujuan dari CRD secara informatif. Jika tidak informatif, CRD akan ditolak.

Contoh: `Handle client with invalid SSL to be able to receive the DR`

### Application Version
Menjelaskan versi stack (bahasa pemrograman / framework) yang digunakan.

Opsi: `Java 8`, `Java 11`, `Golang`, `PHP 7.2`, `MySQL 5.5`, `Microsoft SQL Server 2005`, `ReactJS`

> Jika stack belum ada pada list dropdown, request ke PMO untuk ditambahkan.

### Application
Menjelaskan aplikasi yang di update. Set to `Other`.

### Application Server
Menjelaskan server production dimana aplikasi akan di deploy. Set to `Other`.

### Product
Set to `Jatis`.

### CR Type
Menjelaskan jenis perubahan.

| CR Type | Description |
|---|---|
| New | Berlaku untuk CRD development aplikasi baru yang belum pernah dibuat sebelumnya. |
| Update/Modification | Berlaku apabila CRD merupakan update untuk existing aplikasi, perubahan konfigurasi aplikasi pada production dan perubahan pada database. |

Contoh: `Update/Modification`

### Attachment
Lampiran file berisi script query jika ada.

Contoh:
```
add_index.sql
```
```sql
CREATE INDEX idx_senderid ON sender_cloud_type (senderid);
```

### Database
Menjelaskan DB yang digunakan pada CRD / aplikasi.

Opsi: `MongoDB`, `PostgreSQL`, `Ms SQL`, `MySql`, `Oracle`, `Other`

Contoh: `MySql`

### Database Server
Menjelaskan letak server database yang digunakan pada CRD/aplikasi. Pilih `Other`.

### Pre-Implementation Procedure
- Repository link with branch name
- App version
- Sonarqube scan result link
- FSD/TRD link (wajib)
- Flow URL link
- Test scenario documentation link

### Implementation Procedure
Must include ALL of the following:
- **Library changes**: Only include if the user mentions library changes. Default: omit this section entirely.
- **Config changes**: Explicitly state if there are changes or not. If changes exist:
  - List each config with value and description of purpose
  - For new configs: explain what it does
  - For removed configs: explain why removed
  - Values should match production environment. If unknown, mark as sample with note
- **Database/collection changes**: Explicitly state if there are changes or not
- **Step-by-step deployment instructions**: Based on app type (JAR, binary, Docker, etc.)
- **How to run and stop**: Link to wiki or explicit commands

### Post-Implementation Procedure
- Verify status aplikasi:
  - Jika binary/JAR: cek PID file (`cat <app-name>.pid`) atau `ps aux | grep <appname>`
  - Jika Docker: cek container status (`docker ps | grep <container_name>`)
- Check main log for errors
- Additional verification steps as needed

### Success Criteria
- Existing test cases pass
- New functionality works (describe specific scenarios)
- Cover both success and failure paths

### Rollback Procedure
- Stop application
- Revert to previous version
- Additional rollback steps if needed (e.g., database rollback)

---

## Workflow

### Step 1: Gather Information

Use the AskUserQuestion tool to collect ALL required information before generating the CRD.

Ask the user for the following (group into 1-2 question rounds to be efficient):

**Round 1 - Project & Task Info:**
1. **Jenis task**: Update aplikasi / Tambah fitur baru / Bug fix / Database change / Konfigurasi / Lainnya
2. **Deskripsi singkat perubahan**: Apa yang diubah dan mengapa
3. **Repository URL** (Gitlab): URL branch dari repository url git dan branch yang saat ini digunakan
4. **App version**: Versi aplikasi terbaru
5. **Bahasa/framework aplikasi**: Java (JAR) / Go / Node.js / Python / Docker / Lainnya

**After Round 1 — Wiki Auto-Analysis:**

Setelah mendapatkan Repository URL, lakukan analisis wiki secara otomatis:

**Cara mengambil konten wiki** (coba secara berurutan):
1. **`glab api`** (default): `glab api projects/:id/wikis/feature` atau `glab api projects/:id/wikis/uat`
   (`:id` = project ID atau `group%2Frepo` URL-encoded)
2. **`curl`** (fallback, butuh `$GITLAB_JATIS_TOKEN`):
   `curl --header "PRIVATE-TOKEN: $GITLAB_JATIS_TOKEN" "https://gitlab.com/api/v4/projects/:id/wikis/feature"`

**Flow URL (Feature Wiki):**
- Konstruksi slug: `feature` dari repository URL
- Gunakan cara di atas untuk membaca halaman wiki
- Jika berhasil: tampilkan daftar link/section yang tersedia sebagai pilihan kepada user, biarkan user memilih atau input manual
- Jika gagal/tidak tersedia: minta user input URL flow URL secara manual

**Test Scenario (UAT Wiki):**
- Konstruksi slug: `uat` dari repository URL
- Gunakan cara di atas untuk membaca halaman wiki
- Jika berhasil: tampilkan daftar link/section yang tersedia sebagai pilihan kepada user, biarkan user memilih atau input manual
- Jika gagal/tidak tersedia: minta user input URL test scenario secara manual

**Round 2 - Documentation & Details:**
6. **Sonarqube URL**: Link hasil scan (wajib untuk update aplikasi & unit test)
7. **FSD / TRD URL**: Link dokumen (wajib)
8. **Flow URL URL**: (Gunakan hasil analisis wiki feature di atas, atau input manual jika tidak tersedia)
9. **Test scenario / UAT URL**: (Gunakan hasil analisis wiki UAT di atas, atau input manual jika tidak tersedia)
10. **Perubahan konfigurasi**: Ada atau tidak? Jika ada, detail perubahannya (nama config, value, keterangan)
11. **Perubahan library**: Ada atau tidak? Jika ada, detail perubahannya
12. **Perubahan database/collection**: Ada atau tidak? Jika ada, detail perubahannya
13. **Cara menjalankan & stop aplikasi**: Custom atau ada wiki link?
14. **Wiki config explanation URL**: Jika ada

If user provides `$ARGUMENTS`, use it as task description and still collect missing required info.

### Step 2: Validate Required Documentation

Before generating, verify these mandatory items are provided:
- [ ] Repository URL + branch
- [ ] App version
- [ ] Sonarqube URL (wajib untuk update aplikasi & unit test)
- [ ] FSD/TRD URL (wajib)
- [ ] Flow URL (wajib)
- [ ] Test scenario documentation (wajib)

If any mandatory item is missing, warn the user:
> **Peringatan**: CRD akan ditolak jika dokumentasi wajib belum lengkap. Item berikut belum disertakan: [list missing items]

Ask if they want to proceed anyway or provide the missing info.

### Step 3: Generate CRD

Generate the CRD following the template at [templates/crd-template.md](templates/crd-template.md).
Reference examples at [examples/](examples/) for formatting guidance.

**Post-Implementation — pilih sesuai deployment type dari Round 1:**
- Jika binary/JAR: gunakan baris `Pastikan aplikasi berhasil menggenerate file .pid: cat <app-name>.pid`
- Jika Docker: gunakan baris `Pastikan container berjalan: docker ps | grep <container_name>`
- Hapus baris yang tidak relevan dari template.

### Step 4: Output

Output the complete CRD text directly in the conversation (formatted in markdown).

Also ask the user if they want to save the output to a file.

