-------------------------------------------------
-- Github Contributions Widget for Awesome Window Manager
-- Shows the contributions graph
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/github-contributions-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require "awful"
local naughty = require "naughty"
local wibox = require "wibox"
local gears = require "gears"
local helpers = require "helpers"
local widget_themes = require "widget.github.themes"

local GET_CONTRIBUTIONS_CMD = [[bash -c "curl -s https://github-contributions.vercel.app/api/v1/%s]]
    .. [[ | jq -r '[.contributions[] ]]
    .. [[ | select ( .date | strptime(\"%%Y-%%m-%%d\") | mktime < now)][:%s]| .[].intensity'"]]

local github_contributions_widget = wibox.widget {
    reflection = {
        horizontal = true,
        vertical = true,
    },
    widget = wibox.container.mirror,
}

local function show_warning(message)
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Github Contributions Widget",
        text = message,
    }
end

local args = {}

local username = "betty2310"
local days = 365
local color_of_empty_cells = args.color_of_empty_cells
local with_border = false
local margin_top = 5
local theme = args.theme or "standard"

if widget_themes[theme] == nil then
    show_warning("Theme " .. theme .. " does not exist")
    theme = "standard"
end

if with_border == nil then
    with_border = true
end

local function get_square(color)
    if color_of_empty_cells ~= nil and color == widget_themes[theme][0] then
        color = color_of_empty_cells
    end

    return wibox.widget {
        fit = function()
            return 3, 3
        end,
        draw = function(_, _, cr, _, _)
            cr:set_source(gears.color(color))
            cr:rectangle(0, 0, with_border and 2 or 3, with_border and 2 or 3)
            cr:fill()
        end,
        layout = wibox.widget.base.make_widget,
    }
end

local col = { layout = wibox.layout.fixed.vertical }
local row = { layout = wibox.layout.fixed.horizontal }
local day_idx = 5 - os.date "%w"
for _ = 0, day_idx do
    table.insert(col, get_square(color_of_empty_cells))
end

local update_widget = function(_, stdout, _, _, _)
    for intensity in stdout:gmatch "[^\r\n]+" do
        if day_idx % 7 == 0 then
            table.insert(row, col)
            col = { layout = wibox.layout.fixed.vertical }
        end
        table.insert(col, get_square(widget_themes[theme][tonumber(intensity)]))
        day_idx = day_idx + 1
    end
    github_contributions_widget:setup {
        row,
        margins = 7,
        layout = wibox.container.margin,
    }
end

awful.spawn.easy_async(string.format(GET_CONTRIBUTIONS_CMD, username, days), function(stdout)
    update_widget(github_contributions_widget, stdout)
end)
local popup = awful.popup {
    ontop = true,
    visible = false,
    shape = helpers.prrect(dpi(0), true, true, true, true),
    border_width = 3,
    border_color = x.color2,
    width = 500,
    height = 500,
    x = 200,
    y = 770,
    widget = github_contributions_widget,
    hide_on_right_click = true,
    type = "dock",
}

if sidebar and sidebar.visible then
    popup.visible = true
else
    popup.visible = false
end

local go2 = wibox.widget {
    font = "JetBrainsMono Nerd Font 13",
    markup = helpers.colorize_text(" ", x.color2),
    widget = wibox.widget.textbox,
}
go2:buttons(gears.table.join(awful.button({}, 1, function()
    popup.visible = not popup.visible
end)))
return go2
