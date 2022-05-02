local u = require("m.utils")

local M = {}

M.w = nil -- width			1920
M.h = nil -- height			1080
M.s = nil -- scale			u.calculate_scale(width, fov)
M.f = nil -- fov			30

M.sc  = 10				-- segments count on screen
M.pos = vmath.vector3() -- current position
M.cor = 1 				-- current corner
M.seg = 1 				-- current segment

M.buffer_info = nil
M.road = nil

function M.next_step(road, cor, seg)
	local return_data = road and true or false
	road = road or M.road
	cor = cor or M.cor
	seg = seg or M.seg
	seg = seg + 1
	if seg > road[cor].seg_count then
		seg = 1
		cor = cor + 1
		if (cor > #road) then
			cor=1
		end
	end
	if return_data then
		return cor, seg
	else
		M.cor = cor
		M.seg = seg
	end
end

function M.reset_camera_pos()
	M.pos.z = M.pos.z - 1 -- 0.001
	M.next_step()
end

function M.draw_track(road, buffer_info)
	road = road or M.road
	buffer_info = buffer_info or M.buffer_info
	local resolution = vmath.vector3(M.w, M.h, 0)
	local cor, seg = M.cor, M.seg
	
	local cam_angular = M.pos.z * road[M.cor].turn_to
	local offset_iterator = vmath.vector3(-cam_angular, 0, 1)
	local skewed_pos = u.skew(M.pos, offset_iterator)
	local cursor = vmath.vector3(-skewed_pos.x, -skewed_pos.y+1, -skewed_pos.z+1)
	local half_w = M.w * 0.5
	
	for i = 1, M.sc do
		local y = u.project(resolution, cursor, M.s)
		local line_half_length = half_w/cursor.z
		local x = half_w + cursor.x
		
		drawpixels.line(M.buffer_info,
			x - line_half_length, y,
			x + line_half_length, y,
			255, 255, 255, 255,
			true)
		
		-- move forward
		cursor.x = cursor.x + offset_iterator.x
		cursor.y = cursor.y + offset_iterator.y
		cursor.z = cursor.z + offset_iterator.z

		-- turn_to
		offset_iterator.x = offset_iterator.x + road[cor].turn_to
		
		cor, seg = M.next_step(road, cor, seg)
	end
end

return M

--[[
M.buffer_info = {
	M.buffer_info = buffer.create(width * height, -- size of the buffer width*height
	{{
		name = hash("p3d"),
		type = buffer.VALUE_TYPE_UINT8,
		count = 4 -- same as channels
	}}),
	width = 512,
	height = 512,
	channels = 4,
	premultiply_alpha = true
}

M.road = {
	{seg_count=10, turn_to=0},
	{seg_count=6, turn_to=-2},
	{seg_count=8, turn_to=0},
	{seg_count=4, turn_to=2.5},
	{seg_count=10, turn_to=1.2},
	{seg_count=4, turn_to=0},
	{seg_count=5, turn_to=-2},
}
--]]