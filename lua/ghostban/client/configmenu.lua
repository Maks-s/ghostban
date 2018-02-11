GhostBan = GhostBan or {}

hook.Add("OnPlayerChat", "GhostBan_OpenSettings", function(ply, text)
	if string.Trim(text) ~= "/ghostban" then return end
	if ply ~= LocalPlayer() || !ply:IsAdmin() then
		return true
	end
	local PANEL = {}
	PANEL.window = vgui.Create("DFrame")
	PANEL.window:SetSize(440,360)
	PANEL.window:Center()
	PANEL.window:SetTitle("GhostBan config")
	function PANEL.window:Paint(w,h)
		draw.RoundedBox(5,0,0,w,h,Color(100,100,100))
		draw.RoundedBoxEx(5,0,0,w,25,Color(70,70,70),true,true)
	end 
	PANEL.scroll = vgui.Create("DScrollPanel",PANEL.window)
	PANEL.scroll:Dock(FILL)
	PANEL.window:MakePopup()
	local function createCheckBox(name, text, value)
		PANEL[name] = PANEL.scroll:Add("DCheckBoxLabel")
		PANEL[name]:Dock(TOP)
		PANEL[name]:SetText(text)
		PANEL[name]:DockMargin(5,0,10,5)
		PANEL[name]:SetValue(value)
	end
	createCheckBox("spawnprop", "Ghosts can spawn props", GhostBan.CanSpawnProps)
	createCheckBox("property", "Ghosts can use property", GhostBan.CanProperty)
	createCheckBox("tool", "Ghosts can use the toolgun", GhostBan.CanTool)
	createCheckBox("voice", "Ghosts can talk with their voice", GhostBan.CanTalkVoice)
	createCheckBox("tChat", "Ghosts can talk with the chat", GhostBan.CanTalkChat)
	createCheckBox("loadout", "Ghosts have their weapons when they spawn", GhostBan.Loadouts)
	createCheckBox("item", "Ghosts can pickup items", GhostBan.CanPickupItem)
	createCheckBox("wep", "Ghosts can pickup weapons", GhostBan.CanPickupWep)
	createCheckBox("vehicle", "Ghosts can enter vehicles", GhostBan.CanEnterVehicle)
	createCheckBox("suicide", "Ghosts can suicide", GhostBan.CanSuicide)
	PANEL['collideText'] = PANEL.scroll:Add("DLabel")
	PANEL['collideText']:SetText("Ghosts don't collide with... (Warning: If activated, ghosts can't be hurt)")
	PANEL['collideText']:Dock(TOP)
	PANEL['collideText']:DockMargin(5,0,10,5)
	PANEL['collideText']:SizeToContents()
	PANEL['collide'] = PANEL.scroll:Add("DComboBox")
	PANEL['collide']:Dock(TOP)
	PANEL['collide']:DockMargin(5,0,10,5)
	PANEL['collide']:AddChoice("Players", 0)
	PANEL['collide']:AddChoice("Everything", 1)
	PANEL['collide']:AddChoice("Nothing", 2)
	PANEL['collide']:ChooseOptionID(GhostBan.CanCollide+1)
	createCheckBox("lowHud", "Display reason of ban at the bottom of the screen", GhostBan.DisplayReason)
	createCheckBox("mContext", "Ghosts can open the context menu", GhostBan.CanOpenContextMenu)
	createCheckBox("mProps", "Ghosts can open the props menu", GhostBan.CanOpenPropsMenu)
	createCheckBox("mGame", "Ghosts can open the game menu", GhostBan.CanOpenGameMenu)
	createCheckBox("ghostText", "Display 'GHOST' above ghost's head", GhostBan.DisplayCyanGhost)
	createCheckBox("hurt", "Ghosts can hurt players", GhostBan.CanHurt)
	createCheckBox("freeze", "Ghosts are frozen, they can't move", GhostBan.freezeGhost)
	createCheckBox("jailMode", "JailMode : If you want to use Ghostban to jail and not to ban", GhostBan.jailMode)
	createCheckBox("seeMe", "Ghosts are invisible", GhostBan.CantSeeMe)
	--createCheckBox("superhot", "Lower time left only when player is on the server", GhostBan.SuperHot)
	if ulx || Clockwork then
		createCheckBox("repDEF", "Replace default ban command", GhostBan.replaceDefBan)
	end
	if DarkRP then
		createCheckBox("changeJob", "Ghosts can change job (DarkRP)", GhostBan.canChangeJob)
	end
	PANEL['percentKickText'] = PANEL.scroll:Add("DLabel")
	PANEL['percentKickText']:SetText("Percent of players before ghosts are kicked and can't join the server (0 to disable)")
	PANEL['percentKickText']:Dock(TOP)
	PANEL['percentKickText']:DockMargin(5,0,10,5)
	PANEL['percentKickText']:SizeToContents()
	PANEL['percentKick'] = PANEL.scroll:Add("DNumSlider")
	PANEL['percentKick']:Dock(TOP)
	PANEL['percentKick']:DockMargin(5,0,10,5)
	PANEL['percentKick'].PerformLayout = nil -- remove label
	PANEL['percentKick']:SetMinMax(0, 100)
	PANEL['percentKick']:SetDecimals(0)
	PANEL['percentKick']:SetValue(GhostBan.percentKick)
	PANEL['percentKick'].TextArea:SetDrawLanguageID(false)
	PANEL['percentKick'].TextArea:SetTextColor(Color(230,230,230))
	PANEL['materialText'] = PANEL.scroll:Add("DLabel")
	PANEL['materialText']:SetText("Set ghost material to : ( leave blank to not change the material )")
	PANEL['materialText']:Dock(TOP)
	PANEL['materialText']:DockMargin(5,0,10,5)
	PANEL['materialText']:SizeToContents()
	PANEL['material'] = PANEL.scroll:Add("DTextEntry")
	PANEL['material']:Dock(TOP)
	PANEL['material']:DockMargin(5,0,10,5)
	PANEL['material']:SetText(GhostBan.material)
	PANEL['material']:SetDrawLanguageID(false)
	PANEL['language'] = PANEL.scroll:Add("DComboBox")
	PANEL['language']:Dock(TOP)
	PANEL['language']:DockMargin(5,0,10,5)
	PANEL['language']:AddChoice("English", "EN")
	PANEL['language']:AddChoice("Français", "FR")
	PANEL['language']:AddChoice("русский", "RU")
	if GhostBan.Language == "EN" then
		PANEL['language']:ChooseOptionID(1)
	elseif GhostBan.Language == "FR" then
		PANEL['language']:ChooseOptionID(2)
	else
		PANEL['language']:ChooseOptionID(3)
	end
	PANEL.save = PANEL.scroll:Add("DButton")
	PANEL.save:Dock(TOP)
	PANEL.save:DockMargin(5,0,10,5)
	PANEL.save:SetText("Save")
	function PANEL.save:DoClick()
		local material = PANEL['material']:GetText()
		if material ~= "" && Material(material):IsError() then -- invalid material
			notification.AddLegacy("Invalid material", NOTIFY_ERROR, 3)
			surface.PlaySound("buttons/button10.wav")
			return
		end
		net.Start("ghost_ban_net")
		local settings = {
			['spawnprop'] = PANEL['spawnprop']:GetChecked(),
			['property'] = PANEL['property']:GetChecked(),
			['tool'] = PANEL['tool']:GetChecked(),
			['voice'] = PANEL['voice']:GetChecked(),
			['tChat'] = PANEL['tChat']:GetChecked(),
			['loadout'] = PANEL['loadout']:GetChecked(),
			['item'] = PANEL['item']:GetChecked(),
			['wep'] = PANEL['wep']:GetChecked(),
			['vehicle'] = PANEL['vehicle']:GetChecked(),
			['suicide'] = PANEL['suicide']:GetChecked(),
			['collide'] = PANEL['collide']:GetOptionData(PANEL['collide']:GetSelectedID()),
			['lowHud'] = PANEL['lowHud']:GetChecked(),
			['mContext'] = PANEL['mContext']:GetChecked(),
			['mProps'] = PANEL['mProps']:GetChecked(),
			['mGame'] = PANEL['mGame']:GetChecked(),
			['ghostText'] = PANEL['ghostText']:GetChecked(),
			['hurt'] = PANEL['hurt']:GetChecked(),
			['lang'] = PANEL['language']:GetOptionData(PANEL['language']:GetSelectedID()) or GhostBan.Language,
			['freezer'] = PANEL['freeze']:GetChecked(),
			['jailmode'] = PANEL['jailMode']:GetChecked(),
			['seeme'] = PANEL['seeMe']:GetChecked(),
			['material'] = PANEL['material']:GetText(),
			-- ['superhot'] = PANEL['superhot']:GetChecked(),
			['kPercent'] = PANEL['percentKick'].TextArea:GetValue() -- Get from TextArea because it doesn't have decimal
		}
		if ulx then
			settings['repDEF'] = PANEL['repDEF']:GetChecked()
		end
		if DarkRP then
			settings['changejob'] = PANEL['changeJob']:GetChecked()
		end
		net.WriteTable(settings)
		net.SendToServer()
		PANEL.window:Close()
	end
	return true
end)