# CRD Implementation Procedure Template

## Pre-Implementation Procedure

Repository:
{repo_url}
branch: {branch_name}

App version: {app_version}

Sonarqube:
{sonarqube_url}

{fsd_trd_section}

Flow:
{flow_url}

Test Scenario:
{test_scenario_url}

---

## Implementation Procedure

{library_section}

{deployment_steps}

{config_section}

{database_section}

{run_stop_section}

---

## Post-Implementation Procedure

Pastikan aplikasi berhasil menggenerate file .pid

Cek log utama tidak ada log error hingga aplikasi berjalan

{additional_post_impl_steps}

---

## Success Criteria

Berhasil menjalankan existing test case.

{success_criteria_items}

---

## Rollback Procedure

Stop app dan kembalikan ke versi sebelumnya.

{additional_rollback_steps}

---

# Section Templates

## Library Section Variants

### No changes:
```
Tidak ada penambahan atau pengurangan library.
```

### With changes:
```
Perubahan library:
- Tambah: {library_name} v{version} — {purpose}
- Hapus: {library_name} — {reason}
- Update: {library_name} v{old_version} → v{new_version} — {reason}
```

## Config Section Variants

### No changes:
```
Tidak ada penambahan atau perubahan konfigurasi.

Config explanation:
{config_wiki_url}
```

### With changes (application.properties / config.yaml):
```
Perbarui {config_file}:

Config baru:
{config_key}={config_value} #{description_and_purpose}

Config yang dihapus:
{config_key}={old_value} #{reason_for_removal}

Config yang diubah:
{config_key}={new_value} #{description_of_change, old_value → new_value}

Note: Nilai konfigurasi di atas merupakan sampel. Harap disesuaikan dengan kebutuhan di production.

Config explanation:
{config_wiki_url}
```

## Database Section Variants

### No changes:
```
Tidak ada penambahan atau perubahan structure collection/table di database.
```

### With changes:
```
Perubahan database:
- {describe_change}: {detail}
```

## Deployment Steps by App Type

### Java (JAR):
```
1. Salin file jar terbaru v{version}
2. Perbarui start.sh untuk menjalankan jar terbaru
3. Perbarui {config_file} (jika ada perubahan konfigurasi)
4. Jalankan start.sh start
```

### Go (Binary):
```
1. Salin binary terbaru v{version}
2. Perbarui {config_file} (jika ada perubahan konfigurasi)
3. Jalankan aplikasi sesuai prosedur: {run_wiki_url}
```

### Docker:
```
1. Pull image terbaru v{version}
2. Perbarui {config_file} (jika ada perubahan konfigurasi)
3. Restart container: docker-compose up -d
```

### Node.js:
```
1. Salin source code terbaru v{version}
2. Install dependencies: npm install
3. Perbarui {config_file} (jika ada perubahan konfigurasi)
4. Jalankan aplikasi: {start_command}
```

### Custom (with wiki):
```
How to run and stop app:
{run_stop_wiki_url} section {section_name}
```

## Run/Stop Section Variants

### With wiki:
```
How to run and stop app:
{wiki_url} section {section_name}
```

### Without wiki (JAR):
```
Stop app: ./stop.sh atau kill PID
Start app: ./start.sh start
```

## Success Criteria Template
```
Berhasil menjalankan existing test case.
{for_each_new_feature}
Berhasil {describe_expected_outcome}.
{end_for_each}

{if_has_failure_scenarios}
Ketika {failure_condition}:
- Berhasil {describe_fallback_behavior}
{end_if}
```

## FSD/TRD Section (if available)
```
FSD: {fsd_url}
```
or
```
TRD: {trd_url} tab {tab_name}
```
