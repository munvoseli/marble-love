local orange = {}
orange.type = "multiline"
local cursor = {}
if true then
	local hhh = {}
	hhh.type = "line"
	table.insert(orange, hhh)
end

local Curt = {
	glyph = 0,
	line = 1,
	multiline = 2
}

local function printPurple(p)
	for i=1,#p.glyphs do
		print(i, p.glyphs[i].curt, p.glyphs[i].xa, p.glyphs[i].xb, p.glyphs[i].ya, p.glyphs[i].yb)
	end
end

local function printPurpleTS(p)
	print(#p.glyphs, p.xa, p.ya, p.xb, p.yb)
	for i=1,#p.glyphs do
		print(i, p.glyphs[i].curt, p.glyphs[i].tx, p.glyphs[i].ty, p.glyphs[i].sx, p.glyphs[i].sy)
	end
end

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
	p.glyphs = {}
	table.insert(p.glyphs, g)
	return p
end

local function getCursor(upcur, t)
	return getCursorN(upcur, t, 0)
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
		r.xa = 0
		r.xb = 40
		r.ya = -20
		r.yb = 60
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
		p.glyphs = {}
		table.insert(p.glyphs, g)
		return p
	elseif o.type == "line" then
		local p = emptyPurple()
		for i=1,#o do
			local sp = getPurple(o[i], cur, i)
			translatePurple(sp, 0, p.xb - sp.xa)
			addPurple(p, sp)
		end
		return p
	elseif o.type == "multiline" then
		local p = getCursorN(cur, "line-new", 1)
		for i = 1,#o do
			local sp = getPurple(o[i], cur, i)
			local pp = getCursorN(cur, "line-block", i)
			translatePurple(sp, pp.xb - pp.xa, p.ya - sp.yb)
			translatePurple(pp, 0, p.yb - sp.ya)
			addPurple(p, sp)
			addPurple(p, pp)
			local spn = getCursorN(cur, "line-new", i + 1)
			translatePurple(spn, 0, p.yb - spn.ya)
			addPurple(p, spn)
		end
		return p
	end
	assert(false, string.format("Type %s not handled.", o.type))
end

local function drawPurple(p)
	local cam = {}
	cam.tx = 0
	cam.ty = 0
	cam.sx = 1
	cam.sy = 1
	for i=1,#p.glyphs do
		local x = p.glyphs[i].xa
		local y = p.glyphs[i].ya
		local w = p.glyphs[i].xb - x
		local h = p.glyphs[i].yb - y
		love.graphics.rectangle("fill", x, y, w, h)
	end
end

local function cameraPurple(p, w, h)
	translatePurple(p, -p.xa, -p.ya)
	local j = w / p.xb
	scalePurple(p, j, j)
end

local function purpleGenGlyphBounds(p)
	for i=1,#p.glyphs do
		p.glyphs[i].xa =
		 p.glyphs[i].ref.xa * p.glyphs[i].sx + p.glyphs[i].tx;
		p.glyphs[i].xb =
		 p.glyphs[i].ref.xb * p.glyphs[i].sx + p.glyphs[i].tx;
		p.glyphs[i].ya =
		 p.glyphs[i].ref.ya * p.glyphs[i].sy + p.glyphs[i].ty;
		p.glyphs[i].yb =
		 p.glyphs[i].ref.yb * p.glyphs[i].sy + p.glyphs[i].ty;
	end
end

local function insertAtCursor(cur, curt)
	local o = orange
--	for i=1,#cur-1 do
--		o = o[cur[i]]
--	end
	local i = cur[#cur-1]
end

local hd = 0

function mouseToCursor(p)
	local x, y = love.mouse.getPosition()
	local curs = {}
	for i=1,#p.glyphs do
		if x > p.glyphs[i].xa and x < p.glyphs[i].xb and
		   y > p.glyphs[i].ya and y < p.glyphs[i].yb then
			local cur = {}
			cur.curt = p.glyphs[i].curt
			for j=1,#p.glyphs[i].cur do
				table.insert(cur, p.glyphs[i].cur[j])
			end
			insertAtCursor(p.glyphs[i].cur, curt)
			table.insert(curs, cur)
		end
	end
	return curs
end

function love.draw()
	local p = getPurple(orange)
	cameraPurple(p, 100, 100)
	purpleGenGlyphBounds(p)
	if love.mouse.isDown(1) then
		local curs = mouseToCursor(p)
		if #curs > 0 then
			print(curs[1].curt .. " " .. table.concat(curs[1], " "))
		end
	end
	drawPurple(p)
	hd = hd + 1
end

function love.update(_)
	for e, a, b, c in love.event.poll() do
		print("event", e)
		if e == "q" or e == "quit" then
		end
	end
end
