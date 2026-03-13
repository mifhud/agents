# Contoh CRD: CosterConverterOutbound - Handle Empty Parameters Template

## Pre-Implementation Procedure

Repository:
https://git-rbi.jatismobile.com/rte-cimb-niaga/costerconverteroutbound
branch: fix/PB1025286126000252YA/handle-empty-parameters-template

App version: v1.2.0

Sonarqube:
https://sonarqube.jatismobile.com/dashboard?id=converter_coster_outbound

TRD: https://docs.google.com/spreadsheets/d/1fseX5T0C5q64ZhEh68skmGLh275UqScz-mwNIlmI78A/edit?gid=1282550851#gid=1282550851 tab converter-outbound-handle-empty-object

Flow:
https://git-rbi.jatismobile.com/rte-cimb-niaga/costerconverteroutbound/-/wikis/flowchart section v1.2.0

## Implementation Procedure

How to run and stop app:
https://git-rbi.jatismobile.com/rte-cimb-niaga/costerconverteroutbound/-/wikis/home section production

Config explanation:
Tidak ada penambahan atau ubah dari config.yaml

https://git-rbi.jatismobile.com/rte-cimb-niaga/costerconverteroutbound/-/wikis/config-explanation

Tidak ada penambahan atau ubah structure collection di database

## Post-Implementation Procedure

Pastikan aplikasi berhasil menggenerate file .pid
Cek log utama tidak ada log error hingga aplikasi berjalan

## Success Criteria

Berhasil menjalankan test case, contohnya berikut:
https://git-rbi.jatismobile.com/rte-cimb-niaga/costerconverteroutbound/-/wikis/uat/v1.2.0/handle-empty-parameters-template-message

## Rollback Procedure

Stop app dan kembalikan ke versi sebelumnya
