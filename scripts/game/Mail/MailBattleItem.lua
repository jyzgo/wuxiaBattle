--[[
 --
 -- add by vicky
 -- 2014.12.02 
 --
 --]]

 require("utility.richtext.richText") 

 local BattleType = {
 	none = 0, 
 	arena = 1, 
 	duobao = 2,  
 	biwu = 3
 }


 local MailBattleItem = class("MailBattleItem", function()
 		return CCTableViewCell:new() 
 end)


 function MailBattleItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("mail/mail_battle_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
	end 
	
 	return self._contentSz 
 end 


 function MailBattleItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	local getMoreMailFunc = param.getMoreMailFunc 
 	self._mailTotalNum = param.totalNum 
 	self._curMailNum = param.curMailNum 
 	self._isCanShowMoreBtn = param.isCanShowMoreBtn 
 	self._id = param.id 

 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("mail/mail_battle_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 


 	self._biwuButton = display.newSprite("#mail_biwu_btn.png")
	 		self._biwuButton:setAnchorPoint(cc.p(0.5,0.5))
	 		self._biwuButton:setPosition(self._rootnode["duobaoBtn"]:getPosition())
	 		self._biwuButton:setTouchEnabled(true)
	 		self:addChild(self._biwuButton,1000)

 	self:refreshItem(itemData) 

	self._rootnode["duobaoBtn"]:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_DUOBAO)
        
    end, CCControlEventTouchUpInside)


    self._rootnode["arenaBtn"]:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_ARENA) 
    end, CCControlEventTouchUpInside)


    self._biwuButton:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
            if event.name == "began" then 
                self._biwuButton:setScale(1.1)
                return true
            elseif event.name == "ended" then 
                self._biwuButton:setScale(1.0)
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        		GameStateManager:ChangeState(GAME_STATE.STATE_BIWU)  
            end
        end)
 	return self 
 end 


 function MailBattleItem:refresh(param) 
 	self._id = param.id 
 	self:refreshItem(param.itemData) 
 end 


 function MailBattleItem:refreshItem(itemData) 
 	if self._isCanShowMoreBtn and self._id == self._curMailNum then 
 		self._rootnode["normal_node"]:setVisible(false) 
 		self._rootnode["getMore_tag"]:setVisible(true) 
 		if self._biwuButton then
 			self._biwuButton:setVisible(false)
 		end
 	else 
 		self._rootnode["normal_node"]:setVisible(true) 
 		self._rootnode["getMore_tag"]:setVisible(false) 
	 	self._rootnode["time_lbl"]:setString(tostring(itemData.disDay)) 
	 	self._rootnode["title_lbl"]:setString(tostring(itemData.title)) 

	 	local duobaoBtn = self._rootnode["duobaoBtn"] 
	 	local arenaBtn = self._rootnode["arenaBtn"] 
	 	if itemData.battleType == BattleType.arena then 
	 		duobaoBtn:setVisible(false) 
	 		arenaBtn:setVisible(true) 
	 	elseif itemData.battleType == BattleType.duobao then 
	 		duobaoBtn:setVisible(true) 
	 		arenaBtn:setVisible(false) 
	 	elseif itemData.battleType == BattleType.biwu then 
	 		duobaoBtn:setVisible(false) 
	 		arenaBtn:setVisible(false) 
	 		self._biwuButton:setVisible(true)
	 	end 

	 	local contentNode = self._rootnode["content_tag"] 
	 	contentNode:removeAllChildren() 

	 	local richHtmlText = itemData.richHtmlText 

	 	local infoNode = getRichText(richHtmlText, contentNode:getContentSize().width) 
	 	infoNode:setPosition(0, contentNode:getContentSize().height - 30) 
	 	contentNode:addChild(infoNode) 
	end 
 end 


 return MailBattleItem  

