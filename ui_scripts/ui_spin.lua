local l_gfx = love.graphics
local mouse = love.mouse
local tostring = tostring
local format = string.format
-- this is a spin element
-- currently it's only way of control is by mousewheel, wheelup increases the value by a step, wheeldown decreases
-- it also has mutlipliers, like precise multiplier, base multiplier, coarse and turbo multipliers
-- if you press left shift, or left ctrl or left alt while mouse over the spin element, you will switch its step multiplier and show its value in a box to the right
-- multipliers are redefinable on runtime as well as you can deny it from use step multipliers at all
-- its changeValue() method is fired on every increase or decrease

Spin = {}
Spin.__index = Spin
Spin.ident = "ui_spin"
Spin.leftCaption = false
Spin.w = 48
Spin.h = 16
Spin.caption = "Spin"
Spin.name = "Spin"
Spin.caption_xpad = -4
Spin.caption_ypad = 0
Spin.updateable = true
Spin.maxdec = 1
function Spin:new(name)
	local self = {}
	setmetatable(self,Spin)
	self.value = 0
	self.step = 1
	self.step_mult = 1
	self.isHeld = false
	self.allowMult = false
	self.displMult = false
	self.mult_coarse = 10
	self.mult_base = 1
	self.mult_precise = 0.1
	self.mult_turbo = 100
	self.held_timer = 0
	self.max = nil
	self.min = nil
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Spin,{__index = UIElement})

function Spin:click(b)
	if b == 1 then
		self.isHeld = true	
		local mx,my = mouse.getPosition()
		if self:isMouseOver() then
			if mx>=self.x+self.w/2 then self:increment() else self:decrement() end
			self:changeValue()
		end
	end
end

function Spin:wheelmoved(x,y)
	local mx,my = love.mouse.getPosition()
	if self:isMouseOver(mx,my) then
		if y > 0 then
			self:increment()
			self:changeValue()
		elseif y < 0 then
			self:decrement()
			self:changeValue()
		end
	end
end

function Spin:update(dt)
	if self.isHeld == true then
		self.held_timer = self.held_timer + dt
		if self.held_timer>0.5 then
			local mx,my = mouse.getPosition()
			if self:isMouseOver() then
				if mx>=self.x+self.w/2 then self:increment() else self:decrement() end
				self:changeValue()
			end
		end
	end
end

function Spin:unclick(b)
	if b == 1 then
		self.isHeld = false
		self.held_timer = 0
	end
end

function Spin:increment()
	if self.max ~= nil then
		if self.value<=self.max-self.step*self.step_mult then self.value = self.value + self.step*self.step_mult end
	else
		self.value = self.value + self.step*self.step_mult
	end
end

function Spin:decrement()
	if self.min ~= nil then
		if self.value>=self.min+self.step*self.step_mult then self.value = self.value - self.step*self.step_mult end 
	else
		self.value = self.value - self.step*self.step_mult
	end
end

function Spin:keypressed(key) 
	if self.allowMult == true then
		if key == "lshift" then
			self.step_mult = self.mult_coarse
			self.displMult = true
		elseif key == "lctrl" then
			self.step_mult = self.mult_precise
			self.displMult = true
		elseif key == "lalt" then
			self.step_mult = self.mult_turbo
			self.displMult = true
		end
	end
end

function Spin:keyreleased(key) 
	if key == "lshift" or key == "lctrl" or key == "lalt" then
		self.step_mult = self.mult_base
		self.displMult = false
	end
end

function Spin:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	local dynwidth = self.w
	local deccnt = self.maxdec
	local v = format("%."..deccnt.."f",self.value)	
	if self:isMouseOver() == true then
		if dynwidth<l_gfx.getFont():getWidth(tostring(v)) then
			dynwidth = l_gfx.getFont():getWidth(tostring(v)) + 2
		end
	end
	if self.active == true then
		l_gfx.setColor(self.colorFill)
	else
		l_gfx.setColor(self.colorDisabledFill)
	end
	l_gfx.rectangle("fill",self.x,self.y,dynwidth,self.h)
	if self:isMouseOver() == true then
		local mx,my = mouse:getPosition()
		l_gfx.setColor(self.colorHighlight)
		if mx>=self.x+dynwidth/2 then 
			l_gfx.rectangle("fill",self.x+dynwidth/2,self.y,dynwidth/2,self.h)
		else
			l_gfx.rectangle("fill",self.x,self.y,dynwidth/2,self.h)
		end
		if self.displMult == true then
			local str = "x"..self.step_mult*self.step
			l_gfx.setColor(self.colorFill)
			l_gfx.rectangle("fill",self.x+dynwidth,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str)+2,14)
			l_gfx.setColor(self.colorHighlight)
			l_gfx.rectangle("line",self.x+dynwidth,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str),14)
			l_gfx.setColor(self.colorFont)
			l_gfx.print(str,self.x+dynwidth,self.y+(self.h/2-7))
		end
		l_gfx.setColor(self.colorFill)
	else
		
	end
	
	l_gfx.setColor(self.colorFont)
	while l_gfx.getFont():getWidth(tostring(v))>=dynwidth do
		deccnt = deccnt - 1
		if deccnt<0 then v = "..." break end
		v = format("%."..deccnt.."f",self.value)
	end
	local sh = self.h/2-7
	l_gfx.printf(v,self.x,self.y+sh,dynwidth,"center")
	if self.leftCaption == true then
		l_gfx.print(self.caption,self.x-l_gfx:getFont():getWidth(self.caption)+self.caption_xpad,self.y+(self.h/2-7)+self.caption_ypad)
	else
		l_gfx.print(self.caption,self.x+self.caption_xpad,self.y-14+self.caption_ypad)
	end
	
	l_gfx.setColor(cr,cg,cb,ca)
end

function Spin:changeValue() end
function Spin:setValue(value) self.value = value end


-- Editable spin, once hovered over, receives text input
SpinEdit = {}
SpinEdit.__index = SpinEdit
SpinEdit.ident = "ui_spinedit"
SpinEdit.name = "SpinEdit"
-- Yes, it does look crude, but i cannot use dot or comma as assoc.array key like arr = {. = '.'}
local ac = {}
ac['1'] = '1'
ac['2'] = '2'
ac['3'] = '3'
ac['4'] = '4'
ac['5'] = '5'
ac['6'] = '6'
ac['7'] = '7'
ac['8'] = '8'
ac['9'] = '9'
ac['0'] = '0'
ac['.'] = '.'
ac[','] = '.'
ac['kp1'] = '1'
ac['kp2'] = '2'
ac['kp2'] = '3'
ac['kp3'] = '3'
ac['kp4'] = '4'
ac['kp5'] = '5'
ac['kp6'] = '6'
ac['kp7'] = '7'
ac['kp8'] = '8'
ac['kp9'] = '9'
ac['kp0'] = '0'
SpinEdit.allowedChars = ac
function SpinEdit:new(name)
	local self = setmetatable({},SpinEdit)
	self.name = name or self.name
	self.value = 0
	self.step = 1
	self.step_mult = 1
	self.isHeld = false
	self.allowMult = false
	self.displMult = false
	self.mult_coarse = 10
	self.mult_base = 1
	self.mult_precise = 0.1
	self.mult_turbo = 100
	self.held_timer = 0
	self.max = nil
	self.min = nil
	return self
end
setmetatable(SpinEdit,{__index = Spin})

function SpinEdit:keypressed(key) 
	if self.allowMult == true then
		if key == "lshift" then
			self.step_mult = self.mult_coarse
			self.displMult = true
		elseif key == "lctrl" then
			self.step_mult = self.mult_precise
			self.displMult = true
		elseif key == "lalt" then
			self.step_mult = self.mult_turbo
			self.displMult = true
		end
	end
	if self:isMouseOver() == true then
		local rk = self.allowedChars[key]
		if rk ~= nil then
			
			
		end
	end
end

function SpinEdit:keyreleased(key) 
	if key == "lshift" or key == "lctrl" or key == "lalt" then
		self.step_mult = self.mult_base
		self.displMult = false
	end
end
