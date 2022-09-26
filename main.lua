local orange = {}
orange.type = "multiline"
local globCursor = {}
globCursor.curt = "none"
local font = love.graphics.newFont("glyphs.ttf", 60)
love.graphics.setFont(font)

local Curt = {
	glyph = 0,
	line = 1,
	multiline = 2
}

local function dumpOrange(o, cur)
	if o.type == nil then
		print(table.concat(cur, " ") .. "  [nil type]")
	else
		print(table.concat(cur, " ") .. "  " .. o.type)
	end
	for i=1,#o do
		table.insert(cur, i)
		dumpOrange(o[i], cur)
		table.remove(cur)
	end
end
dumpOrange(orange, {})

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
	elseif o.type == "for" then
		local mp = getPurple(o[3], cur, 3)
		local go = {}
		go.type = "gly"
		go.symb = "f"
		local fp = getPurple(go)
		local scp = getCursorN(cur, "line-nodel", 1)
		local slin = getPurple(o[1], cur, 1)
		table.insert(cur, 2)
		local mcp = getCursorN(cur, "line-nodel", 0)
		table.remove(cur)
		addMid(scp, slin)
		translatePurple(scp, 0, fp.yb - scp.ya)
		addPurple(fp, scp)
		translatePurple(mp, fp.xb, 0)
		addPurple(fp, mp)
		return fp
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
			love.graphics.print(p.glyphs[i].ref.symb, x, y)
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

local function insertAtCursor(cur, symb)
	local curt = cur.curt
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
		table.insert(cur, 1)
		cur.curt = "glyph"
	elseif curt == "line-block" or curt == "line-nodel" then
		local go = {}
		go.type = "gly"
		go.symb = symb
		table.insert(o[i], 1, go)
		table.insert(cur, 1)
		cur.curt = "glyph"
	elseif curt == "glyph" then
		local go = {}
		go.type = "gly"
		go.symb = symb
		table.insert(o, i + 1, go)
		cur[#cur] = cur[#cur] + 1
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
		cur[#cur] = cur[#cur] - 1
	end
end

local function actionAtCursor(cur)
	local oo = orange
	for i=1,#cur-2 do
		oo = oo[cur[i]]
	end
	local i = cur[#cur-1]
	local j = cur[#cur]
	print(table.concat(cur, ", "))
	if oo[i].type == "line" then
		local k = j
		local s = ""
		while true do
			if k == 0 then
				break
			end
			if oo[i][k].symb == nil then
				break
			end
			if not #oo[i][k].symb == 1 then
				break
			end
			if oo[i][k].symb == " " then
				break
			end
			s = oo[i][k].symb .. s
			k = k - 1
		end
		print(s)
		local line = oo[i]
		if s == "for" and oo.type == "multiline" then
			local foro = {}
			local mlo = {}
			mlo.type = "multiline"
			local alo = {}
			alo.type = "line"
			local blo = {}
			blo.type = "line"
			table.insert(foro, alo)
			table.insert(foro, blo)
			table.insert(foro, mlo)
			foro.type = "for"
			oo[i] = foro
		else
			if k > 0 then
				assert(line[k].symb == " ")
				table.remove(line, k)
			else
				k = 1
			end
			for i=1,#s do
				table.remove(line, k)
			end
			cur[#cur] = cur[#cur] - #s
			local go = {}
			go.type = "gly"
			if s == "a" then
				go.symb = "A"
			elseif s == "add" then
				go.symb = "+"
			end
			table.insert(line, k, go)
		end
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
	elseif #key == 1 then
		insertAtCursor(globCursor, key)
	elseif key == "space" then
		insertAtCursor(globCursor, " ")
	elseif key == "return" then
		actionAtCursor(globCursor)
	elseif key == "escape" then
		dumpOrange(orange, {})
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
