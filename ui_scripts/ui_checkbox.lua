local l_gfx = love.graphics

-- the checkbox class definition
-- looks like a rectangle in a rectangle, changes its state on click and does stuff

CheckBox = {}
CheckBox.__index = CheckBox
CheckBox.caption = "CheckBox"
CheckBox.ident = "ui_checkbox"
CheckBox.colorHighlight = {192,192,192,128}
CheckBox.name = "CheckBox"
CheckBox.w = 16
CheckBox.h = 16
function CheckBox:new(name)
	local self = {}
	setmetatable(self,CheckBox)
	if name ~= nil then self.name = name end
	self.checked = false
	return self
end
setmetatable(CheckBox,{__index = UIElement})

function CheckBox:mousepressed(x,y,b) 
	if self:isMouseOver(x,y) then 
	self.checked = not(self.checked) -- toggle checked state on click
	self:click(b)  -- and do stuff after it
	end 
end

function CheckBox:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.colorHighlight)
	l_gfx.rectangle("line",self.x,self.y,16,16)
	if self.checked == true then
		l_gfx.setColor(self.colorHighlight)
		l_gfx.rectangle("fill",self.x+2,self.y+2,12,12)
	end
	l_gfx.setColor(self.dFontColor)
	l_gfx.print(self.caption,self.x+18,self.y)
	l_gfx.setColor(cr,cg,cb,ca)
end