--
-- Author: Daniel
-- Date: 2015-01-21 17:16:43
--
BiwuController = {}
BiwuConst = {
	BIWU     = 1,
	ENEMY    = 2,
	TIAOZHAN = 3,
}
TabIndex = {
	BIWU     = 1,
	CHOUREN  = 2,
	TIANBANG = 4
}

BiwuController.sendFightData = function (type,roleid,tabIndex)
	if game.player:getNaili() < 2 then
		local layer = require("game.Arena.ArenaBuyMsgBox").new({updateListen = handler(self, BiwuController.updateNaiLiLbl)})
        display.getRunningScene():addChild(layer,1000000)
		return
	end
	RequestHelper.biwuSystem.getFightData({
				type = type,
				roleId = roleid,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        GameStateManager:ChangeState(GAME_STATE.STATE_BIWU_BATTLE,{ data = data , tabindex = tabIndex})
                    end
                end 
                })

end


BiwuController.updateNaiLiLbl = function ()
	
	PostNotice(NoticeKey.CommonUpdate_Label_Naili)
    PostNotice(NoticeKey.BIWu_update_naili)
    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
    PostNotice(NoticeKey.CommonUpdate_Label_Silver)
end


