local l_gfx = love.graphics

-- big and invisible container element
-- used for paged interface, useless without page controller

PageSwitch = {}
PageSwitch.__index = PageSwitch
PageSwitch.ident = "ui_pageswitch"
PageSwitch.name = "PageSwitch"
PageSwitch.updateable = true
PageSwitch.updateAll = false -- if true, it will try to update all the pages in it, instead of only current one
PageSwitch.isContainer = true
function PageSwitch:new(name)
	local self = {}
	setmetatable(self,PageSwitch)
	self.pages = {}
	self.index = 0
	if name ~= nil then self.name = name end
	return self
end
setmetatable(PageSwitch,{__index = UIElement})

function PageSwitch:draw()
	local c = #self.pages
	if c>0 then
		self.pages[self.index]:draw()
	end
end


function PageSwitch:update(dt)
	local c = #self.pages
	if c>0 then
		if self.updateAll == true then
			for i=1,c do
				self.pages[i]:draw()
			end
		else
			self.pages[self.index]:update(dt)
		end
	end
end

-- to prevent input overlap, input is handled only for current page
function PageSwitch:mousemoved(x,y)
	local c = #self.pages
	if c>0 then self.pages[self.index]:mousemoved(x,y) end
end

function PageSwitch:mousepressed(x,y,b)
	local c = #self.pages
	if c>0 then self.pages[self.index]:mousepressed(x,y,b) end
end

function PageSwitch:mousereleased(x,y,b)
	local c = #self.pages
	if c>0 then self.pages[self.index]:mousereleased(x,y,b) end
end


function PageSwitch:keypressed(key,isrepeat)
	local c = #self.pages
	if c>0 then self.pages[self.index]:keypressed(key,isrepeat) end
end

function PageSwitch:keyreleased(key)
	local c = #self.pages
	if c>0 then self.pages[self.index]:keyreleased(key,isrepeat) end
end

function PageSwitch:wheelmoved(x,y)
	local c = #self.pages
	if c>0 then self.pages[self.index]:wheelmoved(x,y) end
end

function PageSwitch:setPosition(x,y)
	if self.isContainer == true then
		local dx,dy = (x or self.x) - self.x, (y or self.y) - self.y 
		local c = #self.pages 
		if c>0 then
			for i=1,c do 
				local e = self.pages[i]
				e:setPosition(e.x+dx,e.y+dy)
			end
		end
	end
	self.x,self.y = x or self.x, y or self.y
end



function PageSwitch:addPage(pg)
	if type(pg) == "table" then
		local indx = table.getn(self.pages)+1
		table.insert(self.pages,pg)
		self.index = indx
		return pg
	elseif type(pg) == "string" or pg == nil then	
		local indx = table.getn(self.pages)+1
		local page = Page:new(pg or ("Page"..indx))
		table.insert(self.pages,page)
		self.index = indx
		return page
	end
	
end

function PageSwitch:removePage(page)
	local c = #self.pages
	if c>0 then
		if page == nil then
			table.remove(self.pages,self.index)
			self:nextPage()
		else
			for i=1,c do
				if self.pages[i].name == page then
					table.remove(self.pages,i)
					self:nextPage()
					break
				end
			end
		end
	end
end

function PageSwitch:nextPage()
	local c = #self.pages
	self.index = self.index + 1
	if self.index>c then self.index = c end
end

function PageSwitch:prevPage()
	self.index = self.index-1
	if self.index <= 0 then self.index = 1 end
end

function PageSwitch:getItem(name)
	local c = #self.pages
	if c>0 then
		if page == nil then
			return self.pages[self.index]
		else
			for i=1,c do
				if self.pages[i].name == page then
					return self.pages[i]
				end
			end
		end
	end
end

-- the page is a copy of groupbox
Page = {}
Page.__index = Page
Page.ident = "ui_page"
Page.name = "Page"
Page.caption = "Page"
Page.showBorder = false
function Page:new(name)
	local self = {}
	setmetatable(self,Page)
	self.items = {}
	self.drawList = {}
	self.updateList = {}
	self.inputList = {}
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Page,{__index = GroupBox})


-- this element controls pageswitch if linked to one. has page flip, add and remove buttons
PageSwitchController = {}
PageSwitchController.__index = PageSwitchController
PageSwitchController.ident = "ui_pageswitchcontroller"
PageSwitchController.name = "PageSwitchController"
PageSwitchController.caption_xpad = 132
PageSwitchController.caption_ypad = 8
function PageSwitchController:new(name)
	local self = {}
	setmetatable(self,PageSwitchController)	
	if name ~= nil then self.name = name end
	
	local bnext = Button:new("ButtonNext")
	bnext.caption = ">"
	bnext:setSize(32,32)
	bnext:setPosition(32,0)
	
	local bprev = Button:new("ButtonPrev")
	bprev.caption = "<"
	bprev:setSize(32,32)
	bprev:setPosition(0,0)
	
	
	local badd = Button:new("ButtonAdd")
	badd.caption = "+"
	badd:setSize(32,32)
	badd:setPosition(64,0)
	
	
	local brem = Button:new("ButtonRemove")
	brem.caption = "-"
	brem:setSize(32,32)
	brem:setPosition(96,0)

	
	
	self.items = {bprev,bnext,badd,brem,labcount}
	self.drawList = {bprev,bnext,badd,brem,labcount}
	self.updateList = {}
	self.inputList = {bprev,bnext,badd,brem}
	self.w = 128
	self.caption = "0/0"
	return self
end
setmetatable(PageSwitchController,{__index = GroupBox})

function PageSwitchController:setPageSwitch(pgs)
	if pgs.ident == "ui_pageswitch" then
		self.pageswitch = pgs
		local psc = self
		local bp,bn,ba,br,lc = self.items[1],self.items[2],self.items[3],self.items[4],self.items[5]
		function bn:click(b) if b == "l" then pgs:nextPage() psc.caption = pgs.index.."/"..#pgs.pages end end
		function bp:click(b) if b == "l" then pgs:prevPage() psc.caption = pgs.index.."/"..#pgs.pages end end
		function ba:click(b) if b == "l" then pgs:addPage() psc.caption = pgs.index.."/"..#pgs.pages end end
		function br:click(b) if b == "l" then pgs:removePage() psc.caption = pgs.index.."/"..#pgs.pages	end end
	end
end


