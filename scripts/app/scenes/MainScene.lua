
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")

local  startX,startY = 50,50
local row = 8

function MainScene:ctor()
	self.layer = display.newLayer():addTo(self)
    self.scorelb = ui.newTTFLabel({text = "Score : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
			        :pos(display.width-150, display.height-40)
			        :addTo(self.layer)

    self.timelb = ui.newTTFLabel({text = "Time  : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
				    :pos(display.width-150, display.height-80)
				    :addTo(self.layer)

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
end

function MainScene:getItem( posx, posy )
	local px = math.round((posx - startX)/50)
	local py = math.round((posy-startY)/50)
	local index = row * py + px
	local item = self.items[index]
	printInfo("posx:%d, posy:%d, x:%d, y:%d index:%d", posx, posy, px, py, index)
	return item
end

function MainScene:onExit()
end

return MainScene
