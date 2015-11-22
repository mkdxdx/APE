--[[
	APE (another particle editor) for LÖVE2D by cval
	
	- a particle system editor tool for quick particle system prototyping, multi-paged interface and code-to-clipboard option
	- features crude interface system, numerous framework-over-framework attempts;
	- meets all the creator's needs, who also hopes that it will meet yours (=
	
	13.10.2015 version is uploaded on community forum

	IMPORTANT NOTE that this version was created with 0.9.2 engine version, so please update yours if you have version below
	otherwise some features will cause editor to crash =(
]]


ui_scrdir = "ui_scripts/"
require(ui_scrdir.."ui")

function love.load()
	love.window.setTitle("APE for LÖVE2D by cval")
	uim = UIManager:new()
	local deftexID = love.image.newImageData(1,1)
	deftexID:setPixel(0,0,255,255,255)
	local ic = uim:addItem(ImageCollection:new("IC_Textures"))
	ic:addItem(deftexID,"default")
	
	local pgs = uim:addItem(PageSwitch:new("Scene"))
	local pgsc = uim:addItem(PageSwitchController:new("PSController"))
	pgsc:setPageSwitch(pgs)
	pgsc:setPosition(0,love.graphics.getHeight()-32)
	local pgadd = pgsc:getItem("ButtonAdd")
	function pgadd:click(b)
		if b == "l" then 
			local pg = pgs:addPage() 
			pgsc.caption = pgsc.pageswitch.index.."/"..#pgsc.pageswitch.pages
			fillPage(pg) 
		end
	end
	pgadd:click("l")	
end

function love.update(dt)
	uim:update(dt)
end

function love.draw()
	uim:draw()
end

function love.mousemoved(x,y)
	uim:mousemoved(x,y)
end

function love.mousepressed(x,y,b)
	uim:mousepressed(x,y,b)
end

function love.mousereleased(x,y,b)
	uim:mousereleased(x,y,b)
end

function love.keypressed(key,isrepeat)
	uim:keypressed(key,isrepeat)
end

function love.keyreleased(key) 
	uim:keyreleased(key)
end

function fillPage(page)
	page:setSize(love.graphics:getWidth(),love.graphics:getHeight())
	local vertline = page:addItem(Line:new("L_Vertical"))
	vertline.h = love.graphics.getHeight()-4
	vertline.x = 240
	vertline.y = 2
	
	
	
	local tex = uim:getItem("IC_Textures"):getItem("default")
	local emitter = page:addItem(ParticleEmitter:new("ParticleEmitter",tex))
	emitter.ps:moveTo(love.graphics.getWidth()/2+224,love.graphics.getHeight()/2)
	emitter.ps:setQuads()

	local guidetimer = page:addItem(Timer:new("T_GuideShow"))
	guidetimer.interval = 3
	function guidetimer:trigger()
		page:getItem("Arc_ESpread"):hide()
		page:getItem("R_EArea"):hide()
	end
	
	local emspr = page:addItem(Arc:new("Arc_ESpread"))
	emspr.dFillColor = {255,255,0,255}
	emspr.mode = "line"
	emspr.radius = 128
	emspr:setAngle(-0.01,0.01)
	emspr:setPosition(love.graphics.getWidth()/2+224,love.graphics.getHeight()/2)
	emspr:hide()
	
	local emarea = page:addItem(Rectangle:new("R_EArea"))
	emarea.dFillColor = {255,0,0,255}
	emarea.mode = "line"
	emarea.w = 0
	emarea.h = 0
	emarea.centerOnPos = true
	emarea:setPosition(love.graphics.getWidth()/2+224,love.graphics.getHeight()/2)
	emarea:hide()
	
	local c_quads = page:addItem(Collection:new("C_Quads"))
	function c_quads:onadd()
		local pe = page:getItem("ParticleEmitter")
		pe.ps:setQuads(unpack(c_quads.items))
	end
	function c_quads:ondelete()
		local pe = page:getItem("ParticleEmitter")
		pe.ps:setQuads(unpack(c_quads.items))
	end
	
	c_quads:addItem(love.graphics.newQuad(0,0,1,1,1,1))
	
	
	local bsspin = page:addItem(Spin:new("SP_BufferSize"))
	bsspin.caption = "Buffer:"
	bsspin.leftCaption = true
	bsspin:setPosition(56,8)
	bsspin.max = nil
	bsspin.min = 1
	bsspin.value = 10
	bsspin.allowMult = true
	bsspin.mult_precise = 1
	function bsspin:changeValue() emitter.ps:setBufferSize(bsspin.value) end
	
	local spdir = page:addItem(Spin:new("SP_Direction"))
	spdir.caption = "Direction:"
	spdir.leftCaption = true
	spdir:setPosition(184,8)
	spdir.max = nil
	spdir.min = nil
	spdir.value = 0
	spdir.step = 0.1
	spdir.allowMult = true
	function spdir:changeValue() 
		emitter.ps:setDirection(spdir.value)
		local d,s = page:getItem("ParticleEmitter").ps:getDirection(),emitter.ps:getSpread()
		page:getItem("Arc_ESpread"):setAngle(-math.max((s/2),-0.15)+d,math.max((s/2),0.015)+d)
		page:getItem("Arc_ESpread"):show()
		page:getItem("R_EArea"):show()
		page:getItem("T_GuideShow"):start()
	end
	
	local gb_distr = page:addItem(GroupBox:new("GB_AreaDistribution"))
	gb_distr.caption = "Area distribution"
	gb_distr:setPosition(8,48)
	gb_distr.w = 224
	gb_distr.h = 56
	
	
		local rbdn = gb_distr:addItem(RadioButton:new("RB_Distr_None"))
		rbdn.caption = "none"
		rbdn.checked = true
		rbdn.buttonStyle = true
		rbdn:setSize(64,16)
		rbdn:setPosition(gb_distr.x+8,gb_distr.y+8)
		function rbdn:click(b) 
			if b == "l" then  
				gb_distr:getItem("SP_Distr_X"):hide()
				gb_distr:getItem("SP_Distr_Y"):hide()
				page:getItem("ParticleEmitter").ps:setAreaSpread(gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption,gb_distr:getItem("SP_Distr_X").value,gb_distr:getItem("SP_Distr_Y").value)
				local factor = 1
				if gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "normal" then factor = 2
				elseif gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "none" then factor = 0 end
				page:getItem("R_EArea"):setSize(gb_distr:getItem("SP_Distr_X").value*2*factor,gb_distr:getItem("SP_Distr_Y").value*2*factor)
				page:getItem("Arc_ESpread"):show()
				page:getItem("R_EArea"):show()
				page:getItem("T_GuideShow"):start()
			end 
		end
		
		local rbdnorm = gb_distr:addItem(RadioButton:new("RB_Distr_Normal"))
		rbdnorm.caption = "normal"
		rbdnorm.buttonStyle = true
		rbdnorm:setSize(64,16)
		rbdnorm:setPosition(gb_distr.x+78,gb_distr.y+8)
		function rbdnorm:click(b) 
			if b == "l" then 
				gb_distr:getItem("SP_Distr_X"):show() 
				gb_distr:getItem("SP_Distr_Y"):show()
				if gb_distr:getItem("SP_Distr_X").value <= 0 then gb_distr:getItem("SP_Distr_X").value = 1 end
				if gb_distr:getItem("SP_Distr_Y").value <= 0 then gb_distr:getItem("SP_Distr_Y").value = 1 end
				page:getItem("ParticleEmitter").ps:setAreaSpread(gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption,gb_distr:getItem("SP_Distr_X").value,gb_distr:getItem("SP_Distr_Y").value)
				local factor = 1
				if gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "normal" then factor = 2
				elseif gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "none" then factor = 0 end
				page:getItem("R_EArea"):setSize(gb_distr:getItem("SP_Distr_X").value*2*factor,gb_distr:getItem("SP_Distr_Y").value*2*factor)
				page:getItem("Arc_ESpread"):show()
				page:getItem("R_EArea"):show()
				page:getItem("T_GuideShow"):start()
			end 
		end
		
		local rbdu = gb_distr:addItem(RadioButton:new("RB_Distr_Uniform"))
		rbdu.caption = "uniform"
		rbdu.buttonStyle = true
		rbdu:setSize(64,16)
		rbdu:setPosition(gb_distr.x+148,gb_distr.y+8)
		function rbdu:click(b) 
			if b == "l" then 
				gb_distr:getItem("SP_Distr_X"):show() 
				gb_distr:getItem("SP_Distr_Y"):show()
				if gb_distr:getItem("SP_Distr_X").value <= 0 then gb_distr:getItem("SP_Distr_X").value = 1 end
				if gb_distr:getItem("SP_Distr_Y").value <= 0 then gb_distr:getItem("SP_Distr_Y").value = 1 end
				page:getItem("ParticleEmitter").ps:setAreaSpread(gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption,gb_distr:getItem("SP_Distr_X").value,gb_distr:getItem("SP_Distr_Y").value)
				local factor = 1
				if gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "normal" then factor = 2
				elseif gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "none" then factor = 0 end
				page:getItem("R_EArea"):setSize(gb_distr:getItem("SP_Distr_X").value*2*factor,gb_distr:getItem("SP_Distr_Y").value*2*factor)
				page:getItem("Arc_ESpread"):show()
				page:getItem("R_EArea"):show()
				page:getItem("T_GuideShow"):start()
			end 
		end
		
		local rbdg = {rbdn,rbdnorm,rbdu}
		for i=1,3 do rbdg[i]:setGroup(rbdg) end
		
		local lar = gb_distr:addItem(Label:new("L_Area"))
		lar.caption = "Area:"
		lar:setPosition(gb_distr.x+8,gb_distr.y+32)
		
		local spdistrx = gb_distr:addItem(Spin:new("SP_Distr_X"))
		spdistrx:setPosition(gb_distr.x+56,gb_distr.y+32)
		spdistrx.min = 1
		spdistrx.value = 1
		spdistrx.max = nil
		spdistrx.leftCaption = true
		spdistrx.caption = "X"
		spdistrx.allowMult = true
		spdistrx.active = false
		spdistrx:hide()
		function spdistrx:changeValue() 
			page:getItem("ParticleEmitter").ps:setAreaSpread(gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption,gb_distr:getItem("SP_Distr_X").value,gb_distr:getItem("SP_Distr_Y").value)
			local factor = 1
			if gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "normal" then factor = 2
			elseif gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "none" then factor = 0 end
			page:getItem("R_EArea"):setSize(gb_distr:getItem("SP_Distr_X").value*2*factor,gb_distr:getItem("SP_Distr_Y").value*2*factor)
			page:getItem("Arc_ESpread"):show()
			page:getItem("R_EArea"):show()
			page:getItem("T_GuideShow"):start()
		end
		
		local spdistry = gb_distr:addItem(Spin:new("SP_Distr_Y"))
		spdistry:setPosition(gb_distr.x+148,gb_distr.y+32)
		spdistry.min = 1
		spdistry.value = 1
		spdistry.max = nil
		spdistry.leftCaption = true
		spdistry.caption = "Y"
		spdistry.allowMult = true
		spdistry:hide()
		spdistry.visible = false
		function spdistry:changeValue() 
			page:getItem("ParticleEmitter").ps:setAreaSpread(gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption,gb_distr:getItem("SP_Distr_X").value,gb_distr:getItem("SP_Distr_Y").value)
			local factor = 1
			if gb_distr:getItem("RB_Distr_None").group[rbdn:getGroupIndex()].caption == "normal" then factor = 2 end
			page:getItem("R_EArea"):setSize(gb_distr:getItem("SP_Distr_X").value*2*factor,gb_distr:getItem("SP_Distr_Y").value*2*factor)
			page:getItem("Arc_ESpread"):show()
			page:getItem("R_EArea"):show()
			page:getItem("T_GuideShow"):start()
		end
	
	local btstart = page:addItem(Button:new("B_EmitterStart"))
	btstart:setPosition(168,112)
	btstart.caption = "START"
	btstart:setSize(64,36)
	function btstart:click(b) if b == "l" then page:getItem("ParticleEmitter").ps:start() end end
	
	local sperate = page:addItem(Spin:new("SP_ERate"))
	sperate:setPosition(116,112)
	sperate.leftCaption = true
	sperate.caption = "Emission rate:"
	sperate.min = 0
	sperate.value = 1
	sperate.max = nil
	sperate.allowMult = true
	sperate.caption_xpad = -13
	function sperate:changeValue() page:getItem("ParticleEmitter").ps:setEmissionRate(sperate.value) end
	
	local spemlt = page:addItem(Spin:new("SP_EmLifetime"))
	spemlt:setPosition(116,132)
	spemlt.leftCaption = true
	spemlt.caption = "Emitter lifetime:"
	spemlt.min = -1
	spemlt.value = -1
	spemlt.max = nil
	spemlt.allowMult = true
	function spemlt:changeValue() if spemlt.value<0 then spemlt.value = -1 end page:getItem("ParticleEmitter").ps:setEmitterLifetime(spemlt.value) page:getItem("ParticleEmitter").ps:start() end
	
	
	
	local gb_lacc = page:addItem(GroupBox:new("GB_LinearAcceleration"))
	gb_lacc.caption = "Linear acceleration"
	gb_lacc:setPosition(8,172)
	gb_lacc.w = 224
	gb_lacc.h = 42
	
		local splaxmin = gb_lacc:addItem(Spin:new("SP_LA_XMin"))
		splaxmin:setPosition(gb_lacc.x+40,gb_lacc.y+4)
		splaxmin.min = nil
		splaxmin.max = nil
		splaxmin.allowMult = true
		splaxmin.leftCaption = true
		splaxmin.caption = "XMin"
		function splaxmin:changeValue()
			local em = page:getItem("ParticleEmitter").ps
			local laxmin = gb_lacc:getItem("SP_LA_XMin").value
			local laymin = gb_lacc:getItem("SP_LA_YMin").value
			local laxmax = gb_lacc:getItem("SP_LA_XMax").value
			local laymax = gb_lacc:getItem("SP_LA_YMax").value
			em:setLinearAcceleration(laxmin,laymin,laxmax,laymax)
		end
		
		local splaymin = gb_lacc:addItem(Spin:new("SP_LA_YMin"))
		splaymin:setPosition(gb_lacc.x+40,gb_lacc.y+22)
		splaymin.min = nil
		splaymin.max = nil
		splaymin.allowMult = true
		splaymin.leftCaption = true
		splaymin.caption = "YMin"
		function splaymin:changeValue()
			local em = page:getItem("ParticleEmitter").ps
			local laxmin = gb_lacc:getItem("SP_LA_XMin").value
			local laymin = gb_lacc:getItem("SP_LA_YMin").value
			local laxmax = gb_lacc:getItem("SP_LA_XMax").value
			local laymax = gb_lacc:getItem("SP_LA_YMax").value
			em:setLinearAcceleration(laxmin,laymin,laxmax,laymax)
		end
		
		local splaxmax = gb_lacc:addItem(Spin:new("SP_LA_XMax"))
		splaxmax:setPosition(gb_lacc.x+154,gb_lacc.y+4)
		splaxmax.min = nil
		splaxmax.max = nil
		splaxmax.allowMult = true
		splaxmax.leftCaption = true
		splaxmax.caption = "XMax"
		function splaxmax:changeValue()
			local em = page:getItem("ParticleEmitter").ps
			local laxmin = gb_lacc:getItem("SP_LA_XMin").value
			local laymin = gb_lacc:getItem("SP_LA_YMin").value
			local laxmax = gb_lacc:getItem("SP_LA_XMax").value
			local laymax = gb_lacc:getItem("SP_LA_YMax").value
			em:setLinearAcceleration(laxmin,laymin,laxmax,laymax)
		end
		
		local splaymax = gb_lacc:addItem(Spin:new("SP_LA_YMax"))
		splaymax:setPosition(gb_lacc.x+154,gb_lacc.y+22)
		splaymax.min = nil
		splaymax.max = nil
		splaymax.allowMult = true
		splaymax.leftCaption = true
		splaymax.caption = "YMax"
		function splaymax:changeValue()
			local em = page:getItem("ParticleEmitter").ps
			local laxmin = gb_lacc:getItem("SP_LA_XMin").value
			local laymin = gb_lacc:getItem("SP_LA_YMin").value
			local laxmax = gb_lacc:getItem("SP_LA_XMax").value
			local laymax = gb_lacc:getItem("SP_LA_YMax").value
			em:setLinearAcceleration(laxmin,laymin,laxmax,laymax)
		end
	
	local emtfill = page:addItem(ProgressBar:new("PB_EmitterFill"))
	emtfill:setPosition(8,236)
	emtfill.showCaption = true
	emtfill.caption = "Emitter fill"
	emtfill:setSize(160,16)
	emtfill.value = 32
	function emtfill:update(dt) emtfill.max = emitter.ps:getBufferSize() emtfill.value = emitter.ps:getCount() end
	
	local lfps = page:addItem(RefreshingLabel:new("RL_FPS"))
	local ltim = love.timer
	function lfps:update(dt) lfps.caption = "FPS:"..ltim.getFPS() end
	lfps:setPosition(180,236)
	lfps.wrap = false
	
	local gbplt = page:addItem(GroupBox:new("GB_PLifetime"))
	gbplt:setPosition(8,272)
	gbplt.caption = "Part. lifetime"
	gbplt:setSize(84,42)
	
	local sppltmin = gbplt:addItem(Spin:new("SP_PLifetime_Min"))
	sppltmin:setPosition(40,276)
	sppltmin.allowMult = true
	sppltmin.caption = "min"
	sppltmin.leftCaption = true
	function sppltmin:changeValue()
		page:getItem("ParticleEmitter").ps:setParticleLifetime(gbplt:getItem("SP_PLifetime_Min").value,gbplt:getItem("SP_PLifetime_Max").value)
	end
	
	local sppltmax = gbplt:addItem(Spin:new("SP_PLifetime_Max"))
	sppltmax:setPosition(40,294)
	sppltmax.allowMult = true
	sppltmax.leftCaption = true
	sppltmax.caption = "max"
	function sppltmax:changeValue()
		page:getItem("ParticleEmitter").ps:setParticleLifetime(gbplt:getItem("SP_PLifetime_Min").value,gbplt:getItem("SP_PLifetime_Max").value)
	end
	
	local gbracc = page:addItem(GroupBox:new("GB_RadialAcceleration"))
	gbracc:setPosition(146,272)
	gbracc.caption = "Radial accel."
	gbracc:setSize(84,42)
	
		local spraccmin = gbracc:addItem(Spin:new("SP_RadialAcc_Min"))
		spraccmin:setPosition(178,276)
		spraccmin.allowMult = true
		spraccmin.caption = "min"
		spraccmin.leftCaption = true
		function spraccmin:changeValue()
			page:getItem("ParticleEmitter").ps:setRadialAcceleration(gbracc:getItem("SP_RadialAcc_Min").value,gbracc:getItem("SP_RadialAcc_Max").value)
		end
		
		local spraccmax = gbracc:addItem(Spin:new("SP_RadialAcc_Max"))
		spraccmax:setPosition(178,294)
		spraccmax.allowMult = true
		spraccmax.leftCaption = true
		spraccmax.caption = "max"
		function spraccmax:changeValue()
			page:getItem("ParticleEmitter").ps:setRadialAcceleration(gbracc:getItem("SP_RadialAcc_Min").value,gbracc:getItem("SP_RadialAcc_Max").value)
		end
	
	
	local gbrot = page:addItem(GroupBox:new("GB_Rotation"))
	gbrot.caption = "Part. rotation"
	gbrot:setSize(84,42)
	
		local sprotmin = gbrot:addItem(Spin:new("SP_Rotation_Min"))
		sprotmin:setPosition(32,4)
		sprotmin.allowMult = true
		sprotmin.caption = "min"
		sprotmin.leftCaption = true
		function sprotmin:changeValue()
			page:getItem("ParticleEmitter").ps:setRotation(gbrot:getItem("SP_Rotation_Min").value,gbrot:getItem("SP_Rotation_Max").value)
		end
		
		local sprotmax = gbrot:addItem(Spin:new("SP_Rotation_Max"))
		sprotmax:setPosition(32,22)
		sprotmax.allowMult = true
		sprotmax.leftCaption = true
		sprotmax.caption = "max"
		function sprotmax:changeValue()
			page:getItem("ParticleEmitter").ps:setRotation(gbrot:getItem("SP_Rotation_Min").value,gbrot:getItem("SP_Rotation_Max").value)
		end
	gbrot:setPosition(8,334)
	
	
	local gbspin = page:addItem(GroupBox:new("GB_Spin"))
	gbspin.caption = "Part. spin"
	gbspin:setSize(84,42)
	
		local spspmin = gbspin:addItem(Spin:new("SP_Spin_Min"))
		spspmin:setPosition(32,4)
		spspmin.allowMult = true
		spspmin.caption = "min"
		spspmin.leftCaption = true
		function spspmin:changeValue()
			page:getItem("ParticleEmitter").ps:setSpin(gbspin:getItem("SP_Spin_Min").value,gbspin:getItem("SP_Spin_Max").value)
		end
		
		local spspmax = gbspin:addItem(Spin:new("SP_Spin_Max"))
		spspmax:setPosition(32,22)
		spspmax.allowMult = true
		spspmax.leftCaption = true
		spspmax.caption = "max"
		function spspmax:changeValue()
			page:getItem("ParticleEmitter").ps:setSpin(gbspin:getItem("SP_Spin_Min").value,gbspin:getItem("SP_Spin_Max").value)
		end
	gbspin:setPosition(146,334)
	
	
	local gbspd = page:addItem(GroupBox:new("GB_Speed"))
	gbspd.caption = "Part. speed"
	gbspd:setSize(84,42)
	
		local spspdmin = gbspd:addItem(Spin:new("SP_Speed_Min"))
		spspdmin:setPosition(32,4)
		spspdmin.allowMult = true
		spspdmin.caption = "min"
		spspdmin.leftCaption = true
		function spspdmin:changeValue()
			page:getItem("ParticleEmitter").ps:setSpeed(gbspd:getItem("SP_Speed_Min").value,gbspd:getItem("SP_Speed_Max").value)
		end
		
		local spspdmax = gbspd:addItem(Spin:new("SP_Speed_Max"))
		spspdmax:setPosition(32,22)
		spspdmax.allowMult = true
		spspdmax.leftCaption = true
		spspdmax.caption = "max"
		function spspdmax:changeValue()
			page:getItem("ParticleEmitter").ps:setSpeed(gbspd:getItem("SP_Speed_Min").value,gbspd:getItem("SP_Speed_Max").value)
		end
	gbspd:setPosition(8,396)
	
	
	local gbtga = page:addItem(GroupBox:new("GB_TangentialAcc"))
	gbtga.caption = "Tg accel."
	gbtga:setSize(84,42)
	
		local sptgamin = gbtga:addItem(Spin:new("SP_TgAcc_Min"))
		sptgamin:setPosition(32,4)
		sptgamin.allowMult = true
		sptgamin.caption = "min"
		sptgamin.leftCaption = true
		function sptgamin:changeValue()
			page:getItem("ParticleEmitter").ps:setTangentialAcceleration(gbtga:getItem("SP_TgAcc_Min").value,gbtga:getItem("SP_TgAcc_Max").value)
		end
		
		local sptgamax = gbtga:addItem(Spin:new("SP_TgAcc_Max"))
		sptgamax:setPosition(32,22)
		sptgamax.allowMult = true
		sptgamax.leftCaption = true
		sptgamax.caption = "max"
		function sptgamax:changeValue()
			page:getItem("ParticleEmitter").ps:setTangentialAcceleration(gbtga:getItem("SP_TgAcc_Min").value,gbtga:getItem("SP_TgAcc_Max").value)
		end
		gbtga:setPosition(146,396)
	
	local linediv = page:addItem(Line:new("L_Divider"))
	linediv:setPosition(120,272)
	linediv:setSize(1,168)
	
	
	local spspvar = page:addItem(Spin:new("SP_Spin_Variation"))
	spspvar:setPosition(56,444)
	spspvar.caption = "Spin v."
	spspvar.step = 0.1
	spspvar.min = 0
	spspvar.max = 1
	spspvar.allowMult = true
	spspvar.leftCaption = true
	function spspvar:changeValue() page:getItem("ParticleEmitter").ps:setSpinVariation(page:getItem("SP_Spin_Variation").value) end
	
	local spspread = page:addItem(Spin:new("SP_Spread"))
	spspread:setPosition(180,444)
	spspread.caption = "Spread"
	spspread.step = 0.1
	spspread.min = 0
	spspread.max = 6.28
	spspread.allowMult = true
	spspread.leftCaption = true
	function spspread:changeValue() 
		page:getItem("ParticleEmitter").ps:setSpread(page:getItem("SP_Spread").value)
		local d,s = page:getItem("ParticleEmitter").ps:getDirection(),emitter.ps:getSpread()
		page:getItem("Arc_ESpread"):setAngle(-math.max((s/2),-0.15)+d,math.max((s/2),0.015)+d)
		page:getItem("Arc_ESpread"):show()
		page:getItem("R_EArea"):show()
		page:getItem("T_GuideShow"):start()
	end
	
	local cbrelrot = page:addItem(CheckBox:new("CB_RelativeRotation"))
	cbrelrot.caption = "Rel. rotation"
	cbrelrot:setPosition(8,468)
	function cbrelrot:click(b) if b == "l" then page:getItem("ParticleEmitter").ps:setRelativeRotation(cbrelrot.checked) end end
	
	local cbfmouse = page:addItem(CheckBox:new("CB_FollowMouse"))
	cbfmouse.caption = "Follow mouse"
	cbfmouse:setPosition(128,468)
	function cbfmouse:click(b) if b == "l" then page:getItem("ParticleEmitter").followMouse = cbfmouse.checked if cbfmouse.checked == false then
		page:getItem("ParticleEmitter").ps:moveTo(love.graphics.getWidth()/2+224,love.graphics.getHeight()/2) end
	end end
	
	local gbimode = page:addItem(GroupBox:new("GB_InsertMode"))
	gbimode:setSize(224,24)
	gbimode.caption = "Insert mode"
	
		local rbimtop = gbimode:addItem(RadioButton:new("RB_IM_Top"))
		rbimtop:setPosition(4,4)
		rbimtop.caption = "top"
		rbimtop.buttonStyle = true
		rbimtop:setSize(64,16)
		rbimtop.checked = true
		function rbimtop:click(b) if b == "l" then page:getItem("ParticleEmitter").ps:setInsertMode(rbimtop.group[rbimtop:getGroupIndex()].caption) end end
		
		local rbimbot = gbimode:addItem(RadioButton:new("RB_IM_Bottom"))
		rbimbot:setPosition(80,4)
		rbimbot.caption = "bottom"
		rbimbot.buttonStyle = true
		rbimbot:setSize(64,16)
		function rbimbot:click(b) if b == "l" then page:getItem("ParticleEmitter").ps:setInsertMode(rbimbot.group[rbimbot:getGroupIndex()].caption) end end
		
		local rbimrnd = gbimode:addItem(RadioButton:new("RB_IM_Random"))
		rbimrnd:setPosition(156,4)
		rbimrnd.caption = "random"
		rbimrnd.buttonStyle = true
		rbimrnd:setSize(64,16)
		function rbimrnd:click(b) if b == "l" then page:getItem("ParticleEmitter").ps:setInsertMode(rbimrnd.group[rbimrnd:getGroupIndex()].caption) end end
		local imgroup = {rbimtop,rbimbot,rbimrnd}
		for i=1,3 do imgroup[i]:setGroup(imgroup) end
		gbimode:setPosition(8,504)
	
	
	local gbsizes = page:addItem(GroupBox:new("GB_Size_Selector"))
	gbsizes:setSize(224,48)
	gbsizes.caption = "Sizes"
	
		local spsrange = gbsizes:addItem(Spin:new("SP_Size_Range"))
		spsrange.caption = "Range:"
		spsrange.leftCaption = true
		spsrange:setPosition(56,4)
		spsrange:setSize(24,16)
		spsrange.max = 8
		spsrange.min = 1
		spsrange.value = 1
		
		local spszvar = gbsizes:addItem(Spin:new("SP_Size_Var"))
		spszvar.caption = "Var."
		spszvar.max = 1
		spszvar.min = 0
		spszvar.leftCaption = true
		spszvar.step = 0.1
		spszvar:setPosition(188,4)
		spszvar:setSize(32,16)
		function spszvar:changeValue()	page:getItem("ParticleEmitter").ps:setSizeVariation(spszvar.value)	end
		
		local spsvalue = gbsizes:addItem(Spin:new("SP_Size_Value"))
		spsvalue.caption = "Size:"
		spsvalue.leftCaption = true
		spsvalue:setPosition(120,4)
		spsvalue:setSize(32,16)
		spsvalue.max = nil
		spsvalue.min = nil
		spsvalue.value = 1
		spsvalue.allowMult = true
		
		
		
		local rbsz1 = gbsizes:addItem(RadioButton:new("RB_Size_1"))
		rbsz1.buttonStyle = true
		rbsz1:setSize(24,16)
		rbsz1.caption = "1"
		rbsz1:setPosition(8,28)
		rbsz1.checked = true
		function rbsz1:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz1.group[rbsz1:getGroupIndex()].caption)
			end
		end
		
		local rbsz2 = gbsizes:addItem(RadioButton:new("RB_Size_2"))
		rbsz2.buttonStyle = true
		rbsz2:setSize(24,16)
		rbsz2.caption = "1"
		rbsz2:setPosition(33,28)
		function rbsz2:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz2.group[rbsz2:getGroupIndex()].caption)
			end
		end
		
		local rbsz3 = gbsizes:addItem(RadioButton:new("RB_Size_3"))
		rbsz3.buttonStyle = true
		rbsz3:setSize(24,16)
		rbsz3.caption = "1"
		rbsz3:setPosition(58,28)
		function rbsz3:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz3.group[rbsz3:getGroupIndex()].caption)
			end
		end
		
		local rbsz4 = gbsizes:addItem(RadioButton:new("RB_Size_4"))
		rbsz4.buttonStyle = true
		rbsz4:setSize(24,16)
		rbsz4.caption = "1"
		rbsz4:setPosition(83,28)
		function rbsz4:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz4.group[rbsz4:getGroupIndex()].caption)
			end
		end
		
		local rbsz5 = gbsizes:addItem(RadioButton:new("RB_Size_5"))
		rbsz5.buttonStyle = true
		rbsz5:setSize(24,16)
		rbsz5.caption = "1"
		rbsz5:setPosition(108,28)
		function rbsz5:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz5.group[rbsz5:getGroupIndex()].caption)
			end
		end
		
		local rbsz6 = gbsizes:addItem(RadioButton:new("RB_Size_6"))
		rbsz6.buttonStyle = true
		rbsz6:setSize(24,16)
		rbsz6.caption = "1"
		rbsz6:setPosition(133,28)
		function rbsz6:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz6.group[rbsz6:getGroupIndex()].caption)
			end
		end
		
		local rbsz7 = gbsizes:addItem(RadioButton:new("RB_Size_7"))
		rbsz7.buttonStyle = true
		rbsz7:setSize(24,16)
		rbsz7.caption = "1"
		rbsz7:setPosition(158,28)
		function rbsz7:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz7.group[rbsz7:getGroupIndex()].caption)
			end
		end
		
		local rbsz8 = gbsizes:addItem(RadioButton:new("RB_Size_8"))
		rbsz8.buttonStyle = true
		rbsz8:setSize(24,16)
		rbsz8.caption = "1"
		rbsz8:setPosition(183,28)
		function rbsz8:click(b) 
			if b == "l" then 
				local val = page:getItem("GB_Size_Selector"):getItem("SP_Size_Value")
				val.value = tonumber(rbsz8.group[rbsz8:getGroupIndex()].caption)
			end
		end
		
		local rbszgr = {rbsz1,rbsz2,rbsz3,rbsz4,rbsz5,rbsz6,rbsz7,rbsz8}
		for i=1,8 do 
			rbszgr[i]:setGroup(rbszgr)
			if i>1 then rbszgr[i].active = false end
		end
		
		function spsrange:changeValue()
			local szapp = {}
			for i=1,8 do
				if i<=spsrange.value then rbszgr[i].active = true szapp[i] = tonumber(rbszgr[i].caption) else rbszgr[i].active = false end
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szapp))
		end
		
		function spsvalue:changeValue()
			local rb = page:getItem("GB_Size_Selector"):getItem("RB_Size_1")
			rb.group[rb:getGroupIndex()].caption = spsvalue.value
			local szapp = {}
			local spsrange = gbsizes:getItem("SP_Size_Range")
			for i=1,8 do
				if i<=spsrange.value then rbszgr[i].active = true szapp[i] = tonumber(rbszgr[i].caption) else rbszgr[i].active = false end
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szapp))
		end
	gbsizes:setPosition(8,548)
	
	-- color picker commencing!
	
	local gbcolors = page:addItem(GroupBox:new("GB_Color_Selector"))
	gbcolors:setSize(224,48)
	gbcolors.caption = "Colors"
	
		local spcrange = gbcolors:addItem(Spin:new("SP_Color_Range"))
		spcrange.caption = "Range:"
		spcrange.leftCaption = true
		spcrange:setPosition(56,4)
		spcrange:setSize(28,16)
		spcrange.max = 8
		spcrange.min = 1
		spcrange.value = 1
		
		local spcvala = gbcolors:addItem(Spin:new("SP_Color_ValA"))
		spcvala.caption = ""
		spcvala.leftCaption = true
		spcvala:setPosition(188,4)
		spcvala:setSize(32,16)
		spcvala.max = 255
		spcvala.min = 0
		spcvala.value = 255
		spcvala.allowMult = true
		spcvala.mult_precision = 1
		
		local spcvalb = gbcolors:addItem(Spin:new("SP_Color_ValB"))
		spcvalb.caption = ""
		spcvalb.leftCaption = true
		spcvalb:setPosition(154,4)
		spcvalb:setSize(32,16)
		spcvalb.max = 255
		spcvalb.min = 0
		spcvalb.value = 255
		spcvalb.allowMult = true
		spcvalb.mult_precision = 1
		
		local spcvalg = gbcolors:addItem(Spin:new("SP_Color_ValG"))
		spcvalg.caption = ""
		spcvalg.leftCaption = true
		spcvalg:setPosition(120,4)
		spcvalg:setSize(32,16)
		spcvalg.max = 255
		spcvalg.min = 0
		spcvalg.value = 255
		spcvalg.allowMult = true
		spcvalg.mult_precision = 1
		
		local spcvalr = gbcolors:addItem(Spin:new("SP_Color_ValR"))
		spcvalr.caption = ""
		spcvalr.leftCaption = true
		spcvalr:setPosition(86,4)
		spcvalr:setSize(32,16)
		spcvalr.max = 255
		spcvalr.min = 0
		spcvalr.allowMult = true
		spcvalr.mult_precision = 1
		spcvalr.value = 255
		
		
		local rbcl1 = gbcolors:addItem(RadioColorPicker:new("RB_Color1"))
		rbcl1.buttonStyle = true
		rbcl1:setSize(24,16)
		rbcl1.caption = "1"
		rbcl1:setPosition(8,28)
		rbcl1.checked = true
		function rbcl1:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl1.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl2 = gbcolors:addItem(RadioColorPicker:new("RB_Color2"))
		rbcl2.buttonStyle = true
		rbcl2:setSize(24,16)
		rbcl2.caption = "1"
		rbcl2:setPosition(33,28)
		function rbcl2:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl2.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl3 = gbcolors:addItem(RadioColorPicker:new("RB_Color3"))
		rbcl3.buttonStyle = true
		rbcl3:setSize(24,16)
		rbcl3.caption = "1"
		rbcl3:setPosition(58,28)
		function rbcl3:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl3.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl4 = gbcolors:addItem(RadioColorPicker:new("RB_Color4"))
		rbcl4.buttonStyle = true
		rbcl4:setSize(24,16)
		rbcl4.caption = "1"
		rbcl4:setPosition(83,28)
		function rbcl4:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl4.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl5 = gbcolors:addItem(RadioColorPicker:new("RB_Color5"))
		rbcl5.buttonStyle = true
		rbcl5:setSize(24,16)
		rbcl5.caption = "1"
		rbcl5:setPosition(108,28)
		function rbcl5:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl5.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl6 = gbcolors:addItem(RadioColorPicker:new("RB_Color6"))
		rbcl6.buttonStyle = true
		rbcl6:setSize(24,16)
		rbcl6.caption = "1"
		rbcl6:setPosition(133,28)
		function rbcl6:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl6.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl7 = gbcolors:addItem(RadioColorPicker:new("RB_Color7"))
		rbcl7.buttonStyle = true
		rbcl7:setSize(24,16)
		rbcl7.caption = "1"
		rbcl7:setPosition(158,28)
		function rbcl7:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl7.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbcl8 = gbcolors:addItem(RadioColorPicker:new("RB_Color8"))
		rbcl8.buttonStyle = true
		rbcl8:setSize(24,16)
		rbcl8.caption = "1"
		rbcl8:setPosition(183,28)
		function rbcl8:click(b) 
			if b == "l" then 
				local cs = page:getItem("GB_Color_Selector")
				local valarr = {cs:getItem("SP_Color_ValR"),cs:getItem("SP_Color_ValG"),cs:getItem("SP_Color_ValB"),cs:getItem("SP_Color_ValA"),}
				for i=1,4 do valarr[i].value = rbcl8.group[rbcl1:getGroupIndex()].color[i] end
			end
		end
		
		local rbclgr = {rbcl1,rbcl2,rbcl3,rbcl4,rbcl5,rbcl6,rbcl7,rbcl8}
		for i=1,8 do 
			rbclgr[i]:setGroup(rbclgr)
			if i>1 then rbclgr[i].active = false end
		end
		
		function spcrange:changeValue()
			local clapp = {}
			for i=1,8 do
				local cl = {}
				if i<=spcrange.value then 
					rbclgr[i].active = true 
					for j=1,4 do
						cl[j] = rbclgr[i].color[j]
					end
					clapp[i] = cl
				else 
					rbclgr[i].active = false 
				end
			end
			page:getItem("ParticleEmitter").ps:setColors(unpack(clapp))
		end
		
		function spcvalr:changeValue()
			local rb = page:getItem("GB_Color_Selector"):getItem("RB_Color1")
			rb.group[rb:getGroupIndex()].color[1] = spcvalr.value
			local clapp = {}
			local spcrange = gbcolors:getItem("SP_Color_Range")
			for i=1,8 do
				local cl = {}
				if i<=spcrange.value then  
					for j=1,4 do
						cl[j] = rbclgr[i].color[j]
					end
					clapp[i] = cl
				end
			end
			page:getItem("ParticleEmitter").ps:setColors(unpack(clapp))
		end
		
		function spcvalg:changeValue()
			local rb = page:getItem("GB_Color_Selector"):getItem("RB_Color1")
			rb.group[rb:getGroupIndex()].color[2] = spcvalg.value
			local clapp = {}
			local spcrange = gbcolors:getItem("SP_Color_Range")
			for i=1,8 do
				local cl = {}
				if i<=spcrange.value then  
					for j=1,4 do
						cl[j] = rbclgr[i].color[j]
					end
					clapp[i] = cl
				end
			end
			page:getItem("ParticleEmitter").ps:setColors(unpack(clapp))
		end
		
		function spcvalb:changeValue()
			local rb = page:getItem("GB_Color_Selector"):getItem("RB_Color1")
			rb.group[rb:getGroupIndex()].color[3] = spcvalb.value
			local clapp = {}
			local spcrange = gbcolors:getItem("SP_Color_Range")
			for i=1,8 do
				local cl = {}
				if i<=spcrange.value then  
					for j=1,4 do
						cl[j] = rbclgr[i].color[j]
					end
					clapp[i] = cl
				end
			end
			page:getItem("ParticleEmitter").ps:setColors(unpack(clapp))
		end
		
		function spcvala:changeValue()
			local rb = page:getItem("GB_Color_Selector"):getItem("RB_Color1")
			rb.group[rb:getGroupIndex()].color[4] = spcvala.value
			local clapp = {}
			local spcrange = gbcolors:getItem("SP_Color_Range")
			for i=1,8 do
				local cl = {}
				if i<=spcrange.value then  
					for j=1,4 do
						cl[j] = rbclgr[i].color[j]
					end
					clapp[i] = cl
				end
			end
			page:getItem("ParticleEmitter").ps:setColors(unpack(clapp))
		end
	gbcolors:setPosition(8,616)
	
	local gbldamp = page:addItem(GroupBox:new("GB_LinearDamping"))
	gbldamp.caption = "Lin. damping"
	gbldamp:setSize(84,42)
	
	local spldmin = gbldamp:addItem(Spin:new("SP_LD_Min"))
	spldmin.caption = "min"
	spldmin.allowMult = true
	spldmin.leftCaption = true
	spldmin:setPosition(32,4)
	function spldmin:changeValue() 	page:getItem("ParticleEmitter").ps:setLinearDamping(gbldamp:getItem("SP_LD_Min").value,gbldamp:getItem("SP_LD_Max").value) end
	
	local spldmax = gbldamp:addItem(Spin:new("SP_LD_Max"))
	spldmax.caption = "max"
	spldmax.allowMult = true
	spldmax.leftCaption = true
	spldmax:setPosition(32,22)
	function spldmax:changeValue() 	page:getItem("ParticleEmitter").ps:setLinearDamping(gbldamp:getItem("SP_LD_Min").value,gbldamp:getItem("SP_LD_Max").value) end
	
	gbldamp:setPosition(8,684)
	
	local btexman = page:addItem(Button:new("B_TexMan_Show"))
	btexman.caption = "Texture manager"
	btexman:setSize(112,54)
	btexman:setPosition(120,670)
	function btexman:click(b) if b=="l" then local tm = page:getItem("GB_Tex_Manager") if tm.visible == true then tm:hide() else tm:show() end end end
	
	local gbtexman = page:addItem(GroupBox:new("GB_Tex_Manager"))
	gbtexman.caption = "Texture manager"
	gbtexman:setSize(224,256)
	gbtexman.showBorder = false
	gbtexman.cornerLT = true
	
		local lbtex = gbtexman:addItem(ListBox:new("LB_TextureList"))
		lbtex:setSize(160,276)
		lbtex:setPosition(4,32)
		function lbtex:click(b) if b == "l" then 
			local tex = uim:getItem("IC_Textures"):getItem(lbtex:getSelected())
			page:getItem("ParticleEmitter").ps:setTexture(tex)	
			page:getItem("GB_Tex_Manager"):getItem("IM_TM_Texture"):setImage(uim:getItem("IC_Textures"):getItem(lbtex:getSelected()))
			page:getItem("GB_Tex_Manager"):getItem("L_TextureCaption").caption = "Texture: "..lbtex:getSelected()..":"..tex:getWidth().."x"..tex:getHeight()
			local qc = page:getItem("C_Quads")
			qc:purge()
			qc:addItem(love.graphics.newQuad(0,0,tex:getWidth(),tex:getHeight(),tex:getWidth(),tex:getHeight()))
			local gbqc = gbtexman:getItem("GB_QuadControl")
			local qlist = gbqc:getItem("LB_TM_QuadList")
			qlist:clear()
			local qx,qy,qw,qh = qc:getItem(1):getViewport()
			qlist:addItem(qx..","..qy..","..qw..","..qh)
			gbqc:getItem("SP_QViewport_X").value = qx
			gbqc:getItem("SP_QViewport_Y").value = qy
			gbqc:getItem("SP_QViewport_W").value = qw
			gbqc:getItem("SP_QViewport_H").value = qh
			gbqc:getItem("SP_QViewport_X"):changeValue()
			local offs = gbtexman:getItem("GB_TM_Offset")
			offs:getItem("B_TM_Offset_CenterImage"):click("l")
			end	
		end
		
		local ltmdiv = gbtexman:addItem(Line:new("L_TM_Div"))
		ltmdiv:setPosition(170,4)
		ltmdiv:setSize(1,300)
		
		local btmrefr = gbtexman:addItem(Button:new("B_TM_Refresh"))
		btmrefr:setSize(160,24)
		btmrefr:setPosition(4,4)
		btmrefr.caption = "Reload list"
		function btmrefr:click(b) 
			if b=="l" then
				local ic = uim:getItem("IC_Textures")
				local lfs = love.filesystem
				local files = lfs.getDirectoryItems("particles/")
				for i,v in ipairs(files) do
					local str = "particles/"..v
					local tex,texname = str,v
					ic:addItem(tex,texname)
				end			
				local lbt = page:getItem("GB_Tex_Manager"):getItem("LB_TextureList")
				lbt:clear()
				for i = 1,ic:getCount() do
					local item,name = ic:getItem(i)
					lbt:addItem(name)
				end
			end
		end
		btmrefr:click("l")
		
		
		local ltexcapt = gbtexman:addItem(Label:new("L_TextureCaption"))
		ltexcapt.caption = "Texture: 1x1"
		ltexcapt.wrap = false
		ltexcapt:setPosition(182,4)
		
		local imgtex = gbtexman:addItem(Image:new("IM_TM_Texture"))
		imgtex:setPosition(178,36)
		imgtex.showBorder = true
		local img_tex = uim:getItem("IC_Textures"):getItem("default")
		imgtex:setImage(img_tex)
		
		local imgcross = gbtexman:addItem(Cross:new("CR_Cross"))
		imgcross:setPosition(178,36)
		imgcross.centerOnPos = true
		imgcross.blendMode = "replace"
		
		local quadrect = gbtexman:addItem(Rectangle:new("R_QuadRect"))
		quadrect.mode = "line"
		quadrect.dFillColor = {255,0,0,255}
		quadrect:setPosition(178,36)
		quadrect:setSize(1,1)
		
		local gbtmoff = gbtexman:addItem(GroupBox:new("GB_TM_Offset"))
		gbtmoff.caption = "Offset"
		gbtmoff:setSize(148,42)
				
			local boffcent = gbtmoff:addItem(Button:new("B_TM_Offset_CenterImage"))
			boffcent.caption = "Tex. center"
			boffcent:setPosition(66,4)
			boffcent:setSize(80,16)
			function boffcent:click(b) 
				if b=="l" then
					local spox = gbtmoff:getItem("SP_TM_OffsetX")
					local spoy = gbtmoff:getItem("SP_TM_OffsetY")
					local img = uim:getItem("IC_Textures"):getItem(lbtex:getSelected())
					spox.value,spoy.value = img:getWidth()/2,img:getHeight()/2
					spox:changeValue()
				end
			end
			
			local boffcentq = gbtmoff:addItem(Button:new("B_TM_Offset_CenterQuad"))
			boffcentq.caption = "Quad center"
			boffcentq:setPosition(66,22)
			boffcentq:setSize(80,16)
			boffcentq.active = false
			function boffcentq:click(b)
				if b == "l" then
					local qlb = gbtexman:getItem("GB_QuadControl"):getItem("LB_TM_QuadList")
					local qcol = page:getItem("C_Quads")
					if gbtexman:getItem("CB_TM_UseQuads").checked == true then
						local qx,qy,qw,qh = qcol:getItem(qlb.index):getViewport()
						local spox = gbtmoff:getItem("SP_TM_OffsetX")
						local spoy = gbtmoff:getItem("SP_TM_OffsetY")
						spox.value,spoy.value = qw/2,qh/2
						spox:changeValue()					
					end
				end
			end		
			
			local spoffx = gbtmoff:addItem(Spin:new("SP_TM_OffsetX"))
			spoffx.caption = "X"
			spoffx.leftCaption = true
			spoffx.allowMult = true
			spoffx:setPosition(16,4)
			function spoffx:changeValue() 
				local sox,soy,cross,im = gbtmoff:getItem("SP_TM_OffsetX"),gbtmoff:getItem("SP_TM_OffsetY"),gbtexman:getItem("CR_Cross"),gbtexman:getItem("IM_TM_Texture")
				page:getItem("ParticleEmitter").ps:setOffset(sox.value,soy.value) 
				cross:setPosition(im.x+sox.value,im.y+soy.value)
			end
			
			local spoffy = gbtmoff:addItem(Spin:new("SP_TM_OffsetY"))
			spoffy.caption = "Y"
			spoffy.leftCaption = true
			spoffy.allowMult = true
			spoffy:setPosition(16,22)
			function spoffy:changeValue() 
				local sox,soy,cross,im = gbtmoff:getItem("SP_TM_OffsetX"),gbtmoff:getItem("SP_TM_OffsetY"),gbtexman:getItem("CR_Cross"),gbtexman:getItem("IM_TM_Texture")
				page:getItem("ParticleEmitter").ps:setOffset(sox.value,soy.value) 
				cross:setPosition(im.x+sox.value,im.y+soy.value) 
			end
			
		gbtmoff:setPosition(4,324)
		
		local cbuseq = gbtexman:addItem(CheckBox:new("CB_TM_UseQuads"))
		cbuseq.caption = "Use quads"
		cbuseq:setPosition(4,372)
		function cbuseq:click(b) 
			if b=="l" then
				gbtexman:getItem("GB_TM_Offset"):getItem("B_TM_Offset_CenterQuad").active = self.checked
				if self.checked == false then
					gbtexman:getItem("GB_QuadControl"):hide()
					page:getItem("ParticleEmitter").ps:setQuads()
				else
					gbtexman:getItem("GB_QuadControl"):show()
					local cquads = page:getItem("C_Quads")
					page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
				end
			end
		end
		
		local gbqctrl = gbtexman:addItem(GroupBox:new("GB_QuadControl"))
		gbqctrl.caption = "Quad control"
		gbqctrl:setSize(164,276)
		gbqctrl:hide()
		
			local lqviewport = gbqctrl:addItem(Label:new("L_QViewport"))
			lqviewport.caption = "Viewport:"
			lqviewport:setPosition(4,4)
			lqviewport.wrap = false
			
			local spqvpx = gbqctrl:addItem(Spin:new("SP_QViewport_X"))
			spqvpx.caption = "X"
			spqvpx.leftCaption = true
			spqvpx.allowMult = true
			spqvpx:setPosition(16,24)
			function spqvpx:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
				page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
				local str = qx.value..","..qy.value..","..qw.value..","..qh.value
				qlb:setItemValue(qlb.index,str)
				local qr = gbtexman:getItem("R_QuadRect")
				qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
				qr:setSize(qw.value,qh.value)
			end
			
			local spqvpy = gbqctrl:addItem(Spin:new("SP_QViewport_Y"))
			spqvpy.caption = "Y"
			spqvpy.leftCaption = true
			spqvpy.allowMult = true
			spqvpy:setPosition(16,42)
			function spqvpy:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
				page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
				local str = qx.value..","..qy.value..","..qw.value..","..qh.value
				qlb:setItemValue(qlb.index,str)
				local qr = gbtexman:getItem("R_QuadRect")
				qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
				qr:setSize(qw.value,qh.value)
			end
			
			
			local spqvpw = gbqctrl:addItem(Spin:new("SP_QViewport_W"))
			spqvpw.caption = "W"
			spqvpw.leftCaption = true
			spqvpw.allowMult = true
			spqvpw:setPosition(96,24)
			function spqvpw:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
				page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
				local str = qx.value..","..qy.value..","..qw.value..","..qh.value
				qlb:setItemValue(qlb.index,str)
				local qr = gbtexman:getItem("R_QuadRect")
				qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
				qr:setSize(qw.value,qh.value)
			end
			
			local spqvph = gbqctrl:addItem(Spin:new("SP_QViewport_H"))
			spqvph.caption = "H"
			spqvph.leftCaption = true
			spqvph.allowMult = true
			spqvph:setPosition(96,42)
			function spqvph:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
				page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
				local str = qx.value..","..qy.value..","..qw.value..","..qh.value
				qlb:setItemValue(qlb.index,str)
				local qr = gbtexman:getItem("R_QuadRect")
				qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
				qr:setSize(qw.value,qh.value)
			end
			
			
			bqadd = gbqctrl:addItem(Button:new("B_TM_AddQuad"))
			bqadd:setSize(48,24)
			bqadd:setPosition(4,64)
			bqadd.caption = "Add"
			function bqadd:click(b)
				if b=="l" then
					local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
					gbqctrl:getItem("LB_TM_QuadList"):addItem(qx.value..","..qy.value..","..qw.value..","..qh.value)
					gbqctrl:getItem("LB_TM_QuadList"):last()
					local tex = uim:getItem("IC_Textures"):getItem(gbtexman:getItem("LB_TextureList"):getSelected())
					page:getItem("C_Quads"):addItem(love.graphics.newQuad(qx.value,qy.value,qw.value,qh.value,tex:getWidth(),tex:getHeight()))
				end
			end
			
			bqrem = gbqctrl:addItem(Button:new("B_TM_AddQuad"))
			bqrem:setSize(52,24)
			bqrem:setPosition(56,64)
			bqrem.caption = "Remove"
			function bqrem:click(b)
				if b == "l" then
					local lbql = gbqctrl:getItem("LB_TM_QuadList")
					local ql = page:getItem("C_Quads")
					ql:deleteItem(lbql.index)
					lbql:clear()
					for i=1,ql:getCount() do
						local qx,qy,qw,qh = ql:getItem(i):getViewport()
						lbql:addItem(qx..","..qy..","..qw..","..qh)
					end

				end
			end
			
			bqset = gbqctrl:addItem(Button:new("B_TM_AddQuad"))
			bqset:setSize(48,24)
			bqset:setPosition(112,64)
			bqset.caption = "Tex"
			function bqset:click(b)
				if b=="l" then
					local qc = page:getItem("C_Quads")
					local ql = gbqctrl:getItem("LB_TM_QuadList")
					local tex = uim:getItem("IC_Textures"):getItem(gbtexman:getItem("LB_TextureList"):getSelected())
					local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
					qx.value,qy.value,qw.value,qh.value = 0,0,tex:getWidth(),tex:getHeight()
					qx:changeValue()
				end
			end
			
			lbqlist = gbqctrl:addItem(ListBox:new("LB_TM_QuadList"))
			lbqlist:setSize(156,176)
			lbqlist:setPosition(4,96)
			function lbqlist:click(b)
				if b == "l" then
					local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
					local quad = page:getItem("C_Quads"):getItem(lbqlist.index)
					qx.value,qy.value,qw.value,qh.value = quad:getViewport()
					qx:changeValue()
				end
			end
			
		gbqctrl:setPosition(4,410)
	gbtexman:setPosition(248,24)
	
	local gbmisc = page:addItem(GroupBox:new("GB_Misc"))
	gbmisc.caption = "Miscellaneous"
	gbmisc:setSize(138,32)
		
		local bgetcode = gbmisc:addItem(Button:new("B_GetCode"))
		bgetcode:setPosition(4,4)
		bgetcode.caption = "Code"
		bgetcode:setSize(48,24)
		function bgetcode:click(b) 
			if b == "l" then
				local em = page:getItem("ParticleEmitter").ps
				local code = ""
				code = code.."emitter = love.graphics.newParticleSystem(tex,"..em:getBufferSize()..")\n"
				code = code.."emitter:setDirection("..em:getDirection()..")\n"
				local as,asx,asy = em:getAreaSpread()
				code = code.."emitter:setAreaSpread(\""..as.."\","..asx..","..asy..")\n"
				code = code.."emitter:setEmissionRate("..em:getEmissionRate()..")\n"
				code = code.."emitter:setEmitterLifetime("..em:getEmitterLifetime()..")\n"
				local elaxmin,elaymin,elaxmax,elaymax = em:getLinearAcceleration()
				code = code.."emitter:setLinearAcceleration("..elaxmin..","..elaymin..","..elaxmax..","..elaymax..")\n"
				local pttlmin,pttlmax = em:getParticleLifetime()
				code = code.."emitter:setParticleLifetime("..pttlmin..","..pttlmax..")\n"
				local praccmin,praccmax = em:getRadialAcceleration()
				code = code.."emitter:setRadialAcceleration("..praccmin..","..praccmax..")\n"
				local protmin,protmax = em:getRotation()
				code = code.."emitter:setRotation("..protmin..","..protmax..")\n"
				local ptgamin,ptgamax = em:getTangentialAcceleration()
				code = code.."emitter:setTangentialAcceleration("..ptgamin..","..ptgamax..")\n"
				local pspdmin,pspdmax = em:getSpeed()
				code = code.."emitter:setSpeed("..pspdmin..","..pspdmax..")\n"
				local pspinmin,pspinmax = em:getSpin()
				code = code.."emitter:setSpin("..pspinmin..","..pspinmax..")\n"
				code = code.."emitter:setSpinVariation("..em:getSpinVariation()..")\n"
				local pldmin,pldmax = em:getLinearDamping()
				code = code.."emitter:setLinearDamping("..pldmin..","..pldmax..")\n"
				code = code.."emitter:setSpread("..em:getSpread()..")\n"
				code = code.."emitter:setRelativeRotation("..tostring(em:hasRelativeRotation())..")\n"
				local ox,oy = em:getOffset()
				code = code.."emitter:setOffset("..ox..","..oy..")\n"
				local sizes = ""
				for i=1,spsrange.value do
					sizes = sizes..rbszgr[i].caption
					if i~=spsrange.value then sizes = sizes.."," end
				end
				code = code.."emitter:setSizes("..sizes..")\n"
				code = code.."emitter:setSizeVariation("..em:getSizeVariation()..")\n"
				local colors = ""
				for i=1,spcrange.value do
					for j=1,4 do
						colors = colors..rbclgr[i].color[j]
						if j >= 4 and i>=spcrange.value then colors = colors.."" else colors = colors.."," end
					end
					colors = colors.." "
				end
				code = code.."emitter:setColors("..colors..")\n"
				if cbuseq.checked == true and #lbqlist.items>0 then
					local texw,texh = em:getImage():getWidth(),em:getImage():getHeight()
					local qlist = ""
					local qvarlist = ""
					for i=1,#lbqlist.items do 
						qlist = qlist.."local q"..i.." = love.graphics.newQuad("..lbqlist.items[i]..","..texw..","..texh..")\n"
						qvarlist = qvarlist.."q"..i
						if i<#lbqlist.items then qvarlist = qvarlist.."," end
					end
					code = code..qlist
					code = code.."emitter:setQuads("..qvarlist..")".."\n"
				end
				love.system.setClipboardText(code)
			end
		end
		
		local bbmode = gbmisc:addItem(Button:new("B_ShowBlendMode"))
		bbmode.caption = "Blend mode"
		bbmode:setSize(80,24)
		bbmode:setPosition(54,4)
		function bbmode:click(b) if b == "l" then if gbmisc:getItem("LB_BlendMode").visible == true then gbmisc:getItem("LB_BlendMode"):hide() else gbmisc:getItem("LB_BlendMode"):show() end end end
		
		local lbbmode = gbmisc:addItem(ListBox:new("LB_BlendMode"))
		lbbmode:addItem(love.graphics.getBlendMode())
		lbbmode:addItem("additive")
		lbbmode:addItem("subtractive")
		lbbmode:addItem("screen")
		lbbmode:addItem("replace")
		lbbmode:addItem("premultiplied")
		lbbmode:addItem("multiplicative")
		lbbmode:setSize(128,128)
		lbbmode:setPosition(168,-88)
		function lbbmode:click(b)
			page:getItem("ParticleEmitter").mode = lbbmode:getSelected()
		end
		lbbmode:hide()
	
	gbmisc:setPosition(252,love.graphics.getHeight()-36)
	
	
end
