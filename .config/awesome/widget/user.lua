local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local create_profile = function()
    local profile_imagebox = wibox.widget {
        {
            id = "icon",
            image = beautiful.pfp,
            widget = wibox.widget.imagebox,
            resize = true,
            forced_height = dpi(40),
            clip_shape = gears.shape.circle,
        },
        layout = wibox.layout.align.horizontal,
    }

    local profile_name = wibox.widget {
        font = "iosevka medium 14",
        markup = "User",
        align = "left",
        valign = "center",
        widget = wibox.widget.textbox,
    }

    awful.spawn.easy_async_with_shell(
        [[
		sh -c '
        user
		'
		]],
        function(stdout)
            local stdout = stdout:gsub("%\n", "")
            profile_name:set_markup(stdout)
        end
    )

    local user_profile = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(15),
        {
            layout = wibox.layout.align.vertical,
            expand = "none",
            nil,
            profile_imagebox,
            nil,
        },
        profile_name,
    }

    return user_profile
end

return create_profile
