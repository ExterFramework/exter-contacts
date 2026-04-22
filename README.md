# exter-contacts (Refactored)

Script kontak NPC + sistem reputasi untuk FiveM dengan arsitektur modular dan kompatibilitas multi-framework.

## Fitur Utama

- Kompatibel framework: **QBCore**, **Qbox**, **ESX**, dan **standalone fallback**.
- Sistem reputasi berbasis domain (tersimpan di database).
- UI dialog + tablet kontak.
- Shop NPC dengan validasi server-side yang lebih aman.
- Adapter inventory modular:
  - `qb-inventory`
  - `ox_inventory`
  - `esx_inventory` (fallback item handling via ESX player inventory API)
  - `qs-inventory` (fallback generic)
  - `standalone`
- Adapter fuel modular:
  - `LegacyFuel`
  - `CDN-Fuel`
  - `ox_fuel`
  - `qb-fuel`
  - fallback native GTA fuel level
- Export API untuk resource lain:
  - `exports['exter-contacts']:createContact(cfg, contactId, label)`
  - `exports['exter-contacts']:removeContact(contactId)`
  - `exports['exter-contacts']:modifyReputation(playerId, domain, delta)`
  - `exports['exter-contacts']:GetFuel(vehicle)`
  - `exports['exter-contacts']:SetFuel(vehicle, amount)`

## Instalasi

1. Copy resource ke folder `resources/[local]/exter-contacts`.
2. Import database:
   - Jalankan `database.sql`.
3. Pastikan dependency aktif:
   - `oxmysql`
   - resource framework pilihan Anda (`qb-core`, `qbx_core`, atau `es_extended`)
   - `interact`
4. Tambahkan ke `server.cfg`:
   ```cfg
   ensure oxmysql
   ensure exter-contacts
   ```
5. Sesuaikan konfigurasi di `shared/config.lua`.

## Konfigurasi

Pada `shared/config.lua`:

- `Config.Framework`:
  - `auto` (disarankan)
  - `qbcore`, `qbox`, `esx`, `standalone`
- `Config.FrameworkFolder`:
  - nama export framework (legacy override).
- `Config.Inventory`:
  - `auto`, `qb-inventory`, `ox_inventory`, `esx_inventory`, `qs-inventory`, `standalone`
- `Config.InventoryImagesLocation`:
  - `auto` untuk gunakan path image default inventory.
  - string URL custom bila ingin pakai CDN/path tertentu.
- `Config.FuelSystem`:
  - `auto`, `LegacyFuel`, `CDN-Fuel`, `ox_fuel`, `qb-fuel`, `none`
- `Config.Debug`:
  - `true/false` log debug deteksi adapter.

## Cara Menambahkan NPC Baru

Tambahkan object baru di `Config.npcs`:

- Properti minimum:
  - `name`, `domain`, `ped`, `coords`, `text`, `options`
- Opsi tambahan:
  - `private`, `hide`, `police`, `scenario`

Setiap opsi dialog mendukung:
- `type = add` (sub-dialog)
- `type = client`
- `type = server`
- `type = command`
- `type = shop`
- `type = none`

## Menambahkan Item Shop per Framework/Inventory

### 1) QBCore + qb-inventory

- Tambahkan item di `qb-core/shared/items.lua`.
- Pastikan `name`, `label`, `image` terisi.
- Di dialog NPC, isi `items`:
  ```lua
  { name = 'fishbait', description = 'Tools', requiredrep = 0, price = 20 }
  ```

### 2) QBCore/Qbox + ox_inventory

- Tambahkan item di data item `ox_inventory`.
- Gunakan `Config.Inventory = 'ox_inventory'` atau `auto`.
- Shop akan add item via export `ox_inventory:AddItem`.

### 3) ESX + esx_inventory

- Tambahkan item pada tabel/items sesuai implementasi ESX Anda.
- Shop memakai `xPlayer.addInventoryItem` sebagai fallback generik.

### 4) QS-Inventory

- Set `Config.Inventory = 'qs-inventory'` bila auto-detect tidak tepat.
- Karena API QS dapat berbeda antar versi, script memakai jalur generic player inventory.

### 5) Standalone

- Item handling tetap aman (no hard-crash), namun fitur inventory bergantung implementasi server Anda.

## Error Handling & Validasi

Refactor terbaru menambahkan:

- Validasi payload NUI sebelum diproses.
- Validasi cart item (nama item, qty, price).
- Guard ketika callback/framework/resource tidak tersedia.
- Proteksi kamera agar tidak double-destroy.
- Penanganan fallback notifikasi lintas framework.

## Dukungan Fuel

Script menyediakan helper fuel lintas resource.

Contoh:

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local currentFuel = exports['exter-contacts']:GetFuel(vehicle)
exports['exter-contacts']:SetFuel(vehicle, currentFuel - 10)
```

## Pengujian yang Disarankan

Lakukan smoke test berikut:

1. Spawn semua NPC dari config, cek interaksi `Talk`.
2. Buka/close menu berulang, pastikan kamera normal.
3. Test opsi rep kurang/cukup.
4. Test pembelian item dengan uang cukup dan tidak cukup.
5. Test mark GPS dari tablet.
6. Test tiap kombinasi framework + inventory yang Anda pakai.
7. Restart resource saat player online untuk memastikan ped/interaksi dibersihkan.

## Catatan Migrasi

- Disarankan set mode `auto` untuk framework/inventory/fuel agar mudah dipindah environment.
- Bila server Anda memakai nama resource non-standar, gunakan pengaturan manual pada config.

## Lisensi

Ikuti lisensi pada file `LICENSE` bawaan resource.
