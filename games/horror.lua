-- games/horror.lua  |  Horror / Hantu
-- Kode khusus game ini. Dimuat otomatis oleh risyadh.lua kalau game cocok
-- (cocoknya diatur di daftar PROFILES di risyadh.lua).
-- Kamu bisa edit file ini tanpa nyentuh game lain.

local pf = {
    horror = true,
    enemy = {"hantu", "pocong", "kuntilanak", "tuyul", "genderuwo", "wewe", "sundel", "ghost", "monster", "killer", "demon", "entity"},
    items = {"key", "kunci", "battery", "baterai", "pickup", "note", "catatan", "flashlight", "senter", "medkit", "gold", "item"},
    scare = {"hantu", "kejut"},
    tps = {{"TP ke Item Terdekat", "@items"}, {"TP ke Pintu Keluar", {"exit", "escape", "gate"}},
        {"TP ke Generator", {"generator"}}},
    alerts = {{title = "Peringatan Hantu", keys = {"hantu", "pocong", "kuntilanak", "tuyul", "genderuwo", "wewe", "sundel", "ghost", "monster", "killer", "demon", "entity"}}},
    cards = {"Movement", "Teleport", "Protection", "Gebuk Setan", "ESP Musuh & Item", "World"},
}

return pf
