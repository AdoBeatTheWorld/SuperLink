
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")
function MainScene:ctor()
    ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
	local item = SpriteItem.new()
	item:setData(0)
	item:setPos(2,2)
	item:addTo(self)
end

function MainScene:onExit()
end

return MainScene
