-------------------------------------------------
-- Logout widget for Awesome Window Manager
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/logout-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local capi = {keygrabber = keygrabber }
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awesomebuttons = require("awesome-buttons.awesome-buttons")
local colors = require('utils.colors')

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. '/.config/awesome/awesome-wm-widgets/logout-popup-widget'


local w = wibox {
    bg = colors.bg,
    max_widget_size = 500,
    ontop = true,
    height = 500,
    width = 130,
    border_width = 5,
    border_color = colors.polar.lightest
}

local action = wibox.widget {
    text = ' ',
    widget = wibox.widget.textbox
}

local phrase_widget = wibox.widget{
    align  = 'center',
    widget = wibox.widget.textbox
}

local function create_button(icon_name, action_name, accent_color, label_color, onclick, icon_size, icon_margin)

    local button = awesomebuttons.with_icon {
        type = 'basic',
        icon = icon_name,
        color = accent_color,
        icon_size = icon_size,
        icon_margin = icon_margin,
        onclick = function()
            onclick()
            w.visible = false
            capi.keygrabber.stop()
        end
    }
    button:connect_signal("mouse::enter", function()
            action:set_markup('<span color="' .. label_color .. '">' .. action_name .. '</span>')
        end)

    button:connect_signal("mouse::leave", function() action:set_markup('<span> </span>') end)

    return button
end

local function launch(args)
    args = args or {}

    local bg_color = args.bg_color or beautiful.bg_normal
    local accent_color = args.accent_color or beautiful.bg_focus
    local text_color = args.text_color or beautiful.fg_normal
    local label_color = args.label_color or colors.green
    local phrases = args.phrases or {}--{'Bye bye!', "It's been a large journey, huh?"}
    local icon_size = args.icon_size or 40
    local icon_margin = args.icon_margin or 16

    local onlogout = args.onlogout or function () awesome.quit() end
    local onlock = args.onlock or function() awful.spawn.with_shell("i3lock") end
    local onreboot = args.onreboot or function() awful.spawn.with_shell("/sbin/reboot") end
    local onsuspend = args.onsuspend or function() awful.spawn.with_shell("systemctl suspend") end
    local onpoweroff = args.onpoweroff or function() awful.spawn.with_shell("/sbin/shutdown now") end

    w:set_bg(bg_color)
    if #phrases > 0 then
        phrase_widget:set_markup(
            '<span color="'.. text_color .. '" size="20000">' .. phrases[ math.random( #phrases ) ] .. '</span>')
    end

    w:setup {
        {
            phrase_widget,
            {
                {
                    create_button('log-out', 'Cerrar sesión (l)',
                        accent_color, label_color, onlogout, icon_size, icon_margin),
                    create_button('lock', 'Bloquear pantalla (k)',
                        accent_color, label_color, onlock, icon_size, icon_margin),
                    create_button('refresh-cw', 'Reiniciar (r)',
                        accent_color, label_color, onreboot, icon_size, icon_margin),
                    create_button('moon', 'Suspender (u)',
                        accent_color, label_color, onsuspend, icon_size, icon_margin),
                    create_button('power', 'Apagar (s)',
                        accent_color, label_color, onpoweroff, icon_size, icon_margin),
                    id = 'buttons',
                    spacing = 8,
                    layout = wibox.layout.fixed.vertical
                },
                valigh = 'center',
                layout = wibox.container.place
            },
            {
                action,
                haligh = 'center',
                layout = wibox.container.place
            },
            spacing = 32,
            layout = wibox.layout.fixed.vertical
        },
        id = 'a',
        shape_border_width = 1,
        valigh = 'center',
        layout = wibox.container.place
    }
    s = mouse.screen
    w.screen = s
    w.x = s.workarea.x + (s.workarea.width - (w.width)-30) 
    w.y = s.workarea.y + 25  
    w.visible = true

    --awful.placement.centered(w)
    capi.keygrabber.run(function(_, key, event)
        if event == "release" then return end
        if key then
            if key == 'Escape' then
                phrase_widget:set_text('')
                capi.keygrabber.stop()
                w.visible = false
            elseif key == 's' then onpoweroff()
            elseif key == 'r' then onreboot()
            elseif key == 'u' then onsuspend()
            elseif key == 'k' then onlock()
            elseif key == 'l' then onlogout()
            end

            if key == 'Escape' or string.match("srukl", key) then
                phrase_widget:set_text('')
                capi.keygrabber.stop()
                w.visible = false
            end
        end
    end)
end

local function widget(args)
    local icon = args.icon or WIDGET_DIR .. '/power.svg'

    local res = wibox.widget {
        {
            {
                image = icon,
                widget = wibox.widget.imagebox
            },
            margins = 4,
            layout = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal,
    }

    res:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if w.visible then
                    phrase_widget:set_text('')
                    capi.keygrabber.stop()
                    w.visible = false
                else
                    launch(args)
                end
            end)
        ))

    return res

end

return {
    launch = launch,
    widget = widget
}
