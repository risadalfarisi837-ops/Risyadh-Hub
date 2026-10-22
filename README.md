# Risyadh Hub

Script hub Roblox buatan Risyadh. Inti hub ada di [`risyadh.lua`](risyadh.lua), dan kode tiap game dipisah di folder [`games/`](games/), satu file per game.

## Struktur

```
risyadh.lua          inti hub: UI, fitur umum, daftar deteksi game (PROFILES)
games/
  nights99.lua       99 Nights in the Forest (auto farm, anti damage)
  doors.lua          DOORS
  mm2.lua            Murder Mystery 2
  bloxfruits.lua     Blox Fruits
  brainrot.lua       Steal a Brainrot dkk
  horror.lua         game horror umum
```

Hub cuma mengunduh file game yang cocok dengan game yang sedang dimainkan.

## Setup

1. Upload seluruh folder ini ke repo GitHub kamu (`risyadh.lua` dan folder `games/`).
2. Di bagian atas `risyadh.lua`, ganti `USERNAME/REPO` di `env.RisyadhBase` dengan repo kamu.
3. Jalankan `risyadh.lua` lewat executor.

Tanpa GitHub: taruh folder `games/` di `workspace/RisyadhHub/games/` milik executor, hub akan membacanya dari sana.

## Tambah game baru

1. Salin salah satu file di `games/` jadi `games/<id>.lua`, lalu isi.
2. Tambah satu baris di daftar `PROFILES` di `risyadh.lua` (`id`, `label`, `places`, `file`).

Isi yang bisa ada di file game (semuanya opsional kecuali `cards`):

- `enemy`, `items`, `scare`: kata kunci untuk ESP musuh, ESP item, anti jumpscare
- `tps`, `alerts`: tombol teleport dan notifikasi
- `cards`: kartu fitur yang tampil
- `build(api)`: kode khusus game (`api.card`, `api.toggle`, `api.slider`, `api.button`, `api.info`)
- `cleanup()`: dipanggil saat ganti profil atau unload

File game menerima `ctx` lewat `local ctx = ...` (berisi `lp`, `Base`, `note`, `posOf`, `isChar`, `tpTo`, `root`, `hum`, `alive()`).
