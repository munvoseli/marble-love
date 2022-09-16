local orange = {}
orange.type = "multiline"
cursor = {}

Curt = {
	glyph = 0,
	line = 1,
	multiline = 2
}

function addPurple(a, b)
	for i=1,#b.glyphs do
		table.insert(a.glyphs, b.glyphs[i])
	end
	a.xa = math.max(a.xa, b.xa)
	a.ya = math.max(a.ya, b.ya)
	a.xb = math.max(a.xb, b.xb)
	a.yb = math.max(a.yb, b.yb)
end

function translatePurple(p, x, y)
	p.xa = p.xa + x
	p.xb = p.xb + x
	p.ya = p.ya + y
	p.yb = p.yb + y
	for i=1,#p.glyphs do
		p.glyphs[i].tx = p.glyphs[i].tx + x
		p.glyphs[i].ty = p.glyphs[i].tx + y
	end
end
function scalePurple(p, x, y)
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

function emptyPurple()
	p = {}
	p.xa = 0
	p.ya = 0
	p.xb = 0
	p.yb = 0
	p.glyphs = {}
	return p
end

function getCursor(upcur, t)
	cur = {}
	for i=1,#upcur do
		cur[i] = upcur[i]
	end
	cur[#upcur] = 0
	r = {}
	r.xa = 0
	r.xb = 40
	r.ya = 0
	r.yb = 40
	p = {}
	p.xa = r.xa
	p.xb = r.xb
	p.ya = r.ya
	p.yb = r.yb
	g = {}
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


function getPurple(o, upcur, n)
	cur = {}
	if upcur ~= nil then
		for i=1,#upcur do
			cur[i] = upcur[i]
		end
		cur[#upcur] = n
	end
	if o.type == "gly" then
		r = {}
		r.xa = 0
		r.xb = 40
		r.ya = -20
		r.yb = 60
		p = {}
		p.xa = r.xa
		p.xb = r.xb
		p.ya = r.ya
		p.yb = r.yb
		g = {}
		g.tx = 0
		g.ty = 0
		g.sx = 1
		g.sy = 1
		g.ref = r
		g.cur = cur
		g.curt = "glyph"
		p.glyphs = g
		return p
	elseif o.type == "line" then
		p = emptyPurple()
		for i=1,#o do
			sp = getPurple(o[i], cur, i)
			translatePurple(sp, 0, p.xb - sp.xa)
			addPurple(p, sp)
		end
		return p
	elseif o.type == "multiline" then
		-- p = emptyPurple()
		p = getCursor(cur, "line-new")
		for i = 1,#o do
			sp = getPurple(o[i], cur, i)
			translatePurple(sp, p.ya - sp.yb)
			addPurple(p, sp)
		end
		return p
	end
	assert(false, string.format("Type %s not handled.", o.type))
end

function drawPurple(p)
	cam = {}
	cam.tx = 0
	cam.ty = 0
	cam.sx = 1
	cam.sy = 1
--	print(string.format("drawing %d glyphs", #p.glyphs))
	for i=1,#p.glyphs do
--		x = p.glyphs[i].ref.xa
--		y = p.glyphs[i].ref.ya
--		w = p.glyphs[i].ref.xb - p.glyphs[i].ref.xa
--		h = p.glyphs[i].ref.yb - p.glyphs[i].ref.ya
--
--		x = x * p.glyphs[i].sx
--		y = y * p.glyphs[i].sy
--		w = w * p.glyphs[i].sx
--		h = h * p.glyphs[i].sy
--
--		x = x + p.glyphs[i].tx
--		y = y + p.glyphs[i].tx
--
--		x = (x + cam.tx) * cam.sx
--		y = (y + cam.ty) * cam.sy
--		w = w * cam.sx
--		h = h * cam.sy
		x = p.glyphs[i].xa
		y = p.glyphs[i].ya
		w = p.glyphs[i].xb - x
		h = p.glyphs[i].yb - y
		love.graphics.rectangle("fill", x, y, w, h)
	end
end

function cameraPurple(p, w, h)
	translatePurple(p, -p.xa, -p.ya)
	h = w / p.xb
	scalePurple(p, h, h)
end

function purpleGenGlyphBounds(p)
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

function love.draw()
	p = getPurple(orange)
	cameraPurple(p, 100, 100)
	purpleGenGlyphBounds(p)
--	for k,v in pairs(p.glyphs) do
--		print(v.xa, v.ya, v.xb, v.yb)
--	end
	x, y = love.mouse.getPosition()
	for i=1,#p.glyphs do
		if x > p.glyphs[i].xa and x < p.glyphs[i].xb and
		   y > p.glyphs[i].ya and y < p.glyphs[i].yb then
			print("hovering over")
			for j=1,#p.glyphs[i].cur do
				print(p.glyphs[i].cur[i])
			end
		end
	end
	drawPurple(p)
end
