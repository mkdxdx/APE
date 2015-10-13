local l_gfx = love.graphics

-- an updateable element which can show values, or can be updated manually without defining its update behavior

ProgressBar = {}
ProgressBar.__index = ProgressBar
ProgressBar.ident = "ui_progressbar"
ProgressBar.name = "ProgressBar"
ProgressBar.caption = "ProgressBar"
ProgressBar.updateable = true
ProgressBar.colorHighlight = {192,192,192,128}
ProgressBar.w = 128
function ProgressBar:new()
	local self = {}
	setmetatable(self,ProgressBar)
	if name ~= nil then self.name = name end
	self.value = 0
	self.max = 100
	self.showCaption = false
	return self
end
setmetatable(ProgressBar,{__index = UIElement})

function ProgressBar:draw() 
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.dFillColor)
	l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	l_gfx.setColor(self.colorHighlight)
	local factor = math.min(1,self.value/self.max)
	l_gfx.rectangle("fill",self.x,self.y,self.w*factor,self.h)
	l_gfx.setColor(self.dFontColor)
	l_gfx.printf(self.value.."/"..self.max,self.x,self.y+(self.h/2-7),self.w,"center")
	if self.showCaption == true then
		l_gfx.print(self.caption,self.x,self.y-16)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end
