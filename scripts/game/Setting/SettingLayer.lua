--[[
 --
 -- add by vicky
 -- 2014.10.15
 --
 --]]  

 -- local MAX_ZODER = 1100 

 local SettingLayer = class("SettingLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)

 
 function SettingLayer:ctor()
 	local rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("mainmenu/setting_layer.ccbi", proxy, rootnode)
	node:setPosition(display.width/2, display.height/2) 
	self:addChild(node) 

	rootnode["titleLabel"]:setString("设 置") 
    rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true) 
        end,CCControlEventTouchUpInside)

    -- CDKey兑换
    local cdkeyBtn = rootnode["cdkeyBtn"]
    cdkeyBtn:addHandleOfControlEvent(function(eventName,sender)
        cdkeyBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local cdkeyRewardLayer = require("game.Huodong.CDKeyReward.CDKeyRewardLayer").new({
            endFunc = function() 
                cdkeyBtn:setEnabled(true) 
            end
            })
		game.runningScene:addChild(cdkeyRewardLayer, self:getZOrder() + 1)
    end,CCControlEventTouchUpInside)

    -- 判断背景音乐 
    local enable = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_MUSIC) 
    if enable then 
    	rootnode["music_bg_close_btn"]:setVisible(false)
    	rootnode["music_bg_open_btn"]:setVisible(true) 
    else
    	rootnode["music_bg_close_btn"]:setVisible(true)
    	rootnode["music_bg_open_btn"]:setVisible(false) 
    end 

    rootnode["music_bg_open_btn"]:addHandleOfControlEvent(function(eventName,sender) 

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    		GameAudio.setSoundEnable(false) 
    		GameAudio.stopMusic() 
    		rootnode["music_bg_close_btn"]:setVisible(true) 
    		rootnode["music_bg_open_btn"]:setVisible(false) 
	    end,CCControlEventTouchUpInside)

    rootnode["music_bg_close_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	    	GameAudio.setSoundEnable(true) 
                    GameAudio.playMainmenuMusic(true) 
    		PostNotice(NoticeKey.MainMenuScene_Music) 
    		rootnode["music_bg_open_btn"]:setVisible(true) 
    		rootnode["music_bg_close_btn"]:setVisible(false) 
	    end,CCControlEventTouchUpInside) 


    -- 判断游戏音效 
    local sfxEnable = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_SFX) 
    if sfxEnable then 
    	rootnode["music_sfx_close_btn"]:setVisible(false)
    	rootnode["music_sfx_open_btn"]:setVisible(true) 
    else 
    	rootnode["music_sfx_close_btn"]:setVisible(true)
    	rootnode["music_sfx_open_btn"]:setVisible(false) 
    end 

    rootnode["music_sfx_open_btn"]:addHandleOfControlEvent(function(eventName,sender) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    		GameAudio.setSfxEnable(false) 
    		rootnode["music_sfx_close_btn"]:setVisible(true) 
    		rootnode["music_sfx_open_btn"]:setVisible(false) 
	    end,CCControlEventTouchUpInside)

    rootnode["music_sfx_close_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	    	GameAudio.setSfxEnable(true) 
            GameAudio.playMainmenuMusic(true) 
    		rootnode["music_sfx_open_btn"]:setVisible(true) 
    		rootnode["music_sfx_close_btn"]:setVisible(false) 
	    end,CCControlEventTouchUpInside) 


    rootnode["handbook_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_HANDBOOK)

        end,CCControlEventTouchUpInside) 



     local function sdkCenter( ... )
        local btnText = "用户中心"
        if( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_91 or CSDKShell.GetSDKTYPE() == CSDKShell.SDKTYPES.IOS_91_OFFICIAL ) then
            btnText = "91中心"
                    
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_PP) then
            btnText = "PP中心"
            
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_TB) then
            btnText = "同步推"
            
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_ITOOLS) then
            btnText = "itools"
            
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG) then
            btnText = "快用"
            
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_XY) then
            btnText = "XY"
        
        elseif( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_AS) then
            btnText = "爱思"
        end

                -- TOdo
        if(device.platform == "android") then
             btnText = "返回"
        end
        rootnode["returnLoginBtn"]:setTitleForState(CCString:create(btnText), CCControlStateNormal)


    end
    -- sdk 用户中心
    sdkCenter()
    rootnode["returnLoginBtn"]:addHandleOfControlEvent(function(eventName,sender)   
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))  
                if(device.platform == "android") then
                    self:removeFromParentAndCleanup(true) 
                else 
                    CSDKShell.enterPlatform()         
                end
            end,CCControlEventTouchUpInside)
    -- 返回登录 （只加了PP的）
  --   rootnode["returnLoginBtn"]:addHandleOfControlEvent(function(eventName,sender)
		-- if( CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_PP) then 
			
		-- 	CSDKShell.showToolbar()
	 --    end 
  --   end,CCControlEventTouchUpInside)

 end 


 return SettingLayer 

