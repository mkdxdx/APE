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
Image.colorTint = {255,255,255,255}
Image.mode = "alpha"
function Image:new(name)
	local self = {}
	setmetatable(self,Image)
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Image,{__index = UIElement})

function Image:draw()
	if self.img ~= nil then
		local r,g,b,a = l_gfx.getColor()
		l_gfx.setColor(self.colorTint)
		if self.stencil ~= nil then
			l_gfx.stencil(self.stencil)
		end
		local mode = l_gfx.getBlendMode()
		l_gfx.setBlendMode(self.mode)
		l_gfx.draw(self.img, self.x,self.y,self.r,self.sx,self.sy,self.ox,self.oy,self.kx,self.ky)
		l_gfx.setBlendMode(mode)
		l_gfx.setStencilTest()
		if self.showBorder == true then
			l_gfx.setColor(self.colorLine)
			local w,h = self.img:getWidth(),self.img:getHeight()
			l_gfx.rectangle("line",self.x-1,self.y-1,w+2,h+2)
		end
		l_gfx.setColor(r,g,b,a)
	end
end


function Image:setImage(img)
	if type(img) == "string" then
		self.img = l_gfx.newImage(img)
	else 
		self.img = img
	end
end

QuadSlider = {}
QuadSlider.__index = QuadSlider
QuadSlider.name = "QuadSlider"
QuadSlider.ident = "ui_quadslider"
function QuadSlider:new(name)
	local self = setmetatable({},QuadSlider)
	self.name = name or self.name
	self.index = 1
	return self
end
setmetatable(QuadSlider,{__index = Image})

function QuadSlider:setQuads(q)
	self.quads = q
end

function QuadSlider:draw()
	if self.img ~= nil and self.quads ~= nil and self.index<=#self.quads then
		l_gfx.setColor(self.colorTint)
		l_gfx.draw(self.img, self.quads[self.index], self.x,self.y,self.r,self.sx,self.sy,self.ox,self.oy,self.kx,self.ky)
		if self.showBorder == true then
			l_gfx.setColor(self.colorLine)
			local w,h = self.img:getWidth(),self.img:getHeight()
			l_gfx.rectangle("line",self.x-1,self.y-1,w+2,h+2)
		end
	end
end
