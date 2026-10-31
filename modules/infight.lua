pfUI:RegisterModule("infight", function ()
  pfUI.infight = CreateFrame("Frame", "pfUICombatScreen", WorldFrame)
  pfUI.infight:SetAllPoints(WorldFrame)
  pfUI.infight:EnableMouse(false)
  pfUI.infight:Hide()

  -- Shift the glow between red and a paler orange for good. The group only
  -- advances while the glow is shown, so a hidden glow costs nothing.
  local pulse = pfUI.infight:CreateAnimationGroup()
  pulse:SetLooping("BOUNCE")
  local shift = pulse:CreateAnimation()
  shift:SetDuration(.3)
  shift:SetSmoothing("IN_OUT")
  shift:SetScript("OnUpdate", function(self)
    local fade = self:GetSmoothProgress() * .3
    pfUI.infight:SetBackdropBorderColor(1, .2 + fade, fade, 1 - fade)
  end)
  pulse:Play()

  -- Combat, health and death come from events. Aggro has no event, so a
  -- ticker polls it while that glow is enabled.
  local combat, health, dead, aggro, poll

  local function Refresh()
    pfUI.infight:SetShown((combat or health or aggro) and not dead)
  end

  local function UpdatePlayer()
    combat = C.appearance.infight.screen == "1" and UnitAffectingCombat("player")
    health = C.appearance.infight.health == "1" and UnitHealth("player") / UnitHealthMax("player") <= .25
    dead = UnitIsDeadOrGhost("player")
    Refresh()
  end

  local function UpdateAggro()
    aggro = UnitHasAggro("player") > 0
    Refresh()
  end

  pfUI.infight:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.infight:RegisterEvent("PLAYER_REGEN_DISABLED")
  pfUI.infight:RegisterEvent("PLAYER_REGEN_ENABLED")
  pfUI.infight:RegisterEvent("PLAYER_DEAD")
  pfUI.infight:RegisterEvent("PLAYER_ALIVE")
  pfUI.infight:RegisterEvent("PLAYER_UNGHOST")
  pfUI.infight:RegisterUnitEvent("UNIT_HEALTH", "player")
  pfUI.infight:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
  pfUI.infight:SetScript("OnEvent", UpdatePlayer)

  pfUI.infight.UpdateConfig = function(self)
    pfUI.infight:SetBackdrop({
      edgeFile = pfUI.media["img:glow"], edgeSize = tonumber(C.appearance.infight.intensity),
      insets = {left = 0, right = 0, top = 0, bottom = 0},
    })

    if poll then poll:Cancel() end
    poll = C.appearance.infight.aggro == "1" and C_Timer.NewTicker(.3, UpdateAggro)
    aggro = nil

    UpdatePlayer()
  end

  pfUI.infight:UpdateConfig()
end)
