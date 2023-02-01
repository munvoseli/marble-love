local M = {}

--[[
feature multiplicity
same thing in different ways
++
 ++
+= 1
= 1 +
--]]

local putil = require("putil")

local function getArgPlaceholder(fo, i)
	local p = putil.rectPurple(40, 40)
	p.glyphs[1].onclick = function()
		fo.args[i] = selsym
	end
	return p
end

local function getArgTrashcan(fo, i)
	local p = putil.rectPurple(20, 20)
	p.glyphs[1].onclick = function()
		fo.args[i] = nil
	end
	return p
end

local function getLinePlaceholder(mo, i)
	local p = putil.rectPurple(40, 20)
	p.glyphs[1].onclick = function()
		table.insert(mo.lines, i, selsym)
	end
	return p
end

--[[
you know,
ides were always kind of confusing to me
what you type is not what appears

in the case of adding brackets and parentheses,
brackets are added automatically,
but it isn't shown which brackets you can type over
or what you will add

adding brackets manually is more pona,
but is also not fun
--]]

local function orangeToPurple(o)
	local tag = o.tag
	if tag == "multiline" then
		local p = getLinePlaceholder(o, 1)
		for i = 1,#o.lines do
			local sp = orangeToPurple(o.lines[i])
			putil.addBottom(p, sp)
			local pp = getLinePlaceholder(o, i + 1)
			putil.addBottom(p, pp)
		end
		return p
	elseif tag == "fcall" then
		local p = putil.stringPurple(o.func)
		for i = 1,#o.argt do
			if o.args[i] == nil then
				local pp = getArgPlaceholder(o, i)
				putil.addRight(p, pp)
			else
				local pp = orangeToPurple(o.args[i])
				local tp = getArgTrashcan(o, i)
				putil.addBottom(pp, tp)
				putil.addRight(p, pp)
			end
		end
		return p
	elseif tag == "if" then
	elseif tag == "lit" then
	elseif tag == "raw" then
		return putil.stringPurple(o.stuff)
	end
	assert(false, string.format("Type %s not handled.", tag))
end

M.orangeToPurple = orangeToPurple

--[[
i need to make a version control system called flowey
fill ur repos with determination
--]]

return M
