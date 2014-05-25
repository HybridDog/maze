minetest.register_chatcommand("maze", {
	params = "<size_x> <size_y>",
	description = "Create a maze with size_x * size_y",
	-- privs = {},
	func = function(name, param)
		local player_pos = minetest.env:get_player_by_name(name):getpos()
		local found, _, maze_size_x_st, maze_size_y_st, material_floor, material_wall, material_ceiling = param:find("(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)")
		local min_size = 10
		local maze_size_x = tonumber(maze_size_x_st)
		local maze_size_y = tonumber(maze_size_y_st)
		if maze_size_x == nil then maze_size_x = min_size end
		if maze_size_y == nil then maze_size_y = min_size end
		if maze_size_x < min_size then maze_size_x = min_size end
		if maze_size_y < min_size then maze_size_y = min_size end
		if material_floor == nil then material_floor = "default:cobble" end
		if material_wall == nil then material_wall = "default:cobble" end
		if material_ceiling == nil then material_ceiling = "default:cobble" end
		
		minetest.chat_send_player(name, "Try to build maze with dimension "..maze_size_x.." * "..maze_size_y)

		maze = {}
		for x=0, maze_size_x-1, 1 do
			maze[x] = {}
			for y=0, maze_size_y-1, 1 do
				maze[x][y] = 1
			end
		end

		local start_x = 0
		local start_y = 1
		local pos_x = start_x
		local pos_y = start_y
		maze[pos_x][pos_y] = 0
		moves = {}
		table.insert(moves, {x=pos_x, y=pos_y})
		-- print(#moves.." "..moves[1].x.." "..moves[1].y);
		repeat
			local possible_ways = {};
			-- ist N möglich?
			if (
				((pos_y-1) >= 0) and ((pos_y-2) >= 0) and ((pos_x-1) >= 0) and ((pos_x+1) < maze_size_x) and 
				(maze[pos_x][pos_y-1] == 1) and -- nord ist mauer
				(maze[pos_x][pos_y-2] == 1) and -- nord von nord ist mauer
				(maze[pos_x-1][pos_y-1] == 1) and -- west von nord ist mauer
				(maze[pos_x+1][pos_y-1] == 1) -- ost von nord ist mauer
			) then
				table.insert(possible_ways, 'N')
			end
			-- ist E möglich?
			if (
				((pos_x+1) < maze_size_x) and ((pos_x+2) < maze_size_x) and ((pos_y-1) >= 0) and ((pos_y+1) < maze_size_y) and 
				(maze[pos_x+1][pos_y] == 1) and -- ost ist mauer
				(maze[pos_x+2][pos_y] == 1) and -- ost von ost ist mauer
				(maze[pos_x+1][pos_y-1] == 1) and -- nord von ost ist mauer
				(maze[pos_x+1][pos_y+1] == 1) -- sued von ost ist mauer
			) then
				table.insert(possible_ways, 'E')
			end
			-- ist S möglich?
			if (
				((pos_y+1) < maze_size_y) and ((pos_y+2) < maze_size_y) and ((pos_x-1) >= 0) and ((pos_x+1) < maze_size_x) and 
				(maze[pos_x][pos_y+1] == 1) and -- sued ist mauer
				(maze[pos_x][pos_y+2] == 1) and -- sued von sued ist mauer
				(maze[pos_x-1][pos_y+1] == 1) and -- west von sued ist mauer
				(maze[pos_x+1][pos_y+1] == 1) -- ost von sued ist mauer
			) then
				table.insert(possible_ways, 'S')
			end
			-- ist W möglich?
			if (
				((pos_x-1) >= 0) and ((pos_x-2) >= 0) and ((pos_y-1) >= 0) and ((pos_y+1) < maze_size_y) and 
				(maze[pos_x-1][pos_y] == 1) and -- west ist mauer
				(maze[pos_x-2][pos_y] == 1) and -- west von west ist mauer
				(maze[pos_x-1][pos_y-1] == 1) and -- nord von west ist mauer
				(maze[pos_x-1][pos_y+1] == 1) -- sued von west ist mauer
			) then
				table.insert(possible_ways, 'W')
			end
			if #possible_ways>0 then
				local direction = possible_ways[math.random(# possible_ways)]
				if direction == 'N' then pos_y = pos_y - 1 end
				if direction == 'E' then pos_x = pos_x + 1 end
				if direction == 'S' then pos_y = pos_y + 1 end
				if direction == 'W' then pos_x = pos_x - 1 end
				table.insert(moves, {x=pos_x, y=pos_y})
				maze[pos_x][pos_y] = 0;
				-- print(# possible_ways.." "..direction);
			else
				local pos = table.remove(moves)
				pos_x = pos.x
				pos_y = pos.y
				-- print("get back to "..pos_x.." / "..pos_y);
			-- }
			end
		until ((pos_x == start_x) and (pos_y == start_y));
		maze[maze_size_x-1][maze_size_y-2] = 0


		-- local player_dir=minetest.env:get_player_by_name(name):get_look_dir()

		local offset_x = 1
		local offset_y = 1
		for y=0, maze_size_y-1, 1 do
			local line = "";
			for x=0, maze_size_x-1, 1 do
				local pos = {x=player_pos.x + x + offset_x, y=player_pos.y-1, z=player_pos.z + y + offset_y}
				minetest.env:add_node(pos,{type="node",name=material_floor})
				if maze[x][y] == 1 then 
					line = line.."X"
					local pos = {x=player_pos.x + x + offset_x, y=player_pos.y, z=player_pos.z + y + offset_y}
					minetest.env:add_node(pos,{type="node",name=material_wall})
					local pos = {x=player_pos.x + x + offset_x, y=player_pos.y+1, z=player_pos.z + y + offset_y}
					minetest.env:add_node(pos,{type="node",name=material_wall})
				else
					line = line.." " 
					local pos = {x=player_pos.x + x + offset_x, y=player_pos.y, z=player_pos.z + y + offset_y}
					minetest.env:add_node(pos,{type="node",name="air"})
					local pos = {x=player_pos.x + x + offset_x, y=player_pos.y+1, z=player_pos.z + y + offset_y}
					minetest.env:add_node(pos,{type="node",name="air"})
				end
				local pos = {x=player_pos.x + x + offset_x, y=player_pos.y+2, z=player_pos.z + y + offset_y}
				minetest.env:add_node(pos,{type="node",name=material_ceiling})
			end
			print(line)
		end

		-- print("playerdir: ("..player_dir.x..", "..player_dir.y..", "..player_dir.z..")")
		-- print("playerpos: ("..player_pos.x..", "..player_pos.y..", "..player_pos.z..")")
	end,
})