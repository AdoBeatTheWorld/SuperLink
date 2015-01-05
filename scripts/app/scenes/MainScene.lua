
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")

local  startX,startY = 50,50
local row = 8

MainScene._GrayFilter = {"GRAY",{0.2, 0.3, 0.5, 0.1}}
MainScene._DIRECTIONS = {1,2,8,16}
MainScene.RIGHT = 1
MainScene.DOWN = 2
MainScene.LEFT = 8
MainScene.UP = 16

function MainScene:ctor()
	self.layer = display.newLayer():addTo(self)
    self.scorelb = ui.newTTFLabel({text = "Score : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
			        :pos(display.width-150, display.height-40)
			        :addTo(self.layer)

    self.timelb = ui.newTTFLabel({text = "Time  : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
				    :pos(display.width-150, display.height-80)
				    :addTo(self.layer)

	self.selectedIcon = display.newSprite("res/selected.png"):addTo(self.layer)
	self.selectedIcon:setVisible(false)
	self.items = {}
	self.openlist = {}
	self.closelist = {}
end

function MainScene:onEnter()
	print(#MainScene._DIRECTIONS)
	local item
	local item0
	local temptype = 1
	for i=1,32 do
		temptype = math.floor(math.random(0,10))
		item = SpriteItem.new()
		item:setData(temptype)
		item:addTo(self.layer)
		item:setName(string.format("item%d", i))
		self.items[i] = item
		item:setPos(math.floor((i-1)%row),math.floor((i-1)/row))

		item0 = SpriteItem.new()
		item0:setData(temptype)
		item0:addTo(self.layer)
		self.items[i+32] = item0
		item0:setName(string.format("item%d", i+32))
		item0:setPos(math.floor((i+31)%row),math.floor((i+31)/row))
	end

	self:shuffle(self.items)

	self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouched))
	self.layer:setTouchEnabled(true)
end

function MainScene:onTouched(event)
	local tx,ty = event.x, event.y
	print("onTouche", tx, ty)
	local item = self:getItem(tx,ty)
	if item == nil then
		return
	end
	--如果已经选中了一个item就进行连接判断
	if self.selectedItem then
		if self.selectedItem ~= item then
			local sx,sy = self.selectedItem:getPos()
			local tx,ty = item:getPos()

			local path = {{0,sx,sy}}
			self.openlist = {}
			self.closelist = {}
			self.openlist[string.format("%d_%d", sx,sy)] = true
			for i=1,#MainScene._DIRECTIONS do
				path = self:getPath(path, sx, sy, tx, ty, MainScene._DIRECTIONS[i], 0)
				if path ~= nil then
					print("Path found")
				end
			end
			
			if path == nil then
				self.selectedItem = item
				self.selectedIcon:setPosition(item:getPosition())
			end
		else
			self.selectedItem = nil
			self.selectedIcon:setVisible(false)
		end
	else
		self.selectedItem = item
		self.selectedIcon:setVisible(true)
		self.selectedIcon:setPosition(item:getPositionX()-1, item:getPositionY()-1)
	end
end

function MainScene:getItem( posx, posy )	
	local px = math.round((posx - startX)/50)
	local py = math.round((posy-startY)/50)
	if px > 8 or py > 8 then
		return nil
	end
	local index = row * py + px + 1
	local item = self.items[index]
	
	return item
end

function MainScene:getItemByPos( px,py )
	if px > 8 or py > 8 then
		return nil
	end
	local index = row * py + px + 1
	local item = self.items[index]
	
	return item
end

function MainScene:getNextItem( sx,sy,dir )
	-- body
end
--path 当前已遍历数组 sx 当前item的x sy当前item的y tx目标x ty目标y cdir当前方向 ct当前转向次数
function MainScene:getPath(path, sx,sy,tx,ty,cdir,ct, ci)
	local next
	if cdir == MainScene.RIGHT then
		sx = sx + 1
	elseif cdir == MainScene.LEFT then
		sx = sx - 1
	elseif cdir == MainScene.DOWN then
		sy = sy - 1
	elseif cdir == MainScene.UP then
		sy = sy + 1
	end

	local  key = string.format("%d_%d", sx,sy)
	if self.openlist[key] or self.closelist[key] then--not looped
		return nil
	end

	if sx == tx and sy == ty then--found
		path[1] = {ci,sx,sy} 
		return path
	end

	next = self:getItemByPos(sx,sy)
	if next == nil then
		return self:getPath(path, sx, sy, tx, ty, cdir, ct, ci)--get next do not need change dir
	elseif next ~= nil then-- need change dir
		
	end
	return path
end

function MainScene:shuffle(t)
	local  len = #t
	for i=1,len*2 do
		local a = math.floor(math.random(len))
		local b = math.floor(math.random(len))
		
		if a ~= b then
			t[a],t[b] = t[b],t[a]
			t[a]:setPos(math.floor((a-1)%row),math.floor((a-1)/row))
			t[b]:setPos(math.floor((b-1)%row),math.floor((b-1)/row))
			--printInfo("swap item %d : %d", a,b)
		end
	end
	--[[i = 1
	for i=1,len do
		print(t[i]:getName())
	end]]
end

function MainScene:onExit()
end

return MainScene
