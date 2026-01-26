Important Rules:
- JANGAN HAPUS DATA EXISTING YANG SUDAH ADA DI DATABASE SEBELUMNYA.
- JANGAN MODIFIKASI CODE APAPUN - hanya eksekusi test dan laporkan hasil
- don't remove files test and log files (if available)
- don't clean up test data in databases after uat run

---

Saya akan memberikan dokumen UAT untuk diverifikasi. Tugas Anda:

1. ANALISIS JENIS TEST dari UAT yang diberikan:
   - HTTP/REST API requests
   - Queue/Topic messaging (ActiveMQ, RabbitMQ, Kafka, dll)
   - Scheduler/Cron tasks

2. UNTUK HTTP/REST API:
   - Parse endpoint, method, headers, dan body dari UAT
   - Setup data requirements menggunakan MCP database jika diperlukan
   - Capture response dan bandingkan dengan expected result di UAT
   - Buat laporan verifikasi (passed/failed dengan detail)

3. UNTUK QUEUE/TOPIC MESSAGING:
   - Identifikasi queue/topic name, broker, dan message format
   - Setup data requirements menggunakan MCP message broker(like rabbitmq, activemq, etc) jika diperlukan
   - Verifikasi message masuk ke queue/topic dengan benar
   - Buat laporan verifikasi

4. UNTUK SCHEDULER TASKS:
   - Identifikasi scheduled task yang akan dijalankan
   - Setup data requirements menggunakan MCP database jika diperlukan
   - Verifikasi kondisi pre-execution dan post-execution
   - Cek database untuk memastikan task berjalan sesuai ekspektasi
   - Buat laporan verifikasi

5. HANDLING ERROR:
   ⚠️ PENTING: JANGAN PERBAIKI CODE JIKA ADA ERROR!
   - Hanya laporkan bahwa test FAILED
   - Capture error message lengkap dan stack trace
   - Identifikasi reproduction steps dengan jelas
   - Berikan root cause explanation
   - Sertakan evidence yang mendukung diagnosis

CATATAN:
- Lokasi configurasi MCP terdapat di .utcp_config.json
- Fokus pada accuracy diagnosis dan clarity reporting

6. FORMAT LAPORAN UAT (gunakan format ini):
```markdown
# UAT Execution Report
**Total Test Cases:** {total}
**Passed:** {pass_count}
**Failed:** {fail_count}

---

## Test Case: {Test Case ID/Title}
### Status: ✅ PASS / ❌ FAIL

### Test Details:
- **Type:** {HTTP/Queue/Scheduler}
- **Endpoint/Queue/Task:** {detail}
- **Method/Action:** {detail}

### Expected Result:
{expected dari UAT}

### Actual Result:
{actual result dari execution}

### Root Cause Analysis:
{jika FAIL, berikan analisis root cause}

#### Error Details:
{error message dan stack trace lengkap}

#### Reproduction Steps:

1. {step 1}
2. {step 2}
3. ...

#### Root Cause:

{penjelasan detail penyebab error}

#### Evidence:

- {screenshot/log file}
- {database state}

---

{ulangi untuk setiap test case}

```

7. DELIVERABLES:
   - Simpan di new folder: `myspec/debug/uat/results/{feature-name}-{datemonthhourminutesecond}`
   - File laporan: `uat-result.md`
   - Evidence folder: `evidence` berisi:
     - responses/ (response dari setiap request)
     - logs/ (log files)
     - screenshots/ (jika ada)