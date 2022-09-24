local orange = {}
orange.type = "multiline"
local globCursor = {}
globCursor.curt = "none"
--local font = love.graphics.newFont("glyphs.ttf")
--love.graphics.setFont(font)

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
		for i = 1,#o do
			local sp = getPurple(o[i], cur, i)
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
	end
	assert(false, string.format("Type %s not handled.", o.type))
end

local function drawPurple(p)
	-- local cam = {}
	-- cam.tx = 0
	-- cam.ty = 0
	-- cam.sx = 1
	-- cam.sy = 1
	for i=1,#p.glyphs do
		local x = p.glyphs[i].xa
		local y = p.glyphs[i].ya
		local w = p.glyphs[i].xb - x
		local h = p.glyphs[i].yb - y
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", x, y, w, h)
		if p.glyphs[i].ref.symb then
			love.graphics.setColor(0, 0, 0)
			love.graphics.print(p.glyphs[i].ref.symb, x+w/2, y+h/2)
		end
	end
end

local function cameraPurple(p, w, h)
	translatePurple(p, -p.xa, -p.ya)
	local j = w / p.xb
	--scalePurple(p, j, j)
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

local function insertAtCursor(cur, curt, symb)
	print(curt .. "  " .. table.concat(cur, " "))
	local o = orange
	for i=1,#cur-1 do
		o = o[cur[i]]
	end
	local i = cur[#cur]
	if curt == "line-new" then
		local lo = {}
		lo.type = "line"
		local go = {}
		go.type = "gly"
		go.symb = symb
		table.insert(lo, go)
		table.insert(o, i, lo)
	elseif curt == "line-block" then
		local go = {}
		go.type = "gly"
		go.symb = symb
		table.insert(o[i], 1, go)
	elseif curt == "glyph" then
		local go = {}
		go.type = "gly"
		go.symb = symb
		table.insert(o, i + 1, go)
	end
end

local function removeAtCursor(cur, curt)
	local o = orange
	for i=1,#cur-1 do
		o = o[cur[i]]
	end
	local i = cur[#cur]
	if curt == "line-block" then
		table.remove(o, i)
	elseif curt == "glyph" then
		table.remove(o, i)
	end
end

local hd = 0

local function mouseToCursor(p)
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
			table.insert(curs, cur)
		end
	end
	return curs
end


local adowntime = 0
local remdowntime = 0

function love.load()
	love.keyboard.setTextInput(true)
end

function love.keypressed(key)
	print(key)
	if key == "backspace" then
		removeAtCursor(globCursor, globCursor.curt)
	else
		insertAtCursor(globCursor, globCursor.curt, key)
	end
end

function love.draw()
	local p = getPurple(orange)
	cameraPurple(p, 100, 100)
	purpleGenGlyphBounds(p)
	if love.mouse.isDown(1) then
		local curs = mouseToCursor(p)
		if #curs > 0 then
			print(curs[1].curt .. " " .. table.concat(curs[1], " "))
			globCursor = curs[1]
		end
	end
	drawPurple(p)
	hd = hd + 1
end
