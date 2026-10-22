-- games/mm2.lua  |  Murder Mystery 2
-- Kode khusus game ini. Dimuat otomatis oleh risyadh.lua kalau game cocok
-- (cocoknya diatur di daftar PROFILES di risyadh.lua).
-- Kamu bisa edit file ini tanpa nyentuh game lain.

local pf = {
    role = true, items = {"coin", "gundrop"}, noPrompt = true, coin = true,
    tps = {{"TP ke Gun Drop", {"gundrop"}}, {"TP ke Lobby", {"lobby"}}, {"TP ke Spawn Map", {"spawn"}}},
    alerts = {{title = "Notif Gun Drop", keys = {"gundrop"}, deep = true}},
    cards = {"Movement", "Utility", "Fly", "Teleport", "ESP", "World"},
}

return pf
