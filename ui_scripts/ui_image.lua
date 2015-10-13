local l_gfx = love.graphics

-- this elements just draws an image which you can specify with SetImage method
-- you can also set offset,scale,angle,skew and make it display its border
Image = {}
Image.__index = Image
Image.ident = "ui_image"
Image.name = "Image"
Image.caption = ""
Image.ox = 0
Image.oy = 0
Image.sx = 1
Image.sy = 1
Image.r = 0
Image.kx = 0
Image.ky = 0
Image.showBorder = false
function Image:new(name)
	local self = {}
	setmetatable(self,Image)
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Image,{__index = UIElement})

function Image:draw()
	if self.img ~= nil then
		l_gfx.setColor(255,255,255,255)
		l_gfx.draw(self.img, self.x,self.y,self.r,self.sx,self.sy,self.ox,self.oy,self.kx,self.ky)
		if self.showBorder == true then
			l_gfx.setColor(self.dLineColor)
			local w,h = self.img:getWidth(),self.img:getHeight()
			l_gfx.rectangle("line",self.x-1,self.y-1,w+2,h+2)
		end
	end
	
end

function Image:setImage(img)
	if type(img) == "string" then
		self.img = l_gfx.newImage(img)
	else 
		self.img = img
	end
end