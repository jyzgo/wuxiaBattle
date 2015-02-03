--[[
 --
 -- add by vicky
 -- 2014.11.25 
 --
 --]]

 require("data.data_item_item") 


 local WorldBossExtraRewardLayer = class("WorldBossExtraRewardLayer", function()
 		return require("utility.ShadeLayer").new()
 end) 


 function WorldBossExtraRewardLayer:ctor(rewardListData, confirmFunc)  
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 

 	local node = CCBuilderReaderLoad("huodong/worldBoss_extraReward_layer.ccbi", proxy, self._rootnode)
 	local layer = tolua.cast(node, "CCLayer")
 	layer:setPosition(display.width/2, display.height/2)
 	self:addChild(layer) 

 	-- 关闭
 	self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
	 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))  
            if confirmFunc ~= nil then 
                confirmFunc() 
            end 
	 		self:removeFromParentAndCleanup(true) 
	 	end, CCControlEventTouchUpInside) 

 	self:getWardData(rewardListData) 
 	self:createRewardList() 

 end 


 function WorldBossExtraRewardLayer:getWardData(rewardListData) 
 	self._rewardDatas = {} 
 	for j, bossData in ipairs(rewardListData) do 
        local itemData = {}
        for i = 1, bossData.reward_num do 
        	local itemType = bossData.type[i] 
        	local id = bossData.itemid[i] 
        	local iconType = ResMgr.getResType(itemType) 
        	local item 
        	if iconType == ResMgr.HERO then 
        		item = ResMgr.getCardData(id) 
        	else 
        		item = data_item_item[id] 
        	end 

        	ResMgr.showAlert(item, "rewardListData 没有此物品，id: " .. tostring(id))

            local num = bossData.num[i] or 0 
            if itemType == 7 and id == 2 then 
                num = num * game.player:getLevel() 
            end 

        	table.insert(itemData, {
        		id = id, 
        		type = itemType, 
        		name = item.name, 
        		describe = item.describe or "", 
        		iconType = iconType, 
        		num = num 
        		})
        end 

        table.insert(self._rewardDatas, {
        	title = bossData.title or "", 
        	rewardId = bossData.id,  
        	itemData = itemData 
        	}) 
    end  

 end 


 function WorldBossExtraRewardLayer:createRewardList() 
 	local listViewDisH = self._rootnode["titleBoard"]:getContentSize().height + self._rootnode["listView"]:getPositionY() + 20   
 	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height - listViewDisH 
	local listViewSize = CCSizeMake(boardWidth, boardHeight) 

	local listBg = display.newScale9Sprite("#sh_rank_bg.png", 0, 0, CCSizeMake(boardWidth * 0.9, boardHeight + 20)) 
    listBg:setAnchorPoint(0.5, 0) 
    listBg:setPosition(boardWidth/2, -10) 
    self._rootnode["listView"]:addChild(listBg) 
	
	-- 创建
    local function createFunc(index)
    	local item = require("game.Worldboss.WorldBossExtraRewardItem").new()
    	return item:create({
    		viewSize = listViewSize, 
            cellData = self._rewardDatas[index + 1] 
    		})
    end 

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh(self._rewardDatas[index + 1]) 
    end 

    local cellContentSize = require("game.Worldboss.WorldBossExtraRewardItem").new():getContentSize()

    self.ListTable = require("utility.TableViewExt").new({
    	size        = listViewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #self._rewardDatas, 
        cellSize    = cellContentSize 
    })

    self.ListTable:setPosition(0, 0) 
    self._rootnode["listView"]:addChild(self.ListTable)  

 end 


 return WorldBossExtraRewardLayer 
