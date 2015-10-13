local l_gfx = love.graphics


-- particle emitter element
-- made specifically for particle editor
-- so it may not meet your needs

ParticleEmitter = {}
ParticleEmitter.__index = ParticleEmitter
ParticleEmitter.ident = "ui_particleemitter"
ParticleEmitter.name = "ParticleEmitter"
ParticleEmitter.updateable = true
ParticleEmitter.x = 0
ParticleEmitter.y = 0
ParticleEmitter.followMouse = false -- if true it will follow the cursor
ParticleEmitter.mode = l_gfx.getBlendMode()
function ParticleEmitter:new(name,tex)
	local self = {}
	setmetatable(self,ParticleEmitter)
	self.ps = l_gfx.newParticleSystem(tex,10)
	self.ps:setEmissionRate(1)
	self.ps:setEmitterLifetime(-1)
	self.ps:setSizes(1)
	self.ps:setParticleLifetime(1)
	if name ~= nil then self.name = name end
	return self
end

setmetatable(ParticleEmitter,{__index = UIElement})

function ParticleEmitter:draw()
	local bm = l_gfx.getBlendMode()
	l_gfx.setBlendMode(self.mode)
	l_gfx.draw(self.ps)
	l_gfx.setBlendMode(bm)
end

function ParticleEmitter:update(dt)
	self.ps:update(dt)
end

function ParticleEmitter:mousemoved(x,y)
	if self.followMouse == true then
		self.ps:moveTo(x,y)
	end
end