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

local function addMid(ap, bp)
	translatePurple(bp, ap.xb - ap.xa, -(bp.ya+bp.yb)/2)
	translatePurple(ap, 0, -(ap.ya+ap.yb)/2)
	addPurple(ap, bp)
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

local function stringPurple(text)
	local g = {
		tag = "text",
		tx = 0, ty = 0, sx = 1, sy = 1,
		text = text
	}
	local p = {
		xa = 0,
		ya = 0,
		xb = font:getWidth(text),
		yb = font:getHeight(),
		glyphs = { g }
	}
	return p
end

local function rectPurple(w, h)
	local g = {
		tag = "rect",
		tx = 0, ty = 0, sx = 1, sy = 1,
		w = w, h = h
	}
	local p = {
		xa = 0,
		ya = 0,
		xb = w,
		yb = h,
		glyphs = { g }
	}
	return p
end

local function genGlyphBounds(p)
	for i=1,#p.glyphs do
		p.glyphs[i].xa =
		 p.glyphs[i].ref.xa * p.glyphs[i].sx + p.glyphs[i].tx
		p.glyphs[i].xb =
		 p.glyphs[i].ref.xb * p.glyphs[i].sx + p.glyphs[i].tx
		p.glyphs[i].ya =
		 p.glyphs[i].ref.ya * p.glyphs[i].sy + p.glyphs[i].ty
		p.glyphs[i].yb =
		 p.glyphs[i].ref.yb * p.glyphs[i].sy + p.glyphs[i].ty
	end
end


M.addPurple = addPurple
M.translatePurple = translatePurple
M.emptyPurple = emptyPurple
M.stringPurple = stringPurple
M.rectPurple = rectPurple
M.genGlyphBounds = genGlyphBounds

return M
