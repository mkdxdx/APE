local l_gfx = love.graphics

-- these are various UI shapes


Rectangle = {}
Rectangle.__index = Rectangle
Rectangle.ident = "ui_rectangle"
Rectangle.name = "Rectangle"
Rectangle.centerOnPos = false
function Rectangle:new(name)
	local self = {}
	setmetatable(self,Rectangle)
	self.mode = "fill"
	if name ~= nil then self.name = name end
	return self
end

setmetatable(Rectangle,{__index = UIElement})

function Rectangle:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.dFillColor)
	if self.centerOnPos == true then
		l_gfx.rectangle(self.mode,self.x-self.w/2,self.y-self.h/2,self.w,self.h)
	else
		l_gfx.rectangle(self.mode,self.x,self.y,self.w,self.h)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end



Circle = {}
Circle.__index = Circle
Circle.ident = "ui_circle"
Circle.name = "Circle"
Circle.centerOnPos = false
function Circle:new()
	local self = {}
	setmetatable(self,Circle)
	self.mode = "fill"
	self.radius = 32
	self.segments = 20
	if name ~= nil then self.name = name end
	return self
end

setmetatable(Circle,{__index = UIElement})

function Circle:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.dFillColor)
	if self.centerOnPos == true then
		l_gfx.circle(self.mode,self.x,self.y,self.radius,self.segments)
	else
		l_gfx.circle(self.mode,self.x+self.radius,self.y+self.radius,self.radius,self.segments)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

Line = {}
Line.__index = Line
Line.ident = "ui_line"
Line.name = "Line"
Line.horizontal = false
function Line:new(name)
	local self = {}
	setmetatable(self,Line)
	if name ~= nil then self.name = name end
	return self
end

setmetatable(Line,{__index = UIElement})

function Line:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.dFillColor)
	if self.horizontal == true then
		l_gfx.line(self.x.self.y,self.x+self.w,self.y)
	else
		l_gfx.line(self.x,self.y,self.x,self.y+self.h)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

Cross = {}
Cross.__index = Cross
Cross.name = "Cross"
Cross.ident = "ui_cross"
Cross.centerOnPos = false
function Cross:new(name)
	local self = {}
	setmetatable(self,Cross)
	
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Cross,{__index = UIElement})

function Cross:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	local bm = l_gfx.getBlendMode()
	l_gfx.setBlendMode(self.blendMode)
	l_gfx.setColor(self.dLineColor)
	if self.centerOnPos == true then
		l_gfx.line(self.x-self.w/2,self.y,self.x+self.w/2,self.y)
		l_gfx.line(self.x,self.y-self.h/2,self.x,self.y+self.h/2)
	else
		l_gfx.line(self.x,self.y+self.h/2,self.x+self.w,self.y+self.h/2)
		l_gfx.line(self.x+self.w/2,self.y,self.x+self.w/2,self.y+self.h)
	end
	l_gfx.setBlendMode(bm)
	l_gfx.setColor(cr,cg,cb,ca)
end

Arc = {}
Arc.__index = Arc
Arc.name = "Arc"
Arc.ident = "ui_arc"
Arc.centerOnPos = true
Arc.mode = "fill"
Arc.segments = 20
function Arc:new(name)
	local self = {}
	setmetatable(self,Arc)
	self.a1 = 0
	self.a2 = 0
	self.radius = 16
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Arc,{__index = UIElement})

function Arc:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	l_gfx.setColor(self.dFillColor)
	if self.centerOnPos == true then
		l_gfx.arc(self.mode,self.x,self.y,self.radius,self.a1,self.a2,self.segments)
	else
		l_gfx.arc(self.mode,self.x+self.radius,self.y+self.radius,self.radius,self.a1,self.a2,self.segments)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

function Arc:setAngle(a1,a2)
	self.a1,self.a2 = a1 or self.a1,a2 or self.a2
end