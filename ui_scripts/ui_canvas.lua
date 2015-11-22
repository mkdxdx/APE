local l_gfx = love.graphics

UICanvas = {}
UICanvas.__index = UICanvas
UICanvas.ident = "ui_canvas"
UICanvas.mode = "additive"
function UICanvas:new(name)
	local self = setmetatable({},UICanvas)
	self.name = name or self.name
	return self
end
setmetatable(UICanvas,{__index = Image})

function UICanvas:create(x,y)
	self.canvas = l_gfx.newCanvas(x,y)
end

function UICanvas:draw()
	if self.canvas ~= nil then
		local bm = l_gfx.getBlendMode()
		local cr,cg,cb,ca = l_gfx.getColor()
		l_gfx.setColor(self.colorTint)
		l_gfx.setBlendMode(self.mode)
		l_gfx.draw(self.canvas,self.x,self.y)
		l_gfx.setBlendMode(bm)
		l_gfx.setColor(cr,cg,cb,ca)
		self.canvas:clear()
	end
end

function UICanvas:get()
	return self.canvas
end