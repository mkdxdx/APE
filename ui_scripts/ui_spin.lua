local l_gfx = love.graphics

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
Spin.colorHighlight = {128,128,128,128}
Spin.name = "Spin"
Spin.caption_xpad = -4
Spin.caption_ypad = 0
function Spin:new(name)
	local self = {}
	setmetatable(self,Spin)
	self.value = 0
	self.step = 1
	self.step_mult = 1
	self.allowMult = false
	self.displMult = false
	self.mult_coarse = 10
	self.mult_base = 1
	self.mult_precise = 0.1
	self.mult_turbo = 100
	self.max = nil
	self.min = nil
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Spin,{__index = UIElement})

function Spin:click(b)
	if b == "wu" then
		self:increment()
		self:changeValue()
	elseif b == "wd" then
		self:decrement()
		self:changeValue()
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
	if self:isMouseOver() == true then
		if self.displMult == true then
			
			local str = "x"..self.step_mult*self.step
			l_gfx.setColor(self.colorHardFill)
			l_gfx.rectangle("fill",self.x+self.w+2,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str)+2,14)
			l_gfx.setColor(self.dFontColor)
			l_gfx.rectangle("line",self.x+self.w+2,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str),14)
			l_gfx.setColor(self.dFontColor)
			l_gfx.print(str,self.x+self.w+2,self.y+(self.h/2-7))
		end
		l_gfx.setColor(self.colorHighlight)
	else
		l_gfx.setColor(self.dFillColor)
	end
	l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	l_gfx.setColor(self.dFontColor)
	--local factor = 1/(self.step*self.step_mult)
	--local factor = 1
	--local v = math.floor(self.value*factor)/factor
	local v = "±"..self.value
	
	l_gfx.printf(v,self.x,self.y+(self.h/2-7),self.w,"center")
	if self.leftCaption == true then
		l_gfx.print(self.caption,self.x-l_gfx:getFont():getWidth(self.caption)+self.caption_xpad,self.y+(self.h/2-7)+self.caption_ypad)
	else
		l_gfx.print(self.caption,self.x+self.caption_xpad,self.y-14+self.caption_ypad)
	end
	
	l_gfx.setColor(cr,cg,cb,ca)
end

function Spin:changeValue() end
function Spin:setValue(value) self.value = value end
