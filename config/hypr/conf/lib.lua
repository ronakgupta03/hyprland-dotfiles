-- The `rice` table: state and helpers that outlive a single config file.
--
-- `hyprctl eval` runs in the same Lua state as the config, so the scripts call
-- these instead of rebuilding Hyprland calls in bash:
--   rice.rebind(...)       rice-binds-ctl.py (the keybind menu)
--   rice.focus(on)         hypr-focus.sh (writing mode)
-- A `hyprctl reload` rebuilds all of it from the config files.

rice = rice or {}

-- ------------------------------------------------------------------ binds --
-- Every bind made through these is remembered under the key string it was
-- COMMITTED with (as written in conf/binds.lua), so a rebind can find it again
-- however often it has moved. A key string used twice keeps both, in order.
rice.binds = {}

local function binder(opts)
    return function(keys, action)
        local entry = { action = action, opts = opts, keys = keys }
        entry.handle = hl.bind(keys, action, opts)
        local list = rice.binds[keys] or {}
        list[#list + 1] = entry
        rice.binds[keys] = list
    end
end

rice.bind   = binder(nil)
rice.bindr  = binder({ repeating = true })                 -- repeats while held
rice.bindl  = binder({ locked = true })                    -- works on the lock screen
rice.bindrl = binder({ repeating = true, locked = true })
rice.bindm  = binder({ mouse = true })                     -- drag with a mouse button

-- changes: { { committed_keys, n, new_keys }, ... } where n picks between binds
-- that share committed keys (1 for the usual case). All are removed before any
-- is bound again: in a swap one bind's new keys are the other's old ones.
function rice.rebind(changes)
    local todo = {}
    for _, ch in ipairs(changes) do
        local entry = (rice.binds[ch[1]] or {})[ch[2] or 1]
        if not entry then
            error("rice.rebind: no bind committed as \"" .. tostring(ch[1]) .. "\"")
        end
        todo[#todo + 1] = { entry = entry, keys = ch[3] }
    end
    for _, t in ipairs(todo) do
        t.entry.handle:remove()
    end
    for _, t in ipairs(todo) do
        t.entry.handle = hl.bind(t.keys, t.entry.action, t.entry.opts)
        t.entry.keys = t.keys
    end
end

-- ------------------------------------------------------------- focus mode --
-- Entering saves the LIVE gaps/border/rounding and leaving puts exactly those
-- back, so whatever rice-settings set survives the round trip. After a reload
-- there is nothing saved, and nothing to restore: the config values are back.
function rice.focus(on)
    if on then
        rice.focus_saved = rice.focus_saved or {
            gaps_out = hl.get_config("general.gaps_out"),
            gaps_in = hl.get_config("general.gaps_in"),
            border_size = hl.get_config("general.border_size"),
            rounding = hl.get_config("decoration.rounding"),
        }
        hl.config({
            general = { gaps_out = 140, gaps_in = 0, border_size = 0 },
            decoration = { rounding = 0 },
        })
    elseif rice.focus_saved then
        local s = rice.focus_saved
        hl.config({
            general = { gaps_out = s.gaps_out, gaps_in = s.gaps_in, border_size = s.border_size },
            decoration = { rounding = s.rounding },
        })
        rice.focus_saved = nil
    end
end

-- ----------------------------------------------------------- scratchpad --
-- Sway-compatible scratchpad stack (FIFO/MRU stack, cycling, auto-tile eject)
rice.scratchpad_stack = rice.scratchpad_stack or {}
rice.scratchpad_active = nil

local function find_window_by_address(addr)
    if not addr then return nil end
    for _, w in ipairs(hl.get_windows()) do
        if tostring(w.address) == tostring(addr) then
            return w
        end
    end
    return nil
end

local function clean_scratchpad_stack()
    local valid = {}
    local seen = {}
    for _, addr in ipairs(rice.scratchpad_stack) do
        local w = find_window_by_address(addr)
        if w and not seen[addr] then
            seen[addr] = true
            valid[#valid + 1] = addr
        end
    end
    rice.scratchpad_stack = valid
end
local function close_special_if_open()
    local sws = hl.get_active_special_workspace()
    if sws then
        local name = sws.name:gsub("^special:?", "")
        if name == "" then name = "scratchpad" end
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
    for _, m in ipairs(hl.get_monitors()) do
        if m.special_workspace then
            local name = tostring(m.special_workspace.name or ""):gsub("^special:?", "")
            if name == "" then name = "scratchpad" end
            hl.dispatch(hl.dsp.workspace.toggle_special(name))
        end
    end
end

-- Sway move scratchpad (Mod+Shift+-)
function rice.scratchpad_move()
    local win = hl.get_active_window()
    if not win then return end
    local addr = tostring(win.address)

    clean_scratchpad_stack()
    for i, a in ipairs(rice.scratchpad_stack) do
        if a == addr then
            table.remove(rice.scratchpad_stack, i)
            break
        end
    end
    table.insert(rice.scratchpad_stack, 1, addr)
    if rice.scratchpad_active == addr then
        rice.scratchpad_active = nil
    end

    hl.dispatch(hl.dsp.window.move({ workspace = "special:scratchpad", window = win }))
    close_special_if_open()
end

-- Sway scratchpad show (Mod+-)
function rice.scratchpad_show()
    clean_scratchpad_stack()
    if #rice.scratchpad_stack == 0 then return end

    local active_win = hl.get_active_window()
    local active_addr = active_win and tostring(active_win.address) or nil
    local cur_ws = hl.get_active_workspace()
    if not cur_ws then return end

    local current_showing = nil
    if rice.scratchpad_active then
        current_showing = find_window_by_address(rice.scratchpad_active)
        if not current_showing then
            rice.scratchpad_active = nil
        end
    end

    if current_showing then
        local on_current_ws = (current_showing.workspace and current_showing.workspace.id == cur_ws.id)

        if not on_current_ws then
            -- Window is showing on another monitor or different workspace:
            -- Transport it over to the currently active monitor and workspace!
            hl.dispatch(hl.dsp.window.move({ workspace = cur_ws.id, window = current_showing }))
            hl.dispatch(hl.dsp.window.float({ action = "set", window = current_showing }))
            hl.dispatch(hl.dsp.focus({ window = current_showing }))
            hl.dispatch(hl.dsp.window.center({ window = current_showing }))
            rice.scratchpad_active = tostring(current_showing.address)
            return
        end

        if active_addr == rice.scratchpad_active then
            if #rice.scratchpad_stack == 1 then
                hl.dispatch(hl.dsp.window.move({ workspace = "special:scratchpad", window = current_showing }))
                close_special_if_open()
                rice.scratchpad_active = nil
                return
            else
                hl.dispatch(hl.dsp.window.move({ workspace = "special:scratchpad", window = current_showing }))
                close_special_if_open()
                local top = table.remove(rice.scratchpad_stack, 1)
                table.insert(rice.scratchpad_stack, top)
            end
        else
            hl.dispatch(hl.dsp.focus({ window = current_showing }))
            hl.dispatch(hl.dsp.window.center({ window = current_showing }))
            return
        end
    end

    local target_addr = rice.scratchpad_stack[1]
    local target_win = find_window_by_address(target_addr)
    if not target_win then
        table.remove(rice.scratchpad_stack, 1)
        return rice.scratchpad_show()
    end

    -- Pull window from scratchpad directly to the CURRENT active workspace on the CURRENT monitor
    hl.dispatch(hl.dsp.window.move({ workspace = cur_ws.id, window = target_win }))
    close_special_if_open()
    hl.dispatch(hl.dsp.window.float({ action = "set", window = target_win }))
    hl.dispatch(hl.dsp.focus({ window = target_win }))
    hl.dispatch(hl.dsp.window.center({ window = target_win }))
    rice.scratchpad_active = target_addr
end

-- Leave scratchpad and tile (Mod+Shift+Space / Mod+Space)
function rice.scratchpad_tile_or_float()
    local win = hl.get_active_window()
    if not win then return end
    local addr = tostring(win.address)
    local is_scratchpad = false

    for i, a in ipairs(rice.scratchpad_stack) do
        if a == addr then
            table.remove(rice.scratchpad_stack, i)
            is_scratchpad = true
            break
        end
    end
    if rice.scratchpad_active == addr then
        rice.scratchpad_active = nil
        is_scratchpad = true
    end

    if is_scratchpad then
        hl.dispatch(hl.dsp.window.float({ action = "disable", window = win }))
    else
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
end

function rice.scratchpad_tile_or_split()
    local win = hl.get_active_window()
    if not win then
        hl.dispatch(hl.dsp.layout("togglesplit"))
        return
    end
    local addr = tostring(win.address)
    local is_scratchpad = false

    for i, a in ipairs(rice.scratchpad_stack) do
        if a == addr then
            table.remove(rice.scratchpad_stack, i)
            is_scratchpad = true
            break
        end
    end
    if rice.scratchpad_active == addr then
        rice.scratchpad_active = nil
        is_scratchpad = true
    end

    if is_scratchpad then
        hl.dispatch(hl.dsp.window.float({ action = "disable", window = win }))
    else
        hl.dispatch(hl.dsp.layout("togglesplit"))
    end
end
