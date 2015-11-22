TabbedList = {}
TabbedList.__index = TabbedList
TabbedList.ident = "ui_tabbedlist"
TabbedList.name = "TabbedList"
TabbedList.tabCount = 2
function TabbedList:new(name)
	local self = setmetatable({},TabbedList)
	self.name = name or self.name
	return self
end