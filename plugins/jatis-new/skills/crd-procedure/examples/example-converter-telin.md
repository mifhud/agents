# Contoh CRD: ConverterTelin - Create New Application

## Pre-Implementation Procedure

Add index in transactions table, by executing SQL script in the attachment.

FSD : https://docs.google.com/document/d/1Q9zCQudC8WCQSYSdyrkDq6JPcB4XA4kVGRU5jkgbxLk/edit?usp=sharing

Sonarqube scan result : https://sonarqube.jatismobile.com/dashboard?id=jatis_cloudapi_convertertelin

Repository : https://git-rbi.jatismobile.com/jatis_cloudapi/convertertelin/-/tree/PB10201852929686YA-Create_ConverterTelin

App version: 1.0.1

Flow : https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&page-id=yxBf1safwajOTtR_V9lJ#G1AQQa9bdsVdE7fl06vsCq4vqIPfi8_8B9

## Implementation Procedure

Tidak ada perubahan pada library.

Salin file jar terbaru v1.0.0
Perbarui start.sh untuk menjalankan jar terbaru
Perbarui application.properties:

facebookgraphapiurl=http://localhost:9000 #diisi dengan url meta, perlu diubah sesuai dengan URL aktual Meta
app.api.telin.url=http://localhost:9001/message/template #diisi dengan url telin, perlu diubah sesuai dengan URL aktual Telin

Dan hapus properties lama untuk berikut:
facebookgraphapitokenaccess=EAANVPoi74RMBOyIR0WSLZCaJuDMzYHnhZBHH3nK1l6GBzmIUlZCwX77… #konfigurasi tidak digunakan lagi

Tambahkan waextcontroller authorization untuk header hit ke meta atau telin (pengganti token di application.properties)
Tambahkan sender ke sender_telin untuk sender yg menggunakan telin
Jalankan start.sh start

## Post-Implementation Procedure

Pastikan aplikasi berhasil menggenerate file .pid
Cek log utama tidak ada log error hingga aplikasi berjalan

## Success Criteria

Berhasil menjalankan existing test case.
Berhasil convert queue Meta Template Payload menjadi Telin Template Payload.
Berhasil kirim queue ke TransmitterTelin ketika berhasil convert queue.
Ketika gagal convert queue:
- Berhasil kirim queue ke cloud-submit-result-handler
- Berhasil direct save ke mongo submit-result-handler
- Berhasil mengirim queue ke drhandler
- Berhasil direct save mongo watosms
- Berhasil direct save ke msg-division-mapping

## Rollback Procedure

Rollback to previous version
