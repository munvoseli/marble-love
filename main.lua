font = love.graphics.newFont("charis.ttf", 30)
love.graphics.setFont(font)

local otoc = require("otoc")
local otop = require("otop")

local funcPurple = otop.emptyPurple()

local orange = {
	type = "multiline",
	lines = {}
}
local globCursor = {}
globCursor.curt = "none"


local extsymb = {
	func = {
		{
			"printint",
			"r", "int"
		},{
			"add",
			"w", "int",
			"r", "int",
			"r", "int"
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
		local x = p.glyphs[i].xa
		local y = p.glyphs[i].ya
		local w = p.glyphs[i].xb - x
		local h = p.glyphs[i].yb - y
		local g = p.glyphs[i]
		--local c = g.bgclr
		--love.graphics.setColor(c[1], c[2], c[3])
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.rectangle("fill", x, y, w, h)
		if p.glyphs[i].ref.symb then
			--local c = g.fgclr
			--love.graphics.setColor(c[1], c[2], c[3])
			love.graphics.setColor(0.7, 0.7, 0.7)
			love.graphics.print(p.glyphs[i].ref.symb, x, y)
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if x > 600 then
		
	else
		local curs = mouseToCursor(funcPurple)
		if #curs > 0 then
			print(curs[1].curt .. " " .. table.concat(curs[1], " "))
			globCursor = curs[1]
		end
	end
end

local function cameraPurple(p, w, h)
	otop.translatePurple(p, -p.xa, -p.ya)
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
				cur[#cur] = cur[#cur] + 1
			end
			for l=1,#s do
				table.remove(line, k)
			end
			cur[#cur] = cur[#cur] - #s
			local go = {}
			go.type = "gly"
			if s == "a" then -- assign
				go.symb = "A"
			elseif s == "add" then
				go.symb = "+"
			elseif s == "in" then
				go.symb = "B"
			end
			if go.symb ~= nil then
				table.insert(line, k, go)
			else
				cur[#cur] = cur[#cur] - 1
			end
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
	print(love.window.setMode(1200, 600))
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
	funcPurple = otop.getPurple(orange)
	cameraPurple(funcPurple, 100, 100)
	purpleGenGlyphBounds(funcPurple)
	love.graphics.clear(1, 1, 1)
	drawPurple(funcPurple)
	drawSymbols()
	hd = hd + 1
end
