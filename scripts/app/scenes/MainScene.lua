
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")
function MainScene:ctor()

    self.scorelb = ui.newTTFLabel({text = "Score : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
			        :pos(display.width-150, display.height-40)
			        :addTo(self)

    self.timelb = ui.newTTFLabel({text = "Time  : 0", size = 30, align = ui.TEXT_ALIGN_LEFT})
				    :pos(display.width-150, display.height-80)
				    :addTo(self)

	self.items = {}
end

function MainScene:onEnter()
	local item
	local row = 8
	for i=1,64 do
		item = SpriteItem.new()
		item:setData(math.floor(math.random(0,10)))
		item:addTo(self)
		self.items[i] = item
		item:setPos(math.floor((i-1)%row),math.floor((i-1)/row))
		printInfo("item %d pos : %d, %d", i, item:getPos())
	end
	
end

function MainScene:onExit()
end

return MainScene
