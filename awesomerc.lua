-------------------------------------------------------------------------------
-- @file awesomerc.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------
-- {{{1 Tables

local tags      = { }
local statusbar = { }
local promptbox = { }
local taglist   = { }
local tasklist  = { }
local layoutbox = { }
local settings  = { }

-- {{{1 Imports

-- Standard awesome libraries
require('awful')
require('beautiful')
-- Notification library
require('naughty')
-- My own functions
require('functions')

-- {{{1 Variables

settings.modkey     = 'Mod4'
settings.term       = 'urxvtc'
settings.browser    = 'firefox-nightly'
settings.music      = "wine ~/.wine/drive_c/Program\\ Files/Spotify/spotify.exe"
settings.theme_path = awful.util.getdir('config')..'/themes/bluish'

-- Actually load theme
beautiful.init(settings.theme_path)

settings.layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

settings.app_rules =
{  -- Class         Instance        Title               Screen      Tag       Floating
    { 'xterm',      nil,            nil,                1           , 9,      nil  },
    { 'Firefox',    nil,            nil,                1           , 2,      nil  },
    { 'Firefox',    'Download',     nil,                1           , nil,    true },
    { 'Firefox',    'Places',       nil,                1           , nil,    true },
    { 'MPlayer',    nil,            nil,                1           , 4,      true },
    { nil,          nil,            'VLC media player', 1           , 4,      true },
    { nil,          'spotify.exe',  'Spotify',          1           , 4,      true }
}

settings.tag_properties =
{
    { name = '1.m', layout = settings.layouts[1] },
    { name = '2.w', layout = settings.layouts[3] },
    { name = '3.d', layout = settings.layouts[1] },
    { name = '4',   layout = settings.layouts[1] },
    { name = '5',   layout = settings.layouts[1] },
    { name = '6',   layout = settings.layouts[1] },
    { name = '7',   layout = settings.layouts[1] },
    { name = '8',   layout = settings.layouts[1] },
    { name = '9',   layout = settings.layouts[1] }
}


-- {{{1 Tags

for s = 1, screen.count() do
    tags[s] = { }
    for i, v in ipairs(settings.tag_properties) do
        tags[s][i] = tag(v.name)
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], 'layout', v.layout)
        awful.tag.setproperty(tags[s][i], 'mwfact', v.mwfact)
        awful.tag.setproperty(tags[s][i], 'nmaster', v.nmaster)
        awful.tag.setproperty(tags[s][i], 'ncols', v.ncols)
        awful.tag.setproperty(tags[s][i], 'icon', v.icon)
    end
    tags[s][1].selected = true
end

-- {{{1 Widgets

local awesome_submenu =
{
    { 'restart', awesome.restart },
    { 'quit',    awesome.quit    }
}

local main_menu = awful.menu.new(
{
    items =
    {
        { 'terminal', settings.term     },
        { 'Firefox',  settings.browser  },
        { 'Spotify',  settings.music    },
        { 'Awesome',  awesome_submenu   }
    }
})

systray = widget({ type = 'systray', align = 'right' })
cpubox  = widget({ type = 'textbox', align = 'right' })
loadbox = widget({ type = 'textbox', align = 'right' })
membox  = widget({ type = 'textbox', align = 'right' })
clockbox = widget({ type = 'textbox', align = 'right' })
batbox  = widget({ type = 'textbox', align = 'right' })
volbox  = widget({ type = 'textbox', align = 'right' })

taglist.buttons =
{
    button({        }, 1, awful.tag.viewonly),
    button({ settings.modkey }, 1, awful.client.movetotag),
    button({        }, 3, function (tag) tag.selected = not tag.selected end),
    button({ settings.modkey }, 3, awful.client.toggletag),
    button({        }, 4, awful.tag.viewnext),
    button({        }, 5, awful.tag.viewprev) 
}
tasklist.buttons =
{
    button({ }, 1, function (c) client.focus = c; c:raise() end),
    button({ }, 4, function () awful.client.focus.byidx(1) end),
    button({ }, 5, function () awful.client.focus.byidx(-1) end) 
}

for s = 1, screen.count() do
    promptbox[s] = widget({ type = 'textbox', align = 'left' })
    layoutbox[s] = widget({ type = 'textbox', align = 'left' })
    layoutbox[s]:buttons(
    {
        button({ }, 1, function () awful.layout.inc(settings.layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(settings.layouts, -1) end),
        button({ }, 4, function () awful.layout.inc(settings.layouts, 1) end),
        button({ }, 5, function () awful.layout.inc(settings.layouts, -1) end)
    })
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.noempty, taglist.buttons)
    tasklist[s] = awful.widget.tasklist.new(function(c)
        return awful.widget.tasklist.label.currenttags(c, s)
    end, tasklist.buttons)

    statusbar[s] = wibox(
    {
        position = 'top',
        height = '14',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal,
    })
    statusbar[s].widgets =
    {
        taglist[s],
        layoutbox[s],
        spsep,
        promptbox[s],
        tasklist[s],
        cpubox,
        loadbox,
        membox,
        batbox,
        clockbox,
        volbox,
        s == 1 and systray or nil
    }
    statusbar[s].screen = s
end

-- {{{1 Binds

root.buttons(
{
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})

local globalkeys =
{
    key({ settings.modkey            }, 'Left',  awful.tag.viewprev),
    key({ settings.modkey            }, 'Right', awful.tag.viewnext),
    key({ settings.modkey            }, 'x',     function () awful.util.spawn(settings.term) end),
    key({ settings.modkey            }, 'f',     function () awful.util.spawn(settings.browser) end),
    key({ settings.modkey            }, 'a',     function () main_menu:toggle() end),
    key({ settings.modkey, 'Control' }, 'r',     awesome.restart),
    key({ settings.modkey, 'Shift'   }, 'q',     awesome.quit),
    key({ settings.modkey            }, 'j',     function ()
        awful.client.focus.byidx( 1)
        if client.focus then
            client.focus:raise()
        end
    end),
    key({ settings.modkey            }, 'k',     function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end),
    key({ settings.modkey            }, 'Tab',   function ()
        local allclients = awful.client.visible(client.focus.screen)
        for i,v in ipairs(allclients) do
            if allclients[i+1] then
                allclients[i+1]:swap(v)
            end
        end
        awful.client.focus.byidx(-1)
    end),
    key({ settings.modkey            }, 'l',     function () awful.tag.incmwfact(0.025) end),
    key({ settings.modkey            }, 'h',     function () awful.tag.incmwfact(-0.025) end),
    key({ settings.modkey, 'Shift'   }, 'h',     function () awful.client.incwfact(0.05) end),
    key({ settings.modkey, 'Shift'   }, 'l',     function () awful.client.incwfact(-0.05) end),
    key({ settings.modkey, 'Control' }, 'h',     function () awful.tag.incnmaster(1) end),
    key({ settings.modkey, 'Control' }, 'l',     function () awful.tag.incnmaster(-1) end),
    key({ settings.modkey            }, 'space', function () awful.layout.inc(settings.layouts, 1) end),
    key({ settings.modkey, 'Shift'   }, 'space', function () awful.layout.inc(settings.layouts, -1) end),
    key({ settings.modkey }, 'r',function ()
        awful.prompt.run({ prompt = ' Run: ' },
        promptbox[mouse.screen], awful.util.spawn,
        awful.completion.shell, awful.util.getdir('cache')..'/history')
    end),
    key({ settings.modkey }, 'F4', function ()
        awful.prompt.run({ prompt = ' Run Lua: ' },
        promptbox[mouse.screen], awful.util.eval,
        awful.prompt.bash, awful.util.getdir('cache')..'/history_eval')
    end),
    key({                   }, '#121',  function () awful.util.spawn('rvol -t') end),
    key({                   }, '#122',  function () awful.util.spawn('rvol -d 2') end),
    key({                   }, '#123',  function () awful.util.spawn('rvol -i 2') end)
}

local clientkeys =
{
    key({ settings.modkey            }, "c",     function (c) c:kill() end),
    key({ settings.modkey, "Control" }, "space", awful.client.floating.toggle),
    key({ settings.modkey, "Shift"   }, "r",     function (c) c:redraw() end),
    key({ settings.modkey            }, "t",     awful.client.togglemarked),
    key({ settings.modkey            }, "m",     function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
}

-- Using keynumbers instead of 1->9 because of my stupid azerty keyboard
local key_list = { '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18' }
local keynumber = table.getn(key_list)
for i = 1, keynumber do
    table.insert(globalkeys, key({ settings.modkey }, key_list[i], function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end))
    table.insert(globalkeys, key({ settings.modkey, 'Control' }, key_list[i], function ()
        local screen = mouse.screen
        if tags[screen][i] then
            tags[screen][i].selected = not tags[screen][i].selected
        end
    end))
    table.insert(globalkeys, key({ settings.modkey, 'Shift'   }, key_list[i], function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end))
    table.insert(globalkeys, key({ settings.modkey, 'Control', 'Shift' }, key_list[i], function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
end

root.keys(globalkeys)

-- {{{1 Hooks

-- Gets executed when focusing a client
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Gets executed when unfocusing a client
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Gets executed when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Gets executed when unmarking a client
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Gets executed when the mouse enters a client
awful.hooks.mouse_enter.register(function (c)
    if awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Gets executed when a new client appears
awful.hooks.manage.register(function (c)
    c:keys(clientkeys)

    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    c:buttons(
    {
        button({                   }, 1, function (c) client.focus = c; c:raise() end),
        button({ settings.modkey            }, 1, awful.mouse.client.move),
        button({ settings.modkey, 'Control' }, 1, awful.mouse.client.dragtotag.widget),
        button({ settings.modkey            }, 3, awful.mouse.client.resize)
    })

    -- Prevent new clients from becoming master
    awful.client.setslave(c)

    -- Check application->screen/tag mappings and floating state
    local isfloat, isscreen, istag
    for index, rule in pairs(settings.app_rules) do
        if (((rule[1] == nil) or (c.class and c.class == rule[1]))
        and ((rule[2] == nil) or (c.instance and c.instance == rule[2]))
        and ((rule[3] == nil) or (c.name and string.find(c.name, rule[3], 1, true)))) then
            isscreen = rule[4]
            istag = rule[5]
            isfloat = rule[6]
        end
    end
 
    if isscreen then
        awful.client.movetoscreen(c, isscreen)
        c.screen = isscreen
    else
        isscreen = mouse.screen
        c.screen = isscreen
    end
 
    if istag then
        awful.client.movetotag(tags[isscreen][istag], c)
        c.tag = istag
    end
 
    if isfloat then
      awful.client.floating.set(c, isfloat)
    end

    client.focus = c

    -- Ignore size hints usually given out by terminals (prevent gaps between windows)
    c.size_hints_honor = false

    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end)

-- Gets executed when arranging the screen (as in, tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout then
        layoutbox[screen].text = functions.set_fg(beautiful.fg_focus, ' .')..layout..functions.set_fg(beautiful.fg_focus, '. ')
    else
        layoutbox[screen].text = nil
    end

    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end

    local tiledclients = awful.client.tiled(screen)
    if (#tiledclients == 0) then return end
    if (#tiledclients == 1) or (layout == 'max') then
        tiledclients[1].border_width = 0
    else
        for unused, current in pairs(tiledclients) do
            current.border_width = beautiful.border_width
            current:lower()
        end
    end
end)

-- Runonce
functions.cpu(cpubox)
functions.loadavg(loadbox)
functions.memory(membox)
functions.battery(batbox, 'BAT1')
functions.clock(clockbox, '%B %d %H:%M')
functions.volume(volbox, 'Master')

-- 10 seconds
awful.hooks.timer.register(10, function ()
    functions.cpu(cpubox)
    functions.loadavg(loadbox)
end)

-- 20 seconds
awful.hooks.timer.register(20, function ()
    functions.memory(membox)
    functions.battery(batbox, 'BAT1')
    functions.volume(volbox, 'Master')
end)

-- 1 minute
awful.hooks.timer.register(60, function ()
    functions.clock(clockbox, '%B %d %H:%M')
end)

io.stderr:write("\n\rAwesome loaded at "..os.date("%B %d, %H:%M").."\r\n\n")
