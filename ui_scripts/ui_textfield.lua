local l_gfx = love.graphics
local utf8 = require("utf8")

TextField = {}
TextField.__index = TextField
TextField.name = "TextField"
TextField.ident = "ui_textfield"
TextField.inContext = false
TextField.limit = 26
TextField.align = "left"
function TextField:new(name)
	local self = setmetatable({},TextField)
	self.name = name or self.name
	self.text = ""
	return self
end
setmetatable(TextField,{__index = UIElement})

function TextField:draw()
	local cr,cg,cb,ca = l_gfx.getColor()
	l_gfx.setColor(self.colorFill)
	l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	l_gfx.setColor(self.colorFont)
	l_gfx.printf(self.text,self.x,self.y,self.w,self.align)
	if self.inContext == true then
		l_gfx.setColor(self.colorLine)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

function TextField:mousepressed(x,y,b)
	if self:isMouseOver(x,y) then
		if b == "l" then
			self.inContext = true
		end
		self:click(b)
	else 
		self.inContext = false
	end
end

function TextField:keypressed(key,isrepeat)
	if self.inContext == true and #self.text>0 and key == "backspace" then
		local l = string.len(self.text)
		if l>0 then
			self.text = string.sub(self.text,1,l-1)
		end
	end
end

function TextField:textinput(t)
	if self.inContext == true and #self.text<=self.limit then
		self.text = self.text .. t
	end
end

function TextField:clear()
	self.text = ""
end