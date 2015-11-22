local l_gfx = love.graphics


-- The Button class definition
-- highlights when mouse over it
-- does stuff if clicked
-- has caption
-- somewhat cute

Button = {}
Button.__index = Button
Button.ident = "ui_button"
Button.caption = "Button"
Button.colorHighlight = {160,160,160,128}
Button.name = "Button"
Button.showBorder = false
function Button:new(name)
	local self = {}
	setmetatable(self,Button)
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Button,{__index = UIElement}) -- inherits from UIElement class, inherits its input methods and stuff


function Button:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	if self:isMouseOver() == true and self.active == true then
		l_gfx.setColor(self.colorHighlight)
	else
		l_gfx.setColor(self.colorFill)
	end
	l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	if self.showBorder == true then
		l_gfx.setColor(self.colorLine)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	end
	if self.active == true then
		l_gfx.setColor(self.colorFont)
	else 
		l_gfx.setColor(self.colorDisabledFill)
	end
	l_gfx.printf(self.caption,self.x,self.y+(self.h/2-7),self.w,"center")
	l_gfx.setColor(cr,cg,cb,ca)
end