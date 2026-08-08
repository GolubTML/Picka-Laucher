-- This is the main file of your mod
-- Plese, before you start making your mod, learn Lua and Picka API
-- Link for Lua 5.4: https://www.lua.org/manual/5.4/manual.html
-- Current Picka API documentation: https://github.com/GolubTML/Picka/blob/main/Documentation.md

-- Just printing Hello from mod in game
local Main = picka.getClass("Assembly-CSharp", "Terraria", "Main")
local NewText = picka.getMethodAddr(Main, "NewText", 4)

local Player = picka.getClass("Assembly-CSharp", "Terraria", "Player")
local Spawn = picka.getMethodAddr(Player, "Spawn", -1)

-- this will print every time player had spawned, even after death
picka.hook(Spawn, 1, function(original, instance, context)
    local hiString = picka.newString("Hello from " .. picka.getModName() .. " made by " .. picka.getModAuthor() .. " v" .. picka.getModVersion())
    picka.callNative(NewText, hiString, 255, 255, 255)

    picka.callNative(original, instance, context)
end)