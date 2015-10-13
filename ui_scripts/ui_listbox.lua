local l_gfx = love.graphics

-- simple list box with index and clickable string list
-- usually linked to collection in its behavior

ListBox = {}
ListBox.__index = ListBox
ListBox.ident = "ui_listbox"
ListBox.name = "ListBox"
ListBox.caption = "ListBox"
ListBox.itemSpacing = 1 -- this will define a gap between items
ListBox.itemCaptionAlign = "left" 
ListBox.itemCaptionPadding = 4 -- this will make text appear shifted
ListBox.colorHighlight = {128,128,128,128}
ListBox.displayMax = 16
ListBox.shift = 0
ListBox.showBorder = false
function ListBox:new(name)
	local self = {}
	setmetatable(self,ListBox)
	self.items = {}
	self.index = 0
	self.itemHeight = 16
	if name ~= nil then self.name = name end
	return self
end
setmetatable(ListBox,{__index = UIElement})

function ListBox:mousepressed(x,y,b)
	if self:isMouseOver(x,y) then
		if b == "l" then
			local c = #self.items
			if c>0 then
				local sx,sy,sw,ih = self.x,self.y,self.w,self.itemHeight
				for i=(self.shift+1),(self.shift+math.min(self.displayMax,c)) do
					local factor = i-1-self.shift
					local ix,iy = sx,factor*ih+factor*self.itemSpacing
					if x>=sx and x<=sx+sw and y>=sy+iy and y<=sy+iy+ih then
						self.index = i
						break
					end
				end
			end
		elseif b == "wu" then
			self.shift = self.shift - 1
			if self.shift<0 then self.shift = 0 end
		elseif b == "wd" then	
			if self.shift<(#self.items-self.displayMax) then
				self.shift = self.shift+1
			end
		end
		self:click(b)
	end
end

-- this will return highlighted element
function ListBox:getSelected()
	return self.items[self.index]
end

function ListBox:addItem(item,name)
	table.insert(self.items,item)
	if #self.items == 1 then self.index = 1 end
end


function ListBox:clear()
	for k,v in pairs(self.items) do self.items[k] = nil end
	self.index = 0
end

function ListBox:last()
	self.index = #self.items
end

function ListBox:first()
	if #self.items>0 then self.index = 1 else self.index = 0 end
end

function ListBox:setSize(w,h) 
	self.w = w or self.w self.h = h or self.h 
	self.displayMax = math.floor(self.h/(self.itemHeight+self.itemSpacing))
end

-- if you specify a number, it will return you an item as if you index an array, otherwise it will try to look for it by comparing strings
function ListBox:getItem(item)
	if type(item) == "number" then
		return self.items[item]
	elseif type(item) == "string" then
		local c = #self.items
		if c>0 then
			for i=1,c do
				if self.items[i] == item then return self.items[i] end
			end
		end
	end
	return nil
end

function ListBox:setItemValue(item,value)
	self.items[item] = value
end

function ListBox:draw()
	if self.showBorder == true then
		l_gfx.setColor(self.dLineColor)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	end
	local c = #self.items
	if c>0 then	
		local sx,sy,sw,ih = self.x,self.y,self.w,self.itemHeight
		for i=(self.shift+1),(self.shift+math.min(self.displayMax,c)) do
			if self.index == i then
				l_gfx.setColor(self.colorHighlight)
			else
				l_gfx.setColor(self.dFillColor)
			end
			local factor = i-1-self.shift
			l_gfx.rectangle("fill",self.x,self.y+factor*self.itemHeight+factor*self.itemSpacing,self.w,self.itemHeight)
			l_gfx.setColor(self.dFontColor)
			if type(self.items[i]) == "table" then
				l_gfx.printf(self.items[i][1],self.x+self.itemCaptionPadding,self.y+factor*self.itemHeight+factor*self.itemSpacing,self.w-self.itemCaptionPadding,self.itemCaptionAlign)
			elseif type(self.items[i] == "string") then
				l_gfx.printf(self.items[i],self.x+self.itemCaptionPadding,self.y+factor*self.itemHeight+factor*self.itemSpacing,self.w-self.itemCaptionPadding,self.itemCaptionAlign)
			end
		end
	end
end
