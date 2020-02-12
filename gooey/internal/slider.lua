local core = require "gooey.internal.core"
local actions = require "gooey.actions"

local M = {}

local sliders = {}

-- instance functions
local SLIDER = {}
function SLIDER.refresh(slider)
	if slider.refresh_fn then slider.refresh_fn(button) end
end
function SLIDER.scroll_to(slider, x, y)
	assert(slider)
	assert(x)
	assert(y)
	local handle_pos = gui.get_position(slider.node)

	x = core.clamp(x, 0, 1)
	y = core.clamp(y, 0, 1)
	if slider.vertical then
		local adjusted_height = slider.bounds_size.y
		handle_pos.y = y * adjusted_height -- adjusted_height - 
		gui.set_position(slider.node, handle_pos)
		gui.set_size(slider.fill, vmath.vector3(slider.fill_size.x, handle_pos.y, slider.fill_size.z))
	else
		local adjusted_width = slider.bounds_size.x
		handle_pos.x = x * adjusted_width -- adjusted_width - x * adjusted_width
		gui.set_position(slider.node, handle_pos)
		gui.set_size(slider.fill, vmath.vector3(handle_pos.x, slider.fill_size.y, slider.fill_size.z))
	end

	slider.scroll.y = y
end
function SLIDER.set_visible(slider, visible)
	gui.set_enabled(slider.node, visible)
end
function SLIDER.set_long_pressed_time(slider, time)
	slider.long_pressed_time = time
end


function M.vertical(handle_id, fill_id, bounds_id, action_id, action, fn, refresh_fn)
	handle_id = core.to_hash(handle_id)
	fill_id = core.to_hash(fill_id)
	bounds_id = core.to_hash(bounds_id)
	local handle = gui.get_node(handle_id)
	local fill = gui.get_node(fill_id)
	local bounds = gui.get_node(bounds_id)
	assert(handle)
	assert(fill)
	assert(bounds)
	local slider = core.instance(handle_id, sliders, SLIDER)
	slider.scroll = slider.scroll or vmath.vector3(0, 0, 0)
	slider.vertical = true

	local fill_size = gui.get_size(fill)
	local bounds_size = gui.get_size(bounds)

	local bounds_scale = gui.get_scale(bounds)
	fill_size.x = fill_size.x * bounds_scale.x

	slider.enabled = core.is_enabled(handle)
	slider.node = handle
	slider.fill = fill
	slider.bounds = bounds
	slider.bounds_size = bounds_size
	slider.fill_size = fill_size
	slider.ratio = 0

	if action then
		slider.refresh_fn = refresh_fn

		local action_pos = vmath.vector3(action.x, action.y, 0)

		core.clickable(slider, action_id, action)
		if slider.pressed_now or slider.pressed then
			local bounds_pos = core.get_root_position(bounds)
			local size = bounds_size.y
			local ratio = (size - (action_pos.y - bounds_pos.y) / bounds_scale.y) / size
			slider.ratio = 1 - ratio
			SLIDER.scroll_to(slider, 0, 1 - ratio)
			fn(slider)
		end
	else
		SLIDER.scroll_to(slider, 0, slider.scroll.y)
	end

	slider.refresh()
	return slider
end

function M.horizontal(handle_id, fill_id, bounds_id, action_id, action, fn, refresh_fn)
	handle_id = core.to_hash(handle_id)
	fill_id = core.to_hash(fill_id)
	bounds_id = core.to_hash(bounds_id)
	local handle = gui.get_node(handle_id)
	local fill = gui.get_node(fill_id)
	local bounds = gui.get_node(bounds_id)
	assert(handle)
	assert(fill)
	assert(bounds)
	local slider = core.instance(handle_id, sliders, SLIDER)
	slider.scroll = slider.scroll or vmath.vector3(0, 0, 0)
	slider.vertical = false

	local fill_size = gui.get_size(fill)
	local bounds_size = gui.get_size(bounds)

	local bounds_scale = gui.get_scale(bounds)
	fill_size.x = fill_size.x * bounds_scale.x

	slider.enabled = core.is_enabled(handle)
	slider.node = handle
	slider.fill = fill
	slider.bounds = bounds
	slider.bounds_size = bounds_size
	slider.fill_size = fill_size
	slider.ratio = 0

	if action then
		slider.refresh_fn = refresh_fn
		local action_pos = vmath.vector3(action.x, action.y, 0)
		local bounds_pos = core.get_root_position(bounds)

		core.clickable(slider, action_id, action)
		if slider.pressed_now or slider.pressed then
			local bounds_pos = core.get_root_position(bounds)
			local size = bounds_size.x
			local ratio = (size - (action_pos.x - bounds_pos.x) / bounds_scale.x) / size
			slider.ratio = 1 - ratio
			SLIDER.scroll_to(slider, 1 - ratio, 0)
			fn(slider)
		end
	else
		SLIDER.scroll_to(slider, slider.scroll.x, 0)
	end

	slider.refresh()
	return slider
end

setmetatable(M, {
	__call = function(_, ...)
		return M.slider(...)
	end
})

return M