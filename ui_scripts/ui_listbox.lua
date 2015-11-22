local l_gfx = love.graphics
local min,max = math.min,math.max

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
ListBox.colorHighlight = {160,160,160,128}
ListBox.displayMax = 16
ListBox.shift = 0
ListBox.showBorder = false
ListBox.showScroll = false
ListBox.scrollWidth = 16

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
		if b == "l" or b == "r" then
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
	print(self.name.."|"..self.displayMax)
end

-- if you specify a number, it will return you an item as if you index an array, otherwise it will try to look for it by comparing strings
function ListBox:getItem(item)
	local c = #self.items
	if c>0 then
		for i=1,c do
			if self.items[i]:getName() == name then
				return self.items[i]
			elseif self.items[i].items ~= nil and deep == true then
				self.items[i]:getItem(name,deep)
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
		l_gfx.setColor(self.colorLine)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	end
	local c = #self.items
	local fh = l_gfx.getFont():getHeight()/2
	if c>0 then	
		local sx,sy,sw,ih = self.x,self.y,self.w,self.itemHeight
		for i=(self.shift+1),(self.shift+min(self.displayMax,c)) do
			if self.index == i then
				l_gfx.setColor(self.colorHighlight)
			else
				l_gfx.setColor(self.colorFill)
			end
			local factor = i-1-self.shift
			local space = factor*self.itemSpacing
			local ix,iy,iw = self.x, self.y+factor*self.itemHeight+space,self.w
			if self.showScroll == true then iw = iw - self.scrollWidth end
			local fpad = self.itemHeight/2-fh
			
			l_gfx.rectangle("fill",ix,iy,iw,self.itemHeight)
			l_gfx.setColor(self.colorFont)
			l_gfx.printf(self.items[i],ix+self.itemCaptionPadding,iy+fpad,iw-self.itemCaptionPadding,self.itemCaptionAlign)
		end
		if self.showScroll == true then
			l_gfx.setColor(self.colorFill)
			l_gfx.rectangle("line",self.w+self.x-self.scrollWidth,self.y,self.scrollWidth,self.h)
			local h = self.h/(math.max(#self.items/self.displayMax,1))
			l_gfx.rectangle("fill",self.w+self.x-self.scrollWidth,self.y+self.shift*self.displayMax,self.scrollWidth,h)
		end
	end
end


GaugeList = {}
GaugeList.__index = GaugeList
GaugeList.ident = "ui_gaugelist"
GaugeList.name = "GaugeList"
GaugeList.colorProgress = {0,160,160,128}
function GaugeList:new(name)
	local self = {}
	setmetatable(self,GaugeList)
	self.items = {}
	self.index = 0
	self.itemHeight = 16
	if name ~= nil then self.name = name end
	return self
end
setmetatable(GaugeList,{__index = ListBox})

function GaugeList:addItem(item,val)
	table.insert(self.items,{item,val or 0})
	if #self.items == 1 then self.index = 1 end
end

function GaugeList:setItemValue(item,value,value2)
	self.items[item][1] = value or self.items[item][1]
	self.items[item][2] = value2 or 0
end

function GaugeList:draw()
	if self.showBorder == true then
		l_gfx.setColor(self.colorLine)
		l_gfx.rectangle("line",self.x,self.y,self.w,self.h)
	end
	local c = #self.items
	local fh = l_gfx.getFont():getHeight()/2
	if c>0 then	
		local sx,sy,sw,ih = self.x,self.y,self.w,self.itemHeight
		for i=(self.shift+1),(self.shift+min(self.displayMax,c)) do
			if self.index == i then
				l_gfx.setColor(self.colorHighlight)
			else
				l_gfx.setColor(self.colorFill)
			end
			local factor = i-1-self.shift
			local space = factor*self.itemSpacing
			local ix,iy,iw = self.x, self.y+factor*self.itemHeight+space,self.w
			if self.showScroll == true then iw = iw - self.scrollWidth end
			local fpad = self.itemHeight/2-fh
			
			l_gfx.rectangle("fill",ix,iy,iw,self.itemHeight)
			l_gfx.setColor(self.colorProgress)
			local prg = min(self.items[i][2]/100,1)
	
			l_gfx.rectangle("fill",ix,iy,prg*iw,self.itemHeight)
			l_gfx.setColor(self.colorFont)
			l_gfx.printf(self.items[i][1],ix+self.itemCaptionPadding,iy+fpad,iw-self.itemCaptionPadding,self.itemCaptionAlign)
		end
		if self.showScroll == true then
			l_gfx.setColor(self.colorFill)
			l_gfx.rectangle("line",self.w+self.x-self.scrollWidth,self.y,self.scrollWidth,self.h)
			local h = self.h/(max(#self.items/self.displayMax,1))
			l_gfx.rectangle("fill",self.w+self.x-self.scrollWidth,self.y+self.shift*self.displayMax,self.scrollWidth,h)
		end
	end
end

function GaugeList:clear()
	for k,v in pairs(self.items) do 
		self.items[k][1],self.items[k][2] = nil,nil
		self.items[k] = nil
	end
	self.index = 0
end


