local gpu = require"component".gpu
local computer = require"computer"
local event = require"event"
local len = require"unicode".len

local listeners = {}
local users = {}
local doWork = true
local oldW, oldH = gpu.getResolution()
local oldBg, oldFg = gpu.getBackground(), gpu.getForeground()
local offsetY = 2

local PLAYERS = {"kaka888", "ECS", "Hikooshi"}
local DELAY = 16
local W, H = 31, 25
local BG_COLOR = 0x000080 --0x330033
local SEP_COLOR = 0xFFFF00
local TITLE = "Onliner"

function event.shouldInterrupt() return false end

local function isOnline(nickname)
    if computer.addUser(nickname) then
        computer.removeUser(nickname)
        return true
    else
        return false
    end
end

local function exit()
    for _, user in pairs(users) do
        computer.addUser(user)
    end
    
    doWork = false
    
    for _, listenerId in pairs(listeners) do
        event.cancel(listenerId)
    end
    
    gpu.setResolution(oldW, oldH)
    gpu.setBackground(oldBg)
    gpu.setForeground(oldFg)
    gpu.fill(1, 1, oldW, oldH, " ")
end

local function drawTemplate()
    gpu.setResolution(W, H)
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(BG_COLOR)
    gpu.fill(1, 1, W, H, " ")
    
    for i, nickname in pairs(PLAYERS) do
        gpu.set(math.ceil((W - 12)/2 - len(nickname)/2), offsetY+i, nickname)
    end
    
    gpu.setForeground(SEP_COLOR)
    gpu.fill(W-11, 1, 1, H-1, "|")
    gpu.fill(1, 2, W, 1, "=")
    gpu.fill(1, H-1, W, 1, "=")
    gpu.set(math.ceil(W/2 - len(TITLE)/2), 1, TITLE)
    
    gpu.setForeground(0xFF0000)
    gpu.setBackground(0xC0C0C0)
    gpu.set(W-4, H, "Выйти")
end

local function update()
    local onlineCounter = 0
    
    gpu.setBackground(BG_COLOR)
    
    for i, nickname in pairs(PLAYERS) do
        local online = isOnline(nickname)
        
        if online then
            gpu.setForeground(0x00FF00)
            onlineCounter = onlineCounter + 1
        else
            gpu.setForeground(0xFF0000)
        end
        
        gpu.fill(W-8, offsetY+i, 7, 1, " ")
        gpu.set(W-8, offsetY+i, online and "online" or "offline")
    end
    
    gpu.setForeground(0x000000)--0x6666FF)
    gpu.setBackground(0xC0C0C0)
    gpu.set(1, H, "Текущий онлайн: " .. onlineCounter)
end

for _, user in pairs({computer.users()}) do
    table.insert(users, user)
    computer.removeUser(user)
end

table.insert(listeners, event.listen("key_down", function(_, _, _, key)
    if key == 16 then
        exit()
    end
end))

table.insert(listeners, event.listen("touch", function(_, _, x, y)
    if x >= W-4 and x <= W and y == H then
        exit()
    end
end))

drawTemplate()

while doWork do
    update()
    
    os.sleep(DELAY)
end
