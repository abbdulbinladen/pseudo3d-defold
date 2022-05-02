M = {}

function M.calculate_scale(width, fov_angle)
	return (width/2) / math.tan(fov_angle/2)
end

function M.project(resolution, position, scale)
	return (position.y*scale)/position.z + (resolution.y/2) -- y position
end

function M.skew(pos, offset)
	return vmath.vector3(pos.x+pos.z*offset.x, pos.y+pos.z*offset.y, pos.z)
end

return M