pfUI:RegisterModule("easteregg", function ()
  local today = date("%m%d")
  -- merry x-mas!
  if today == "1224" or today == "1225" then
    local title = (UnitFactionGroup("player") == "Horde") and PVP_RANK_18_0 or PVP_RANK_18_1
    local oldflag = _G.CHAT_FLAG_AFK

    local pvpking = CreateFrame("Frame", "pfPvPKing", UIParent)
    pvpking:Hide()

    pvpking:RegisterEvent("PLAYER_FLAGS_CHANGED")
    pvpking:SetScript("OnEvent", function()
      if UnitIsAFK('player') then
        _G.CHAT_FLAG_AFK = title .. " "
        this.time = GetTime()
        this:Show()
      end
    end)

    pvpking:SetScript("OnUpdate", function()
      if this.time + 1 < GetTime() then
        _G.CHAT_FLAG_AFK = oldflag
        this:Hide()
      end
    end)

    _G.MARKED_AFK           = "You are now |cff33ffcc" .. title .. "|r (AFK)."
    _G.MARKED_AFK_MESSAGE   = "You are now |cff33ffcc" .. title .. "|r (AFK): %s"
    _G.CLEARED_AFK          = "You are no longer |cff33ffcc" .. title .. "|r (AFK).\n|cff33ffccShagu|cffffffff wishes you a merry christmas. Thanks for using |cff33ffccpf|cffffffffUI|cffffffff!|r"
  end

  -- happy new year
  if today == "1231" or today == "0101" then
    local fireworks = CreateFrame("Button", "pfFireworks", WorldFrame)
    fireworks:SetFrameStrata("DIALOG")
    fireworks:SetAllPoints()
    fireworks:Hide()

    fireworks.night = fireworks:CreateTexture("LOW")
    fireworks.night:SetColorTexture(0,0,0,1)
    fireworks.night:SetGradientAlpha("VERTICAL", 0,0,0,.5, 0,0,0,1)
    fireworks.night:SetAllPoints()

    fireworks.stext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.stext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.stext:SetPoint("TOP", 0, -380)
    fireworks.stext:SetText("|cff33ffccShagu|cffffffff wishes you a")

    fireworks.text = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.text:SetFont(pfUI.media["font:BigNoodleTitling.ttf"], 38)
    fireworks.text:SetPoint("TOP", 0, -400)
    fireworks.text:SetText("happy new year!")

    fireworks.dtext = fireworks:CreateFontString("Status", "LOW", "GameFontWhite")
    fireworks.dtext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fireworks.dtext:SetPoint("TOP", 0, -430)
    fireworks.dtext:SetText("Another year with |cff33ffccpf|rUI has passed.\nThanks for continuing to use it!\n\n|cff444444<Click> or '/afk' to exit")

    fireworks:SetScript("OnClick", function()
      this:Hide()
    end)

    -- trigger fireworks when being AFK
    fireworks:RegisterEvent("PLAYER_FLAGS_CHANGED")
    fireworks:SetScript("OnEvent", function()
      this:SetShown(UnitIsAFK('player'))
    end)

    -- Each explosion grows by 100px and fades out over 5/3s, then goes back
    -- to the pool.
    local explosions = CreateTexturePool(fireworks, "OVERLAY")

    local function Explode(x, y, size, r, g, b, a)
      local tex = explosions:Acquire()
      if not tex.burst then
        tex.burst = tex:CreateAnimationGroup()
        tex.burst:SetIgnoreFramerateThrottle(true)
        tex.burst.grow = tex.burst:CreateAnimation("Scale")
        tex.burst.grow:SetDuration(5/3)
        local fade = tex.burst:CreateAnimation("Alpha")
        fade:SetChange(-1)
        fade:SetDuration(5/3)
        tex.burst:SetScript("OnFinished", function() explosions:Release(tex) end)
      end

      tex:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
      tex:SetSize(size, size)
      tex:SetColorTexture(r, g, b, a)
      tex.burst.grow:SetScale((size + 100) / size, (size + 100) / size)
      tex:Show()
      tex.burst:Play()
    end

    -- Fade the night in by playing a fade-out backwards. The frame keeps an
    -- alpha of 1, which comes back when the fade ends.
    fireworks.dusk = fireworks:CreateAnimationGroup()
    local fade = fireworks.dusk:CreateAnimation("Alpha")
    fade:SetChange(-1)
    fade:SetDuration(.8)

    fireworks:SetScript("OnShow", function()
      this.dusk:Play(true)
    end)

    -- start over on the next AFK
    fireworks:SetScript("OnHide", function()
      this:StopAnimating()
      explosions:ReleaseAll()
    end)

    -- create random amount of fireworks at random positions
    local width, height = GetScreenWidth(), GetScreenHeight()
    fireworks:SetScript("OnUpdate", function()
      if this.dusk:IsPlaying() then return end

      -- let the "happy new year" blink
      local r,g,b = this.text:GetTextColor()
      this.text:SetTextColor(r+(math.random()-.5)/10, g+(math.random()-.5)/10, b+(math.random()-.5)/10,1)

      if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .2 end

      local x,y = math.random(1, width), -1*math.random(1,height)

      -- create the base explosion
      Explode(x, y, 25, 1, 1, 1, .5)

      -- create random amount of colored explosions
      for i=1, math.random(20) do
        Explode(x+(math.random(0,100)-50), y+(math.random(0,100)-50), 2, math.random(), math.random(), math.random(), 1)
      end
    end)
  end
end)
