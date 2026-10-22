-- games/nights99.lua  |  99 Nights in the Forest
-- Kode khusus game ini. Dimuat otomatis oleh risyadh.lua kalau game cocok
-- (cocoknya diatur di daftar PROFILES di risyadh.lua).
-- Kamu bisa edit file ini tanpa nyentuh game lain.

local ctx = ...
local lp, Base, VirtualUser, env = ctx.lp, ctx.Base, ctx.VirtualUser, ctx.env
local note, posOf, isChar, tpTo, root, hum = ctx.note, ctx.posOf, ctx.isChar, ctx.tpTo, ctx.root, ctx.hum

-- ===== Anti Damage (remote damage 99 Nights) =====
local DMG_GROUPS = {
    protect = {"NPCProjectileDamagePlayer", "DamagePlayer", "ClientTriggerNPCAttack", "JungleSpikeTrapDamage", "NPCProjectileDamagePet"},
    enemy = {"ExplosiveProjectileDamageEnemy", "ProjectileDamageEnemy"},
}
local dmgHeld = {protect = {}, enemy = {}}
local function setDmg(group, v)
    local folder = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 5)
    if v then
        if not folder then
            if env.RisyadhNotify then env.RisyadhNotify("Anti Damage", "Folder RemoteEvents nggak ketemu", false) end
            return
        end
        for _, n in ipairs(DMG_GROUPS[group]) do
            local r = folder:FindFirstChild(n)
            if r then dmgHeld[group][r] = folder r.Parent = nil end
        end
    else
        for r, par in pairs(dmgHeld[group]) do pcall(function() r.Parent = par end) end
        table.clear(dmgHeld[group])
    end
end

local pf = {
    enemy = {"wolf", "bear", "cultist", "alien", "mammoth", "deer"},
    scare = {"deer", "mammoth", "cultist", "alien", "jumpscare", "scream", "screech", "roar", "growl"},
    items = {"child", "kid", "chest", "scrap", "coal", "fuel", "bandage", "medkit", "berry", "carrot", "log", "apple", "meat", "steak", "mushroom", "pumpkin", "corn"},
    tps = {{"TP ke Api Unggun", {"campfire", "mainfire"}}, {"TP ke Anak Terdekat", {"child", "kid"}},
        {"TP ke Chest Terdekat", {"chest"}}, {"TP ke Item Terdekat", "@items"}, {"TP ke Pohon Terdekat", {"tree"}}},
    alerts = {{title = "Musuh Muncul", keys = {"wolf", "bear", "cultist", "alien", "mammoth"}, deep = true}},
    cards = {"Movement", "Utility", "Fly", "Teleport", "Protection", "Gebuk Setan", "ESP", "ESP Musuh & Item", "World"},
}

local F = {
    Chest = false, Wood = false, Food = false, Eat = false, Drop = false, Craft = false, Take = false,
    Delay = 0.6, Limit = 15, Hunger = 40, DropAt = "Api Unggun", Range = 25, UseRemote = false,
}
local REMOTE_ITEMS = {"log", "coal", "fuel", "scrap", "bolt", "sheet", "radio", "fan", "tire", "bandage", "medkit",
    "carrot", "berry", "morsel", "steak", "meat", "apple", "mushroom", "pumpkin", "corn", "sapling", "ammo", "gear", "oil"}
local remCache, peak = {}, 100
local function getRemote(name)
    if remCache[name] == nil then
        remCache[name] = game:GetService("ReplicatedStorage"):FindFirstChild(name, true) or false
    end
    return remCache[name] or nil
end
local SKIP = {"buy", "sell", "shop", "purchase", "robux", "teleport", "rebirth", "trade", "gift", "upgrade"}
local FOOD = {"carrot", "berry", "apple", "meat", "steak", "mushroom", "pumpkin", "corn", "stew", "food", "cooked"}
local bad, cache, noted = {}, {}, {}
local running = false

local function matches(n, keys)
    n = n:lower()
    for _, k in ipairs(keys) do
        if n:find(k, 1, true) then return true end
    end
    return false
end
local function once(k, t, m)
    if not noted[k] then noted[k] = true note(t, m, false) end
end
-- scan workspace (di-cache 3 detik biar nggak berat)
local function scan(keys)
    local id = table.concat(keys, ",")
    local c = cache[id]
    if c and os.clock() - c.t < 3 then return c.list end
    local list = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if (o:IsA("Model") or o:IsA("BasePart")) and matches(o.Name, keys) then
            local par = o.Parent
            local childOfMatch = o:IsA("BasePart") and par and par:IsA("Model") and matches(par.Name, keys)
            if not childOfMatch and not isChar(o) then list[#list + 1] = o end
        end
    end
    cache[id] = {t = os.clock(), list = list}
    return list
end
local function nearest(keys)
    local r = root()
    if not r then return end
    local best, bd
    for _, o in ipairs(scan(keys)) do
        if o.Parent and not (bad[o] and bad[o] > os.clock()) then
            local p = posOf(o)
            if p then
                local d = (p - r.Position).Magnitude
                if not bd or d < bd then best, bd = o, d end
            end
        end
    end
    return best, bd
end
-- ambil / buka: prompt -> click detector -> sentuh
local function grab(o)
    if not tpTo(o) then return false end
    task.wait(0.15)
    local did = false
    for _, d in ipairs(o:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled then Base.fireP(d) did = true end
    end
    if not did and fireclickdetector then
        for _, d in ipairs(o:GetDescendants()) do
            if d:IsA("ClickDetector") then pcall(fireclickdetector, d) did = true end
        end
    end
    if not did and firetouchinterest then
        local r = root()
        local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart", true)
        if r and part then
            pcall(firetouchinterest, r, part, 0)
            pcall(firetouchinterest, r, part, 1)
            did = true
        end
    end
    return did
end
local function toolsIn(c, keys)
    local list = {}
    if c then
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and (not keys or matches(t.Name, keys)) then list[#list + 1] = t end
        end
    end
    return list
end
local function allTools(keys)
    local list = toolsIn(lp.Character, keys)
    for _, t in ipairs(toolsIn(lp:FindFirstChildOfClass("Backpack"), keys)) do list[#list + 1] = t end
    return list
end
local function equip(keys)
    local h = hum()
    if not h then return end
    local eq = toolsIn(lp.Character, keys)[1]
    if eq then return eq end
    local t = toolsIn(lp:FindFirstChildOfClass("Backpack"), keys)[1]
    if t then
        pcall(function() h:EquipTool(t) end)
        task.wait(0.15)
        return t
    end
end
-- cari nilai lapar (atribut / ValueBase bernama "hunger") di player + karakter
local function readHunger()
    local function look(o)
        if not o then return end
        for k, v in pairs(o:GetAttributes()) do
            if type(v) == "number" and k:lower():find("hunger", 1, true) then
                return v, o:GetAttribute("Max" .. k)
            end
        end
        for _, d in ipairs(o:GetDescendants()) do
            if d:IsA("ValueBase") and d.Name:lower():find("hunger", 1, true) and type(d.Value) == "number" then
                local mx = d.Parent and d.Parent:FindFirstChild("Max" .. d.Name)
                return d.Value, mx and mx.Value
            end
        end
    end
    local v, mx = look(lp)
    if v == nil then v, mx = look(lp.Character) end
    return v, mx
end

-- ambil semua yang ada di sekitar: prompt (kecuali beli/jual dll) + item yang bisa disentuh
local function sweep(center, secs)
    local total, fired = 0, {}
    local store = F.UseRemote and getRemote("RequestBagStoreItem")
    local t0 = os.clock()
    while ctx.alive() and os.clock() - t0 < secs do
        local r = root()
        if not r then break end
        local origin = center or r.Position
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                if d.Enabled and not fired[d] then
                    local part = d.Parent
                    if part and part:IsA("Attachment") then part = part.Parent end
                    if part and part:IsA("BasePart") and (part.Position - origin).Magnitude <= F.Range and not isChar(part) then
                        local txt = (d.ActionText .. " " .. d.ObjectText .. " " .. part.Name):lower()
                        if not matches(txt, SKIP) then
                            fired[d] = true
                            if (part.Position - r.Position).Magnitude > 12 then
                                r.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                            end
                            Base.fireP(d)
                            total += 1
                            task.wait(0.08)
                        end
                    end
                end
            elseif firetouchinterest and d:IsA("BasePart") and not fired[d] and (d.Position - origin).Magnitude <= F.Range then
                if pf.items and matches(d.Name, pf.items) and not matches(d.Name, {"chest", "tree"}) and not isChar(d) then
                    fired[d] = true
                    pcall(firetouchinterest, r, d, 0)
                    pcall(firetouchinterest, r, d, 1)
                    total += 1
                end
            elseif store and d:IsA("Model") and not fired[d] and matches(d.Name, REMOTE_ITEMS)
                and not matches(d.Name, {"chest", "tree"}) then
                local mp = posOf(d)
                if mp and (mp - origin).Magnitude <= F.Range and not isChar(d) then
                    fired[d] = true
                    pcall(function() store:FireServer(d) end)
                    total += 1
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.5)
    end
    return total
end

local function doEat()
    local v, mx = readHunger()
    if not v then
        once("nohunger", "No Lapar", "Nilai lapar nggak ketemu. Tekan Scan lalu kirim hasilnya ke developer")
        return false
    end
    peak = math.max(peak, v)
    local pctNow = mx and (v / mx * 100) or (v / peak * 100)
    if pctNow > F.Hunger then return false end
    local food = equip(FOOD)
    if not food then once("nofoodtool", "No Lapar", "Nggak ada makanan di tas") return false end
    pcall(function() food:Activate() end)
    task.wait(0.6)
    return true
end
local function doDrop()
    if #allTools() < F.Limit then return false end
    local spot = false
    if F.DropAt == "Safe Spot" and Base.goSafe then
        Base.goSafe()
        spot = true
    else
        local fire = nearest({"campfire", "mainfire"})
        if fire and tpTo(fire) then spot = true end
    end
    if not spot then once("nospot", "Auto Drop", "Api unggun / safe spot nggak ketemu") return false end
    task.wait(0.25)
    local r, h = root(), hum()
    if not (r and h) then return false end
    local prompts = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled then
            local part = d.Parent
            if part and part:IsA("Attachment") then part = part.Parent end
            if part and part:IsA("BasePart") and (part.Position - r.Position).Magnitude < 25 then
                prompts[#prompts + 1] = d
            end
        end
    end
    local n = 0
    for _, t in ipairs(allTools()) do
        if not (F.Drop and ctx.alive()) or n >= 25 then break end
        n += 1
        pcall(function() h:EquipTool(t) end)
        task.wait(0.1)
        for _, d in ipairs(prompts) do Base.fireP(d) end
        task.wait(0.1)
    end
    pcall(function() h:UnequipTools() end)
    return true
end
local function doChest()
    local o = nearest({"chest"})
    if not o then once("nochest", "Auto Farm Chest", "Chest nggak ketemu") return false end
    grab(o)
    task.wait(0.4)
    sweep(posOf(o), 2.4)
    bad[o] = os.clock() + 90
    return true
end
-- ===== remote asli 99 Nights (hasil rekaman) =====
local RS = game:GetService("ReplicatedStorage")
local function RE(n)
    local f = RS:FindFirstChild("RemoteEvents")
    return f and f:FindFirstChild(n)
end
local function invItem(keys)
    local inv = lp:FindFirstChild("Inventory")
    if not inv then return end
    for _, o in ipairs(inv:GetChildren()) do
        if matches(o.Name, keys) then return o end
    end
end
local curEquip
local function takeRemote(item)
    local sack = invItem({"sack", "bag"})
    local drag, store, stop = RE("RequestStartDraggingItem"), RE("RequestBagStoreItem"), RE("StopDraggingItem")
    if not (sack and drag and store) then
        once("noremote", "Ambil Item", "Remote drag/bag atau Old Sack nggak ketemu")
        return false
    end
    pcall(function() drag:FireServer(item) end)
    task.wait(0.15)
    local tmp = RS:FindFirstChild("TempStorage")
    local target = item
    if tmp and item.Parent ~= tmp then target = tmp:FindFirstChild(item.Name) or item end
    local ok = pcall(function() return store:InvokeServer(sack, target) end)
    if stop then pcall(function() stop:FireServer(item) end) end
    return ok
end
local function takeNear(center, range, keys)
    local items = workspace:FindFirstChild("Items")
    if not items then return 0 end
    local n = 0
    for _, o in ipairs(items:GetChildren()) do
        if not ctx.alive() then break end
        local p = posOf(o)
        if p and (p - center).Magnitude <= range and not (bad[o] and bad[o] > os.clock())
            and (not keys or matches(o.Name, keys)) then
            bad[o] = os.clock() + 20
            tpTo(o)
            task.wait(0.1)
            takeRemote(o)
            n += 1
            task.wait(0.1)
        end
    end
    return n
end
local function doWood()
    local tree = nearest({"tree"})
    if not tree then once("notree", "Auto Farm Kayu", "Pohon nggak ketemu") return false end
    local axe = invItem({"axe", "hatchet", "chainsaw"})
    if not axe then once("noaxe", "Auto Farm Kayu", "Kapak nggak ada di Inventory") bad[tree] = os.clock() + 5 return false end
    local ev = RE("EquipItemHandle")
    if curEquip ~= axe and ev then
        pcall(function() ev:FireServer("FireAllClients", axe) end)
        curEquip = axe
        task.wait(0.4)
    end
    local r, p = root(), posOf(tree)
    if not (r and p) then return false end
    local flat = Vector3.new(r.Position.X - p.X, 0, r.Position.Z - p.Z)
    local dir = flat.Magnitude > 0.1 and flat.Unit or Vector3.xAxis
    local stand = Vector3.new(p.X, r.Position.Y, p.Z) + dir * 5
    r.CFrame = CFrame.lookAt(stand, Vector3.new(p.X, stand.Y, p.Z))
    once("woodgo", "Auto Farm Kayu", "Mulai gebuk: " .. tree.Name)
    local hit = RE("PlayEnemyHitSound")
    local tmodel = tree:IsA("Model") and tree or tree:FindFirstAncestorOfClass("Model") or tree
    local t0 = os.clock()
    while F.Wood and ctx.alive() and tree.Parent and os.clock() - t0 < 8 do
        pcall(function() VirtualUser:ClickButton1(Vector2.new(0, 0)) end)
        if hit then pcall(function() hit:FireServer("FireAllClients", tmodel, axe) end) end
        task.wait(0.35)
    end
    bad[tree] = os.clock() + 25
    takeNear(p, 30, {"log"})
    return true
end
local function doFood()
    local o = nearest(FOOD)
    if not o then once("nofood", "Auto Farm Makanan", "Makanan nggak ketemu") return false end
    local ok = grab(o)
    sweep(posOf(o), 1.0)
    bad[o] = os.clock() + (ok and 30 or 120)
    return true
end
local function doCraft()
    local o = nearest({"workbench", "craft", "anvil", "bench"})
    if not o then once("nocraft", "Auto Crafting", "Meja crafting nggak ketemu") return false end
    grab(o)
    bad[o] = os.clock() + 5
    return true
end

local function doTake()
    local r = root()
    return r ~= nil and takeNear(r.Position, F.Range) > 0
end
local function anyOn()
    return F.Chest or F.Wood or F.Food or F.Eat or F.Drop or F.Craft or F.Take
end
local function loop()
    if running then return end
    running = true
    task.spawn(function()
        while ctx.alive() and anyOn() do
            local r, h = root(), hum()
            if r and h and h.Health > 0 then
                local ok, err = pcall(function()
                    if F.Eat and doEat() then return end
                    if F.Drop and doDrop() then return end
                    if F.Chest and doChest() then return end
                    if F.Wood and doWood() then return end
                    if F.Food and doFood() then return end
                    if F.Take and doTake() then return end
                    if F.Craft and doCraft() then return end
                end)
                if not ok then warn("[Risyadh farm]", err) end
            end
            task.wait(F.Delay)
        end
        running = false
    end)
end
local function setF(k, v)
    F[k] = v
    if v then table.clear(noted) loop() end
end

pf.build = function(api)
    local sc = api.card(api.gr, "Anti Jumpscare 99 Nights")
    api.toggle(sc, "Anti Jumpscare (suara + layar + kamera)", false, function(v)
        if Base.setAntiScare then Base.setAntiScare(v) end
    end)
    api.info(sc, "Bisukan suara kejut, sembunyikan UI jumpscare, dan cegah kamera dipaksa/goyang. Kalau masih ada UI yang lolos, nyalakan juga Strict di kartu Protection.")

    local c = api.card(api.gr, "Anti Damage")
    api.toggle(c, "Anti Damage (blok remote damage)", next(dmgHeld.protect) ~= nil, function(v) setDmg("protect", v) end)
    api.toggle(c, "Blok Damage Projectile ke Musuh", next(dmgHeld.enemy) ~= nil, function(v) setDmg("enemy", v) end)
    api.info(c, "Remote dicabut dari ReplicatedStorage.RemoteEvents di sisi kamu, dan dipasang lagi saat toggle dimatikan. Opsi kedua juga bikin projectile kamu sendiri nggak melukai musuh.")

    local f = api.card(api.gl, "Auto Farm (Eksperimen)")
    api.toggle(f, "Auto Farm Chest", false, function(v) setF("Chest", v) end)
    api.toggle(f, "Auto Farm Kayu", false, function(v) setF("Wood", v) end)
    api.toggle(f, "Auto Farm Makanan", false, function(v) setF("Food", v) end)
    api.toggle(f, "No Lapar (Auto Makan)", false, function(v) setF("Eat", v) end)
    api.slider(f, "Makan kalau lapar di bawah (%)", 5, 90, F.Hunger, function(v) F.Hunger = v end)
    api.toggle(f, "Auto Take (ambil semua di sekitar)", false, function(v) setF("Take", v) end)
    api.slider(f, "Radius Ambil", 8, 60, F.Range, function(v) F.Range = v end)
    api.toggle(f, "Ambil via Remote (eksperimen)", false, function(v) F.UseRemote = v end)
    api.toggle(f, "Auto Crafting (buka meja)", false, function(v) setF("Craft", v) end)
    api.slider(f, "Jeda Farm (ms)", 100, 3000, 600, function(v) F.Delay = v / 1000 end)
    api.button(f, "Cek Prompt Sekitar (salin)", function()
        local r = root()
        if not r then return end
        local lines = {
            "fireproximityprompt=" .. tostring(fireproximityprompt ~= nil)
                .. " firetouchinterest=" .. tostring(firetouchinterest ~= nil),
        }
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local part = d.Parent
                if part and part:IsA("Attachment") then part = part.Parent end
                if part and part:IsA("BasePart") then
                    local dist = (part.Position - r.Position).Magnitude
                    if dist <= 50 and n < 40 then
                        n += 1
                        lines[#lines + 1] = ("%s > %s | act=%s obj=%s hold=%s en=%s d=%d"):format(
                            part.Parent and part.Parent.Name or "?", part.Name, d.ActionText, d.ObjectText,
                            tostring(d.HoldDuration), tostring(d.Enabled), math.floor(dist))
                    end
                end
            end
        end
        lines[#lines + 1] = "Total prompt dalam 50 stud: " .. n
        local txt = table.concat(lines, "\n")
        print("[Risyadh prompt]\n" .. txt)
        if setclipboard then pcall(setclipboard, txt) end
        note("Prompt", setclipboard and "Laporan tersalin, kirim ke developer" or "Lihat console (F9)", true)
    end)

    local d = api.card(api.gl, "Auto Drop")
    api.toggle(d, "Auto Drop kalau Tas Penuh", false, function(v) setF("Drop", v) end)
    api.slider(d, "Batas Tas (jumlah item)", 3, 60, F.Limit, function(v) F.Limit = v end)
    api.dropdown(d, "Lokasi Drop", {"Api Unggun", "Safe Spot"}, F.DropAt, function(v) F.DropAt = v end)
    api.button(d, "Scan (salin laporan)", function()
        local rs = game:GetService("ReplicatedStorage")
        local rem = {}
        for _, o in ipairs(rs:GetDescendants()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then rem[#rem + 1] = o.Name end
        end
        table.sort(rem)
        local hv, hm = readHunger()
        local txt = table.concat({
            ("Chest: %d | Pohon: %d | Log: %d | Api unggun: %d | Meja: %d | Makanan: %d"):format(
                #scan({"chest"}), #scan({"tree"}), #scan({"log"}), #scan({"campfire", "mainfire"}),
                #scan({"workbench", "craft", "anvil", "bench"}), #scan(FOOD)),
            "Item di tas: " .. #allTools() .. " | Kapak: " .. #allTools({"axe", "hatchet", "chainsaw"}),
            "Lapar: " .. tostring(hv) .. " / max " .. tostring(hm),
            "Remote (" .. #rem .. "): " .. table.concat(rem, ", ", 1, math.min(#rem, 150)),
        }, "\n")
        print("[Risyadh scan]\n" .. txt)
        if setclipboard then pcall(setclipboard, txt) end
        note("Scan", setclipboard and "Laporan tersalin, kirim ke developer" or "Lihat console (F9)", true)
    end)
    api.info(d, "Drop: pindah ke api unggun / safe spot lalu tekan prompt di sekitarnya sambil pegang item satu-satu. Kalau game kamu pakai cara lain (drag/tombol), kirim hasil Scan.")
end
pf.cleanup = function()
    setDmg("protect", false)
    setDmg("enemy", false)
    for _, k in ipairs({"Chest", "Wood", "Food", "Eat", "Drop", "Craft", "Take"}) do F[k] = false end
end

return pf
