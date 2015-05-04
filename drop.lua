-- Grab environment
local pairs = pairs
local awful = require("awful")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}

local drops = {}
local attach_signal = capi.client.connect_signal    or capi.client.add_signal
local detach_signal = capi.client.disconnect_signal or capi.client.remove_signal

function show(name)
    return
end

function hide(name)
    return
end
-- function show(name)
--     c = drops[name]
--     if c then
--         c.hidden = false
--         c:raise()
--         capi.client.focus = c
--     else
--         spawnw = function (c)
--             detach_signal("manage", spawnw)
-- 
--             vert   = vert   or "bottom"
--             horiz  = horiz  or "center"
--             width  = width  or 1
--             height = height or 0.4
--             sticky = sticky or false
--             screen = capi.mouse.screen
-- 
--             drops[name] = c
--     
--             -- Scratchdrop clients are floaters
--             awful.client.floating.set(c, true)
--     
--             -- Client geometry and placement
--             local screengeom = capi.screen[screen].workarea
--     
--             if width  <= 1 then width  = screengeom.width  * width  end
--             if height <= 1 then height = screengeom.height * height end
--     
--             if     horiz == "left"  then x = screengeom.x
--             elseif horiz == "right" then x = screengeom.width - width
--             else   x =  screengeom.x+(screengeom.width-width)/2 end
--     
--             if     vert == "bottom" then y = screengeom.height + screengeom.y - height
--             elseif vert == "center" then y = screengeom.y+(screengeom.height-height)/2
--             else   y =  screengeom.y - screengeom.y end
--     
--             -- Client properties
--             c:geometry({ x = x, y = y, width = width, height = height })
--             c.ontop = true
--             c.above = true
--             c.skip_taskbar = true
--             if sticky then c.sticky = true end
--             if c.titlebar then awful.titlebar.remove(c) end
--     
--             c:raise()
--             capi.client.focus = c
--         end
-- 
--         clear = function (c)
--             drops[name] = nil
--         end
--     
--         -- Add manage signal and spawn the program
--         attach_signal("manage", spawnw)
--         attach_signal("unmanage", clear)
--         awful.util.spawn(name, false)
--     end
-- end
-- 
-- function hide(name)
--     c = drops[name]
--     if not c then
--         return
--     end
--     c.hidden = true
--     local ctags = c:tags()
--     for i, t in pairs(ctags) do
--         ctags[i] = nil
--     end
--     c:tags(ctags)
-- end

-- function show(name)
--     c = drops[name]
--     if not c then
--         spawn = function (c)
--             detach_signal("manage", spawnw)
--             drops[name] = c
--             -- Scratchdrop clients are floaters
--             awful.client.floating.set(c, true)
-- 
--             screen = 1
--             width = 1.0
--             height = 0.3
--             -- Client geometry and placement
--             local screengeom = capi.screen[screen].workarea
-- 
--             if width  <= 1 then width  = screengeom.width  * width  end
--             if height <= 1 then height = screengeom.height * height end
-- 
--             x =  screengeom.x+(screengeom.width-width)/2 
--             y = screengeom.height + screengeom.y - height
-- 
--             -- Client properties
--             c:geometry({ x = x, y = y, width = width, height = height })
--             c.ontop = true
--             c.above = true
--             c.skip_taskbar = true
--             if sticky then c.sticky = true end
--             if c.titlebar then awful.titlebar.remove(c) end
--         end
--         attach_signal("manage", spawnw)
--         awful.util.spawn(prog, false)
--     end
-- 
--     c = drops[name]
--     awful.client.movetotag(awful.tag.selected(screen), c)
--     c.hidden = false
--     c:raise()
--     capi.client.focus = c
-- end

function toggle(name)
    c = drops[name]
    if not c then
        return
    end
    if c.hidden then
        show(name)
    else
        hide(name)
    end
end

local drop = {}
drop.hide = hide
drop.show = show
drop.toggle = toggle
return drop
