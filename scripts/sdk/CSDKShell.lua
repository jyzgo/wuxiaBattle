--[[

 @Author shan 
 @Date:

]]
require("gamecommon")
require("constant.channelid")
require("data.data_serverurl_serverurl")
GAME_3RD_PLATFORM = true


--[[============================]]

local CSDKShell = {}

hasInited = false


CSDKShell.SDKTYPES = {
	IOS_91          = "IOS_91",		-- 91助手
	IOS_91_OFFICIAL = "IOS_91_OFFICIAL", -- 91 正版
	IOS_PP          = "IOS_PP",		-- pp助手
	IOS_TB          = "IOS_TB",		-- 同步推
	IOS_ITOOLS      = "IOS_ITOOLS",	-- ITOOLS
	IOS_KUAIYONG    = "IOS_KUAIYONG",  -- 快用
	IOS_APPSTORE    = "IOS_APPSTORE",	-- AppStore
	IOS_XY          = "IOS_XY", 		-- XY
	IOS_AS          = "IOS_AS", 		-- 爱思助手 
	IOS_IA 			= "IOS_IA", 		-- i苹果 
	IOS_OTHER       = "IOS_OTHER"

}


-- CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_91
-- CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_PP
local channelid = CHANNELID.TEST
if gamecommon.getchannel then
    printf("channel id = %d", gamecommon.getchannel())
end

function CSDKShell.getChannelID()
    return checkint(channelid)
end

--[[
	版本标识
		发送给服务器，作为除了channelid之外的第2更新标识
	ios:
		100: 上线版本
		101: 开发版本
		102: 渠道评测包
		103: 保留
]]
function CSDKShell.getBuildFlag(  )
	local buildFlags = {100, 101, 102}
	local buildFlag = buildFlags[1]
	if(CHANNEL_BUILD == false) then
		--开发版本
		if(DEV_BUILD == true)then
			buildFlag = buildFlags[2]
		end
	elseif(CHANNEL_BUILD == true) then
		--渠道评测包
		buildFlag = buildFlags[3]
	end
	return buildFlag
end

-- 所有sdk 可以根据 sdk type 定义
local m_sdkInstance = nil


--[[
	初始化 ，只暴露一个初始化 接口给游戏使用
		1.需要判断第3方 sdk 开关
		2.根据 boundleId 判断sdk的平台 可以保证所有平台lua代码的一致性，不再修改lua代码即可打包各个平台 

]]
function CSDKShell.init( ... )
	if(device.platform == "ios") then

	    if(GAME_3RD_PLATFORM == true) then

	    	local boundleID = CSDKShell.GetBoundleID( )
	    	dump(boundleID)
	    	
	    	if(boundleID == "com.fy.rxqz.baidu") then
	    		CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_91 			-- ios91
                channelid = CHANNELID.IOS_91
            elseif(boundleID == "com.fy.rxqzbaidu.exp") then
            	CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_91_OFFICIAL
            	channelid = CHANNELID.IOS_91_OFFICIAL
		    elseif(boundleID == "com.fy.wxqzpp") then
		        CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_PP  		-- iospp
                channelid = CHANNELID.IOS_PP
		    elseif(boundleID == "com.tongbu.fy.rxqz") then
		    	CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_TB  		-- ios tongbu
                channelid = CHANNELID.IOS_TB
		    elseif(boundleID == "com.fy.rxqz2.sky") then
		    	CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_ITOOLS  	-- ios tongbu
                channelid = CHANNELID.IOS_ITOOLS
	    	elseif(boundleID == "com.fy.rxqzkuaiyong") then
	    		CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_KUAIYONG  	-- ios kuaiyong
                channelid = CHANNELID.IOS_KUAIYONG
	    	elseif(boundleID == "com.fy.rxqz.xy") then 
	    		CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_XY  		-- ios xy
                channelid = CHANNELID.IOS_XY
            elseif(boundleID == "com.fy.rxqz.i4") then 				-- ios as 
            	CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_AS 
            	channelid = CHANNELID.IOS_AS 
            elseif(boundleID == "com.cvbx.wuxiadazongshi") then 				-- ios iiapple 
            	CSDKShell.SDK_TYPE = CSDKShell.SDKTYPES.IOS_IA  
            	channelid = CHANNELID.IOS_IA 
            	dump(channelid)
            	dump(CHANNELID.IOS_IA)  

    		elseif(boundleID == "com.douzi.dawuxia") then
    			device.platform = "windows"
		    end
		    dump(CSDKShell.SDK_TYPE)

		    CSDKShell.SetSDKTYPE(CSDKShell.SDK_TYPE)

		    dump(channelid)
	        CSDKShell.initPlatform(checkint(channelid))
        end
    end

	
end

--[[
	uid无法从客户端获取需要从服务器获取
	pp,kuaiyong   

]]
function CSDKShell.getSDKIdFromServer( ... )
	local isFromServer = false
	if(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_PP) then
		isFromServer = true
	end
	return isFromServer
end


--[[------------------------------------------------------]]


--[[
    NSString* appKey = @"cfd705e2321e5fc125e44aedf31bd0b8ce109d5435e30e64";
    
    [[SDKNdCom sharedInstance] init:100892 appKey:appKey delegate:self isDebug:true];
]]

function CSDKShell.initPlatform( channelid )
	if(device.platform == "ios") then

		local appId = data_serverurl_serverurl[channelid].appid												-- 115885
		local appKey = data_serverurl_serverurl[channelid].appkey 	-- "716d60a6b59c69bce9cec872f6c0644b8da16a5893e56af0"
		local cuKey = data_serverurl_serverurl[channelid].cukey 

		dump(CSDKShell.SDK_TYPE)
		-- 91 sdk
		if(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL) then

			m_sdkInstance = require("sdk.SDKNdCom") 
			-- local appId = 115669												-- 115885
			-- local appKey = "f13b267a8193e2b7c26d26cfa12f1408eb77baaa212f58b3" 	-- "716d60a6b59c69bce9cec872f6c0644b8da16a5893e56af0"
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end
			m_sdkInstance.init()

		-- pp助手
		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_PP) then
			m_sdkInstance = require("sdk.SDKPpCom")

			-- local appId = 4413
			-- local appKey = "894cf4eeee3ee0ccabf95b71cd11765c";
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end
			m_sdkInstance.init()

		-- 同步推	
		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_TB) then
			m_sdkInstance = require("sdk.SDKTbCom")
			-- local appId = 141000
			-- local appKey = "lSIfsC5Pbzo2LiYk9SfUrCOEby#2LYvk"
			local isDebug = false  
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end 
			m_sdkInstance.init()

		-- itools	
		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_ITOOLS) then
			m_sdkInstance = require("sdk.SDKIToolsCom")
			-- local appId = 1
			-- local appKey = "58C6A68DDDEE471AA43266E427F38D92"
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end	
			m_sdkInstance.init()
			
		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG) then
			m_sdkInstance = require("sdk.SDKKYCom")	
			-- local appId = 1
			-- local appKey = "1"
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end	
			m_sdkInstance.init()

		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_XY) then
			m_sdkInstance = require("sdk.SDKXYCom")	
			-- local appId = "100003924" 
			-- local appKey = "J3D6StT8mr2598vvwMYeXn7CpFEK8dYT"
			local isDebug = false      
			if(hasInited == false) then
				m_sdkInstance.initPlatform( tostring(appId), appKey, isDebug)
				hasInited = true
			end	

			m_sdkInstance.init()
		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_AS) then
			m_sdkInstance = require("sdk.SDKAsCom") 
			-- local appId = 514
			-- local appKey = "43004ed2f2ae41469d4c8c28609a2345";
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug)
				hasInited = true
			end
			
			m_sdkInstance.init() 

		elseif(CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_IA) then
			m_sdkInstance = require("sdk.SDKIACom") 
			local isDebug = false
			if(hasInited == false) then
				m_sdkInstance.initPlatform( appId, appKey, isDebug, cuKey)
				hasInited = true
			end
			
			m_sdkInstance.init() 
		end
	end

end


-- 根据channelId获取充值url 
function CSDKShell:getIapUrlByChannelId()
	local cid = CSDKShell.getChannelID()

    local _loginUrl = data_serverurl_serverurl[cid].loginUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[cid].loginUrldev
    end
	return _loginUrl  
end


function CSDKShell:getIapNotifyUrlByChannelId()
	local cid = CSDKShell.getChannelID()
    local _loginUrl = data_serverurl_serverurl[cid].payUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[cid].payUrldev
    end
    return _loginUrl
end

function CSDKShell.submitExtData()

end


--[[
	登陆
]]
function CSDKShell.Login( ... )
    if (device.platform == "ios") then
	    	m_sdkInstance.login()    
    end
end


--[[
	是否登陆
]]
function CSDKShell.isLogined( ... )
	local ret = false

    if (device.platform == "ios") then
	    ret = m_sdkInstance.isLogined()    
	elseif( device.platform == "windows") then
		return true; 
	elseif( device.platform == "mac") then
		return true
    elseif( device.platform == "android" ) then
        return true
    end
    return ret
end


--[[
	guest登陆
]]
function CSDKShell.logout( ... )
    if (device.platform == "ios") then
	    ret = m_sdkInstance.logout()    
    end
end

function CSDKShell.onLogout()

end


--[[
	guest登陆
]]
function CSDKShell.loginEx( ... )
    if (device.platform == "ios") then
    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then
	        m_sdkInstance.loginEx()
	    end
    end
end



--[[
	登陆18183
]]
function CSDKShell.enterAppBBS( ... )
    if (device.platform == "ios") then
    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then
	        m_sdkInstance.enterAppBBS()
	    end
    end
end


--[[
	登陆平台
	
]]
function CSDKShell.enterPlatform( ... )
    if (device.platform == "ios") then
    	-- if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 then
	        m_sdkInstance.enterPlatform()
	    -- end
    end
end



--[[
	用户反馈
	
]]
function CSDKShell.userFeedback( ... )
    if (device.platform == "ios") then
    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then
    		if(CSDKShell.isLogined()) then
		        m_sdkInstance.userFeedback()
		    else
		    	CSDKShell.Login()
		    end
	    end
    end
end



--[[
	购买
]]
function CSDKShell.payForCoins( coins )
    if (device.platform == "ios") then
    	if (CSDKShell.isLogined() )then
	    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then
		        local ret = m_sdkInstance.payForCoins(coins)
		        dump(ret)
		        return ret;
		    end
		else
			CSDKShell.Login()
		end
    end
    return nil;
end


--[[
	同步购买
]]
function CSDKShell.BuyCoins( coins, price )
    if (device.platform == "ios") then
    	if (CSDKShell.isLogined() )then
	    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then
		        local ret = m_sdkInstance.Buy91Coins(coins, price)
		        dump(ret)
		        return ret;
		    end
		else
			CSDKShell.Login()
		end
    end
    return nil;
end


--[[
	异步购买
]]
function CSDKShell.BuyAsynCoins(param)
	dump(param)
	local index = param.index 	-- 编号
	local coins = param.coins 
	local price = param.price 

    if (device.platform == "ios") then 
    	if (CSDKShell.isLogined() )then 
    		
	    	if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91_OFFICIAL then 
		        local ret = m_sdkInstance.BuyAsyn91Coins(param) 
		        dump(ret)
		        return ret 

		    elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_PP then 
		    	local ret = m_sdkInstance.payForPPCoins(param)
		    	dump(ret) 
		    	return ret 

		    elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_ITOOLS then 
		    	local ret = m_sdkInstance.payIToolsCoins(param)
		    	dump(ret)
		    	return ret 

		    elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_TB then 
		    	local ret = m_sdkInstance.payForTbCoins(param)
		    	dump(ret)
		    	return ret 

		   	elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG then 
		   		local ret = m_sdkInstance.payForKYCoins(param)
		   		dump(ret)
		   		return ret 

		   	elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_XY then 
		   		local ret = m_sdkInstance.payForXYCoins(param)
		   		dump(ret)
		   		return ret 
		   	elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_AS then 
		   		local ret = m_sdkInstance.payForASCoins(param)
		   		dump(ret)
		   		return ret 
	   		elseif CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_IA then 
		   		local ret = m_sdkInstance.payForIACoins(param)
		   		dump(ret)
		   		return ret 
		    end
		else
			CSDKShell.Login()
		end
    end
    return nil 
end


--[[
	用户信息
]]
function CSDKShell.userInfo()
    if (device.platform == "ios") then
    	if (CSDKShell.isLogined() )then
    		local info = m_sdkInstance.getUserinfo()
    		info.platformID = CSDKShell.getChannelID()
    		return info
    	end
    elseif(device.platform == "mac" or device.platform == "windows") then
    	local info = {}
    	info.platformID = CSDKShell.getChannelID()    	
    	return info
    elseif(device.platform == "android") then
        local info = {}
        info.platformID = CSDKShell.getChannelID()
        return info
	end  
    return nil;
end

function CSDKShell.showToolbar()
    if (device.platform == "ios") then
		m_sdkInstance.showToolbar()
	end  

end

function CSDKShell.pause()

end

function CSDKShell.back()

end

function CSDKShell.HideToolbar()
    if (device.platform == "ios") then
		m_sdkInstance.HideToolbar()	
	end
end

function CSDKShell.addEventCallBack( name ,callback )
	-- body
    if (device.platform == "ios") then
    	m_sdkInstance.addCallback(name, callback)
	end  
	
end

function CSDKShell.delEventCallBack( name )
	-- body
    if (device.platform == "ios") then
    	m_sdkInstance.removeCallback(name)
	end  

end

--[[
	设置sdkshell的类型，通过类型，选择不同sdk
]]
function CSDKShell.SetSDKTYPE( type )
	CSDKShell.SDK_TYPE = type

end


function CSDKShell.GetSDKTYPE( ... )
	return CSDKShell.SDK_TYPE
end

--[[

	获取设备信息
]]
function CSDKShell.GetDeviceInfo( ... )
	if (device.platform == "ios") then
		local GameDevice = require("sdk.GameDevice")
		return GameDevice.GetDeviceInfo()
	end
end

function CSDKShell.GetBoundleID( )
	if(device.platform == "ios") then
		local GameDevice = require("sdk.GameDevice")
		local boundleID = GameDevice.GetBoundleID()		
		return boundleID
	end
end


return CSDKShell