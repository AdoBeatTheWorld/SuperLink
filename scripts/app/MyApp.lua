
require("config")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.data_ = {}
end

function MyApp:run()
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    self:enterScene("StartScene")
end

function MyApp:getData( key )
	return self.data_[key]
end

function MyApp:setData( key,value )
	self.data_[key] = value
end

return MyApp
