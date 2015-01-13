
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local SpriteItem = import("app/views/SpriteItem")

local  startX,startY = 50,50
local row = 8

MainScene._GrayFilter = {"GRAY",{0.2, 0.3, 0.5, 0.1}}
MainScene._DIRECTIONS = {1,2,3,4}
MainScene.RIGHT = 1
MainScene.DOWN = 2
MainScene.LEFT = 3
MainScene.UP = 4

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
	self.itemPool = {}
	self.openlist = {}
	self.closelist = {}
	self.linedisplay = display.newDrawNode():addTo(self)
end

function MainScene:onEnter()
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
	--print("onTouche", tx, ty)
	local item = self:getItem(tx,ty)
	if item == nil then
		return
	end
	self.linedisplay:clear()
	--如果已经选中了一个item就进行连接判断
	if self.selectedItem then
		if self.selectedItem ~= item then
			if self.selectedItem:getValue() == item:getValue() then
				local sx,sy = self.selectedItem:getPos()
				local tx,ty = item:getPos()
				local canDirectLink = self:checkHasDirectLink(sx,sy,tx,ty)
				if canDirectLink then
					self:recycle(self.selectedItem)
					self:recycle(item)
					self.selectedItem = nil
					self.selectedIcon:setVisible(false)
					--self.linedisplay:drawSegment(CCPoint(sx*row,sy*row), CCPoint(tx*row,ty*row), 5, cc.c4f(255, 128, 0,128))
					cc.drawLine(CCPoint(sx*row,sy*row), CCPoint(tx*row,ty*row), 5, cc.c4f(255, 128, 0,128))
					return
				end
				local path = self:hasOneLink(sx,sy,tx,ty)
				if path ~= nil then
					self:recycle(self.selectedItem)
					self:recycle(item)
					self.selectedItem = nil
					self.selectedIcon:setVisible(false)
					return
				end

				path = self:hasTwoLink(sx, sy, tx, ty)
				if path ~= nil then
					self:recycle(self.selectedItem)
					self:recycle(item)
					self.selectedItem = nil
					self.selectedIcon:setVisible(false)
					return
				end
			else
				self.selectedItem = item
				self.selectedIcon:setVisible(true)
				self.selectedIcon:setPosition(item:getPositionX()-1, item:getPositionY()-1)
			end
			
			--[[
			self.openlist = {}
			self.closelist = {}
			self.openlist[string.format("%d_%d", sx,sy)] = true
			printf("get path %d %d ===> %d %d", sx,sy,tx,ty)
			for i=1,#MainScene._DIRECTIONS do
				local path = {{sx,sy}}
				printInfo("Main Loop dir:%d", MainScene._DIRECTIONS[i])
				path = self:getPath(path, sx, sy, tx, ty, MainScene._DIRECTIONS[i], 0)
				if path ~= nil then
					print("Path found")
					for i=1,#path do
						printInfo("Path Node x:%d y:%d",path[i][1],path[i][2])
					end
					self.selectedItem = nil
					item = nil
					return
				end
			end
			
			if path == nil then
				self.selectedItem = item
				self.selectedIcon:setPosition(item:getPosition())
			end
			]]
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
	if px > 7 or py > 7 or px < 0 or py < 0 then
		return nil
	end
	local index = row * py + px + 1
	local item = self.items[index]
	
	return item
end

function MainScene:getItemByPos( px,py )
	if px > 7 or py > 7 or px < 0 or py < 0 then
		return nil
	end
	local index = row * py + px + 1
	local item = self.items[index]
	
	return item
end

--path 当前已遍历数组 sx 当前item的x sy当前item的y tx目标x ty目标y cdir当前方向 ct当前转向次数
function MainScene:getPath(path, sx,sy,tx,ty,cdir,ct)
	
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
	--out of range
	if sx > row  or sx < -1 or sy > row or sy < -1 then
		return nil
	end
	local  key = string.format("%d_%d", sx,sy)
	if self.openlist[key] == true or self.closelist[key] == true then--has looped
		return nil
	end
	self.closelist[key] = true

	if sx == tx and sy == ty then--found
		printInfo("Finally Found")
		path[#path+1] = {sx,sy} 
		return path
	end

	next = self:getItemByPos(sx,sy)
	local results = {}
	if next == nil then
		for i=1,#MainScene._DIRECTIONS do
			local tempdir = MainScene._DIRECTIONS[i]
			printInfo("Sub loop current pos %d %d ,currrent dir:%d", sx,sy,tempdir)
			if tempdir == cdir then
				printInfo("Current Pos:%d %d Keep Loop",sx,sy)
				path[#path+1] = {sx,sy} 
				temppath = self:getPath(path, sx, sy, tx, ty, tempdir, ct)
			else
				if ct <= 2 then
					printInfo("Keep Loop and change dir:%d path length:%d",tempdir,#path)
					path[#path+1] = {sx,sy} 
					temppath = self:getPath(path, sx, sy, tx, ty, tempdir, ct+1)
				end
			end
			if temppath ~= nil then
				results[#results] = temppath
			end
		end
		if #results ~= 0 then
			return getTheShortest(results)
		else
			return nil
		end
	elseif next ~= nil then-- need change dir
		return nil
	end
	return nil
end

function MainScene:checkHasDirectLink( sx,sy,tx,ty)
	--items on same line can link this way
	print("Check Direct Link: ",sx,sy,tx,ty)
	if sx == tx then
		for i=sy,ty, sy > ty and -1 or 1 do
			if i ~= sy and i ~= ty then
				--print("Direct Link Check:",sx,i)
				local next = self:getItemByPos(sx,i)
				if next ~= nil and next:getPosY() ~= ty  then
					return false
				end
			end
		end
	elseif sy == ty then
		for j=sx,tx,sx < tx and 1 or -1 do
			--print("Direct Link Check:",j,sy)
			if j ~= sx and j ~= tx then
				next = self:getItemByPos(j,sy)
				if next ~= nil and next:getPosX() ~= tx then
					return false
				end
			end
		end
	else
		return false
	end
	return true
end

function MainScene:hasOneLink( sx,sy,tx,ty )
	--items on the same line cannot link this way
	print("Check One Link")
	if sx == tx or sy == ty then
		return nil
	end

	local next
	local firstfail = false
	for i=sx,tx,sx < tx and 1 or -1 do --{sx,ty} to {tx,ty}
		--print("One Link Check0:",i,ty)
		if i ~= tx then
			next = self:getItemByPos(i,ty)
			if next ~= nil then
				firstfail = true
				break
			end
		end
	end
	if firstfail ~= true then 
		for j=ty,sy,ty < sy and 1 or -1 do --{sx,ty} to {sx,sy}
			--print("One Link Check",sx,j)
			if j ~= sy then
				next = self:getItemByPos(sx,j)
				if next ~= nil then
					firstfail = true
					break
				end
			end
		end
	end
	

	if firstfail == false then
		print("Has one link 1:",sx,sy,sx,ty,tx,ty)
		return {sx,sy,sx,ty,tx,ty}
	end
	

	for l=sy,ty,sy < ty and 1 or -1 do--{tx,sy} to {tx,ty}
		if l ~= ty then
			print("One Link Check",tx,l)
			next = self:getItemByPos(tx,l)
			if next ~= nil then
				return nil
			end
		end
	end

	for m=tx,sx,sx < tx and -1 or 1 do--{tx,sy} to {sx,sy}
		if m ~= sx then
			print("One Link Check",m,sy)
			next = self:getItemByPos(m,sy)
			if next ~= nil then
				return nil
			end
		end
	end
	print("Has one link 2:",sx,sy,tx,sy,tx,ty)
	return {sx,sy,tx,sy,tx,ty}
end

function MainScene:hasTwoLink( sx,sy,tx,ty )
	print("Check Two Link")
	local linkToSource = self:getDirectPoints(sx, sy)
	local linkToTarget = self:getDirectPoints(tx, ty)
	local len0 = #linkToSource
	local len1 = #linkToTarget
	for i=1,len0 do
		local  item0 = linkToSource[i]
		for j=1,len1 do
			local item1 = linkToTarget[j]
			local result = self:checkHasDirectLink(item0[1],item0[2],item1[1],item1[2])
			if result then
				print("2 Link Found:",sx,sy,item0[1],item0[2],item1[1],item1[2],tx,ty)
				return {sx,sy,item0[1],item0[2],item1[1],item1[2],tx,ty}
			end
		end
	end
	return nil
end

function MainScene:getDirectPoints( sx,sy )
	local result = {}
	local canXUP = true
	local canYUp = true
	local canXDown = true
	local canYDown = true
	local xdownlimit = sx + 1
	local ydownlimit = sy + 1
	local xuplimit = row - sx
	local yuplimit = row - sy
	local uplimit = xuplimit > yuplimit and xuplimit or yuplimit
	local downlimit = xdownlimit < ydownlimit and xdownlimit or ydownlimit
	local next
	local idx = 0
	print("Check Link Points:",sx,sy,downlimit,uplimit)
	for i=1,downlimit > uplimit and downlimit or uplimit do
		if canXUP and sx + i <= row then
			print("Check X Up:",sx+i,sy)
			next = self:getItemByPos(sx+i,sy)
			if next == nil then
				idx = idx + 1
				result[idx] = {sx+i,sy}
				print("Put:",sx+i,sy)
			else
				canXUP = false
			end
		else
			--print("Fuck....")
			canXUP = false
		end

		if canYUp and sy+i <= row then
			print("Check Y Up:",sx,sy+i)
			next = self:getItemByPos(sx,sy+i)
			if next == nil then
				idx = idx + 1
				result[idx] = {sx,sy+i}
				print("Put:",sx,sy+i)
			else
				canYUp = false
			end
		else
			canYUp = false
		end

		if canXDown and sx-i >= -1 then
			print("Check X Down:",sx-i,sy)
			next = self:getItemByPos(sx-i,sy)
			if next == nil then
				idx = idx + 1
				result[idx] = {sx-i,sy}
				print("Put:",sx-i,sy)
			else
				canXDown = false
			end
		else
			canXDown = false
		end

		if canYDown and sy-i >= -1 then
			print("Check Y Down:",sx,sy-i)
			next = self:getItemByPos(sx,sy-i)
			if next == nil then
				idx = idx + 1
				result[idx] = {sx,sy-i}
				print("Put:",sx,sy-i)
			else
				canYDown = false
			end
		else
			canYDown = false
		end
	end
	--sort 
	table.sort(result,function( a,b )
		if a[1] < b[1] then
			return true
		elseif a[1] > b[1] then
			return false
		else
			return a[2] < b[2]
		end
	end)

	--self:quickSort(result,1,#result)
	return result
end

function MainScene:quickSort( list, low, high )
	if low < high then
		local referIndex = self:partition(list, low, high)
		self:quickSort(list,low,referIndex - 1)
		self:quickSort(list, referIndex+1,high)
	end
end

function MainScene:partition( list, low, high )
	local low = low
	local high = high
	local referValue = list[low][1]
	while low < high do
		while low < high and list[high][1] >= referValue do
			high = high - 1
		end
		swap(list,low,high)

		while low < high and list[low][1] <= referValue do
			low = low + 1
		end
		self:swap(list,low,high)
	end
	return low
end

function MainScene:swap( list,i,j )
	list[i],list[j] = list[j],list[i]
end

function MainScene:getTheShortest(value)
	local result
	for i=1,#value do
		if result == nil then
			result = value[i]
		else
			result = #result > #value[i] and value[i] or result
		end
	end
	return result
end

function MainScene:shuffle(t)
	local  len = #t
	for i=1,len*5 do
		local a = math.floor(math.random(len))
		local b = math.floor(math.random(len))
		
		if a ~= b then
			t[a],t[b] = t[b],t[a]
			t[a]:setPos(math.floor((a-1)%row),math.floor((a-1)/row))
			t[b]:setPos(math.floor((b-1)%row),math.floor((b-1)/row))
			--printInfo("swap item %d : %d", a,b)
		end
	end
end

function MainScene:recycle( item )
	if #self.itemPool == 0 then
		self.itemPool[1] = item
	else
		self.itemPool[#self.itemPool]=item
	end
	local rx,ry = item:getPos()
	local itemindex = rx+ry*row+1
	item:removeSelf()
	self.items[itemindex] = nil
end

function MainScene:onExit()
end

return MainScene
