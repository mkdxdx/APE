--[[
	Simple UI library for LOVE2D by cval
	
	Made specifically for particle editor, but can be used anywhere you can put it.
	This library was written for LOVE2D version 0.9.2 (the one with quads in particle system, hooray!)
	
	USAGE EXAMPLE: 
	
	-- include library into your project
	require("ui") 
	
	-- preferrable if it's additional files are in the same directory with ui.lua script
	-- ui_scrdir variable is for convenience
	
	-- create ui manager (preferrably in love.load())
	uimanagername = UIManager:new()
	
	-- after this you should also include:
	-- uimanagername:draw() into love.draw() function
	-- uimanagername:update(dt) into love.update(dt) function
	-- uimanagername:mousemoved(x,y) into love.mousemoved(x,y) function
	-- uimanagername:mousepressed(x,y,b) into love.mousepressed(x,y,b) function
	-- uimanagername:mousereleased(x,y,b) into love.mousereleased(x,y,b) function
	-- uimanagername:keypressed(key,isrepeat) into love.keypressed(key,isrepeat) function
	-- uimanagername:keyreleased(key) into love.keyreleased(key) function
	
	-- now after you defined your UIManager, you can add your ui elements into it, e.g.
	-- syntax as follows: 
	-- uimanagername:addItem(Component:new("ComponentName"))
	-- addItem function also returns pointer to that element, so you can put it into variable:
	-- local component = uimanagername:addItem(Component:new("ComponentName"))
	
	-- adding a button with ui name "Button1" (for referencing it in uimanager), set its caption to "New button!" and set its position to 4,4
	
	button = uimanagername:addItem(Button:new("Button1"))
	button.caption = "New button!"
	button:setPosition(4,4)
	
	-- after this you can define its action if you click on it, for example make it change its caption on left mouse button press:
	
	function button:click(b)
		if b == "l"
			button.caption = "Button is clicked!"
		end
	end
	
	-- adding a groupbox container, and then add another button into it:
	
	local groupbox = uimanagername:addItem(GroupBox:new("GroupBox"))
	local gbbutton = groupbox:addItem(Button:new("GBButton"))
	gbbuton.caption = "Button in a groupbox!"
	
	-- note that not every element with addItem method is able to receive another element (Listboxes usually receive strings)

]]


require(ui_scrdir.."ui_element")
require(ui_scrdir.."ui_uielement")
require(ui_scrdir.."ui_button")
require(ui_scrdir.."ui_label")
require(ui_scrdir.."ui_groupbox")
require(ui_scrdir.."ui_spin")
require(ui_scrdir.."ui_shape")
require(ui_scrdir.."ui_checkbox")
require(ui_scrdir.."ui_pageswitch")
require(ui_scrdir.."ui_radiobutton")
require(ui_scrdir.."ui_progressbar")
require(ui_scrdir.."ui_particleemitter")
require(ui_scrdir.."ui_imagecollection")
require(ui_scrdir.."ui_listbox")
require(ui_scrdir.."ui_image")
require(ui_scrdir.."ui_collection")
require(ui_scrdir.."ui_timer")

local l_gfx = love.graphics


-- define UIManager "class": the one that handles all the buttons and labels,draws them, updates them and handles inputs
UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
	local self = {}
	setmetatable(self,UIManager)
	self.items = {}
	self.drawList = {}
	self.updateList = {}
	self.inputList = {}
	return self
end

function UIManager:addItem(item)
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
	item:oncreate()
	return item
end

function UIManager:getItem(name)
	local c = table.getn(self.items)
	if c>0 then
		for i=1,c do
			if self.items[i]:getName() == name then
				return self.items[i]
			end
		end
	else
		return nil
	end
end

function UIManager:draw()
	local dl = self.drawList
	local c = table.getn(dl)
	if c>0 then
		for i=1,c do
			if dl[i].visible == true then dl[i]:draw() end
		end
	end
end

function UIManager:update(dt)
	local ul = self.updateList
	local c = table.getn(ul)
	if c>0 then
		for i=1,c do
			if ul[i].active == true then ul[i]:update(dt) end
		end
	end
end

function UIManager:mousemoved(x,y)
	local ill = self.inputList
	for i,v in ipairs(ill) do
		if v.active == true then v:mousemoved(x,y) end
	end
end

function UIManager:mousepressed(x,y,b)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:mousepressed(x,y,b) end
	end
end

function UIManager:mousereleased(x,y,b)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:mousereleased(x,y,b) end
	end
end

function UIManager:keypressed(key,isrepeat)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:keypressed(key,isrepeat) end
	end
end

function UIManager:keyreleased(key)
	for i,v in ipairs(self.inputList) do
		if v.active == true then v:keyreleased(key) end
	end
end



