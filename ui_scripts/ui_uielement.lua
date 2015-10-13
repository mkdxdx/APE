-- this is a definition of drawable UI element

UIElement = {}
UIElement.__index = UIElement
UIElement.x = 0
UIElement.y = 0
UIElement.w = 32
UIElement.h = 32
UIElement.visible = true -- UI manager will not draw this element if false
UIElement.active = true -- UI manager will not update, will not handle inputs for this element if false
UIElement.drawable = true -- initial definition: elements created with this flag true are inserted into UIManager's drawing loop
UIElement.input = true
UIElement.updateable = false
UIElement.dFillColor = {96,96,96,128} -- default fill color, you can change it in definition or at runtime for specific instance
UIElement.colorDisabledFill = {32,32,32,128} 
UIElement.dLineColor = {192,192,192,128}
UIElement.dFontColor = {255,255,255,255}
UIElement.colorHardFill =  {64,64,64,255}
UIElement.ident = "ui_uielement"
UIElement.name = "UIElement"
UIElement.caption_xpad = 0 -- if element has caption in it, it will draw caption with shift text's position with these coordinates
UIElement.caption_ypad = 0
UIElement.blendMode = "alpha" -- can be used for element to change its blend mode while drawing
function UIElement:new(name)
	local self = {}
	setmetatable(self,UIElement)
	if name ~= nil then self.name = name end
	return self
end
setmetatable(UIElement,{__index = Element}) -- drawable UIElement inherits stuff from Element

function UIElement:update(dt) end
function UIElement:draw() end -- since its a drawable class, it should have its draw method %)
function UIElement:mousepressed(x,y,b) if self:isMouseOver(x,y) then self:click(b) end end
function UIElement:mousereleased(x,y,b) if self:isMouseOver(x,y) then self:unclick(b) end end
function UIElement:mousemoved(x,y) end
function UIElement:onHover() end -- currently doesnt have its uses, maybe one day
function UIElement:click(b) end -- this function defines your element's behaviour when user clicks on it
function UIElement:unclick(b) end -- ... and when releases a mouse button
function UIElement:isMouseOver(x,y) -- checks whether or not mouse pointer touches element's box (from its x,y position up to its width and height)
	local mx,my = love.mouse:getPosition() 
	x = x or mx 
	y = y or my 
	if x>=self.x and x<=self.x+self.w and y>=self.y and y<=self.y+self.h then 
		return true 
	else 
		return false 
	end 
end
function UIElement:hide(act) self.visible = false self.active = act or false end -- hides an element and makes it inactive if argument is not specified
function UIElement:show(act) self.visible = true self.active = act or true end -- shows an element and makes it active if argument is not specified
function UIElement:setPosition(x,y) self.x = x or self.x self.y = y or self.y end -- sets element's position
function UIElement:setSize(w,h) self.w = w or self.w self.h = h or self.h end -- sets element box size
