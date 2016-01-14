local l_gfx = love.graphics

-- Groupbox is a container element. it can hold other ui elements, they will move with it on every SetPosition call if its isContainer field is true
-- also has caption, can be drawn borderless (showBorder = false) and can display corners
-- this element also will try to update updateables, draw drawables and handle inputs if added elements are ones

GroupBox = {}
GroupBox.__index = GroupBox
GroupBox.ident = "ui_groupbox"
GroupBox.caption = "GroupBox"
GroupBox.updateable = true
GroupBox.stenciled = false
GroupBox.name = "GroupBox"
GroupBox.showBorder = true
GroupBox.isContainer = true
GroupBox.caption_xpad = 4
GroupBox.caption_ypad = -16
GroupBox.captionAlign = "center"
GroupBox.colorBcgFill = {0,32,32,128}
GroupBox.showBackground = false
GroupBox.input = true

function GroupBox:new(name)
	local self = {}
	setmetatable(self,GroupBox)
	self.items = {}
	self.drawList = {}
	self.updateList = {}
	self.inputList = {}
	-- topleft,topright,bottomright,bottomleft corners
	self.cornerLT = false
	self.cornerRT = false
	self.cornerRB = false
	self.cornerLB = false
	if name ~= nil then self.name = name end
	return self
end
-- Group box is a mix between UIManager and UIElement. You could make child of either, but i decided to redefine UIManager's methods instead of UIElement's fields
setmetatable(GroupBox,{__index = UIElement})

function GroupBox:draw()
	local r,g,b,a = l_gfx.getColor()
	if self.showBackground == true then
		l_gfx.setColor(self.colorBcgFill)
		l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	end
	if self.showBorder == true then
		l_gfx.setColor(self.colorLine)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	else
		local c_width,c_height = self.w/2,self.h/2
		if self.cornerLT == true then
			l_gfx.setColor(self.colorLine)
			l_gfx.line(self.x,self.y,self.x,self.y+c_height)
			l_gfx.line(self.x,self.y,self.x+c_width,self.y)
		end
	end
	l_gfx.setColor(self.colorFont)
	l_gfx.printf(self.caption,self.x,self.y+self.caption_ypad,self.w,self.captionAlign)
	local dl = self.drawList
	local c = table.getn(dl)
	if c>0 then
		for i=1,c do
			if dl[i].visible == true then dl[i]:draw() end
		end
	end
	l_gfx.setColor(r,g,b,a)
end

function GroupBox:update(dt)
	local ul = self.updateList
	local c = table.getn(ul)
	if c>0 then
		for i=1,c do
			if ul[i].active == true then ul[i]:update(dt) end
		end
	end
end

function GroupBox:mousemoved(x,y,dx,dy)
	local ill = self.inputList
	for i,v in ipairs(ill) do
		if v.active == true then v:mousemoved(x,y,dx,dy) end
	end
end

function GroupBox:mousepressed(x,y,b)
	local r 
	if self:isMouseOver(x,y) == true then
		self:click(b)
	end
	for i,v in ipairs(self.inputList) do
		if v.active == true then local tr = v:mousepressed(x,y,b) if tr~=nil then r = tr end   end
	end
	return r
end

function GroupBox:wheelmoved(x,y)
	local r 
	for i,v in ipairs(self.inputList) do
		if v.active == true then local tr = v:wheelmoved(x,y) if tr~=nil then r = tr end   end
	end
	return r
end

function GroupBox:mousereleased(x,y,b)
	local r
	if self:isMouseOver(x,y) == true then
		self:unclick(b)
	end
	for i,v in ipairs(self.inputList) do
		if v.active == true then local tr = v:mousereleased(x,y,b) if tr~=nil then r = tr end   end
	end
	return r
end

function GroupBox:keypressed(key,isrepeat)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:keypressed(key,isrepeat) end
	end
end

function GroupBox:keyreleased(key)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:keyreleased(key) end
	end
end

function GroupBox:textinput(t)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:textinput(t) end
	end
end

function GroupBox:addItem(item)
	table.insert(self.items,item)
	if item.updateable == true then
		table.insert(self.updateList,item)
	end
	if item.drawable == true then
		table.insert(self.drawList,item)
	end
	if item.input == true then	
		table.insert(self.inputList,item)
	end
	return item
end

function GroupBox:getItem(name,deep)
	local c = #self.items
	if c>0 then
		for i=1,c do
			if self.items[i]:getName() == name then
				return self.items[i]
			elseif self.items[i].items ~= nil and deep == true then
				self.items[i]:getItem(name,deep)
			end
		end		
	end
	return nil
end

function GroupBox:setPosition(x,y)
	if self.isContainer == true then
		local dx,dy = (x or self.x) - self.x, (y or self.y) - self.y 
		local c = #self.items 
		if c>0 then
			for i=1,c do 
				local e = self.items[i]
				e:setPosition(e.x+dx,e.y+dy)
			end
		end
	end
	self.x,self.y = x or self.x, y or self.y
end

function GroupBox:onchangewindow(w,h) 
	for i,v in ipairs(self.items) do
		v:onchangewindow(w,h)
	end
end