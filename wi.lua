-----------------------
-- AwesomeWM widgets --
--      3.5-rc1      --
--   <tdy@gmx.com>   --
-----------------------

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local vicious = require("vicious")
local naughty = require("naughty")
local drop = require("drop")

terminal = "termite"
graphwidth  = 64
cpugraphwidth  = 32
graphheight = 13
pctwidth    = 32
netwidth    = 50
mpdwidth    = 365

-- {{{ SPACERS
space = wibox.widget.textbox()
space:set_text("  ")

comma = wibox.widget.textbox()
comma:set_markup(",")

pipe = wibox.widget.textbox()
pipe:set_markup("<span color='" .. beautiful.bg_em .. "'>|</span>")

tab = wibox.widget.textbox()
tab:set_text("         ")

volspace = wibox.widget.textbox()
volspace:set_text(" ")
-- }}}

--{{{ textclock
local calendar = nil
local offset = 0

function remove_calendar()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function add_calendar(inc_offset)
   local save_offset = offset
   remove_calendar()
   offset = save_offset + inc_offset
   local datespec = os.date("*t")
   datespec = datespec.year * 12 + datespec.month - 1 + offset
   datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
   local cal = awful.util.pread("cal -m " .. datespec)
   cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
   calendar = naughty.notify({
      text = string.format('<span font_desc="%s">%s</span>', "Droid Sans Mono 30", cal),
      position = "bottom_right", timeout = 0, hover_timeout = 0.5,
      width = 600
   })
end

mytextclock = awful.widget.textclock("<span color='" .. beautiful.fg_em .. "'>%a %m/%d</span> @ %I:%M %p")
mytextclock:connect_signal("mouse::enter", function() add_calendar(0) end)
mytextclock:connect_signal("mouse::leave", remove_calendar)
mytextclock:buttons(awful.util.table.join(
         awful.button({ }, 4, function() add_calendar(-1) end),
         awful.button({ }, 5, function() add_calendar(1) end)
   ))



--}}}

-- {{{ PROCESSOR

htop = terminal .. " -e htop"

-- Cache
vicious.cache(vicious.widgets.cpu)
vicious.cache(vicious.widgets.cpuinf)

-- Core 0 freq
cpufreq = wibox.widget.textbox()
vicious.register(cpufreq, vicious.widgets.cpuinf, function(widget, args)
   return string.format("<span color='" .. beautiful.fg_em .. "'>cpu</span>%1.1fGHz", args["{cpu0 ghz}"])
end, 3000)
cpufreq:connect_signal("mouse::enter", function () drop.show(htop) end )
cpufreq:connect_signal("mouse::leave", function () drop.hide(htop) end )

cpugraph = {}
cpupct = {}
-- Core 0 graph
for c= 1,8 do
  cpugraph[c] = awful.widget.graph()
  cpugraph[c]:set_width(cpugraphwidth):set_height(graphheight)
  cpugraph[c]:set_border_color(nil)
  cpugraph[c]:set_border_color(beautiful.bg_widget)
  cpugraph[c]:set_background_color(beautiful.bg_widget)
  cpugraph[c]:set_color({
    type = "linear",
    from = { 0, graphheight },
    to = { 0, 0 },
    stops = {
      { 0, beautiful.fg_widget },
      { 0.25, beautiful.fg_center_widget },
      { 1, beautiful.fg_end_widget }
    }})
  vicious.register(cpugraph[c], vicious.widgets.cpu, "$"..(c+1))
  
  cpugraph[c]:connect_signal("mouse::enter", function () drop.show(htop) end )
  cpugraph[c]:connect_signal("mouse::leave", function () drop.hide(htop) end )

  -- Core 0 %
  cpupct[c] = wibox.widget.textbox()
  cpupct[c].fit = function(box,w,h)
    local w,h = wibox.widget.textbox.fit(box,w,h) return math.max(pctwidth,w),h
  end
  vicious.register(cpupct[c], vicious.widgets.cpu, "$"..(c+1).."%", 2)
  cpupct[c]:connect_signal("mouse::enter", function () drop.show(htop) end )
  cpupct[c]:connect_signal("mouse::leave", function () drop.hide(htop) end )
end 

-- {{{ MEMORY
-- Cache
vicious.cache(vicious.widgets.mem)

-- Ram used
-- Ram bar

local free = nil
function remove_free()
   if free ~= nil then
      naughty.destroy(free)
      free = nil
   end
end

function add_free()
   remove_free()
   local cal = awful.util.pread("free -m")
   -- cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
   free = naughty.notify({
      text = string.format('<span font_desc="%s">%s</span>', "monospace 16", cal),
      position = "bottom_left", timeout = 0, hover_timeout = 0.5,
      width = 1000 -- ,screen=2
   })
end

memused = wibox.widget.textbox()
vicious.register(memused, vicious.widgets.mem,
  "<span color='" .. beautiful.fg_em .. "'>內 </span>$2MB ", 5)
memused:connect_signal("mouse::enter", add_free)
memused:connect_signal("mouse::leave", remove_free)

membar = awful.widget.progressbar()
membar:set_vertical(false):set_width(graphwidth):set_height(graphheight)
membar:set_ticks(false):set_ticks_size(2)
membar:set_border_color(nil)
membar:set_background_color(beautiful.bg_widget)
membar:set_color({
  type = "linear",
  from = { 0, 0 },
  to = { graphwidth, 0 },
  stops = {
    { 0, beautiful.fg_widget },
    { 0.25, beautiful.fg_center_widget },
    { 1, beautiful.fg_end_widget }
  }})
vicious.register(membar, vicious.widgets.mem, "$1", 13)
membar:connect_signal("mouse::enter", add_free)
membar:connect_signal("mouse::leave", remove_free)

-- Ram %
mempct = wibox.widget.textbox()
mempct.width = pctwidth
vicious.register(mempct, vicious.widgets.mem, "$1%", 5)
mempct:connect_signal("mouse::enter", add_free)
mempct:connect_signal("mouse::leave", remove_free)

-- Swap bar
dstat = terminal .. " -e dstat"

swapbar = awful.widget.progressbar()
swapbar:set_vertical(false):set_width(graphwidth):set_height(graphheight)
swapbar:set_ticks(false):set_ticks_size(2)
swapbar:set_border_color(nil)
swapbar:set_background_color(beautiful.bg_widget)
swapbar:set_color({
  type = "linear",
  from = { 0, 0 },
  to = { graphwidth, 0 },
  stops = {
    { 0, beautiful.fg_widget },
    { 0.25, beautiful.fg_center_widget },
    { 1, beautiful.fg_end_widget }
  }})
vicious.register(swapbar, vicious.widgets.mem, "$5", 13)
swapbar:connect_signal("mouse::enter", function () drop.show(dstat) end )
swapbar:connect_signal("mouse::leave", function () drop.hide(dstat) end )


-- Swap %
swappct = wibox.widget.textbox()
swappct.width = pctwidth
vicious.register(swappct, vicious.widgets.mem,
  "<span color='" .. beautiful.fg_em .. "'>交 </span>$5%", 5)
swappct:connect_signal("mouse::enter", function () drop.show(dstat) end )
swappct:connect_signal("mouse::leave", function () drop.hide(dstat) end )

-- {{{ FILESYSTEM
-- Cache
vicious.cache(vicious.widgets.fs)

-- Root used

local df = nil
function remove_df()
   if df ~= nil then
      naughty.destroy(df)
      df = nil
   end
end

function add_df()
   remove_df()
   local cal = awful.util.pread("df -h")
   cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
   df = naughty.notify({
      text = string.format('<span font_desc="%s">%s</span>', "monospace 23", cal),
      position = "bottom_right", timeout = 0, hover_timeout = 0.5,
      width = 1020 --,screen=2
   })
end


rootfsused = wibox.widget.textbox()
vicious.register(rootfsused, vicious.widgets.fs,
  "<span color='" .. beautiful.fg_em .. "'>外 </span>${/ used_gb}GB ", 97)
rootfsused:connect_signal("mouse::enter", add_df)
rootfsused:connect_signal("mouse::leave", remove_df)


-- Root bar
rootfsbar = awful.widget.progressbar()
rootfsbar:set_vertical(false):set_width(graphwidth):set_height(graphheight)
rootfsbar:set_ticks(false):set_ticks_size(2)
rootfsbar:set_border_color(nil)
rootfsbar:set_background_color(beautiful.bg_widget)
rootfsbar:set_color({
  type = "linear",
  from = { 0, 0 },
  to = { graphwidth, 0 },
  stops = {
    { 0, beautiful.fg_widget },
    { 0.25, beautiful.fg_center_widget },
    { 1, beautiful.fg_end_widget }
  }})
vicious.register(rootfsbar, vicious.widgets.fs, "${/ used_p}", 97)
rootfsbar:connect_signal("mouse::enter", add_df)
rootfsbar:connect_signal("mouse::leave", remove_df)

-- Root %
rootfspct = wibox.widget.textbox()
rootfspct.width = pctwidth
vicious.register(rootfspct, vicious.widgets.fs, "${/ used_p}%", 97)
rootfspct:connect_signal("mouse::enter", add_df)
rootfspct:connect_signal("mouse::leave", remove_df)
-- }}}

-- {{{ NETWORK
-- Cache
vicious.cache(vicious.widgets.net)

local net_naughty = nil
function remove_net()
   if net_naughty ~= nil then
      naughty.destroy(net_naughty)
      net_naughty = nil
   end
end

function add_net()
   remove_net()
   local cal = awful.util.pread("netstat -ntauple 2>&1 | tail -n+4")
   cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
   net_naughty = naughty.notify({
      text = string.format('<span font_desc="%s">%s</span>', "monospace 11", cal),
      position = "bottom_left", timeout = 0, hover_timeout = 0.5,
      width = 1200 --,screen=4
   })
end


-- Up graph
upgraph = awful.widget.graph()
upgraph:set_width(graphwidth):set_height(graphheight)
upgraph:set_border_color(nil)
upgraph:set_background_color(beautiful.bg_widget)
upgraph:set_color({
  type = "linear",
  from = { 0, graphheight },
  to = { 0, 0 },
  stops = {
    { 0, beautiful.fg_widget },
    { 0.25, beautiful.fg_center_widget },
    { 1, beautiful.fg_end_widget }
  }})
vicious.register(upgraph, vicious.widgets.net, "${eth0 up_kb}")
upgraph:connect_signal("mouse::enter", add_net)
upgraph:connect_signal("mouse::leave", remove_net)
-- TX
txwidget = wibox.widget.textbox()
vicious.register(txwidget, vicious.widgets.net,
  "<span color='" .. beautiful.fg_em .. "'>上 </span>${eth0 tx_mb}MB ", 19)
txwidget:connect_signal("mouse::enter", add_net)
txwidget:connect_signal("mouse::leave", remove_net)

-- Up speed
upwidget = wibox.widget.textbox()
upwidget.fit = function(box,w,h)
  local w,h = wibox.widget.textbox.fit(box,w,h) return math.max(netwidth,w),h
end
vicious.register(upwidget, vicious.widgets.net, "${eth1 up_kb}", 2)
upwidget:connect_signal("mouse::enter", add_net)
upwidget:connect_signal("mouse::leave", remove_net)

-- Down graph
downgraph = awful.widget.graph()
downgraph:set_width(graphwidth):set_height(graphheight)
downgraph:set_border_color(nil)
downgraph:set_background_color(beautiful.bg_widget)
downgraph:set_color({
  type = "linear",
  from = { 0, graphheight },
  to = { 0, 0 },
  stops = {
    { 0, beautiful.fg_widget },
    { 0.25, beautiful.fg_center_widget },
    { 1, beautiful.fg_end_widget }
  }})
vicious.register(downgraph, vicious.widgets.net, "${eth1 down_kb}")
downgraph:connect_signal("mouse::enter", add_net)
downgraph:connect_signal("mouse::leave", remove_net)

-- RX
rxwidget = wibox.widget.textbox()
vicious.register(rxwidget, vicious.widgets.net,
  "<span color='" .. beautiful.fg_em .. "'>下 </span>${eth0 rx_mb}MB ", 17)
rxwidget:connect_signal("mouse::enter", add_net)
rxwidget:connect_signal("mouse::leave", remove_net)

-- Down speed
downwidget = wibox.widget.textbox()
downwidget.fit = function(box,w,h)
  local w,h = wibox.widget.textbox.fit(box,w,h) return math.max(netwidth,w),h
end
vicious.register(downwidget, vicious.widgets.net, "${eth0 down_kb}", 2)
downwidget:connect_signal("mouse::enter", add_net)
downwidget:connect_signal("mouse::leave", remove_net)
-- }}}

-- {{{ WEATHER
weather = wibox.widget.textbox()
vicious.register(weather, vicious.widgets.weather,
  "<span color='" .. beautiful.fg_em .. "'>${sky}</span> ${tempc}°C ",
  1501, "RJOO")
weather:buttons(awful.util.table.join(awful.button({ }, 1, function()
  vicious.force({ weather })
end)))
-- }}}

-- {{{ PACMAN
-- Icon
pacicon = wibox.widget.imagebox()
pacicon:set_image(beautiful.widget_pac)

-- Upgrades
pacwidget = wibox.widget.textbox()
vicious.register(pacwidget, vicious.widgets.pkg, function(widget, args)
  if args[1] > 0 then
    pacicon:set_image(beautiful.widget_pacnew)
  else
    pacicon:set_image(beautiful.widget_pac)
  end

  return args[1]
end, 1801, "Arch S") -- Arch S for ignorepkg

-- Buttons
function popup_pac()
  local pac_updates = ""
  local f = io.popen("pacman -Sup --dbpath /tmp/pacsync")
  if f then
    pac_updates = f:read("*a"):match(".*/(.*)-.*\n$")
  end
  f:close()

  if not pac_updates then
    pac_updates = "System is up to date"
  end

  naughty.notify { text = pac_updates }
end
pacwidget:buttons(awful.util.table.join(awful.button({ }, 1, popup_pac)))
pacicon:buttons(pacwidget:buttons())
-- }}}

-- {{{ Mpd
-- Icon
ncmpcpp = terminal .. " -e ncmpcpp"

mpdicon = wibox.widget.imagebox()
mpdicon:set_image(beautiful.widget_mpd)
mpdicon:connect_signal("mouse::enter", function () drop.show(ncmpcpp) end )
mpdicon:connect_signal("mouse::leave", function () drop.hide(ncmpcpp) end )

-- Song info
mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd, function(widget, args)
  mpdicon:set_image(beautiful.widget_mpd)
  if args["{state}"] == "Stop" then 
      return " - "
  else 
      mpdicon:set_image(beautiful.widget_play)
      return args["{Artist}"]..' - '.. args["{Title}"]
  end
end, 3)

mpdwidget:connect_signal("mouse::enter", function () drop.show(ncmpcpp) end )
mpdwidget:connect_signal("mouse::leave", function () drop.hide(ncmpcpp) end )
-- Buttons
mpdwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function() awful.util.spawn("mpc toggle")  end),
  awful.button({ }, 4, function() awful.util.spawn("mpc prev")  end),
  awful.button({ }, 5, function() awful.util.spawn("mpc next")  end)
))
mpdicon:buttons(mpdwidget:buttons())
-- }}}

-- {{{ VOLUME
-- Cache
alsamixer = terminal .. " -e alsamixer"

vicious.cache(vicious.widgets.volume)

-- Icon
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volicon:connect_signal("mouse::enter", function () drop.show(alsamixer) end )
volicon:connect_signal("mouse::leave", function () drop.hide(alsamixer) end )

-- Volume %
volpct = wibox.widget.textbox()
vicious.register(volpct, vicious.widgets.volume, "$1%", nil, "Master")
volpct:connect_signal("mouse::enter", function () drop.show(alsamixer) end )
volpct:connect_signal("mouse::leave", function () drop.hide(alsamixer) end )
-- Buttons
volicon:buttons(awful.util.table.join(
  awful.button({ }, 1,
    function() awful.util.spawn_with_shell("amixer -q set Master toggle") end),
  awful.button({ }, 4,
    function() awful.util.spawn_with_shell("amixer -q set Master 3+% unmute") end),
  awful.button({ }, 5,
    function() awful.util.spawn_with_shell("amixer -q set Master 3-% unmute") end)
))
volpct:buttons(volicon:buttons())
volspace:buttons(volicon:buttons())
-- }}}

-- {{{ BATTERY
-- Battery attributes
local bat_state  = ""
local bat_charge = 0
local bat_time   = 0
local blink      = true

-- Icon
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batfull)

-- Charge %
batpct = wibox.widget.textbox()
vicious.register(batpct, vicious.widgets.bat, function(widget, args)
  bat_state  = args[1]
  bat_charge = args[2]
  bat_time   = args[3]

  if args[1] == "-" then
    if bat_charge > 70 then
      baticon:set_image(beautiful.widget_batfull)
    elseif bat_charge > 30 then
      baticon:set_image(beautiful.widget_batmed)
    elseif bat_charge > 10 then
      baticon:set_image(beautiful.widget_batlow)
    else
      baticon:set_image(beautiful.widget_batempty)
    end
  else
    baticon:set_image(beautiful.widget_ac)
    if args[1] == "+" then
      blink = not blink
      if blink then
        baticon:set_image(beautiful.widget_acblink)
      end
    end
  end

  return args[2] .. "%"
end, nil, "BAT0")

-- Buttons
function popup_bat()
  local state = ""
  if bat_state == "↯" then
    state = "Full"
  elseif bat_state == "↯" then
    state = "Charged"
  elseif bat_state == "+" then
    state = "Charging"
  elseif bat_state == "-" then
    state = "Discharging"
  elseif bat_state == "⌁" then
    state = "Not charging"
  else
    state = "Unknown"
  end

  naughty.notify { text = "Charge : " .. bat_charge .. "%\nState  : " .. state ..
    " (" .. bat_time .. ")", timeout = 5, hover_timeout = 0.5 }
end
batpct:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
baticon:buttons(batpct:buttons())
-- }}}
