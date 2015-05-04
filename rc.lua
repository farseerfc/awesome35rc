local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local wi = require("wi")
local eminent = require("eminent")
-- local scratch = require("scratch")
local keydoc = require("keydoc")

-- {{{ Error handling
-- Startup
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors })
end

-- Runtime
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = err })
      in_error = false
    end)
end
-- }}}

-- {{{ Variables
terminal = "termite"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
altkey = "Mod1"
-- }}}

-- {{{ Layouts
local layouts =
{
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Monaco 12"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 64
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 2
naughty.config.defaults.hover_timeout = nil
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
tags = {
  names = { "鉻", "貳", "叄", "䦉", "伍", "陸", "柒", "捌", "玖", "拾" },
  layouts = { 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2], 
      layouts[2]
  }
}
for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Shutdown
mylauncher = wibox.widget.imagebox()
mylauncher:set_image(beautiful.awesome_icon)
mylauncher:buttons(awful.util.table.join(
  awful.button({ }, 1, function()
      awful.util.spawn_with_shell("slock")
    end),
  awful.button({ }, 3, function()
      awful.util.spawn_with_shell("systemctl suspend")
      awful.util.spawn_with_shell("slock")
    end),
  awful.button({ modkey }, 1, function()
      awful.util.spawn_with_shell("reboot")
    end),
  awful.button({ modkey }, 3, function()
      awful.util.spawn_with_shell("poweroff")
    end)
))
-- }}}

-- Menubar
menubar.utils.terminal = terminal

clientmenu_icon = beautiful.clientmenu_icon or beautiful.awesome_icon
kbd_icon = beautiful.xvkbd_icon or beautiful.awesome_icon

awful.menu.menu_keys = {
	up={ "Up", 'k' }, 
	down = { "Down", 'j' }, 
	back = { "Left", 'x', 'h' }, 
	exec = { "Return", "Right", 'o', 'l' },
	close = { "Escape" }
}

contextmenu_args = {
    coords={ x=0, y=0 },
    keygrabber = true
}

mainmenu_args = {
    coords={ x=0, y=0 },
    keygrabber = true
}

chord_menu_args = {
    coords={ x=0, y=0 },
    keygrabber = false
}
-- Menu helpers--{{{
mymenu = nil
function menu_hide()
    if mymenu ~= nil then
        mymenu:hide()
        mymenu = nil
    end
end

function menu_current(menu, args)
    if mymenu ~= nil and mymenu ~= menu then
        mymenu:hide()
    end
    mymenu = menu
    mymenu:show(args)
    return mymenu
end

-- {{{ Wiboxes
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function(c)
      if c == client.focus then
        c.minimized = true
      else
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, 3, function()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=250 })
      end
    end),
  awful.button({ }, 4, function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({ }, 5, function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end))

for s = 1, screen.count() do
  mypromptbox[s] = awful.widget.prompt()

  -- Layoutbox
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))

  -- Taglist
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Tasklist
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Wibox
  mywibox[s] = awful.wibox({ position = "top", height = 32, screen = s })

  local left_wibox = wibox.layout.fixed.horizontal()
  left_wibox:add(mytaglist[s])
  left_wibox:add(space)
  left_wibox:add(mypromptbox[s])
  left_wibox:add(mylayoutbox[s])
  left_wibox:add(space)

  local right_wibox = wibox.layout.fixed.horizontal()
  right_wibox:add(wibox.widget.systray())
  right_wibox:add(mytextclock)

  local wibox_layout = wibox.layout.align.horizontal()
  wibox_layout:set_left(left_wibox)
  wibox_layout:set_middle(mytasklist[s])
  wibox_layout:set_right(right_wibox)

  mywibox[s]:set_widget(wibox_layout)
end

  -- Graphbox
--  mygraphbox[1] = awful.wibox({ position = "bottom", height = 32, screen = 1 })

--  local left_graphbox = wibox.layout.fixed.horizontal()
  -- left_graphbox:add(weather)
--  left_graphbox:add(mylauncher)
--  left_graphbox:add(cpufreq)
--  left_graphbox:add(space)
--  left_graphbox:add(memused)
--  left_graphbox:add(membar)
--  left_graphbox:add(mempct)
--  left_graphbox:add(space)
--  left_graphbox:add(swappct)
--  left_graphbox:add(swapbar)
--  left_graphbox:add(space)
--  left_graphbox:add(rootfsused)
--  left_graphbox:add(rootfsbar)
--  left_graphbox:add(rootfspct)
  -- cputext = {}
  -- local graphbox3 = wibox.layout.fixed.horizontal()
  -- for c = 1, 8 do
  --   cputext[c] = wibox.widget.textbox()
  --   cputext[c]:set_text(" "..c..":")
  --   left_graphbox:add(cputext[c])
  --   left_graphbox:add(cpugraph[c])
  --   left_graphbox:add(cpupct[c])
  -- end


--  local mid_graphbox = wibox.layout.fixed.horizontal()
--  mid_graphbox:add(mpdicon)
--  mid_graphbox:add(mpdwidget)
--  mid_graphbox:add(pacicon)
--  mid_graphbox:add(pacwidget)
--  mid_graphbox:add(baticon)
--  mid_graphbox:add(batpct)
--  mid_graphbox:add(volicon)
--  mid_graphbox:add(volpct)
--  mid_graphbox:add(volspace)


--  local graphbox_layout = wibox.layout.align.horizontal()
--  graphbox_layout:set_left(left_graphbox)
--  graphbox_layout:set_middle(mid_graphbox)
--  graphbox_layout:set_right(right_wibox)

--  mygraphbox[1]:set_widget(graphbox_layout)

  -- local graphbox2 = wibox.layout.fixed.horizontal()

  -- mygraphbox[2] = awful.wibox({ position = "bottom", height = 32, screen = 2 })
  -- mygraphbox[2]:set_widget(graphbox2)
  -- 
  -- cputext = {}
  -- local graphbox3 = wibox.layout.fixed.horizontal()
  -- graphbox3:add(cpufreq)
  -- for c = 1, 8 do
  --   cputext[c] = wibox.widget.textbox()
  --   cputext[c]:set_text(" "..c..":")
  --   graphbox3:add(cputext[c])
  --   graphbox3:add(cpugraph[c])
  --   graphbox3:add(cpupct[c])
  -- end
  -- mygraphbox[3] = awful.wibox({ position = "bottom", height = 32, screen = 3 })
  -- mygraphbox[3]:set_widget(graphbox3)

  -- local graphbox4 = wibox.layout.fixed.horizontal()
  -- graphbox4:add(txwidget)
  -- graphbox4:add(upgraph)
  -- graphbox4:add(upwidget)
  -- graphbox2:add(space)
  -- graphbox4:add(rxwidget)
  -- graphbox4:add(downgraph)
  -- graphbox4:add(downwidget)
  -- mygraphbox[4] = awful.wibox({ position = "bottom", height = 32, screen = 4 })
  -- mygraphbox[4]:set_widget(graphbox4)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  keydoc.group("Misc"),
  awful.key({ modkey, "Ctrl" }, "F1", keydoc.display,
    "Show awesome keybindings"),
  awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        if mygraphbox[mouse.screen] then
           mygraphbox[mouse.screen].visible = not mygraphbox[mouse.screen].visible
        end
    end,
    "Toggle toolbar, statusbar"),

  -- Standard program
  keydoc.group("Standard program"),
  awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end,
    "Open a terminal"),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    "Restart awesome"),
  awful.key({ modkey}, "t", function () awful.util.spawn_with_shell("/home/farseerfc/.config/awesome/input.sh") end,
    "Input"),
  awful.key({ modkey, "Shift" }, "q", awesome.quit,
    "Quit awesome, logout"),
  awful.key({ modkey,  }, "y", function() awful.util.spawn_with_shell("/home/farseerfc/.config/awesome/ydcv-notify.sh") end,
    "Show ydcv on the cursor word"),
  awful.key({ modkey, "Shift"  }, "y", function() awful.util.spawn_with_shell("/home/farseerfc/.config/awesome/translate-notify.sh") end,
    "Show ydcv on the cursor word"),

  awful.key({ modkey   }, "Print", function() awful.util.spawn_with_shell("scrot -s") end,
    "Show ydcv on the cursor word"),
  -- MPC
  keydoc.group("MPD"),
  awful.key({ modkey, altkey}, " ", function() awful.util.spawn("mpc toggle") end,
    "Play/Pause"),
  awful.key({ modkey, altkey}, "Return", function() awful.util.spawn(terminal .. " -e ncmpcpp") end,
    "Ncmpcpp"),
  awful.key({ modkey, altkey}, "Left", function() awful.util.spawn("mpc prev") end,
    "Prev song"),
  awful.key({ modkey, altkey}, "Right", function() awful.util.spawn("mpc next") end,
    "Next song"),
  awful.key({ modkey, altkey}, "Up", function() awful.util.spawn("mpc volume +5") end,
    "Increase volume"),
  awful.key({ modkey, altkey}, "Down", function() awful.util.spawn("mpc volume -5") end,
    "Decrease volume"),
  awful.key({ modkey, altkey}, "s", function() awful.util.spawn("mpc stop") end,
    "Stop MPD"),
  awful.key({ modkey, altkey}, "p", function() awful.util.spawn("mpc play") end,
    "Play MPD"),
  awful.key({ modkey, altkey}, "r", function() awful.util.spawn("mpc random") end,
    "Random"),



  -- Layout manipulation
  keydoc.group("Layout manipulation"),
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1) end,
    "Swap with next window"),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    "Swap with previous window"),
  awful.key({ modkey, }, "Tab", function() awful.screen.focus_relative( 1) end,
    "Give the focus to next screen"),
  awful.key({ modkey, "Shift" }, "Tab", function() awful.screen.focus_relative(-1) end,
    "Give the focus to prev screen"),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    "Jump to urgent window"),
  awful.key({ modkey, "Shift" }, "p",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    "Focus on history window"),

  awful.key({ altkey, }, "Tab",
    function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end,
    "Focus next window"),
  awful.key({ altkey, "Shift" }, "Tab",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end,
    "Focus prev window"),

  awful.key({ modkey, }, "l", function() awful.tag.incmwfact( 0.05) end,
    "Increase master window fact"),
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
    "Decrease master window fact"),
  awful.key({ modkey, }, "k", function() awful.client.incwfact( 0.03) end,
    "Increase slave window fact"),
  awful.key({ modkey, }, "j", function() awful.client.incwfact(-0.03) end,
    "Decrease slave window fact"),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster( 1) end,
    "Increase number of master window"),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end,
    "Decrease number of master window"),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol( 1) end,
    "Increase number of slave column"),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end,
    "Decrease number of slave column"),
  awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end,
    "Switch to next layout"),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end,
    "Switch to prev layout"),

  awful.key({ modkey, "Control" }, "n", awful.client.restore,
    "Restore the window"),

  -- Prompt
  keydoc.group("Run prompts"),
  -- awful.key({ modkey }, "@", function()
  --    scratch.drop(terminal, "bottom", "center", 1.0, 0.40, false)
  --  end,
  --  "Start a terminal in stratch"),

  awful.key({ modkey }, "r", function() mypromptbox[mouse.screen]:run() end,
    "Run prompt of awesome"),

  awful.key({ modkey }, "x",
    function()
      awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end,
    "Run lua prompt"),

  awful.key({ altkey }, "F2", function() menubar.show() end,
    "Run manu prompt"),

  -- }}}

  keydoc.group("Tags managment"),
  awful.key({ modkey, }, "Left", awful.tag.viewprev ,
    "View prev tag"),
  awful.key({ modkey, }, "Right", awful.tag.viewnext ,
    "View next tag"),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    "Restore last tag"),
  -- {{{ Tag 0
  awful.key({ modkey }, 0,
    function()
      local screen = mouse.screen
      if tags[screen][10].selected then
        awful.tag.history.restore(screen)
      elseif tags[screen][10] then
        awful.tag.viewonly(tags[screen][10])
      end
    end,
    "Switch to tag"),
  awful.key({ modkey, "Control" }, 0,
    function()
      local screen = mouse.screen
      if tags[screen][10] then
        tags[screen][10].selected = not tags[screen][10].selected
      end
    end,
    "Add tag to view"),
  awful.key({ modkey, "Shift" }, 0,
    function()
      if client.focus and tags[client.focus.screen][10] then
        awful.client.movetotag(tags[client.focus.screen][10])
      end
    end,
    "Move window to tag"),
  awful.key({ modkey, "Control", "Shift" }, 0,
    function()
      if client.focus and tags[client.focus.screen][10] then
        awful.client.toggletag(tags[client.focus.screen][10])
      end
    end,
    "Toggle window on tag")
  -- }}}
)

local screenpos = {}
screenpos[1]=2
screenpos[2]=1
screenpos[3]=3
screenpos[4]=4
local screennext = {}
screennext[1]=3
screennext[2]=1
screennext[3]=4
screennext[4]=2
local screenprev = {}
screenprev[1]=2
screenprev[2]=4
screenprev[3]=1
screenprev[4]=3

clientkeys = awful.util.table.join(
  keydoc.group("Window Keys"),
  awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end,
    "Toggle fullscreen"),
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
    "Kill client"),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle ,
    "Toggle float"),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    "Swap with master"),
  awful.key({ modkey, }, "o", function(c) awful.client.movetoscreen(c,screennext[c.screen]) end ,
    "Move window to next screen"),
  awful.key({ modkey, }, "p", function(c) awful.client.movetoscreen(c,screenprev[c.screen]) end ,
    "Move window to prev screen"),
  awful.key({ modkey, "Shift"   }, "F1", function (c) 
      awful.client.movetoscreen(c, screenpos[1]) 
      awful.screen.focus(screenpos[1]) 
    end,  "Move window to the screen"),
  awful.key({ modkey, "Shift"   }, "F2", function (c) 
      awful.client.movetoscreen(c, screenpos[2]) 
      awful.screen.focus(screenpos[2]) 
    end),
  awful.key({ modkey, "Shift"   }, "F3", function (c) 
      awful.client.movetoscreen(c, screenpos[3]) 
      awful.screen.focus(screenpos[3]) 
    end),
  awful.key({ modkey, "Shift"   }, "F4", function (c) 
      awful.client.movetoscreen(c, screenpos[4]) 
      awful.screen.focus(screenpos[4]) 
    end),
  awful.key({ modkey,           }, "F1", function () 
      awful.screen.focus(screenpos[1]) 
    end, "Move focus to the screen"),
  awful.key({ modkey,           }, "F2", function () 
      awful.screen.focus(screenpos[2]) 
    end),
  awful.key({ modkey,           }, "F3", function () 
      awful.screen.focus(screenpos[3]) 
    end),
  awful.key({ modkey,           }, "F4", function () 
      awful.screen.focus(screenpos[4]) 
  end),
  awful.key({ modkey,"Control" }, "t", function(c) c.ontop = not c.ontop end,
    "Toggle top most"),
  awful.key({ modkey, }, "n",
    function(c)
      c.minimized = true
    end,
    "Minimize"),

  -- Maximize
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical = not c.maximized_vertical
    end,
    "Maximize")
)

keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber))
end

for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i].selected then
          awful.tag.history.restore(screen)
        elseif tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.toggletag(tags[client.focus.screen][i])
        end
      end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  { rule = { },
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = clientkeys,
      buttons = clientbuttons } },
  { rule = { class = "MPlayer" },
    properties = { floating = true } },
  { rule = { class = "Skype" },
    properties = { floating = true } },
  { rule = { class = "Godesk" },
    properties = { floating = true } },
  { rule = { class = "pinentry" },
    properties = { floating = true } },
  { rule = { class = "Exe" },
    properties = { floating = true } },
  -- { rule = { class = "Firefox" },
  --   properties = { tag = tags[1][2] } },
  { rule = { class = "Firefox", instance = "Download" },
    properties = { floating = true } },
  { rule = { class = "Plugin-container" },
    properties = { floating = true } },
  { rule = { class = "net-minecraft-launchwrapper-Launch"},
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Browser" },
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Toplevel" },
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Places" },
    properties = { floating = true } },
  { rule = { class = "Thunderbird", instance = "Mail" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Calendar" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Msgcompose" },
    properties = { floating = true, above = true } },
  { rule = { class = "Gimp-2.8" },
    properties = { floating = true } },
  { rule = { class = "Plasma-desktop" },
    properties = { floating = true } }
}
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(c, startup)
    c.size_hints_honor = false

    -- Sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
          client.focus = c
        end
      end)

    if not startup then
      -- Set the windows at the slave
      awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    -- if c.type == "dialog" then
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))

      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      local title = awful.titlebar.widget.titlewidget(c)
      title:buttons(awful.util.table.join(
          awful.button({ }, 1, function()
              client.focus = c
              c:raise()
              awful.mouse.client.move(c)
            end),
          awful.button({ }, 3, function()
              client.focus = c
              c:raise()
              awful.mouse.client.resize(c)
            end)
      ))

      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(title)

      awful.titlebar(c):set_widget(layout)
    end
  end)

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
