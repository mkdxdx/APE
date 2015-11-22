local l_gfx = love.graphics

PointPlotter = {}
PointPlotter.__index = PointPlotter
PointPlotter.ident = "ui_pointplotter"
PointPlotter.name = "PointPlotter"
PointPlotter.drawable = true
PointPlotter.updateable = false
PointPlotter.input = true
PointPlotter.colorPoint = {0,255,255,255}
PointPlotter.sx = 1
PointPlotter.sy = 1
PointPlotter.showBorder = true
function PointPlotter:new(name)
	local self = setmetatable({},PointPlotter)
	self.name = name or self.name
	self.points = {}
	return self
end

function PointPlotter:addItem(x,y,n)
	local indx = #self.points+1
	local pt = {}
	pt[1] = x
	pt[2] = y
	pt[3] = n or ""
	pt[4] = self.colorPoint
	self.points[indx] = pt
	return self.points[indx]
end

function PointPlotter:setItemValue(index,x,y,n)
	self.points[index][1] = x or self.points[index][1]
	self.points[index][2] = y or self.points[index][2]
	self.points[index][3] = n or self.points[index][3]
end

function PointPlotter:clear()
	local c = #self.points
	if c>0 then
		for i=c,1,-1 do
			self.points[i][1] = nil
			self.points[i][2] = nil
			self.points[i][3] = nil
			self.points[i][4] = nil
			table.remove(self.points,i)
		end
	end
end

function PointPlotter:delItem(index)
	self.points[index][1] = nil
	self.points[index][2] = nil
	self.points[index][3] = nil
	self.points[index][4] = nil
	table.remove(self.points,index)
end

function PointPlotter:setScale(sx,sy)
	self.sx = sx or self.sx
	self.sy = sy or self.sy
end

function PointPlotter:draw()
	local cr,cg,cb,ca = l_gfx.getColor()
	local px,py = self:getPosition()
	if self.showBorder == true then
		l_gfx.rectangle("line",px,py,self.w,self.h)
	end
	local c = #self.points
	if c>0 then
		
		for i=1,c do
			local pt = self.points[i]
			l_gfx.setColor(pt[4])
			l_gfx.point(px+pt[1]+self.sx,py+pt[2]*self.sy)
			l_gfx.print(pt[3],px+pt[1]*self.sx+4,py+pt[2]*self.sy+4)
		end
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

setmetatable(PointPlotter,{__index = UIElement})