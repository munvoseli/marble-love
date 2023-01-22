--[[
contains
functions for conversion from Orange to Purple
operations for translating, scaling, constructing, and layering Purple-s
    (instrumentally)
--]]
local M = {}

local function addPurple(a, b)
	for i=1,#b.glyphs do
		table.insert(a.glyphs, b.glyphs[i])
	end
	a.xa = math.min(a.xa, b.xa)
	a.ya = math.min(a.ya, b.ya)
	a.xb = math.max(a.xb, b.xb)
	a.yb = math.max(a.yb, b.yb)
end

local function translatePurple(p, x, y)
	p.xa = p.xa + x
	p.xb = p.xb + x
	p.ya = p.ya + y
	p.yb = p.yb + y
	for i=1,#p.glyphs do
		p.glyphs[i].tx = p.glyphs[i].tx + x
		p.glyphs[i].ty = p.glyphs[i].ty + y
	end
end
local function scalePurple(p, x, y)
	p.xa = p.xa * x
	p.xb = p.xb * x
	p.ya = p.ya * y
	p.yb = p.yb * y
	for i=1,#p.glyphs do
		p.glyphs[i].tx = p.glyphs[i].tx * x
		p.glyphs[i].ty = p.glyphs[i].ty * y
		p.glyphs[i].sx = p.glyphs[i].sx * x
		p.glyphs[i].sy = p.glyphs[i].sy * y
	end
end

local function emptyPurple()
	local p = {}
	p.xa = 0
	p.ya = 0
	p.xb = 0
	p.yb = 0
	p.glyphs = {}
	return p
end

local function getCursorN(upcur, t, n)
	local cur = {}
	for i=1,#upcur do
		table.insert(cur, upcur[i])
	end
	table.insert(cur, n)
	local r = {}
	r.xa = 0
	r.xb = 40
	r.ya = 0
	r.yb = 40
	local p = {}
	p.xa = r.xa
	p.xb = r.xb
	p.ya = r.ya
	p.yb = r.yb
	local g = {}
	g.tx = 0
	g.ty = 0
	g.sx = 1
	g.sy = 1
	g.ref = r
	g.cur = cur
	g.curt = t
	g.bgclr = {0.6, 0.8, 1}
	p.glyphs = {}
	table.insert(p.glyphs, g)
	return p
end

local function getCursor(upcur, t)
	return getCursorN(upcur, t, 0)
end

local function addMid(ap, bp)
	translatePurple(bp, ap.xb - ap.xa, -(bp.ya+bp.yb)/2)
	translatePurple(ap, 0, -(ap.ya+ap.yb)/2)
	addPurple(ap, bp)
end

local function getPurple(o, upcur, n)
	local cur = {}
	if upcur ~= nil then
		for i=1,#upcur do
			table.insert(cur, upcur[i])
		end
		table.insert(cur, n)
	end
	if o.type == "gly" then
		local r = {}
		local w = font:getWidth(o.symb)
		local h = font:getHeight()
		r.xa = 0
		r.xb = w
		r.ya = 0
		r.yb = h
		r.symb = o.symb
		local p = {}
		p.xa = r.xa
		p.xb = r.xb
		p.ya = r.ya
		p.yb = r.yb
		local g = {}
		g.tx = 0
		g.ty = 0
		g.sx = 1
		g.sy = 1
		g.ref = r
		g.cur = cur
		g.curt = "glyph"
		g.fgclr = {0, 0, 0}
		g.bgclr = {1, 1, 1}
		p.glyphs = {}
		table.insert(p.glyphs, g)
		return p
	elseif o.type == "line" then
		local p = emptyPurple()
		for i=1,#o do
			local sp = getPurple(o[i], cur, i)
			translatePurple(sp, p.xb - sp.xa, 0)
			addPurple(p, sp)
		end
		return p
	elseif o.type == "multiline" then
		local p = getCursorN(cur, "line-new", 1)
		for i = 1,#o.lines do
			local sp = getPurple(o.lines[i], cur, i)
			local pp = getCursorN(cur, "line-block", i)
			local pad = 0
			local h = math.max(sp.yb - sp.ya, pp.yb - pp.ya)
			local y0 = p.yb
			local ym = y0 + h/2 + pad
			-- ya -> ym - (yb-ya)/2 = ym + ya/2 - yb/2
			-- yb -> ym + (yb-ya)/2
			-- diff = ym - (ya+yb)/2
			translatePurple(sp, pp.xb - pp.xa, ym - (sp.ya+sp.yb)/2)
			translatePurple(pp, 0, ym - (pp.ya+pp.yb)/2)
			addPurple(p, sp)
			addPurple(p, pp)
			local spn = getCursorN(cur, "line-new", i + 1)
			translatePurple(spn, 0, p.yb - spn.ya + pad)
			addPurple(p, spn)
		end
		return p
	elseif o.type == "for" then
		local mp = getPurple(o[3], cur, 3)
		local go = {}
		go.type = "gly"
		go.symb = "F"
		local fp = getPurple(go)
		scalePurple(fp, 2, 2)
		local scp = getCursorN(cur, "line-nodel", 1)
		local slin = getPurple(o[1], cur, 1)
		table.insert(cur, 2)
		local mcp = getCursorN(cur, "line-nodel", 0)
		table.remove(cur)
		addMid(scp, slin)
		scalePurple(scp, 0.5, 0.5)
		translatePurple(scp, 0, fp.yb - scp.ya)
		addPurple(fp, scp)
		translatePurple(mp, fp.xb, 0)
		addPurple(fp, mp)
		return fp
	end
	assert(false, string.format("Type %s not handled.", o.type))
end

M.getPurple = getPurple
M.translatePurple = translatePurple
M.emptyPurple = emptyPurple

return M
