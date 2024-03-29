font = love.graphics.newFont("charis.ttf", 30)
selsym = {}
love.graphics.setFont(font)

local otoc = require("otoc")
local otop = require("otop")
local putil = require("putil")

local funcPurple = putil.emptyPurple()

local orange = {
	tag = "multiline",
	lines = {
		{
			tag = "fcall",
			func = "hello",
			argt = { "int", "int", "int" },
			args = { nil, {
				tag = "raw",
				stuff = "5"
			}
			}
		}
	}
}

local extsymb = {
	func = {
		{
			"printint",
			{ "r", "int" }
		},{
			"add",
			{ "w", "int" },
			{ "r", "int" },
			{ "r", "int" }
		},{
			"set-one",
			{ "w", "int" },
		}
	},
	var = {
		{ "int", "a" },
		{ "int", "b" },
		{ "int", "c" }
	}
}


local Curt = {
	glyph = 0,
	line = 1,
	multiline = 2
}

local function dumpOrange(o, cur)
	if o.tag == nil then
		print(table.concat(cur, " ") .. "  [nil type]")
	else
		print(table.concat(cur, " ") .. "  " .. o.tag)
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

local function drawWorm(text, x, y)
	local w = font:getWidth(text)
	local h = font:getHeight()
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.setColor(0.7, 0.7, 0.7)
	love.graphics.print(text, x, y)
	return w, h
end

local function drawSymbols()
	love.graphics.setBlendMode("subtract")
	local y = 0
	local x = 600
	for i=1,#extsymb.func do
		local t = extsymb.func[i][1]
		local w, h = drawWorm(t, x, y)
		y = y + h * 1.2
	end
	for i=1,#extsymb.var do
		local t = extsymb.var[i][2]
		local w, h = drawWorm(t, x, y)
		y = y + h * 1.2
	end
end

local function drawPurple(p)
	-- local cam = {}
	-- cam.tx = 0
	-- cam.ty = 0
	-- cam.sx = 1
	-- cam.sy = 1
	love.graphics.setBlendMode("subtract")
	for i=1,#p.glyphs do
		local g = p.glyphs[i]
		local x = g.xa
		local y = g.ya
		local w = g.xb - x
		local h = g.yb - y
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.rectangle("fill", x, y, w, h)
		if g.tag == "text" then
			love.graphics.setColor(0.7, 0.7, 0.7)
			love.graphics.print(g.text, x, y)
		end
	end
end

local function mouseToCursor(p)
	local x, y = love.mouse.getPosition()
	local matched = {}
	for i=1,#p.glyphs do
		if x > p.glyphs[i].xa and x < p.glyphs[i].xb and
		   y > p.glyphs[i].ya and y < p.glyphs[i].yb then
			table.insert(matched, p.glyphs[i])
		end
	end
	return matched
end

function love.mousepressed(x, y, button, istouch, presses)
	if x > 600 then
		local h = font:getHeight()
		local i = math.floor(y / h / 1.2)
		if i < #extsymb.func then
			i = i + 1
			print(extsymb.func[i][1])
			local argt = {}
			for j = 2,#extsymb.func[i] do
				table.insert(argt, extsymb.func[i][j][1])
			end
			selsym = {
				tag = "fcall",
				func = extsymb.func[i][1],
				argt = argt,
				args = {}
			}
		else
			i = i - #extsymb.func + 1
			selsym = {
				tag = "raw",
				stuff = extsymb.var[i][2]
			}
			print(extsymb.var[i][2])
		end
	else
		local glyphs = mouseToCursor(funcPurple)
		if #glyphs == 1 then
			glyphs[1].onclick()
		end
	end
	print(otoc.orangeToc(orange))
end

local function cameraPurple(p, w, h)
	putil.translatePurple(p, -p.xa, -p.ya)
	local j = w / p.xb
	--scalePurple(p, j, j)
end

function love.load()
	love.keyboard.setTextInput(true)
	print(love.window.setMode(1200, 600))
end

function love.draw()
	funcPurple = otop.orangeToPurple(orange)
	cameraPurple(funcPurple, 100, 100)
	putil.genGlyphBounds(funcPurple)
	love.graphics.clear(1, 1, 1)
	drawPurple(funcPurple)
	drawSymbols()
end
