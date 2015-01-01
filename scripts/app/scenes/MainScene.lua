
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")

local  startX,startY = 50,50
local row = 8

MainScene._GrayFilter = {"GRAY",{0.2, 0.3, 0.5, 0.1}}
MainScene.RIGHT = 1
MainScene.DOWN = 2
MainScene.LEFT = 8
MainScene.RIGHT = 16

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
end

function MainScene:onEnter()
	local item
	for i=1,64 do
		item = SpriteItem.new()
		item:setData(math.floor(math.random(0,10)))
		item:addTo(self.layer)
		self.items[i] = item
		item:setPos(math.floor((i-1)%row),math.floor((i-1)/row))
	end
	self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouched))
	self.layer:setTouchEnabled(true)
end

function MainScene:onTouched(event)
	local tx,ty = event.x, event.y
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
			self:getPath(sx, sy, tx, ty, MainScene.RIGHT, 0)
			if path == nil then
				self:getPath(path, sx, sy, tx, ty, MainScene.DOWN, 0)
			end
			if path == nil then
				self:getPath(path, sx, sy, tx, ty, MainScene.LEFT, 0)
			end
			if path == nil then
				self:getPath(path, sx, sy, tx, ty, MainScene.UP, 0)
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
	local index = row * py + px + 1
	local item = self.items[index]
	printInfo("posx:%d, posy:%d, x:%d, y:%d index:%d", posx, posy, px, py)
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

	return path
end

function MainScene:onExit()
end

return MainScene
