-- games/bloxfruits.lua  |  Blox Fruits
-- Kode khusus game ini. Dimuat otomatis oleh risyadh.lua kalau game cocok
-- (cocoknya diatur di daftar PROFILES di risyadh.lua).
-- Kamu bisa edit file ini tanpa nyentuh game lain.

local pf = {
    items = {"fruit", "chest"}, noPrompt = true,
    tps = {{"TP ke Buah Terdekat", {"fruit"}}, {"TP ke Chest Terdekat", {"chest"}}},
    alerts = {{title = "Buah Muncul", keys = {"fruit"}}},
    cards = {"Movement", "Utility", "Fly", "Teleport", "ESP", "ESP Musuh & Item", "World"},
}

return pf
