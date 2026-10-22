-- games/doors.lua  |  DOORS
-- Kode khusus game ini. Dimuat otomatis oleh risyadh.lua kalau game cocok
-- (cocoknya diatur di daftar PROFILES di risyadh.lua).
-- Kamu bisa edit file ini tanpa nyentuh game lain.

local ctx = ...
local note, tpTo = ctx.note, ctx.tpTo

local pf = {
    horror = true,
    enemy = {"rush", "ambush", "seek", "eyes", "halt", "screech", "figure", "a60", "a-60", "a120", "a-120", "timothy", "jeff", "snare"},
    items = {"keyobtain", "key", "fuse", "hint", "lighter", "flashlight", "vitamin", "crucifix", "lockpick", "battery", "bandage", "candle", "gold", "smoothie"},
    scare = {"screech"},
    tps = {{"TP ke Item Terdekat", "@items"}, {"TP ke Tempat Sembunyi", {"wardrobe", "locker", "closet", "bed"}},
        {"TP ke Tuas", {"lever"}}, {"TP ke Emas", {"gold"}}},
    alerts = {{title = "Peringatan Entity", keys = {"rush", "ambush", "seek", "eyes", "halt", "figure", "a60", "a120", "jeff"}}},
    cards = {"Movement", "Protection", "ESP Musuh & Item", "World"},
}

pf.build = function(api)
    local c = api.card(api.gr, "DOORS")
    api.button(c, "TP ke Pintu Berikutnya", function()
        local RS = game:GetService("ReplicatedStorage")
        local gd = RS:FindFirstChild("GameData")
        local lr = gd and gd:FindFirstChild("LatestRoom")
        local rooms = workspace:FindFirstChild("CurrentRooms")
        local room = rooms and lr and rooms:FindFirstChild(tostring(lr.Value))
        local door = room and room:FindFirstChild("Door")
        local part = door and (door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart", true))
        if part and tpTo(part) then note("DOORS", "Teleport ke pintu", true)
        else note("DOORS", "Pintu nggak ketemu", false) end
    end)
    api.info(c, "Peringatan Entity aktif di kartu Teleport Cepat. Nyalakan sebelum jalan, lalu sembunyi kalau ada notifnya.")
end

return pf
