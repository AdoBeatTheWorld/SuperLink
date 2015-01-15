local ResultView = class("ResultView", function ( )
	return display.newNode()
end)

function ResultView:ctor()
	print("Ctor of ResultView")
end

function ResultView:updateDisplay(result,score)
	
end

return ResultView