local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- Xem tất cả functions
for k, v in pairs(Lib) do
    if type(v) == "function" then
        print("FUNCTION:", k)
    elseif type(v) == "table" then
        print("TABLE:", k)
    elseif type(v) == "string" then
        print("STRING:", k, "=", v)
    end
end

-- Thử các cách tạo Window khác nhau
local Win = nil

-- Cách 1
pcall(function() Win = Lib:CreateWindow("Test") end)
if Win then print("Cách 1 OK: CreateWindow") end

-- Cách 2
pcall(function() Win = Lib:Window("Test") end)
if Win then print("Cách 2 OK: Window") end

-- Cách 3
pcall(function() Win = Lib.new("Test") end)
if Win then print("Cách 3 OK: new") end

-- Cách 4
pcall(function() Win = Lib:CreateLib("Test") end)
if Win then print("Cách 4 OK: CreateLib") end

-- Cách 5
pcall(function() Win = Lib:MakeWindow("Test") end)
if Win then print("Cách 5 OK: MakeWindow") end

-- Cách 6
pcall(function() Win = Lib:Load("Test") end)
if Win then print("Cách 6 OK: Load") end
