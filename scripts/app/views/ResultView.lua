local ResultView = class("ResultView", function ( )
	return display.newNode()
end)

function ResultView:ctor()
	--print("Ctor of ResultView")
	self.closeBtn = cc.ui.UIPushButton.new("res/CandyRain/button_close.png")
	self.closeBtn:onButtonPressed(handler(self, self.onClose))
	self.closeBtn:setPosition(display.cx-60, display.cy)
	self.closeBtn:addTo(self)

	self.restartBtn = cc.ui.UIPushButton.new("res/CandyRain/button_restart.png")
	self.restartBtn:onButtonPressed(handler(self, self.onRestart))
	self.restartBtn:setPosition(display.cx+60, display.cy)
	self.restartBtn:addTo(self)

end

function ResultView:onClose( event )
	app:exit()
end

function ResultView:onRestart( event )
	app:setData("currentLv", 0)
    app:enterScene("MainScene",0)
end

function ResultView:updateDisplay(result,score)
	print("ResultView:updateDisplay",result,score)
end

return ResultView