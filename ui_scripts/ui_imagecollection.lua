local l_gfx = love.graphics

-- This undrawable element is a collection for image resource
-- The thing is - it will try not to repeat resource creation if you try to get something from it, instead giving a reference on already created resource

ImageCollection = {}
ImageCollection.__index = ImageCollection
ImageCollection.ident = "ui_imagecollection"
ImageCollection.name = "ImageCollection"
function ImageCollection:new(name)
	local self = {}
	setmetatable(self,ImageCollection)
	self.items = {}
	if name ~= nil then self.name = name end
	return self
end
setmetatable(ImageCollection,{__index = Element})

function ImageCollection:addItem(image,name)
	local c = self:getCount()
	if c>0 then
		
		for i=1,c do
			if self.items[i][2] == name then
				return self.items[i][1]
			end
		end
		local name = name or (#self.items+1)
		local img = l_gfx.newImage(image)
		table.insert(self.items,{img,name})
		return img
	else
		local name = name or (#self.items+1)
		local img = l_gfx.newImage(image)
		table.insert(self.items,{img,name})
		return img
	end
end

function ImageCollection:getItem(item)
	if type(item) == "number" then
		return self.items[item][1],self.items[item][2]
	elseif type(item) == "string" then
		local c = self:getCount()
		if c>0 then
			for i=1,c do
				if self.items[i][2] == item then
					return self.items[i][1],self.items[i][2]
				end
			end
		end
	end
	return nil
end

function ImageCollection:getCount()
	return #self.items
end