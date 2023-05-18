pfUI:RegisterModule("PvPOverlay", "vanilla:tbc", function ()
  pfUI.gui.dropdowns.PvPOverlay_positions = {
    "left:" .. T["Left"],
    "right:" .. T["Right"],
    "off:" .. T["Disabled"]
  }

  -- detect current addon path
  local addonpath
  local tocs = { "", "-master", "-tbc", "-wotlk" }
  for _, name in pairs(tocs) do
    local current = string.format("pfUI-pvpoverlay%s", name)
    local _, title = GetAddOnInfo(current)
    if title then
      addonpath = "Interface\\AddOns\\" .. current
      break
    end
  end

  if pfUI.gui.CreateGUIEntry then -- new pfUI
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["PvP Overlay"], function()
      pfUI.gui.CreateConfig(pfUI.gui.UpdaterFunctions["target"], T["Select dragon position"], C.PvPOverlay, "position", "dropdown", pfUI.gui.dropdowns.PvPOverlay_positions)
    end)
  else -- old pfUI
    pfUI.gui.tabs.thirdparty.tabs.PvPOverlay = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild("PvPOverlay", true)
    pfUI.gui.tabs.thirdparty.tabs.PvPOverlay:SetScript("OnShow", function()
      if not this.setup then
        local CreateConfig = pfUI.gui.CreateConfig
        local update = pfUI.gui.update
        this.setup = true
      end
    end)
  end

  pfUI:UpdateConfig("PvPOverlay",       nil,         "position",   "right")


  local HookRefreshUnit = pfUI.uf.RefreshUnit
  function pfUI.uf:RefreshUnit(unit, component)
    local pos = string.upper(C.PvPOverlay.position)
    local invert = C.PvPOverlay.position == "right" and 1 or -1
    local unitstr = ( unit.label or "" ) .. ( unit.id or "" )

    local size = unit:GetWidth() / 1.5
    local pvp = UnitIsPVP(unitstr)
	local faction = UnitFactionGroup(unitstr)

    unit.targetTop = unit.targetTop or unit:CreateTexture(nil, "OVERLAY")
    unit.targetBottom = unit.targetBottom or unit:CreateTexture(nil, "OVERLAY")

    if unitstr == "" or C.PvPOverlay.position == "off" then
      unit.targetTop:Hide()
      unit.targetBottom:Hide()
    else
      unit.targetTop:ClearAllPoints()
      unit.targetTop:SetWidth(size)
      unit.targetTop:SetHeight(size)
      unit.targetTop:SetPoint("TOP"..pos, unit, "TOP"..pos, invert*size/5, size/7)
      unit.targetTop:SetParent(unit.hp.bar)

      unit.targetBottom:ClearAllPoints()
      unit.targetBottom:SetWidth(size)
      unit.targetBottom:SetHeight(size)
      unit.targetBottom:SetPoint("BOTTOM"..pos, unit, "BOTTOM"..pos, invert*size/5.2, -size/2.98)
      unit.targetBottom:SetParent(unit.hp.bar)

      if pvp == 1 and faction == "Horde" then
        unit.targetTop:SetTexture(addonpath.."\\img\\TOP_GRAY_"..pos)
        unit.targetTop:Show()
        unit.targetTop:SetVertexColor(.55,.09,.09,1)
        unit.targetBottom:SetTexture(addonpath.."\\img\\BOTTOM_GRAY_"..pos)
        unit.targetBottom:Show()
        unit.targetBottom:SetVertexColor(.55,.09,.09,1)
      elseif pvp == 1 and faction == "Alliance" then
        unit.targetTop:SetTexture(addonpath.."\\img\\TOP_GRAY_"..pos)
        unit.targetTop:Show()
        unit.targetTop:SetVertexColor(.18,.29,.58,1)
        unit.targetBottom:SetTexture(addonpath.."\\img\\BOTTOM_GRAY_"..pos)
        unit.targetBottom:Show()
        unit.targetBottom:SetVertexColor(.18,.29,.58,1)
      else
        unit.targetTop:Hide()
        unit.targetBottom:Hide()
      end
    end

    HookRefreshUnit(this, unit, component)
  end
end)
