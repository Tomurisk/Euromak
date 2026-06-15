------------------------------------------------------------
-- IPC (required for terminal: hs -c "restartTaps()")
------------------------------------------------------------

require("hs.ipc")

------------------------------------------------------------
-- GLOBAL STATE
------------------------------------------------------------

ro = false
waitingForSecondKey = false
last4Time = 0
double4Window = 0.50

local FOUR_KEYCODE = 21
layoutStack = {}

local pending4Timer = nil
local pending4Shifted = false
local skipNext4 = false

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

function currentLayout()
    return hs.keycodes.currentLayout()
end

function switchLayout(name)
    hs.keycodes.setLayout(name)
end

function pushUkrainian()
    local cur = currentLayout()
    table.insert(layoutStack, cur)
    ro = false
    switchLayout("Ukrainian")
    hs.alert.show("Layout → Ukrainian")
end

function popLayout()
    if #layoutStack > 0 then
        local prev = table.remove(layoutStack)
        switchLayout(prev)
    else
        hs.alert.show("Layout stack empty")
    end
end

function reset4()
    waitingForSecondKey = false
    pending4Shifted = false
    last4Time = 0
    if pending4Timer then
        pending4Timer:stop()
        pending4Timer = nil
    end
end

function PreviousLayout()
    ro = false
    popLayout()
    local newLayout = currentLayout()
    hs.alert.show(newLayout .. " (LT mode)")
end

-- NEW: Caps Lock detection
function isCapsOn()
    return hs.hid.capslock.get()
end

------------------------------------------------------------
-- LT / RO MODE TOGGLE (Option + Shift)
------------------------------------------------------------

local modtap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
    local f = e:getFlags()

    if f.alt and f.shift then
        local layout = currentLayout()

        if layout == "Ukrainian" then
            PreviousLayout()
        else
            ro = not ro
            hs.alert.show(ro and "Romanian" or "Lithuanian")
        end

        return true
    end

    return false
end)

modtap:start()

------------------------------------------------------------
-- SHARED SYMBOLS
------------------------------------------------------------

BaseMap = {
    y = "–", Y = "–",
    ["9"] = "„",
    ["0"] = "\u{201D}",
    ["5"] = "€"
}

------------------------------------------------------------
-- LT / RO MAPS
------------------------------------------------------------

LTMap = {
    i="č", t="š", e="ž", n="ą", s="ė", o="ę", a="į", m="ų", r="ū",
    I="Č", T="Š", E="Ž", N="Ą", S="Ė", O="Ę", A="Į", M="Ų", R="Ū",
}

ROMap = {
    r="ă", e="â", n="î", t="ș", i="ț",
    R="Ă", E="Â", N="Î", T="Ș", I="Ț",
    ["("]="«", [")"]="»",
}

setmetatable(LTMap, { __index = BaseMap })
setmetatable(ROMap, { __index = BaseMap })

------------------------------------------------------------
-- CYRILLIC MAP (KEYCODE-BASED, Ukrainian JCUKEN on Mac)
------------------------------------------------------------

CYRKeycodeMap = {
    [38] = "ы",  ["38S"] = "Ы",
    [2]  = "қ",  ["2S"]  = "Қ",
    [3]  = "ғ",  ["3S"]  = "Ғ",
    [1]  = "ң",  ["1S"]  = "Ң",
    [40] = "ұ",  ["40S"] = "Ұ",
    [41] = "ә",  ["41S"] = "Ә",
    [4]  = "ө",  ["4S"]  = "Ө",
    [37] = "ү",  ["37S"] = "Ү",
    [0]  = "э",  ["0S"]  = "Э",
    [5]  = "ъ",  ["5S"]  = "Ъ",
    [17] = "ё",  ["17S"] = "Ё",
    [16] = "һ",  ["16S"] = "Һ",
    [6]  = "ћ",  ["6S"]  = "Ћ",
    [12] = "ј",  ["12S"] = "Ј",
    [45] = "љ",  ["45S"] = "Љ",
    [46] = "њ",  ["46S"] = "Њ",
    [43] = "ђ",  ["43S"] = "Ђ",
    [47] = "џ",  ["47S"] = "Џ",
    [31] = "—",  ["31S"] = "—",

    -- Symbols
    [25] = "«",
    [29] = "»",
    ["25S"] = "„",
    ["29S"] = "“"
}

------------------------------------------------------------
-- MAIN EVENTTAP (4 → next key)
------------------------------------------------------------

local tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local keyCode = e:getKeyCode()
    local flags = e:getFlags()
    local char = e:getCharacters(true)
    local now = hs.timer.secondsSinceEpoch()

    if not char or #char ~= 1 then char = "" end

    --------------------------------------------------------
    -- Step 1: Handle "4" invoker
    --------------------------------------------------------
    if keyCode == FOUR_KEYCODE then
        if flags.shift then
            if skipNext4 then
                skipNext4 = false
                return false
            end
            reset4()
            skipNext4 = true
            hs.eventtap.event.newKeyEvent({"shift"}, "4", true):post()
            return true
        end

        if now - last4Time <= double4Window then
            reset4()
            hs.eventtap.keyStrokes("4")
            return true
        end

        last4Time = now
        waitingForSecondKey = true
        pending4Shifted = false

        if pending4Timer then pending4Timer:stop() end
        pending4Timer = hs.timer.doAfter(2.0, function()
            if waitingForSecondKey then
                reset4()
                hs.eventtap.keyStrokes("4")
            end
        end)

        return true
    end

    --------------------------------------------------------
    -- Step 2: Handle second key after 4
    --------------------------------------------------------
    if waitingForSecondKey then
        local wasShifted = flags.shift or isCapsOn()
        reset4()

        local layout = currentLayout()
        local out = nil

        if layout == "Ukrainian" then
            -- FIX: Caps Lock should uppercase Cyrillic too
            local shifted = flags.shift or isCapsOn()
            local key = shifted and (tostring(keyCode) .. "S") or keyCode
            out = CYRKeycodeMap[key]
        else
            -- LT/RO: Caps Lock uppercases lookup key
            local lookupKey = wasShifted and char:upper() or char
            if ro then
                out = ROMap[lookupKey]
            else
                out = LTMap[lookupKey]
            end
        end

        if out then
            hs.eventtap.keyStrokes(out)
            if flags.shift then
                hs.eventtap.event.newKeyEvent(hs.keycodes.map["shift"], true):post()
            end
        else
            local mods = {}
            if flags.shift then table.insert(mods, "shift") end
            if flags.alt   then table.insert(mods, "alt")   end
            if flags.cmd   then table.insert(mods, "cmd")   end
            if flags.ctrl  then table.insert(mods, "ctrl")  end
            hs.eventtap.event.newKeyEvent(mods, keyCode, true):post()
        end
        return true
    end

    return false
end)

tap:start()

------------------------------------------------------------
-- ALT+SPACE (Ukrainian toggle)
------------------------------------------------------------

hs.hotkey.bind({"alt"}, "space", function()
    if currentLayout() ~= "Ukrainian" then
        pushUkrainian()
    else
        PreviousLayout()
    end
end)

------------------------------------------------------------
-- EVENTTAP WATCHDOG
------------------------------------------------------------

function restartTaps()
    tap:stop()
    tap:start()
    modtap:stop()
    modtap:start()
end

local watchdog = hs.timer.doEvery(20, restartTaps)

------------------------------------------------------------
-- CAFFEINATE WATCHER
------------------------------------------------------------

local wakeWatcher = hs.caffeinate.watcher.new(function(event)
    local wakeEvents = {
        [hs.caffeinate.watcher.screensDidWake]         = true,
        [hs.caffeinate.watcher.sessionDidBecomeActive] = true,
        [hs.caffeinate.watcher.screensDidUnlock]       = true,
    }
    if wakeEvents[event] then
        restartTaps()
    end
end)

wakeWatcher:start()

------------------------------------------------------------
-- F19 → Cmd+W
------------------------------------------------------------

hs.hotkey.bind({}, "F19", function()
    hs.eventtap.keyStroke({"cmd"}, "w")
end)