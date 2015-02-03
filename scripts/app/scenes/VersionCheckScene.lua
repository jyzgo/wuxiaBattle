--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-12
-- Time: 上午11:33
-- To change this template use File | Settings | File Templates.
--

require("network.NetworkHelper")
require("utility.Func")
require("data.data_serverurl_serverurl")
require("constant.ZipLoader")
require("data.data_sdkinfo")
local VersionCheckScene = class("VersionCheckScene", function()
    return display.newScene("VersionCheckScene")
end)

function VersionCheckScene:ctor()
    self:showUI()
    addbackevent(self)
end

--根据是否有更新切换不同的场景
local function checkforupdate(data)
    if data and data.vn_dis and #data.vn_dis > 0 then
        DISPLAY_VERSION = data.vn_dis
    end

    if data and data.st == 1 and #data.url > 0 then
        local layer = require("app.scenes.DownloadTipLayer").new({
            size = data.pkgsize,
            listener = function()
                local url = data.url
                local scene = require("update.UpdatingScene").new(data.vn, url)
                display.replaceScene(scene)
            end
        })
        display.getRunningScene():addChild(layer, 10)
    else  --没有可以更新的自己，直接进入游戏
        if data.st == 6 then
            show_tip_label("有最新版本，请前往下载")
        end
        ziploader("game/game.zip")
        ziploader("game/data.zip")


        display.replaceScene(require("game.login.LoginScene").new())
    end
end

function VersionCheckScene:showUI()
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
    local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")

    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        bgSprite:setPosition(display.cx, display.height*0.55)
        bgSprite:setScale(0.9)
    elseif(display.widthInPixels == 640 and display.heightInPixels == 960) then
        bgSprite:setPosition(display.cx, display.height*0.55)
    else
        bgSprite:setPosition(display.cx, display.cy)
    end
    self:addChild(bgSprite)

    if CSDKShell.GetSDKTYPE() == SDKType.ANDROID_TENCENT then
        self:showQQUI()
    else
        self:showOtherUI()
    end
end


function VersionCheckScene:showQQUI()
    local QQLOGIN = 1
    local WXLOGIN = 2

    local btnSprite = display.newScale9Sprite("#com_btn_qq.png")
    local qqLoginBtn = CCControlButton:create()
    qqLoginBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
    qqLoginBtn:setPosition(display.cx * 0.5, 80)
    qqLoginBtn:setPreferredSize(CCSizeMake(275, 90))
    self:addChild(qqLoginBtn)

    qqLoginBtn:addHandleOfControlEvent(function()
        if(CSDKShell.isLogined()) then
            if self._versionInfo then
                checkforupdate(self._versionInfo)
            end
        else
            CSDKShell.Login(QQLOGIN)
        end
    end, CCControlEventTouchDown)

    btnSprite = display.newScale9Sprite("#com_btn_wx.png")
    local wxLoginBtn = CCControlButton:create()
    wxLoginBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
    wxLoginBtn:setPosition(display.cx * 1.5, 80)
    wxLoginBtn:setPreferredSize(CCSizeMake(275, 90))
    self:addChild(wxLoginBtn)

    wxLoginBtn:addHandleOfControlEvent(function()
        if(CSDKShell.isLogined()) then
            if self._versionInfo then
                checkforupdate(self._versionInfo)
            end
        else
            CSDKShell.Login(WXLOGIN)
        end
    end, CCControlEventTouchDown)
end



function VersionCheckScene:showOtherUI()

    local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
    local btn = CCControlButton:create("登录", "fonts/FZCuYuan-M03S.ttf", 30)
    btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
    btn:setPosition(display.cx, 80)
    btn:setPreferredSize(CCSizeMake(157, 69))
    self:addChild(btn)

    btn:addHandleOfControlEvent(function()
        if(CSDKShell.isLogined()) then
            if self._versionInfo then
                checkforupdate(self._versionInfo)
            end
        else
            CSDKShell.Login()
        end
    end, CCControlEventTouchDown)
end

function VersionCheckScene:request()
    local function request()
        local channelID = checkint(CSDKShell.getChannelID())
        NetworkHelper.request(data_serverurl_serverurl[channelID].versionUrl, {
            ac = "dwurl",
            channel = CSDKShell.getChannelID(),
            version = getlocalversion(),
            buildFlag = CSDKShell.getBuildFlag()
        }, function(data)
            dump(data)
            self._versionInfo = data

            checkforupdate(data)
        end, "GET")
    end
    request()
end

function VersionCheckScene:onEnter()

end

function VersionCheckScene:onEnterTransitionFinish()
    if(CSDKShell.isLogined()) then
        self:request()
    else
        if CSDKShell.GetSDKTYPE() ~= SDKType.ANDROID_TENCENT then
            CSDKShell.Login()
        end

        local scheduler = require("framework.scheduler")
        local loginSche
        loginSche = scheduler.scheduleGlobal(function()
            if(CSDKShell.isLogined()) then
                scheduler.unscheduleGlobal(loginSche)
                self:request()
            end
        end, 0.5)
    end
end

return VersionCheckScene

