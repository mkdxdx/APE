local l_gfx = love.graphics

-- RadioButton component is the one that can create groups of switches with only one switched on, usage:
--[[

	local rb1 = RadioButton:new("RB1")
	local rb2 = RadioButton:new("RB2")
	local rb3 = RadioButton:new("RB3")
	
	local rbgroup = {rb1,rb2,rb3}
	
	for i=1,3 do
		rbgroup[i]:setGroup(rbgroup)
	end
	
	-- clicking on one radiobutton will make it checked, and every other in this group unchecked
]]

RadioButton = {}
RadioButton.__index = RadioButton
RadioButton.ident = "ui_radiobutton"
RadioButton.name = "RadioButton"
RadioButton.caption = "RadioButton"
RadioButton.colorHighlight = {192,192,192,128}
RadioButton.w = 16
RadioButton.h = 16
RadioButton.buttonStyle = false -- if true, it will be drawn as a button
function RadioButton:new(name)
	local self = {}
	setmetatable(self,RadioButton)
	self.group = {self} -- group array this radiobutton belongs to
	self.checked = false
	if name ~= nil then self.name = name end
	return self
end
setmetatable(RadioButton,{__index = UIElement})


function RadioButton:mousepressed(x,y,b) 
	if self:isMouseOver(x,y) then 
		if b == "l" then
			local c = #self.group
			if c>0 then
				for i=1,c do
					if self.group[i].name ~= self.name then
						self.group[i].checked = false
					end
				end
			end
			self.checked = true
		end
		self:click(b) 
	end 
end


-- this sets radiobutton group
function RadioButton:setGroup(group)
	self.group = group or {self}
end

-- and this gives an index of a checked radiobutton in this group
function RadioButton:getGroupIndex()
	local c = #self.group
	if c>0 then
		for i=1,c do
			if self.group[i].checked == true then return i end
		end
	end
end

function RadioButton:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	if self.buttonStyle == true then
		if self.checked == true then
			l_gfx.setColor(self.colorHighlight)
		else
			l_gfx.setColor(self.dFillColor)
		end
		if self.active == false then
			l_gfx.setColor(self.colorDisabledFill)
		end
		l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
		if self.active == true then
			l_gfx.setColor(self.dFontColor)
		else
			l_gfx.setColor(self.dFillColor)
		end
		l_gfx.printf(self.caption,self.x,self.y+(self.h/2-7),self.w,"center")
	else
		l_gfx.setColor(self.colorHighlight)
		l_gfx.circle("line",self.x+8,self.y+8,8,16)
		if self.checked == true then
			l_gfx.setColor(self.colorHighlight)
			l_gfx.circle("fill",self.x+8,self.y+8,6,12)
		end
		if self.active == true then
			l_gfx.setColor(self.dFontColor)
		else
			l_gfx.setColor(self.dFillColor)
		end
		l_gfx.print(self.caption,self.x+20,self.y+2)
	end
	l_gfx.setColor(cr,cg,cb,ca)
end

-- this element is specifically for particle editor
-- its buttons are colored and are highlighted with a frame upon checking
RadioColorPicker = {}
RadioColorPicker.__index = RadioColorPicker
RadioColorPicker.ident = "ui_radiocolorpicker"
RadioColorPicker.name = "RadioColorPicker"
RadioColorPicker.caption = ""
RadioColorPicker.colorHighlight = {192,192,192,192}
function RadioColorPicker:new(name)
	local self = {}
	setmetatable(self,RadioColorPicker)
	self.group = {self}
	self.checked = false
	self.color = {255,255,255,255}
	if name ~= nil then self.name = name end
	return self
end
setmetatable(RadioColorPicker,{__index = RadioButton})

function RadioColorPicker:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	if self.checked == true then
		l_gfx.setColor(self.colorHighlight)
	else
		l_gfx.setColor(self.dFillColor)
	end
	if self.active == false then
		l_gfx.setColor(self.colorDisabledFill)
	end
	l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	
	if self.active == true then
		l_gfx.setColor(self.color)
	else
		l_gfx.setColor(self.colorDisabledFill)
	end
	l_gfx.rectangle("fill",self.x+1,self.y+1,self.w-2,self.h-2)	
	l_gfx.setColor(cr,cg,cb,ca)
end

function RadioColorPicker:setColor(r,g,b,a)
	self.color = {r or 255,g or 255,b or 255,a or 255}
end