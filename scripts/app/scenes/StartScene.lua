local StartScene = class("StartScene", function()
	return display.newScene("StartScene")
end)

function StartScene:ctor()
	self.item0 = ui.newTTFLabelMenuItem({text = "标准模式", size = 30, align = ui.TEXT_ALIGN_CENTER, 
        x = display.cx, y = display.cy + 80, color = display.COLOR_GREEN,
         listener = function()
            app:enterScene("MainScene",0)
        end})

	self.item1 = ui.newTTFLabelMenuItem({text = "计时模式", size = 30, align = ui.TEXT_ALIGN_CENTER, 
        x = display.cx, y = display.cy + 40, color = display.COLOR_GREEN,
         listener = function()
            app:enterScene("MainScene",1)
        end})

	self.item2 = ui.newTTFLabelMenuItem({text = "无尽模式", size = 30, align = ui.TEXT_ALIGN_CENTER, 
        x = display.cx, y = display.cy, color = display.COLOR_GREEN,
         listener = function()
            app:enterScene("MainScene",2)
        end})

	self.item3 = ui.newTTFLabelMenuItem({text = "排 行 榜", size = 30, align = ui.TEXT_ALIGN_CENTER, 
        x = display.cx, y = display.cy - 40, color = display.COLOR_GREEN,
         listener = function()
            app:enterScene("RankScene")
        end})

	self.item4 = ui.newTTFLabelMenuItem({text = "关  于", size = 30, align = ui.TEXT_ALIGN_CENTER, 
        x = display.cx, y = display.cy - 80, color = display.COLOR_GREEN,
         listener = function()
            app:enterScene("AboutScene")
        end})
	self.menu = ui.newMenu({self.item0,self.item1,self.item2,self.item3,self.item4}):addTo(self)
end

return StartScene