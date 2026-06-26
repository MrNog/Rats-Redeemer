--Saved VariablesPerCharacter: RedeemerDisplaySay, RedeemerDisplayParty, RedeemerDisplayRaid, RedeemerDisplayWhisper

function Redeemer_OnLoad(self)

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_SPELLCAST_SENT");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("PLAYER_ALIVE");

	SLASH_REDEEMER1 = "/redeemer";
	SlashCmdList["REDEEMER"] = Redeemer_SlashOpts;
end

function Redeemer_OnEvent(self, event, ...)

	if (event == "ADDON_LOADED") then
		local addon = select(1, ...);
		if (addon == "Redeemer") then
			DEFAULT_CHAT_FRAME:AddMessage("Redeemer is locked and loaded! /redeemer for options.", 0.25, 0.88, 0.88);
			--if an option setting is not found, set it to default
			if (RedeemerDisplaySay == nil) then
				DEFAULT_CHAT_FRAME:AddMessage("Redeemer /say option default  set |cffffffff[|cff00ff00on|cffffffff]", 0.25, 0.88, 0.88);
				RedeemerDisplaySay = true;
			end
			if (RedeemerDisplayParty == nil) then
				DEFAULT_CHAT_FRAME:AddMessage("Redeemer /party option default set |cffffffff[|cffff0000off|cffffffff]", 0.25, 0.88, 0.88);
				RedeemerDisplayParty = false;
			end
			if (RedeemerDisplayRaid == nil) then
				DEFAULT_CHAT_FRAME:AddMessage("Redeemer /raid option default set |cffffffff[|cffff0000off|cffffffff]", 0.25, 0.88, 0.88);
				RedeemerDisplayRaid = false;
			end
			if (RedeemerDisplayWhisper == nil) then
				DEFAULT_CHAT_FRAME:AddMessage("Redeemer /whisper option default set |cffffffff[|cffff0000off|cffffffff]", 0.25, 0.88, 0.88);
				RedeemerDisplayWhisper = false;
			end
			--build the config window + minimap button (once)
			Redeemer_InitUI();
		end
	end

	if (event == "UNIT_SPELLCAST_SENT") then
		if (arg1 == "player") then
			--DEFAULT_CHAT_FRAME:AddMessage("Spellcast: " .. arg1 .. arg2 .. arg3 .. arg4);
			if (arg2 == "Redemption") then
				Redeemer_Quotes("Paladin", arg4);
			elseif (arg2 == "Resurrection") then
				Redeemer_Quotes("Priest", arg4);
			elseif (arg2 == "Ancestral Spirit") then
				Redeemer_Quotes("Shaman", arg4);
			elseif (arg2 == "Revive") then
				Redeemer_Quotes("Druid", arg4);
			elseif (arg2 == "Revive Pet") then
				if (PET_NAME) then
					Redeemer_Quotes("Hunter", PET_NAME);
				else
					SendChatMessage("Pet Name unknown!");
				end
			elseif (arg2 == "Rebirth") then
				Redeemer_Quotes("Combat", arg4);
			elseif (arg2 == "Defibrillate") then
				Redeemer_Quotes("Engineer", arg4);
			elseif (arg2 == "Raise Dead") then
				Redeemer_Quotes("DeathKnightDead", arg4);
			elseif (arg2 == "Raise Ally") then
				Redeemer_Quotes("DeathKnightAlly", arg4)
			elseif (arg2 == "Soulstone Resurrection") then
				Redeemer_Quotes("Warlock", arg4);
			end
		end
	end

	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		--if pet dies, gets pet's name
		if (arg2 == "UNIT_DIED") then
			if (arg8 == 0x1111) then
				PET_NAME = arg7;
			end
		end
	end

	if (event == "PLAYER_DEAD") then
		if (HasSoulstone()) then
			RedeemerHasSoulstone = true;
		end
	end

	if (event == "PLAYER_ALIVE") then
		if (RedeemerHasSoulstone) then
			RedeemerHasSoulstone = false;
			Redeemer_Quotes("Self", "self");
		end
	end

end

function Redeemer_Quotes(playerClass, target)

	--DEFAULT_CHAT_FRAME:AddMessage("Redeemer called: " .. playerClass .. target);
	--SendChatMessage("Redeemer called!");
	target = target or "";

	--pick a quote pool by rez type; fall back to genericQuotes
	local pools = {
		Paladin = paladinQuotes,
		Priest = priestQuotes,
		Shaman = shamanQuotes,
		Druid = druidQuotes,
		Hunter = hunterQuotes,
		Combat = combatQuotes,
		Engineer = engineerQuotes,
		DeathKnightDead = deathKnightDeadQuotes,
		DeathKnightAlly = deathKnightAllyQuotes,
		Warlock = warlockQuotes,
		Self = selfQuotes,
	};
	local pool = pools[playerClass];
	if (not pool or #pool == 0) then
		pool = genericQuotes;
	elseif (playerClass ~= "Self" and playerClass ~= "DeathKnightDead") then
		-- each class only has a couple of its own lines, so mix in the generic
		-- pool for variety (skip Self/DeathKnightDead: their %t is empty/different)
		local merged = {};
		for _, q in ipairs(pool) do
			merged[#merged + 1] = q;
		end
		for _, q in ipairs(genericQuotes) do
			merged[#merged + 1] = q;
		end
		pool = merged;
	end
	local chatMessage = pool[random(#(pool))];

	chatMessage = string.gsub(chatMessage, "%%t", target);

	--battle rezzes (cast in the middle of a fight) are forced to raid chat so the whole raid sees them
	local combatRez = (playerClass == "Combat" or playerClass == "Engineer"
		or playerClass == "DeathKnightAlly" or playerClass == "Self");

	Redeemer_SendQuotes(chatMessage, target, combatRez);
	--quote = quote + 1;

end

function Redeemer_SendQuotes(chatMessage, target, forceRaid)

	if (forceRaid) then
		--combat resurrection: always announce to the whole group, ignoring the toggles
		if (UnitInRaid("player")) then
			SendChatMessage(chatMessage, "RAID");
		elseif (GetNumPartyMembers() > 0) then
			SendChatMessage(chatMessage, "PARTY");
		else
			SendChatMessage(chatMessage, "SAY");
		end
	elseif (RedeemerDisplayRaid and UnitInRaid("player")) then
		SendChatMessage(chatMessage, "RAID");
	elseif (RedeemerDisplayParty and GetNumPartyMembers() > 0) then
		SendChatMessage(chatMessage, "PARTY");
	elseif (RedeemerDisplaySay) then
		SendChatMessage(chatMessage, "SAY");
	end

	if (RedeemerDisplayWhisper and string.upper(target) ~= "UNKNOWN") then
		SendChatMessage(chatMessage, "WHISPER", nil, target);
	end

end

function Redeemer_SlashOpts(cmd)

	cmd = string.lower(cmd);

	if (cmd == "say") then
		RedeemerDisplaySay = not RedeemerDisplaySay;
		sayText = "|cffffffff[";
		if (RedeemerDisplaySay) then
			sayText = sayText.."|cff00ff00on";
		else
			sayText = sayText.."|cffff0000off";
		end
		sayText = sayText.."|cffffffff]";
		DEFAULT_CHAT_FRAME:AddMessage("Quotes sent to /say toggled "..sayText, 0.25, 0.88, 0.88);

	elseif (cmd == "party") then
		RedeemerDisplayParty = not RedeemerDisplayParty;
		partyText = "|cffffffff[";
		if (RedeemerDisplayParty) then
			partyText = partyText.."|cff00ff00on";
		else
			partyText = partyText.."|cffff0000off";
		end
		partyText = partyText.."|cffffffff]";
		DEFAULT_CHAT_FRAME:AddMessage("Quotes sent to /party toggled "..partyText, 0.25, 0.88, 0.88);

	elseif (cmd == "raid") then
		RedeemerDisplayRaid = not RedeemerDisplayRaid;
		raidText = "|cffffffff[";
		if (RedeemerDisplayRaid) then
			raidText = raidText.."|cff00ff00on";
		else
			raidText = raidText.."|cffff0000off";
		end
		raidText = raidText.."|cffffffff]";
		DEFAULT_CHAT_FRAME:AddMessage("Quotes sent to /raid toggled "..raidText, 0.25, 0.88, 0.88);

	elseif (cmd == "whisper") then
		RedeemerDisplayWhisper = not RedeemerDisplayWhisper;
		whisperText = "|cffffffff[";
		if (RedeemerDisplayWhisper) then
			whisperText = whisperText.."|cff00ff00on";
		else
			whisperText = whisperText.."|cffff0000off";
		end
		whisperText = whisperText.."|cffffffff]";
		DEFAULT_CHAT_FRAME:AddMessage("Quotes whispered to target toggled "..whisperText, 0.25, 0.88, 0.88);

	elseif (cmd == "ui" or cmd == "config" or cmd == "options" or cmd == "show") then
		Redeemer_ToggleUI();

	elseif (cmd == "minimap") then
		RedeemerMinimapHide = not RedeemerMinimapHide;
		Redeemer_UpdateMinimap();
		if (RedeemerMinimapHide) then
			DEFAULT_CHAT_FRAME:AddMessage("Redeemer minimap button |cffffffff[|cffff0000hidden|cffffffff] (type /redeemer minimap to show)", 0.25, 0.88, 0.88);
		else
			DEFAULT_CHAT_FRAME:AddMessage("Redeemer minimap button |cffffffff[|cff00ff00shown|cffffffff]", 0.25, 0.88, 0.88);
		end

	else
		sayText = "|cffffffff[";
		if (RedeemerDisplaySay) then
			sayText = sayText.."|cff00ff00on";
		else
			sayText = sayText.."|cffff0000off";
		end
		sayText = sayText.."|cffffffff]";
		partyText = "|cffffffff[";
		if (RedeemerDisplayParty) then
			partyText = partyText.."|cff00ff00on";
		else
			partyText = partyText.."|cffff0000off";
		end
		partyText = partyText.."|cffffffff]";
		raidText = "|cffffffff[";
		if (RedeemerDisplayRaid) then
			raidText = raidText.."|cff00ff00on";
		else
			raidText = raidText.."|cffff0000off";
		end
		raidText = raidText.."|cffffffff]";
		whisperText = "|cffffffff[";
		if (RedeemerDisplayWhisper) then
			whisperText = whisperText.."|cff00ff00on";
		else
			whisperText = whisperText.."|cffff0000off";
		end
		whisperText = whisperText.."|cffffffff]";
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer say: Toggle sending quotes to /say "..sayText, 0.25, 0.88, 0.88);
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer party: Toggle sending quotes to /party "..partyText, 0.25, 0.88, 0.88);
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer raid: Toggle sending quotes to /raid "..raidText, 0.25, 0.88, 0.88);
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer whisper: Toggle whispering quotes to target "..whisperText, 0.25, 0.88, 0.88);
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer ui: Open the options window", 0.25, 0.88, 0.88);
		DEFAULT_CHAT_FRAME:AddMessage("/redeemer minimap: Show/hide the minimap button", 0.25, 0.88, 0.88);
	end

	--DEFAULT_CHAT_FRAME:AddMessage("Command: "..cmd);

end

-- ============================================================
--  UI: options window + minimap button (native, no libraries)
-- ============================================================

function Redeemer_ToggleUI()
	local f = RedeemerConfigFrame;
	if (not f) then return; end
	if (f:IsShown()) then
		f:Hide();
	else
		f:Show();
	end
end

function Redeemer_RefreshUI()
	local f = RedeemerConfigFrame;
	if (not f) then return; end
	f.cbSay:SetChecked(RedeemerDisplaySay);
	f.cbParty:SetChecked(RedeemerDisplayParty);
	f.cbRaid:SetChecked(RedeemerDisplayRaid);
	f.cbWhisper:SetChecked(RedeemerDisplayWhisper);
end

function Redeemer_UpdateMinimap()
	local mb = RedeemerMinimapButton;
	if (not mb) then return; end
	if (RedeemerMinimapHide) then
		mb:Hide();
		return;
	end
	mb:Show();
	if (RedeemerMinimapPos == nil) then RedeemerMinimapPos = 200; end
	local angle = math.rad(RedeemerMinimapPos);
	local radius = 80;
	mb:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius);
end

function Redeemer_InitUI()
	if (RedeemerConfigFrame) then return; end  --build only once

	-- ----- options window -----
	local f = CreateFrame("Frame", "RedeemerConfigFrame", UIParent);
	f:SetWidth(250);
	f:SetHeight(230);
	f:SetPoint("CENTER");
	f:SetFrameStrata("DIALOG");
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	});
	f:SetMovable(true);
	f:EnableMouse(true);
	f:RegisterForDrag("LeftButton");
	f:SetScript("OnDragStart", function(self) self:StartMoving(); end);
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end);
	f:SetClampedToScreen(true);
	f:SetScript("OnShow", Redeemer_RefreshUI);
	f:Hide();
	tinsert(UISpecialFrames, "RedeemerConfigFrame");  --closes with Escape

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton");
	close:SetPoint("TOPRIGHT", -4, -4);

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOP", 0, -16);
	title:SetText("Redeemer");

	local sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	sub:SetPoint("TOPLEFT", 22, -48);
	sub:SetText("Send resurrection quotes to:");

	local function makeCheck(label, y)
		local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate");
		cb:SetPoint("TOPLEFT", 24, y);
		cb:SetWidth(26);
		cb:SetHeight(26);
		local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		fs:SetPoint("LEFT", cb, "RIGHT", 4, 1);
		fs:SetText(label);
		return cb;
	end

	f.cbSay     = makeCheck("Say", -70);
	f.cbParty   = makeCheck("Party", -98);
	f.cbRaid    = makeCheck("Raid", -126);
	f.cbWhisper = makeCheck("Whisper (to the rez target)", -154);

	f.cbSay:SetScript("OnClick", function(self)
		RedeemerDisplaySay = self:GetChecked() and true or false;
	end);
	f.cbParty:SetScript("OnClick", function(self)
		RedeemerDisplayParty = self:GetChecked() and true or false;
	end);
	f.cbRaid:SetScript("OnClick", function(self)
		RedeemerDisplayRaid = self:GetChecked() and true or false;
	end);
	f.cbWhisper:SetScript("OnClick", function(self)
		RedeemerDisplayWhisper = self:GetChecked() and true or false;
	end);

	local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
	hint:SetPoint("BOTTOM", 0, 18);
	hint:SetText("Quotes fire when you cast a rez spell.");

	-- ----- minimap button -----
	local mb = CreateFrame("Button", "RedeemerMinimapButton", Minimap);
	mb:SetWidth(31);
	mb:SetHeight(31);
	mb:SetFrameStrata("MEDIUM");
	mb:SetFrameLevel(8);
	mb:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	mb:RegisterForDrag("LeftButton");

	local icon = mb:CreateTexture(nil, "BACKGROUND");
	icon:SetWidth(20);
	icon:SetHeight(20);
	icon:SetTexture("Interface\\Icons\\Spell_Holy_Resurrection");
	icon:SetPoint("TOPLEFT", 7, -6);
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);

	local overlay = mb:CreateTexture(nil, "OVERLAY");
	overlay:SetWidth(53);
	overlay:SetHeight(53);
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
	overlay:SetPoint("TOPLEFT");

	mb:SetScript("OnClick", function(self, button)
		Redeemer_ToggleUI();
	end);
	mb:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:AddLine("Redeemer");
		GameTooltip:AddLine("Click: open options", 1, 1, 1);
		GameTooltip:AddLine("Drag: move this button", 1, 1, 1);
		GameTooltip:Show();
	end);
	mb:SetScript("OnLeave", function(self)
		GameTooltip:Hide();
	end);

	local function dragUpdate(self)
		local mx, my = Minimap:GetCenter();
		local px, py = GetCursorPosition();
		local scale = Minimap:GetEffectiveScale();
		px, py = px / scale, py / scale;
		RedeemerMinimapPos = math.deg(math.atan2(py - my, px - mx));
		Redeemer_UpdateMinimap();
	end
	mb:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", dragUpdate); end);
	mb:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil); end);

	Redeemer_UpdateMinimap();
	Redeemer_RefreshUI();
end

--Interface Options Panel functions
--[[
function RedeemerPanel_OnLoad(panel)

	panel.name = "Redeemer";
	panel.okay = RedeemerPanel_Okay(panel);
	panel.cancel = RedeemerPanel_Cancel(panel);
	panel.default = RedeemerPanel_Default(panel);
	InterfaceOptions_AddCategory(panel);

	RedeemerPanel_LoadSettings(panel);
]]--
--[[
	local quotesPanel = RedeemerQuotesPanel;
	quotesPanel.name = "Redeemer Quotes";
	quotesPanel.parent = "Redeemer";
	InterfaceOptions_AddCategory(quotesPanel);

	local optionsPanel = RedeemerOptionsPanel;
	optionsPanel.name = "Redeemer Options";
	optionsPanel.parent = "Redeemer";
	InterfaceOptions_AddCategory(optionsPanel);
]]--
--[[
end


function RedeemerPanel_LoadSettings(panel)

	--defaults: DisplaySay = true, DisplayParty = false, DisplayRaid = false

	Redeemer_TestVars();

	local panelName = panel:GetName();

	if (RedeemerDisplaySay == nil) then
		RedeemerDisplaySay = true;
	end

	if (RedeemerDisplayParty == nil) then
		RedeemerDisplayParty = false;
	end

	if (RedeemerDisplayRaid == nil) then
		RedeemerDisplayRaid = false;
	end

	getglobal(panelName.."CheckDisplaySay"):SetChecked(RedeemerDisplaySay);
	getglobal(panelName.."CheckDisplayParty"):SetChecked(RedeemerDisplayParty);
	getglobal(panelName.."CheckDisplayRaid"):SetChecked(RedeemerDisplayRaid);


end

function RedeemerPanel_Okay(panel)

	local panelName = panel:GetName();

	setglobal("RedeemerDisplaySay", DisplaySay);
	setglobal("RedeemerDisplayParty", DisplayParty);
	setglobal("RedeemerDisplayRaid", DisplayRaid);

	RedeemerPanel_LoadSettings(panel);

end

function RedeemerPanel_Cancel(panel)

	local panelName = panel:GetName();

		DisplaySay = nil;
		DisplayParty = nil;
		DisplayRaid = nil;

		RedeemerPanel_LoadSettings(panel);

end

function RedeemerPanel_Default(panel)

	setglobal("RedeemerDisplaySay", true);
	setglobal("RedeemerDisplayParty", false);
	setglobal("RedeemerDisplayRaid", false);

	RedeemerPanel_LoadSettings(panel);

end

function Redeemer_TestVars()

	local say;
	local party;
	local raid;

	if (RedeemerDisplaySay) then
		say = "1";
	elseif (RedeemerDisplaySay == nil) then
		say = "-";
	else
		say = "0";
	end
	if (RedeemerDisplayParty) then
		party = "1";
	elseif (RedeemerDisplayParty == nil) then
		party = "-";
	else
		party = "0";
	end
	if (RedeemerDisplayRaid) then
		raid = "1";
	elseif (RedeemerDisplayRaid == nil) then
		raid = "-";
	else
		raid = "0";
	end

	message(say..party..raid);

end
]]--