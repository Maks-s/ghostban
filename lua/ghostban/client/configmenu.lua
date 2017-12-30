GhostBan = GhostBan or {}

hook.Add("OnPlayerChat", "GhostBan_OpenSettings", function(ply, text)
	if string.Trim(text) == "/ghostban" then
		if ply ~= LocalPlayer()  || !ply:IsAdmin()  then
			return true
		end
		local PANEL = {}
		PANEL.window = vgui.Create("DFrame")
		PANEL.window:SetSize(440,360)
		PANEL.window:Center()
		PANEL.window:SetTitle("GhostBan config")
		PANEL.window:MakePopup()
		PANEL.spawnprop = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.spawnprop:SetPos(5, 30)
		PANEL.spawnprop:SetText("Can spawn props")
		PANEL.spawnprop:SizeToContents()
		PANEL.spawnprop:SetValue(GhostBan.CanSpawnProps)
		PANEL.property = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.property:SetPos(5, 50)
		PANEL.property:SetText("Can use property")
		PANEL.property:SizeToContents()
		PANEL.property:SetValue(GhostBan.CanProperty)
		PANEL.tool = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.tool:SetPos(5, 70)
		PANEL.tool:SetText("Can use tool")
		PANEL.tool:SizeToContents()
		PANEL.tool:SetValue(GhostBan.CanTool)
		PANEL.voice = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.voice:SetPos(5, 90)
		PANEL.voice:SetText("Can talk with its voice")
		PANEL.voice:SizeToContents()
		PANEL.voice:SetValue(GhostBan.CanTalkVoice)
		PANEL.tChat = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.tChat:SetPos(5, 110)
		PANEL.tChat:SetText("Can talk with the chat")
		PANEL.tChat:SizeToContents()
		PANEL.tChat:SetValue(GhostBan.CanTalkChat)
		PANEL.loadout = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.loadout:SetPos(5, 130)
		PANEL.loadout:SetText("Have its loadout")
		PANEL.loadout:SizeToContents()
		PANEL.loadout:SetValue(GhostBan.Loadouts)
		PANEL.item = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.item:SetPos(5, 150)
		PANEL.item:SetText("Can pickup items")
		PANEL.item:SizeToContents()
		PANEL.item:SetValue(GhostBan.CanPickupItem)
		PANEL.wep = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.wep:SetPos(5, 170)
		PANEL.wep:SetText("Can pickup weapons")
		PANEL.wep:SizeToContents()
		PANEL.wep:SetValue(GhostBan.CanPickupWep)
		PANEL.vehicle = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.vehicle:SetPos(5, 190)
		PANEL.vehicle:SetText("Can enter vehicles")
		PANEL.vehicle:SizeToContents()
		PANEL.vehicle:SetValue(GhostBan.CanEnterVehicle)
		PANEL.suicide = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.suicide:SetPos(5, 210)
		PANEL.suicide:SetText("Can suicide")
		PANEL.suicide:SizeToContents()
		PANEL.suicide:SetValue(GhostBan.CanSuicide)
		PANEL.collideText = vgui.Create("DLabel", PANEL.window)
		PANEL.collideText:SetText("Ghosts don't collide with...\n\n\nWarning: If activated, ghosts can't be hurt")
		PANEL.collideText:SetPos(6, 240)
		PANEL.collideText:SizeToContents()
		PANEL.collide = vgui.Create("DComboBox", PANEL.window)
		PANEL.collide:SetPos(5, 255)
		PANEL.collide:AddChoice("Players", 0)
		PANEL.collide:AddChoice("Everything", 1)
		PANEL.collide:AddChoice("Nothing", 2)
		PANEL.collide:ChooseOptionID(GhostBan.CanCollide+1)
		PANEL.collide:SetWidth(100)
		PANEL.lowHud = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.lowHud:SetPos(250, 30)
		PANEL.lowHud:SetText("Display reason on ghost's hud")
		PANEL.lowHud:SizeToContents()
		PANEL.lowHud:SetValue(GhostBan.DisplayReason)
		PANEL.mContext = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.mContext:SetPos(250, 50)
		PANEL.mContext:SetText("Can open context menu")
		PANEL.mContext:SizeToContents()
		PANEL.mContext:SetValue(GhostBan.CanOpenContextMenu)
		PANEL.mProps = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.mProps:SetPos(250, 70)
		PANEL.mProps:SetText("Can open props menu")
		PANEL.mProps:SizeToContents()
		PANEL.mProps:SetValue(GhostBan.CanOpenPropsMenu)
		PANEL.mGame = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.mGame:SetPos(250, 90)
		PANEL.mGame:SetText("Can open game menu")
		PANEL.mGame:SizeToContents()
		PANEL.mGame:SetValue(GhostBan.CanOpenGameMenu)
		PANEL.ghostText = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.ghostText:SetPos(250, 110)
		PANEL.ghostText:SetText("Display ghost above ghost head")
		PANEL.ghostText:SizeToContents()
		PANEL.ghostText:SetValue(GhostBan.DisplayCyanGhost)
		PANEL.hurt = vgui.Create("DCheckBoxLabel", PANEL.window)
		PANEL.hurt:SetPos(250, 130)
		PANEL.hurt:SetText("Can hurt players")
		PANEL.hurt:SizeToContents()
		PANEL.hurt:SetValue(GhostBan.CanHurt)
		PANEL.language = vgui.Create("DComboBox", PANEL.window)
		PANEL.language:SetPos(250, 150)
		PANEL.language:AddChoice("EN")
		PANEL.language:AddChoice("FR")
		PANEL.language:AddChoice("RU")
		PANEL.language:ChooseOption(GhostBan.Language)
		PANEL.language:SetWidth(40)
		if ulx then
			PANEL.repULX = vgui.Create("DCheckBoxLabel", PANEL.window)
			PANEL.repULX:SetPos(250, 180)
			PANEL.repULX:SetText("Replace ulx ban")
			PANEL.repULX:SizeToContents()
			PANEL.repULX:SetValue(GhostBan.ReplaceULXBan)
		end
		PANEL.save = vgui.Create("DButton", PANEL.window)
		PANEL.save:SetPos(250, 200)
		PANEL.save:SetText("Save")
		function PANEL.save:DoClick()
			net.Start("ghost_ban_net")
			local settings = {
				['spawnprop'] = PANEL.spawnprop:GetChecked(),
				['property'] = PANEL.property:GetChecked(),
				['tool'] = PANEL.tool:GetChecked(),
				['voice'] = PANEL.voice:GetChecked(),
				['tChat'] = PANEL.tChat:GetChecked(),
				['loadout'] = PANEL.loadout:GetChecked(),
				['item'] = PANEL.item:GetChecked(),
				['wep'] = PANEL.wep:GetChecked(),
				['vehicle'] = PANEL.vehicle:GetChecked(),
				['suicide'] = PANEL.suicide:GetChecked(),
				['collide'] = PANEL.collide:GetOptionData(PANEL.collide:GetSelectedID()),
				['lowHud'] = PANEL.lowHud:GetChecked(),
				['mContext'] = PANEL.mContext:GetChecked(),
				['mProps'] = PANEL.mProps:GetChecked(),
				['mGame'] = PANEL.mGame:GetChecked(),
				['ghostText'] = PANEL.ghostText:GetChecked(),
				['hurt'] = PANEL.hurt:GetChecked(),
				['lang'] = PANEL.language:GetOptionText(PANEL.language:GetSelectedID()) or GhostBan.Language
			}
			if ulx then
				settings['repULX'] = PANEL.repULX:GetChecked()
			end
			net.WriteTable(settings)
			net.SendToServer()
			PANEL.window:Close()
		end
		return true
	end
end)