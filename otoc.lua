--[[
contains a function for conversion from Orange to C code
--]]
local M = {}

local function orangeToc(o)
	local tag = o.tag
	if tag == "multiline" then
		local res = "{\n"
		for i = 1,#o.lines do
			res = res .. orangeToc(o.lines[i])
		end
		res = res .. "}\n"
		return res
	elseif tag == "decl" then
		return o.typ .. " " .. o.nom .. ";\n"
	elseif tag == "set" then
		return o.nom .. " = " .. orangeToc(o.val) .. ";\n"
	elseif tag == "if" then
		local res = "if "
		for i = 1,#o.branches do
			if o.branches[i].condition == nil then
				res = res .. "else {\n"
			else
				if i > 1 then
					res = res .. "else if "
				end
				res = res .. "(" .. orangeToc(o.branches[i].condition) .. ") {\n"
			end
			res = res .. orangeToc(o.branches[i].branch)
			res = res .. "}\n"
		end
		return res
	elseif tag == "fcall" then
		res = o.func .. "("
		for i = 1,#o.args do
			res = res .. orangeToc(o.args[i])
			if i ~= #o.args then
				res = res .. ", "
			end
		end
		res = res .. ");\n"
		return res
	elseif tag == "lit" then
		if o.typ == "int" then
			return o.val
		elseif o.typ == "str" then
			return "\"" .. string.gsub(o.val, "\n", "\\n") .. "\""
		else
			print("aaa")
			return nil
		end
	elseif tag == "raw" then
		return o.stuff
	else
		return ""
	end
end

M.orangeToc = orangeToc

return M
