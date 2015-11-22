PlayerController = {}
PlayerController.__index = PlayerController
PlayerController.name = "PlayerController"
PlayerController.ident = "ui_playercontroller"
PlayerController.updateable = true
function PlayerController:new(name)
	local self = setmetatable({},PlayerController)
	self.name = name or self.name
	self.ui_elements = {}
	return self
end
setmetatable(PlayerController,{__index = Element})

function PlayerController:init()
	
end

function PlayerController:keypressed(key,isrepeat)
	if self.entity ~= nil then
		self.entity:keypressed(key,isrepeat)
	end
end

function PlayerController:keyreleased(key)
	if self.entity~=nil then
		self.entity:keyreleased(key)
	end
end

function PlayerController:setEntity(entity)
	self.entity = entity
end

function PlayerController:getEntity() return self.entity end

function PlayerController:update(dt) end