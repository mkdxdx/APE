-- An invisible timer element
-- you can define its trigger function and then start it, and after an interval it will fire that function
-- if single is false it will autoreload itself

Timer = {}
Timer.__index = Timer
Timer.ident = "ui_timer"
Timer.name = "Timer"
Timer.updateable = true
function Timer:new(name)
	local self = {}
	setmetatable(self,Timer)
	if name ~= nil then self.name = name end
	self.interval = 1
	self.t = 1
	self.isRunning = false
	self.single = true
	return self
end
setmetatable(Timer,{__index = Element})

function Timer:start() self.isRunning = true self.t = self.interval end
function Timer:update(dt) 
	if self.isRunning == true then 
		self.t = self.t-dt 
		if self.t<=0 then 
			self.t = self.interval
			self:trigger() 
			if 	self.single == true then 
				self:pause() 
			end 
		end 
	end
end
function Timer:pause() self.isRunning = false end
function Timer:resume() self.isRunning = true end
function Timer:stop() self.isRunning = false self.t = self.interval end
function Timer:trigger() end