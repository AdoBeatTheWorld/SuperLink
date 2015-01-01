local SpriteItem = class("SpriteItem", function( )
	return display.newNode()
end)
local  startX,startY = 50,50
function SpriteItem:ctor()
	
end

function SpriteItem:setData(value)
	if self.type ~= value then
		self.type = value
		self:initIcon()
	end
end

function SpriteItem:initIcon()
	self.icon = display.newSprite(string.format("res/%d.png", self.type)):addTo(self)
end

function SpriteItem:recycle()
	-- body
end

function SpriteItem:reset()
	-- body
end

function SpriteItem:getValue()
	return self.type
end

function SpriteItem:setPos( px,py )
	self.px = px
	self.py = py
	self:setPosition(px*50+startX, py*50+startY)
end

function SpriteItem:getPos()
	return self.px, self.py
end

return SpriteItem