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

## Workflow

### Step 1: Gather Information

Use the AskUserQuestion tool to collect ALL required information before generating the CRD.

Ask the user for the following (group into 1-2 question rounds to be efficient):

**Round 1 - Project & Task Info:**
1. **Jenis task**: Update aplikasi / Tambah fitur baru / Bug fix / Database change / Konfigurasi / Lainnya
2. **Deskripsi singkat perubahan**: Apa yang diubah dan mengapa
3. **Repository URL** (Gitlab): URL branch yang digunakan
4. **App version**: Versi aplikasi terbaru
5. **Bahasa/framework aplikasi**: Java (JAR) / Go / Node.js / Python / Lainnya

**Round 2 - Documentation & Details:**
6. **Sonarqube URL**: Link hasil scan (wajib untuk update aplikasi & unit test)
7. **FSD / TRD URL**: Link dokumen jika ada (opsional)
8. **Flow diagram URL**: Link .drawio atau diagrams.net atau wiki flowchart
9. **Test scenario / UAT URL**: Link dokumen test scenario
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
- [ ] Flow diagram (wajib)
- [ ] Test scenario documentation (wajib)

If any mandatory item is missing, warn the user:
> **Peringatan**: CRD akan ditolak jika dokumentasi wajib belum lengkap. Item berikut belum disertakan: [list missing items]

Ask if they want to proceed anyway or provide the missing info.

### Step 3: Generate CRD

Generate the CRD following the template at [templates/crd-template.md](templates/crd-template.md).
Reference examples at [examples/](examples/) for formatting guidance.

### Step 4: Output

Output the complete CRD text directly in the conversation (formatted in markdown).

Also ask the user if they want to save the output to a file.

---

## Section Guidelines

### Pre-Implementation Procedure
- Repository link with branch name
- App version
- Sonarqube scan result link
- FSD/TRD link (if available)
- Flow diagram link
- Test scenario documentation link

### Implementation Procedure
Must include ALL of the following:
- **Library changes**: Explicitly state if there are changes or not
- **Config changes**: Explicitly state if there are changes or not. If changes exist:
  - List each config with value and description of purpose
  - For new configs: explain what it does
  - For removed configs: explain why removed
  - Values should match production environment. If unknown, mark as sample with note
- **Database/collection changes**: Explicitly state if there are changes or not
- **Step-by-step deployment instructions**: Based on app type (JAR, binary, Docker, etc.)
- **How to run and stop**: Link to wiki or explicit commands

### Post-Implementation Procedure
- Verify PID file generation / docker container status
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
