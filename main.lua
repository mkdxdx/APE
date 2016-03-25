--[[
	APE (another particle editor) for LÖVE2D by cval
	
	- a particle system editor tool for quick particle system prototyping, multi-paged interface and code-to-clipboard option
	- features crude interface system, numerous framework-over-framework attempts;
	- meets all the creator's needs, who also hopes that it will meet yours (=
	
	25.03.2016 added 'F11' to open save directory by SiENcE
	24.03.2016 added update of GUI when loading particles by SiENcE
	23.03.2016 added load/save functionality by SiENcE
	13.10.2015 version is uploaded on community forum

	IMPORTANT NOTE that this version was created with 0.9.2 engine version, so please update yours if you have version below
	otherwise some features will cause editor to crash =(
]]

local l_gfx = love.graphics
ui_scrdir = "ui_scripts/"
require(ui_scrdir.."ui")
require("utils")

-- open savefolder
local function openSavefolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

-- take screenshot and save it to the save folder with the current date.
-- If the Screenshots folder does not exist, it will attempt to create it.
local function saveparticle( em, spsrange, spcrange, szspins, rbclgr, cbuseq, gbtexman, lbbmode, gbimode )
	-----------------------------------------------------------------------
	local particle = {}
	particle['buffersize'] = em:getBufferSize()
	particle['direction'] = em:getDirection()
	
	local as,asx,asy = em:getAreaSpread()
	particle['areaspread'] = { as=as, asx=asx, asy=asy }

	particle['emissionrate'] = em:getEmissionRate()
	particle['emitterlifetime'] = em:getEmitterLifetime()
	local pttlmin,pttlmax = em:getParticleLifetime()
	particle['particlelifetime'] = { pttlmin=pttlmin,pttlmax=pttlmax }
	local elaxmin,elaymin,elaxmax,elaymax = em:getLinearAcceleration()
	particle['linearacceleration'] = { elaxmin=elaxmin,elaymin=elaymin,elaxmax=elaxmax,elaymax=elaymax }
	local praccmin,praccmax = em:getRadialAcceleration()
	particle['radialacceleration'] = { praccmin=praccmin,praccmax=praccmax }
	local protmin,protmax = em:getRotation()
	particle['rotation'] = { protmin=protmin,protmax=protmax }
	local ptgamin,ptgamax = em:getTangentialAcceleration()
	particle['tangentialacceleration'] = { ptgamin=ptgamin,ptgamax=ptgamax }
	local pspdmin,pspdmax = em:getSpeed()
	particle['speed'] = { pspdmin=pspdmin,pspdmax=pspdmax }
	local pspinmin,pspinmax = em:getSpin()
	particle['spin'] = { pspinmin=pspinmin,pspinmax=pspinmax }
	particle['spinvariation'] = em:getSpinVariation()
	local pldmin,pldmax = em:getLinearDamping()
	particle['lineardamping'] = { pldmin=pldmin,pldmax=pldmax }
	particle['spread'] = em:getSpread()
	particle['relativerotation'] = em:hasRelativeRotation()
	local ox,oy = em:getOffset()
	particle['offset'] = { ox=ox,oy=oy }
	
	particle['sizesrange'] = spsrange.value
	particle['sizevariation'] = em:getSizeVariation()
	particle['sizes'] = {}
	for i=1,spsrange.value do
		particle['sizes'][i]=szspins[i].value
	end
	
	particle['colorsrange'] = spcrange.value
	particle['colors'] = {}
	for i=1,spcrange.value do
		if not particle['colors'][i] then particle['colors'][i] = {} end
		for j=1,4 do
			particle['colors'][i][j]=rbclgr[i].color[j]
		end
	end
	
	particle['quadsuse'] = gbtexman:getItem("GB_TM_Offset"):getItem("B_TM_Offset_CenterQuad").active
	
	particle['quads'] = {}
	if cbuseq.checked == true and #lbqlist.items>0 then
		local texw,texh = em:getTexture():getWidth(),em:getTexture():getHeight()
		for i=1,#lbqlist.items do 
			if not particle['quads'][i] then particle['quads'][i] = {} end
			particle['quads'][i]={ lbqlist.items[i],texw, texh }
		end
	end
				
	local lbtex = gbtexman:getItem("LB_TextureList")
	particle['image'] = lbtex:getSelected()
	particle['blendmode'] = lbbmode:getSelected()
	particle['insertmode'] = em:getInsertMode()
				
	local dump = ndump( {particle=particle} )
				
	local filename = "par_" .. string.format( "%s.txt", os.date("%m-%d_%H-%M-%S", os.time()) )
	love.filesystem.write('saves/' .. filename, "local " .. dump .. "\nreturn particle\n" )
end

local function loadparticle( filename, uim, em, page )
	if not love.filesystem.exists('saves/' .. filename) then return end
	local content = love.filesystem.read('saves/' .. filename )
	local particle = loadstring(content)()

	em:setBufferSize( particle['buffersize'] )
	page:getItem("SP_BufferSize").value = particle['buffersize']
	
	em:setDirection( particle['direction'] )
	page:getItem("SP_Direction").value = particle['direction']
	
	em:setAreaSpread( particle["areaspread"]["as"], particle["areaspread"]["asx"], particle["areaspread"]["asy"])
	local gb_distr = page:getItem("GB_AreaDistribution")
	local rbdn = gb_distr:getItem("RB_Distr_None")
	local rbdnorm = gb_distr:getItem("RB_Distr_Normal")
	local rbdu = gb_distr:getItem("RB_Distr_Uniform")
	print(rbdn.checked,rbdnorm.checked,rbdu.checked)
	gb_distr:getItem("SP_Distr_X"):hide()
	gb_distr:getItem("SP_Distr_Y"):hide()
	if particle["areaspread"]["as"] == 'none' then
		rbdn.checked = true
		rbdnorm.checked = false
		rbdu.checked = false
	elseif particle["areaspread"]["as"] == 'normal' then
		rbdn.checked = false
		rbdnorm.checked = true
		rbdu.checked = false
		gb_distr:getItem("SP_Distr_X"):show()
		gb_distr:getItem("SP_Distr_Y"):show()
	elseif particle["areaspread"]["as"] == 'uniform' then
		rbdn.checked = false
		rbdnorm.checked = false
		rbdu.checked = true
		gb_distr:getItem("SP_Distr_X"):show()
		gb_distr:getItem("SP_Distr_Y"):show()
	else
		rbdn.checked = true
		rbdnorm.checked = false
		rbdu.checked = false
	end
	gb_distr:getItem("SP_Distr_X").value = tonumber(particle["areaspread"]["asx"])
	gb_distr:getItem("SP_Distr_Y").value = tonumber(particle["areaspread"]["asy"])

	em:setEmissionRate( particle['emissionrate'] )
	page:getItem("SP_ERate").value = particle['emissionrate']
	
	em:setEmitterLifetime( particle['emitterlifetime'] )
	page:getItem("SP_EmLifetime").value = particle['emitterlifetime']
	
	em:setParticleLifetime( particle['particlelifetime'].pttlmin, particle['particlelifetime'].pttlmax )
	local gbplt = page:getItem("GB_PLifetime")
	gbplt:getItem("SP_PLifetime_Min").value = particle['particlelifetime'].pttlmin
	gbplt:getItem("SP_PLifetime_Max").value = particle['particlelifetime'].pttlmax

	em:setParticleLifetime( particle['particlelifetime'].pttlmin, particle['particlelifetime'].pttlmax )
	local gb_lacc = page:getItem("GB_LinearAcceleration")
	gb_lacc:getItem("SP_LA_XMin").value = particle["linearacceleration"]["elaxmin"]
	gb_lacc:getItem("SP_LA_YMin").value = particle["linearacceleration"]["elaymin"]
	gb_lacc:getItem("SP_LA_XMax").value = particle["linearacceleration"]["elaxmax"]
	gb_lacc:getItem("SP_LA_YMax").value = particle["linearacceleration"]["elaymax"]
	
	em:setRadialAcceleration( particle["radialacceleration"]["praccmin"], particle["radialacceleration"]["praccmax"] )
	local gbracc = page:getItem("GB_RadialAcceleration")
	gbracc:getItem("SP_RadialAcc_Min").value = particle["radialacceleration"]["praccmin"]
	gbracc:getItem("SP_RadialAcc_Max").value = particle["radialacceleration"]["praccmax"]
	
	em:setRotation( particle["rotation"]["protmin"], particle["rotation"]["protmax"] )
	local gbrot = page:getItem("GB_Rotation")
	gbrot:getItem("SP_Rotation_Min").value = particle["rotation"]["protmin"]
	gbrot:getItem("SP_Rotation_Max").value = particle["rotation"]["protmax"]
	
	em:setTangentialAcceleration( particle["tangentialacceleration"]["ptgamin"], particle["tangentialacceleration"]["ptgamax"] )
	local gbtga = page:getItem("GB_TangentialAcc")
	gbtga:getItem("SP_TgAcc_Min").value = particle["tangentialacceleration"]["ptgamin"]
	gbtga:getItem("SP_TgAcc_Max").value = particle["tangentialacceleration"]["ptgamax"]
	
	em:setSpeed( particle["speed"]["pspdmin"], particle["speed"]["pspdmax"] )
	local gbspd = page:getItem("GB_Speed")
	gbspd:getItem("SP_Speed_Min").value = particle["speed"]["pspdmin"]
	gbspd:getItem("SP_Speed_Max").value = particle["speed"]["pspdmax"]
	
	em:setSpin( particle["spin"]["pspinmin"], particle["spin"]["pspinmax"] )
	local gbspin = page:getItem("GB_Spin")
	gbspin:getItem("SP_Spin_Min").value = particle["spin"]["pspinmin"]
	gbspin:getItem("SP_Spin_Max").value = particle["spin"]["pspinmax"]
	
	em:setSpinVariation( particle["spinvariation"] )
	page:getItem("SP_Spin_Variation").value = particle["spinvariation"]
	
	em:setLinearDamping( particle["lineardamping"]["pldmin"], particle["lineardamping"]["pldmax"] )
	local gbldamp = page:getItem("GB_LinearDamping")
	gbldamp:getItem("SP_LD_Min").value = particle["lineardamping"]["pldmin"]
	gbldamp:getItem("SP_LD_Max").value = particle["lineardamping"]["pldmax"]
	
	em:setSpread( particle["spread"] )
	page:getItem("SP_Spread").value = particle["spread"]
	
	em:setRelativeRotation( enable )
	page:getItem("CB_RelativeRotation").checked = particle["relativerotation"]
	
	-- Offset
	em:setOffset( particle["offset"]["ox"], particle["offset"]["oy"] )
	local gbtexman = page:getItem("GB_Tex_Manager")
	local gbtmoff = gbtexman:getItem("GB_TM_Offset")
	gbtmoff:getItem("SP_TM_OffsetX").value = particle["offset"]["ox"]
	gbtmoff:getItem("SP_TM_OffsetY").value = particle["offset"]["oy"]
	
	-- Sizes
	local gbsizes = page:getItem("GB_Size_Selector")
	gbsizes:getItem("SP_Size_Range").value = particle['sizesrange']
	em:setSizeVariation( particle["sizevariation"] )
	gbsizes:getItem("SP_Size_Var").value = particle["sizevariation"]
	local sizes = {}
	for i=1,8 do
		local spsz = gbsizes:getItem("SP_Size_" .. tostring(i))
		if i <= particle['sizesrange'] then
			spsz.value = particle["sizes"][tostring(i)]
			spsz.active = true
			sizes[i] = particle["sizes"][tostring(i)]
		else
			spsz.value = 1.0
			spsz.active = false
			sizes[i] = 1.0
		end
	end
	em:setSizes( unpack(sizes) )
	
	-- Colors
	local gbcolors = page:getItem("GB_Color_Selector")
	gbcolors:getItem("SP_Color_Range").value = particle["colorsrange"]
	local clapp = {}
	for i=1,8 do
		local rbcl = gbcolors:getItem("RB_Color" .. tostring(i))
		if i == 1 then rbcl.checked = true end
		if i <= particle["colorsrange"] then
			local cl = {}
			for j=1,4 do
				--print(j, particle["colors"][tostring(i)][tostring(j)])
				rbcl.group[i].color[j] = particle["colors"][tostring(i)][tostring(j)]
				cl[j] = rbcl.group[i].color[j]
			end
			clapp[i] = cl
			
			rbcl.active = true
		else
			for j=1,4 do
				rbcl.group[i].color[j] = 255
			end
			rbcl.active = false
		end
	end
	em:setColors(unpack(clapp))

	-- Texture
	local gbtexman = page:getItem("GB_Tex_Manager")
	local lbtex = gbtexman:getItem("LB_TextureList")
	for i,v in ipairs(lbtex.items) do
		if v == particle["image"] then
			lbtex.index = i
			break
		end
	end
	local tex = uim:getItem("IC_Textures"):getItem(lbtex:getSelected())
	em:setTexture( tex )
	page:getItem("GB_Tex_Manager"):getItem("IM_TM_Texture"):setImage(uim:getItem("IC_Textures"):getItem(lbtex:getSelected()))
	page:getItem("GB_Tex_Manager"):getItem("L_TextureCaption").caption = "Texture: "..lbtex:getSelected()..":"..tex:getWidth().."x"..tex:getHeight()

	-- Quads
	gbtexman:getItem("CB_TM_UseQuads").checked = particle['quadsuse']
	if particle['quadsuse'] then
		gbtexman:getItem("GB_QuadControl"):show()
	else
		gbtexman:getItem("GB_QuadControl"):hide()
	end
	local gbqctrl = gbtexman:getItem("GB_QuadControl")
	local lbqlist = gbqctrl:getItem("LB_TM_QuadList")
	lbqlist:clear()
	local c_quads = page:getItem("C_Quads")
	c_quads:purge()
	for i,quadstring in pairsByKeys(particle["quads"]) do
		local stringvalues = split(quadstring["1"], ',')
		local values = {}
		for j,zahl in pairs(stringvalues) do
			values[j] = zahl
		end
		local qx = values[1]
		local qy = values[2]
		local qw = values[3]
		local qh = values[4]
		local texwidth = quadstring["2"]
		local textheight = quadstring["3"]
		lbqlist:addItem(qx..","..qy..","..qw..","..qh)
		gbqctrl:getItem("LB_TM_QuadList"):last()
		page:getItem("C_Quads"):addItem( love.graphics.newQuad(qx,qy,qw,qh,texwidth,textheight) )
		print('Quadcount:', #c_quads.items)
	end
	if particle['quadsuse'] then
		gbqctrl:getItem("SP_QViewport_W").value = particle["quads"]["1"]["2"]
		gbqctrl:getItem("SP_QViewport_H").value = particle["quads"]["1"]["3"]
	else
		gbqctrl:getItem("SP_QViewport_W").value = tex:getWidth()
		gbqctrl:getItem("SP_QViewport_H").value = tex:getHeight()
	end
	em:setQuads(unpack(c_quads.items))
	
	-- update Texture Frame
	local imgcross = gbtexman:getItem("CR_Cross")
	local sox,soy,im = gbtmoff:getItem("SP_TM_OffsetX"),gbtmoff:getItem("SP_TM_OffsetY"),gbtexman:getItem("IM_TM_Texture")
	imgcross:setPosition(im.x+sox.value,im.y+soy.value)
	
	local quadrect = gbtexman:getItem("R_QuadRect")
	if particle['quadsuse'] then
		local qx,qy,qw,qh = c_quads:getItem(1):getViewport()
		quadrect:setPosition(im.x+qx, im.y+qy)
		quadrect:setSize(qw,qh)
	else
		quadrect:setPosition(im.x, im.y)
		quadrect:setSize(tex:getWidth(),tex:getHeight())
	end

	-- insertMode
	em:setInsertMode( particle['insertmode'] )
	local gbimode = page:getItem("GB_InsertMode")
	local rbimtop = gbimode:getItem("RB_IM_Top")
	local rbimbot = gbimode:getItem("RB_IM_Bottom")
	local rbimrnd = gbimode:getItem("RB_IM_Random")
	rbimtop.checked = false
	rbimbot.checked = false
	rbimrnd.checked = false
	if particle['insertmode'] == 'top' then
		rbimtop.checked = true 
	elseif particle['insertmode'] == 'bottom' then
		rbimbot.checked = true
	elseif particle['insertmode'] == 'random' then
		rbimrnd.checked = true
	end

	-- blendmode
	local gbmisc = page:getItem("GB_Misc")
	local lbbmode = gbmisc:getItem("LB_BlendMode")
	-- blendmode select
	page:getItem("ParticleEmitter").mode = particle["blendmode"]
	for i,v in ipairs(lbbmode.items) do
		if v == particle["blendmode"] then
			lbbmode.index = i
			break
		end
	end
end

function love.load()
	love.window.setTitle("APE for LÖVE2D by cval & SiENcE")
	l_gfx.setFont(l_gfx.newFont(12))
	uim = UIManager:new()
	UIElement.colorFill = {48,48,48,255}
	UIElement.colorHardFill = {80,80,80,255}
	UIElement.colorDisabledFill = {16,16,16,255}
	UIElement.colorHighlight = {96,96,96,255}
	local deftexID = love.image.newImageData(1,1)
	deftexID:setPixel(0,0,255,255,255)
	local ic = uim:addItem(ImageCollection:new("IC_Textures"))
	ic:addItem(deftexID,"default")

	local icf = uim:addItem(Collection:new("IC_Files"))

	local pgs = uim:addItem(PageSwitch:new("Scene"))
	local pgsc = uim:addItem(PageSwitchController:new("PSController"))
	pgsc:setPageSwitch(pgs)
	pgsc:setPosition(0,love.graphics.getHeight()-32)
	local pgadd = pgsc:getItem("ButtonAdd")
	function pgadd:click(b)
		if b == 1 then 
			local pg = pgs:addPage() 
			pgsc.caption = pgsc.pageswitch.index.."/"..#pgsc.pageswitch.pages
			fillPage(pg) 
		end
	end
	pgadd:click(1)	
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

function love.wheelmoved(x,y)
	uim:wheelmoved(x,y)
end

function love.mousereleased(x,y,b)
	uim:mousereleased(x,y,b)
end

function love.keypressed(key,isrepeat)
	uim:keypressed(key,isrepeat)

--	if key == 'f5' then
--		saveparticle()
--	end
--	if key == 'f9' then
--		loadparticle()
--	end
	if key == 'f11' then
		openSavefolder()
	end
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
	emspr.colorFill = {255,255,0,255}
	emspr.mode = "line"
	emspr.radius = 128
	emspr:setAngle(-0.01,0.01)
	emspr:setPosition(love.graphics.getWidth()/2+224,love.graphics.getHeight()/2)
	emspr:hide()
	
	local emarea = page:addItem(Rectangle:new("R_EArea"))
	emarea.colorFill = {255,0,0,255}
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
	
	
	local bsspin = page:addItem(SpinEdit:new("SP_BufferSize"))
	bsspin.caption = "Buffer:"
	bsspin.leftCaption = true
	bsspin:setPosition(56,8)
	bsspin.max = nil
	bsspin.maxdec = 0 
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
	spdir.maxdec = 2
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
			if b == 1 then  
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
			if b == 1 then 
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
			if b == 1 then 
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
		spdistrx.maxdec = 0
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
		spdistry.maxdec = 0
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
	function btstart:click(b) if b == 1 then page:getItem("ParticleEmitter").ps:start() end end
	
	local sperate = page:addItem(Spin:new("SP_ERate"))
	sperate:setPosition(116,112)
	sperate.maxdec = 1
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
	spemlt.maxdec = 1
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
		sprotmin.step = 0.1
		sprotmin.maxdec = 2
		sprotmin.leftCaption = true
		function sprotmin:changeValue()
			page:getItem("ParticleEmitter").ps:setRotation(gbrot:getItem("SP_Rotation_Min").value,gbrot:getItem("SP_Rotation_Max").value)
		end
		
		local sprotmax = gbrot:addItem(Spin:new("SP_Rotation_Max"))
		sprotmax:setPosition(32,22)
		sprotmax.allowMult = true
		sprotmax.step = 0.1
		sprotmax.maxdec = 2
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
	spspvar.maxdec = 2
	spspvar.min = 0
	spspvar.max = 1
	spspvar.allowMult = true
	spspvar.leftCaption = true
	function spspvar:changeValue() page:getItem("ParticleEmitter").ps:setSpinVariation(page:getItem("SP_Spin_Variation").value) end
	
	local spspread = page:addItem(Spin:new("SP_Spread"))
	spspread:setPosition(180,444)
	spspread.caption = "Spread"
	spspread.step = 0.1
	spspread.maxdec = 2
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
	function cbrelrot:click(b) if b == 1 then page:getItem("ParticleEmitter").ps:setRelativeRotation(cbrelrot.checked) end end
	
	local cbfmouse = page:addItem(CheckBox:new("CB_FollowMouse"))
	cbfmouse.caption = "Follow mouse"
	cbfmouse:setPosition(128,468)
	function cbfmouse:click(b) if b == 1 then page:getItem("ParticleEmitter").followMouse = cbfmouse.checked if cbfmouse.checked == false then
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
		function rbimtop:click(b) if b == 1 then page:getItem("ParticleEmitter").ps:setInsertMode(rbimtop.group[rbimtop:getGroupIndex()].caption) end end
		
		local rbimbot = gbimode:addItem(RadioButton:new("RB_IM_Bottom"))
		rbimbot:setPosition(80,4)
		rbimbot.caption = "bottom"
		rbimbot.buttonStyle = true
		rbimbot:setSize(64,16)
		function rbimbot:click(b) if b == 1 then page:getItem("ParticleEmitter").ps:setInsertMode(rbimbot.group[rbimbot:getGroupIndex()].caption) end end
		
		local rbimrnd = gbimode:addItem(RadioButton:new("RB_IM_Random"))
		rbimrnd:setPosition(156,4)
		rbimrnd.caption = "random"
		rbimrnd.buttonStyle = true
		rbimrnd:setSize(64,16)
		function rbimrnd:click(b) if b == 1 then page:getItem("ParticleEmitter").ps:setInsertMode(rbimrnd.group[rbimrnd:getGroupIndex()].caption) end end
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
		spsrange.maxdec = 0
		spsrange.min = 1
		spsrange.value = 1
		
		
		local spszvar = gbsizes:addItem(Spin:new("SP_Size_Var"))
		spszvar.caption = "Var."
		spszvar.max = 1
		spszvar.maxdec = 2
		spszvar.min = 0
		spszvar.leftCaption = true
		spszvar.allowMult = true
		spszvar.step = 0.1
		spszvar:setPosition(188,4)
		spszvar:setSize(32,16)
		function spszvar:changeValue()	page:getItem("ParticleEmitter").ps:setSizeVariation(self.value)	end
		
		local spsz8 = gbsizes:addItem(Spin:new("SP_Size_8"))
		local spsz7 = gbsizes:addItem(Spin:new("SP_Size_7"))
		local spsz6 = gbsizes:addItem(Spin:new("SP_Size_6"))
		local spsz5 = gbsizes:addItem(Spin:new("SP_Size_5"))
		local spsz4 = gbsizes:addItem(Spin:new("SP_Size_4"))
		local spsz3 = gbsizes:addItem(Spin:new("SP_Size_3"))
		local spsz2 = gbsizes:addItem(Spin:new("SP_Size_2"))
		local spsz1 = gbsizes:addItem(Spin:new("SP_Size_1"))
		local szspins = {spsz1,spsz2,spsz3,spsz4,spsz5,spsz6,spsz7,spsz8}
		
		spsz1:setSize(24,16)
		spsz1.caption = ""
		spsz1:setPosition(8,28)
		spsz1.step = 0.1
		spsz1.value = 1
		spsz1.allowMult = true
		spsz1.max = nil
		spsz1.min = nil
		function spsz1:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz2:setSize(24,16)
		spsz2.caption = ""
		spsz2:setPosition(spsz1.x+spsz1.w+2,spsz1.y)
		spsz2.step = 0.1
		spsz2.value = 1
		spsz2.allowMult = true
		spsz2.max = nil
		spsz2.min = nil
		spsz2.active = false
		function spsz2:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz3:setSize(24,16)
		spsz3.caption = ""
		spsz3:setPosition(spsz2.x+spsz2.w+2,spsz2.y)
		spsz3.step = 0.1
		spsz3.value = 1
		spsz3.allowMult = true
		spsz3.max = nil
		spsz3.min = nil
		spsz3.active = false
		function spsz3:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz4:setSize(24,16)
		spsz4.caption = ""
		spsz4:setPosition(spsz3.x+spsz3.w+2,spsz3.y)
		spsz4.step = 0.1
		spsz4.value = 1
		spsz4.allowMult = true
		spsz4.max = nil
		spsz4.min = nil
		spsz4.active = false
		function spsz4:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz5:setSize(24,16)
		spsz5.caption = ""
		spsz5:setPosition(spsz4.x+spsz4.w+2,spsz3.y)
		spsz5.step = 0.1
		spsz5.value = 1
		spsz5.allowMult = true
		spsz5.max = nil
		spsz5.min = nil
		spsz5.active = false
		function spsz5:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz6:setSize(24,16)
		spsz6.caption = ""
		spsz6:setPosition(spsz5.x+spsz5.w+2,spsz5.y)
		spsz6.step = 0.1
		spsz6.allowMult = true
		spsz6.max = nil
		spsz6.value = 1
		spsz6.min = nil
		spsz6.active = false
		function spsz6:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz7:setSize(24,16)
		spsz7.caption = ""
		spsz7:setPosition(spsz6.x+spsz6.w+2,spsz6.y)
		spsz7.step = 0.1
		spsz7.allowMult = true
		spsz7.max = nil
		spsz7.value = 1
		spsz7.min = nil
		spsz7.active = false
		function spsz7:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		spsz8:setSize(24,16)
		spsz8.caption = ""
		spsz8:setPosition(spsz7.x+spsz7.w+2,spsz7.y)
		spsz8.step = 0.1
		spsz8.value = 1
		spsz8.allowMult = true
		spsz8.max = nil
		spsz8.min = nil
		spsz8.active = false
		function spsz8:changeValue() 
			local szarr = {}
			for i=1,spsrange.value do
				szarr[i] = szspins[i].value
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
		
		function spsrange:changeValue()
			local szarr = {}
			for i=1,8 do
				szspins[i].active = (i<=self.value)
				if i<=self.value then
					szarr[i] = szspins[i].value
				end
			end
			page:getItem("ParticleEmitter").ps:setSizes(unpack(szarr))
		end
	gbsizes:setPosition(8,548)
	
	-- color picker commencing!
	
	local gbcolors = page:addItem(GroupBox:new("GB_Color_Selector"))
	gbcolors:setSize(224,48)
	gbcolors.caption = "Colors"
	
		local spcrange = gbcolors:addItem(Spin:new("SP_Color_Range"))
		spcrange.caption = "Range:"
		spcrange.leftCaption = true
		spcrange.maxdec = 0
		spcrange:setPosition(56,4)
		spcrange:setSize(28,16)
		spcrange.max = 8
		spcrange.min = 1
		spcrange.value = 1
		
		local spcvala = gbcolors:addItem(Spin:new("SP_Color_ValA"))
		spcvala.caption = ""
		spcvala.maxdec = 0
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
		spcvalb.maxdec = 0
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
		spcvalg.maxdec = 0
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
		spcvalr.maxdec = 0
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
			if b == 1 then 
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
	function btexman:click(b) if b==1 then local tm = page:getItem("GB_Tex_Manager") if tm.visible == true then tm:hide() else tm:show() end end end
	
	local gbtexman = page:addItem(GroupBox:new("GB_Tex_Manager"))
	gbtexman.caption = "Texture manager"
	gbtexman:setSize(224,256)
	gbtexman.showBorder = false
	gbtexman.cornerLT = true
	gbtexman.visible = false
	
		local lbtex = gbtexman:addItem(ListBox:new("LB_TextureList"))
		lbtex:setSize(160,276)
		lbtex:setPosition(4,32)
		function lbtex:click(b) if b == 1 then 
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
			offs:getItem("B_TM_Offset_CenterImage"):click(1)
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
			if b == 1 then
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
		btmrefr:click(1)
		
		
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
		quadrect.colorFill = {255,0,0,255}
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
				if b == 1 then
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
				if b == 1 then
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
			if b == 1 then
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
				if #qlb.items>0 then
					cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
					page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
					local str = qx.value..","..qy.value..","..qw.value..","..qh.value
					qlb:setItemValue(qlb.index,str)
					local qr = gbtexman:getItem("R_QuadRect")
					qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
					qr:setSize(qw.value,qh.value)
				end
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
				if #qlb.items>0 then
					cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
					page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
					local str = qx.value..","..qy.value..","..qw.value..","..qh.value
					qlb:setItemValue(qlb.index,str)
					local qr = gbtexman:getItem("R_QuadRect")
					qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
					qr:setSize(qw.value,qh.value)
				end
			end
			
			
			local spqvpw = gbqctrl:addItem(Spin:new("SP_QViewport_W"))
			spqvpw.caption = "W"
			spqvpw.maxdec = 0
			spqvpw.leftCaption = true
			spqvpw.allowMult = true
			spqvpw:setPosition(96,24)
			function spqvpw:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				if #qlb.items>0 then
					cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
					page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
					local str = qx.value..","..qy.value..","..qw.value..","..qh.value
					qlb:setItemValue(qlb.index,str)
					local qr = gbtexman:getItem("R_QuadRect")
					qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
					qr:setSize(qw.value,qh.value)
				end
			end
			
			local spqvph = gbqctrl:addItem(Spin:new("SP_QViewport_H"))
			spqvph.caption = "H"
			spqvph.leftCaption = true
			spqvph.maxdec = 0
			spqvph.allowMult = true
			spqvph:setPosition(96,42)
			function spqvph:changeValue()
				local qx,qy,qw,qh = gbqctrl:getItem("SP_QViewport_X"),gbqctrl:getItem("SP_QViewport_Y"),gbqctrl:getItem("SP_QViewport_W"),gbqctrl:getItem("SP_QViewport_H")
				local cquads = page:getItem("C_Quads")
				local qlb = gbqctrl:getItem("LB_TM_QuadList")
				if #qlb.items>0 then
					cquads:getItem(qlb.index):setViewport(qx.value,qy.value,qw.value,qh.value)
					page:getItem("ParticleEmitter").ps:setQuads(unpack(cquads.items))
					local str = qx.value..","..qy.value..","..qw.value..","..qh.value
					qlb:setItemValue(qlb.index,str)
					local qr = gbtexman:getItem("R_QuadRect")
					qr:setPosition(gbtexman:getItem("IM_TM_Texture").x+qx.value,gbtexman:getItem("IM_TM_Texture").y+qy.value)
					qr:setSize(qw.value,qh.value)
				end
			end
			
			
			bqadd = gbqctrl:addItem(Button:new("B_TM_AddQuad"))
			bqadd:setSize(48,24)
			bqadd:setPosition(4,64)
			bqadd.caption = "Add"
			function bqadd:click(b)
				if b == 1 then
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
				if b == 1 then
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
				if b == 1 then
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
				if b == 1 then
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
		gbmisc:setSize(210,32)
		
		local bbmode = gbmisc:addItem(Button:new("B_ShowBlendMode"))
		bbmode.caption = "Blend mode"
		bbmode:setSize(80,24)
		bbmode:setPosition(4,4)
		function bbmode:click(b) if b == 1 then if gbmisc:getItem("LB_BlendMode").visible == true then gbmisc:getItem("LB_BlendMode"):hide() else gbmisc:getItem("LB_BlendMode"):show() end end end
		
		local lbbmode = gbmisc:addItem(ListBox:new("LB_BlendMode"))
		lbbmode:addItem(love.graphics.getBlendMode())
		lbbmode:addItem("add")
		lbbmode:addItem("subtract")
		lbbmode:addItem("screen")
		lbbmode:addItem("replace")
		lbbmode:addItem("multiply")
		lbbmode:setSize(128,128)
		lbbmode:setPosition(4,-100)
		function lbbmode:click(b)
			page:getItem("ParticleEmitter").mode = lbbmode:getSelected()
		end
		lbbmode:hide()

		---------------------------------------------------------------------------
		-- save
		---------------------------------------------------------------------------
		local bsaveparticle = gbmisc:addItem(Button:new("B_SaveParticle"))
		bsaveparticle:setPosition(86,4)
		bsaveparticle.caption = "Save"
		bsaveparticle:setSize(48,24)
		function bsaveparticle:click(b)
			if b == 1 then
				local em = page:getItem("ParticleEmitter").ps
				saveparticle( em, spsrange, spcrange, szspins, rbclgr, cbuseq, gbtexman, lbbmode, gbimode )
			end
		end

		local codelabel = gbmisc:addItem(Label:new("L_Codelist"))
		codelabel:setPosition(gbmisc.w+32,gbmisc.y-384)
		codelabel:setSize(512,512)
		codelabel.align = "left"
		codelabel.caption = "No code generated\nPress \"Code\" button to generate it and copy to clipboard"
		codelabel.visible = false
		
		local bgetcode = gbmisc:addItem(Button:new("B_GetCode"))
		bgetcode:setPosition(bsaveparticle.w+2+86,4)
		bgetcode.caption = "Code"
		bgetcode:setSize(48,24)
		function bgetcode:click(b) 
			if b == 1 then
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
					sizes = sizes..szspins[i].value
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
					local texw,texh = em:getTexture():getWidth(),em:getTexture():getHeight()
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
				codelabel.caption = code
			end
		end
	
		local bshowcode = gbmisc:addItem(CheckBox:new("B_ShowCode"))
		bshowcode.buttonStyle = true
		bshowcode.checked = false
		bshowcode:setPosition(bgetcode.x+bgetcode.w+2,bgetcode.y)
		bshowcode:setSize(20,24)
		bshowcode.caption = ">"
		function bshowcode:click(b) if b == 1 then codelabel.visible = self.checked end end
		
		gbmisc:setPosition(252,love.graphics.getHeight()-36)
	
	---------------------------------------------------------------------------
	-- load
	---------------------------------------------------------------------------
	local btexman2 = page:addItem(Button:new("B_FileMan_Show"))
	btexman2.caption = "File manager"
	btexman2:setSize(104,32)
	btexman2:setPosition(133,735)
	function btexman2:click(b) if b==1 then local tm = page:getItem("GB_File_Manager") if tm.visible == true then tm:hide() else tm:show() end end end
	
	local gbtexman2 = page:addItem(GroupBox:new("GB_File_Manager"))
	gbtexman2.caption = "File manager"
	gbtexman2:setSize(224,256)
	gbtexman2:setPosition(428,434)
	gbtexman2.showBorder = false
	gbtexman2.cornerLT = true
	gbtexman2.visible = true

		local lbfile = gbtexman2:addItem(ListBox:new("LB_FileList"))
		lbfile:setSize(160,276)
		lbfile:setPosition(184,38)
		function lbfile:click(b)
			if b == 2 then
				print(lbfile:getSelected())
				local em = page:getItem("ParticleEmitter").ps
				loadparticle( lbfile:getSelected(), uim, em, page )
			end
		end
		
		local btmrefr2 = gbtexman2:addItem(Button:new("B_FM_Refresh"))
		btmrefr2:setSize(160,24)
		btmrefr2:setPosition(gbtexman2.x+5,gbtexman2.y+5)
		btmrefr2.caption = "Reload list"
		function btmrefr2:click(b) 
			if b == 1 then
				local icf = uim:getItem("IC_Files")
				local files = love.filesystem.getDirectoryItems("saves/")
				icf:purge()
				for i,filename in ipairs(files) do
					print(i.. ". " .. filename)
					icf:addItem(filename)
				end
				local lbt = page:getItem("GB_File_Manager"):getItem("LB_FileList")
				lbt:clear()
				for i = 1,icf:getCount() do
					local filename = icf:getItem(i)
					lbt:addItem(filename)
				end
			end
		end
		btmrefr2:click(1)
		
		lbfile:setPosition(btmrefr2.x,btmrefr2.y+btmrefr2.h+4)
end
