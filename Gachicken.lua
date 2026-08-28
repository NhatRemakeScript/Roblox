local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

print("=== LIBRARY FUNCTIONS ===")
for k, v in pairs(Lib) do
    print(k, type(v))
end

-- Thử tạo Window với các tên khác nhau
local Win = Lib:CreateWindow("Test")
if type(Win) == "table" then
    print("=== WINDOW FUNCTIONS ===")
    for k, v in pairs(Win) do
        print(k, type(v))
    end
end
