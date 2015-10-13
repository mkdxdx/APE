-- root element class
-- defines the element itself, usually invisible and is usefull for elements
-- which are invisible but have their purpose (e.g. Timer element, or Collection element)

Element = {}
Element.__index = Element

Element.active = true -- putting this to true will make UIManager to handle this object, like updating, drawing, etc...
Element.drawable = false -- putting this to true will make UIManager to try to draw this element by calling its draw() method
Element.input = true -- this will make UIManager to send input to this object by firing according methods
Element.updateable = false -- this will make UIManager to try to invoke update(dt) method
Element.name = "Element" -- this identifier should be unique to every element you create, so then you can find it without storing a reference variable
Element.ident = "ui_element" -- this is a type identifier, for, say "make all buttons go invisible" or something
function Element:new(name) -- element instancing
	local self = {}
	setmetatable(self,Element)
	if name ~= nil then self.name = name end -- if name is not specified, it will use its default name
	return self
end


-- all the methods are usually fired by uimanager
function Element:getName() return self.name end
function Element:oncreate() end
function Element:keypressed(key,isrepeat) end
function Element:keyreleased(key) end
function Element:mousepressed(x,y,b) end
function Element:mousereleased(x,y,b) end
function Element:mousemoved(x,y) end