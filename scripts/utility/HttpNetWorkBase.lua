 --
 --
 -- @authors shan 
 -- @date    2014-05-06 17:38:17
 -- @version 
 --


require ("game.MsgConst")
require ("zlib")

ENABLE_GAME_ZLIB = true

local HttpNetWorkBase = class("HttpNetWorkBase")


function HttpNetWorkBase:ctor()
	self.outStringData = nil
	self.cb = nil
	self.network = require("framework.network")
end


--[[--
	send to server
]]
local REQ_NUM = 1
function HttpNetWorkBase:Request()
    -- printf("======== request")

	local function responseCB( data )
	    local request = data["request"]
	    local ok = (data.name == "completed")

        if data.name == "failed" then
            if REQ_NUM > 0 then
                printf("-----  failed:%s", request:getErrorMessage())
                self:Request()
                REQ_NUM = REQ_NUM - 1
                return
            else
                if self.errorcb then
                    self.errorcb()
                end
            end
            -- device.showAlert("请重试ztq","网络错误!","OK")
            -- show_tip_label("网络错误，请重试!")
        end

	    if not ok then
	        -- print(request:getErrorCode(), request:getErrorMessage())
	        return
	    end

		local Rescode = request:getResponseStatusCode()
		if(Rescode ~= 200) then
			device.showAlert("警告","网络错误，请检查您的网络!",{"好的"}, function ()
			end)
            return
		end

		local j = require "framework.json"
		local zipRes = request:getResponseData()--request:getResponseDataLua()

		-- print("zip:" ..zipRes)
		local res,eof,bin,bout
		if(ENABLE_GAME_ZLIB == true) then
			-- uncompress data
		 	res,eof,bin,bout = zlib.inflate()(zipRes)
		 else
		 	res = zipRes
		 end

		-- json decode
		if(res ~= "") then
			if string.sub(res, 1, 2) == "B;" then
			 	local index = string.find( res, ";" , 3) 
			 	local ver_num   = string.sub(res,3,index-1)

				local lastIndex = index
			 	index = string.find(res,";",index+1)
			 	local file_name   = string.sub(res,lastIndex+1,index-1)

				lastIndex = index
			 	index = string.find(res,";",index+1)
			 	local file_type   = string.sub(res,lastIndex+1,index-1)
				lastIndex = index
			 	index = string.find(res,";",index+1)
			 	local file_size   = string.sub(res,lastIndex+1,index-1)
				lastIndex = index

				local file_data = string.sub(res,lastIndex+1,string.len(res))
		        if self.cb ~= nil then
		        	self.cb( { ver = ver_num , name = file_name, restype = file_type, size = file_size, data = file_data })
		        end
			else
				codeJson = j.decode(res)
				if(codeJson.errCode == 100011) then
					
					device.showAlert("提示", "您的账号已经在其他设备登陆，请重新登陆！","好的",function ( ... )						
						-- CSDKShell.Login()		
						game.player.m_logout = true
						display.replaceScene(require("app.scenes.VersionCheckScene").new())
						CSDKShell.onLogout()
					end)
				elseif(codeJson.errorCode == 100014) then
					device.showAlert("提示", "游戏版本错误，请下载新版本！","好的",function ( ... )						
						-- CSDKShell.Login()		
						game.player.m_logout = true
						display.replaceScene(require("app.scenes.VersionCheckScene").new())
                        CSDKShell.onLogout()
					end)
				elseif(codeJson.errorCode == 101) then
					device.showAlert("提示", "sdk异常，请重新登录！","好的",function ( ... )						
						-- CSDKShell.Login()		
						game.player.m_logout = true
						display.replaceScene(require("app.scenes.VersionCheckScene").new())
                        CSDKShell.onLogout()
					end)	
				else
			        if self.cb ~= nil then
			    		self.cb(codeJson)
			        end	
				end
			end
		else
			codeJson = ""
		end

	end -- end function


   	local serverURL = self.m_url or ServerInfo["SERVER_URL"]

   	if(GAME_DEBUG == true) then
		local localHost = CCUserDefault:sharedUserDefault():getStringForKey("ip")
		if(localHost ~= nil and localHost ~= "" ) then
			serverURL = "http://" .. localHost
		end
	end
   	--CCHTTPRequest
    local httpRequest = self.network.createHTTPRequest(
    	responseCB , 
    	serverURL, 
    	"POST"
    	)
    httpRequest:setPOSTData(self.outStringData)
    httpRequest:start()

end
--[[--
	@serverID: select server index 
	@requestID: 
	@tableData: the data must be table, it will be encode as json
	@callback: response listener
]]
function HttpNetWorkBase:SendData(playerID, serverID, requestID, tableData , callback, errorcb, url )

	-- 外部可以设置url
	if(url ~= nil) then
		self.m_url = url
	end

	-- 1.网络不好
	if(self.network.isInternetConnectionAvailable() == false) then
		device.showAlert("网络错误，请检查您的网络", "",{"确定"}, function ()
     		if not game.EnterGame then
                os.exit(0);
			end
     	end)
		return
	end

	local msg = {}
	
	-- msg.Head = MSG_HEAD
	-- if (device.platform == "windows") then
	-- 	msg.Head.DID = device.getOpenUDID()--WRUtility:GetDeviceID()
	-- else
	-- 	msg.Head.DID = device.getOpenUDID()
	-- end
		
	-- msg.Head.ReqID = requestID
	-- msg.Head.PID = playerID

	msg.Body = tableData

	msg.Body.v = getlocalversion()

	-- encode json
	local jsonOutPut = require("framework.json")

	if(msg ~= nil) then
		dump(msg)
		local outputStr = jsonOutPut.encode(msg)	    
		self.outStringData = outputStr
	    if( ENABLE_GAME_ZLIB == true) then	    
	    	local xxtea = crypto.encryptXXTEA(outputStr, "!@#asdfD_cdp[")	
	    	self.outStringData = crypto.encodeBase64(xxtea)
	    	-- dump(self.outStringData)
	    	-- local res1,eof1,bin1,bout1
	    	-- res1,eof1,bin1,bout1 = zlib.deflate()(outputStr, "full")
	    	-- self.outStringData = res1
	    	-- dump(outputStr)
	    	-- dump(string.len(self.outStringData))
	   --  	local res,eof,bin,bout
		 	-- res,eof,bin,bout = zlib.inflate()(res1)
		 	-- dump(res)
    	end
    	
	end
	-- set callback
	self.cb = callback
    self.errorcb = errorcb

	-- send Request
    REQ_NUM = 1
	self:Request()
end

function HttpNetWorkBase:disconnect()

end


return HttpNetWorkBase