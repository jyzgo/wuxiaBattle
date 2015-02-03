--[[
 --
 -- add by vicky
 -- 2015.01.08  
 --
 --]]

 require("data.data_error_error") 
 require("data.data_ui_ui") 

 local MAX_ZORDER = 100 
 local kParentScene 

 local GuildMemberJobLayer = class("GuildMemberJobLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 -- 退出帮派 
 local function exitUnion(msgBox) 
    RequestHelper.Guild.exitUnion({  
        uid = game.player:getGuildMgr():getGuildInfo().m_id, 
        errback = function(data)
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                msgBox:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    GameStateManager:ChangeState(GAME_STATE.STATE_GUILD) 
                else
                    msgBox:setBtnEnabled(true) 
                end 
            end 
        end 
        })    
 end


 -- 踢出帮派 
 local function kickRole(roleId, msgBox)
    RequestHelper.Guild.kcikRole({  
        appRoleId = roleId, 
        errback = function(data)
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                msgBox:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    if kParentScene ~= nil then 
                        local index = kParentScene:removeItemFromNormalList(roleId) 
                        kParentScene:forceReloadNormalListView(index - 1)  
                        msgBox:removeFromParentAndCleanup(true) 
                    end 
                else
                    msgBox:setBtnEnabled(true) 
                end 
            end 
        end, 
        })    
 end 


 -- 取消/任命职位 
 function GuildMemberJobLayer:setPosition(roleId, jopType)
    RequestHelper.Guild.setPosition({  
        appRoleId = roleId, 
        jopType = jopType,  
        errback = function(data)
            self:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                self:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    self._itemData.jopType = jopType 
                    if kParentScene ~= nil then 
                        kParentScene:forceReloadNormalListView(0) 
                        self:removeFromParentAndCleanup(true) 
                    end 
                else
                    self:setBtnEnabled(true) 
                end 
            end 
        end, 
        })    
 end 


 function GuildMemberJobLayer:ctor(param) 
    local title = param.title 
    self._itemData = param.itemData 
    kParentScene = param.parentScene 

    local guildMgr = game.player:getGuildMgr() 
    local jopType = guildMgr:getGuildInfo().m_jopType 

    local fileName 
    if self._itemData.isSelf == true then 
        fileName = "ccbi/guild/guild_job_self.ccbi"  
    else 
        if jopType == GUILD_JOB_TYPE.leader then 
            fileName = "ccbi/guild/guild_job_another_leader.ccbi"  
        elseif jopType == GUILD_JOB_TYPE.assistant and self._itemData.jopType == GUILD_JOB_TYPE.normal then 
            fileName = "ccbi/guild/guild_job_another_assistant.ccbi"  
        else
            fileName = "ccbi/guild/guild_job_another_normal.ccbi"  
        end 
    end 

    local proxy = CCBProxy:create()
    self._rootnode = {}
 	local node = CCBuilderReaderLoad(fileName, proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	self._rootnode["titleLabel"]:setString(title) 

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        closeFunc() 
    end, CCControlEventTouchUpInside)

    if self._itemData.isSelf == false and jopType == GUILD_JOB_TYPE.leader then 
        if self._itemData.jopType == GUILD_JOB_TYPE.assistant then 
            self._rootnode["set_assistant_btn"]:setVisible(false) 
            self._rootnode["cancel_assistant_btn"]:setVisible(true) 
        end 

        if self._itemData.jopType == GUILD_JOB_TYPE.elder then 
            self._rootnode["set_elder_btn"]:setVisible(false) 
            self._rootnode["cancel_elder_btn"]:setVisible(true) 
        end 
    end 

    -- 切磋、私聊、加好友、设为副帮主、取消副帮主、设为长老、取消长老、踢出帮派、退出帮派
    self._btnTags = {"battle_btn", "chat_btn", "addFriend_btn", "set_assistant_btn", "cancel_assistant_btn", 
                    "set_elder_btn", "cancel_elder_btn", "kick_btn", "exit_btn" }

    self:registerBtnEvent() 
 end 


 function GuildMemberJobLayer:setBtnEnabled(bEnabled)
    for i, v in ipairs(self._btnTags) do 
        if self._rootnode[v] ~= nil then 
            self._rootnode[v]:setEnabled(bEnabled) 
        end 
    end   
 end


 function GuildMemberJobLayer:registerBtnEvent() 
    local function onTouchBtn(tag)
        self:setBtnEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

        -- 切磋
        if tag == self._btnTags[1] then 
            show_tip_label("暂未开放")
            self:setBtnEnabled(true)

        -- 私聊
        elseif tag == self._btnTags[2] then 
            show_tip_label("暂未开放")
            self:setBtnEnabled(true)

        -- 加好友
        elseif tag == self._btnTags[3] then 
            show_tip_label("暂未开放")
            self:setBtnEnabled(true)

        -- 设为副帮主
        elseif tag == self._btnTags[4] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.assistant) 
        -- 取消副帮主
        elseif tag == self._btnTags[5] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal) 

        -- 设为长老
        elseif tag == self._btnTags[6] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.elder) 

        -- 取消长老
        elseif tag == self._btnTags[7] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal) 

        -- 踢出帮派
        elseif tag == self._btnTags[8] then 
            local content = "是否确定将" .. tostring(self._itemData.roleName) .. "踢出帮派?" 
            local roleId = self._itemData.roleId 
            game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    msg = content,  
                    isSingleBtn = false, 
                    confirmFunc = function(msgBox) 
                        kickRole(roleId, msgBox) 
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 

        -- 退出帮派 
        elseif tag == self._btnTags[9] then 
            -- 提示退出帮派后需要等待24小时的CD时间才可再次申请加入帮派
            game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    msg = data_ui_ui[7].content, 
                    isSingleBtn = false, 
                    confirmFunc = function(msgBox) 
                        exitUnion(msgBox) 
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 
        end 

    end 

    for i, v in ipairs(self._btnTags) do 
        if self._rootnode[v] ~= nil then 
            self._rootnode[v]:addHandleOfControlEvent(function(eventName, sender)
                onTouchBtn(v) 
            end, CCControlEventTouchUpInside) 
        end 
    end 

 end  


 return GuildMemberJobLayer 
