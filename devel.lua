GBLC = LibStub("AceAddon-3.0"):NewAddon("GBLC", "AceConsole-3.0", "AceEvent-3.0")
FrameText = ''

function GBLC:OnInitialize()

	---------------------------------------
	-- Global variable initialization
	---------------------------------------

	self.db = LibStub("AceDB-3.0"):New("GuildBankListCreatorDb", defaults)
	GBLC:RegisterChatCommand('gblc', 'HandleChatCommand');

	if (ListLimiter == nil) then
		ListLimiter = 0
	end
	
	if (ShowLinks == nil) then
		ShowLinks = true
	end
	
	if (StackItems == nil) then
		StackItems = false
	end

	if (UseCSV == nil) then
		UseCSV = false
	end
	
	if (ExcludeList == nil) then
		ExcludeList = {}
	end
	
end

function GBLC:BoolText(input)

	---------------------------------------
	-- Make string Title Case
	---------------------------------------

	local booltext = 'False'

	if (input) then
		booltext = 'True'
	end
	
	return booltext
end

function GBLC:ClearFrameText()
	FrameText = ''
end

function GBLC:AddLine(linetext)
	FrameText = FrameText .. linetext .. '\n'
end

function GBLC:HandleChatCommand(input)

	---------------------------------------
	-- Main chat command handler function
	---------------------------------------

	local lcinput = string.lower(input)
	local gotcommands = false

	---------------------------------------
	-- Display help
	---------------------------------------

	if (string.match(lcinput, "help")) then
		GBLC:ClearFrameText()
--		GBLC:AddLine('OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO')
		GBLC:AddLine('Guild Bank List Creator Help')
		GBLC:AddLine('Usage:')
		GBLC:AddLine('/gblc             -- Creates list of items')
		GBLC:AddLine('/gblc status      -- Shows addon settings and exclusions')
		GBLC:AddLine('/gblc limit (number)')
		GBLC:AddLine('                  -- Sets a character limit on(number) to')
		GBLC:AddLine('                  -- split the list with extra linefeed.')
		GBLC:AddLine('                  -- This is useful when you paste the')
		GBLC:AddLine('                  -- list to Discord which limits post')
		GBLC:AddLine('                  -- lengths to 2000 characters.')
		GBLC:AddLine('                  -- Set limit to 0 if you don\'t')
		GBLC:AddLine('                  -- want to get linefeed splits')
		GBLC:AddLine('/gblc nolimit     -- Same as limit 0')	
		GBLC:AddLine('/gblc links true  -- Shows Wowhead links on each item')
		GBLC:AddLine('/gblc links false -- No Wowhead links on any items')
		GBLC:AddLine('/gblc stack true  -- Combines items with same name')
		GBLC:AddLine('/gblc stack false -- Shows individual items')
		GBLC:AddLine('/gblc csv true    -- Output in CSV format')
		GBLC:AddLine('/gblc csv false   -- Output in original format')
		GBLC:AddLine('/gblc exclude item name (count)')
		GBLC:AddLine('                  -- Excludes (count) number of items')
		GBLC:AddLine('                  -- from the list. If no number is')
		GBLC:AddLine('                  -- provided the count is 1.')
		GBLC:AddLine('/gblc exclude id itemID (count)')
		GBLC:AddLine('                  -- Excludes (count) items from the list.')
		GBLC:AddLine('                  -- If there\'s no number, count is 1.')
		GBLC:AddLine('/gblc include item name (count)')
		GBLC:AddLine('                  -- Includes (count) items to the list')
		GBLC:AddLine('                  -- from the exclusion list. If there\'s')
		GBLC:AddLine('                  -- no number, count is 1.')
		GBLC:AddLine('/gblc include id itemID (count)')
		GBLC:AddLine('                  -- Includes (count) items to the list')
		GBLC:AddLine('                  -- from the exclusion list. If no number')
		GBLC:AddLine('                  -- is provided the count is 1.')
		GBLC:AddLine('/gblc clearitem item name')
		GBLC:AddLine('                  -- Clears an item from the exclusion')
		GBLC:AddLine('                  -- list.')
		GBLC:AddLine('/gblc clearitem id itemID')
		GBLC:AddLine('                  -- Clears an item from the exclusion')
		GBLC:AddLine('                  -- list.')
		GBLC:AddLine('/gblc clearlist   -- Clears the exclusion list.')
		GBLC:DisplayExportString(FrameText)
		GBLC:ClearFrameText()
		gotcommands = true
	end
	
	---------------------------------------
	-- Clear exclusion list
	---------------------------------------

	if (string.match(lcinput, "clearlist")) then
		GBLC:Print('Clearing exclusion list')
		for eitemID, ecount in pairs(ExcludeList) do
			GBLC:RemoveItem(eitemID)
		end
		ExcludeList = nil
		ExcludeList = {}
		GBLC:Print('Exclusion list cleared')
		gotcommands = true
	end

	---------------------------------------
	-- Clear item from exclusion list
	---------------------------------------

	if (string.match(lcinput, "clearitem")) then

		if (string.match(lcinput, "clearitem id ")) then
			local eitemid = tonumber(string.match(lcinput, "clearitem id (%d+)"))
			GBLC:RemoveItem(eitemid)
			GBLC:Print('Removed ' .. GBLC:GetItemLink(eitemid) .. ' from exclusion list.')
		else
			local ename = GBLC:WordCase(string.match(lcinput, "clearitem ([%w%s]+)"))
			ename = string.gsub(ename, "^ ", "")
			local itemID = GBLC:GetItemID(ename)
			local sLink = GBLC:GetItemLink(ename)
			if itemID == nil then
				GBLC:Print( "'" .. ename .. "'" .. ' does not exist.')
			else
				GBLC:RemoveItem(itemID)
			end
		end
		gotcommands = true
	end

	---------------------------------------
	-- Display status
	---------------------------------------
	
	if (string.match(lcinput, "status")) then
	
		GBLC:ClearFrameText()
		GBLC:AddLine('Guild Bank List Creator Status\n')
		GBLC:AddLine('Character limit: ' .. ListLimiter)
		GBLC:AddLine('Show Wowhead links: ' .. GBLC:BoolText(ShowLinks))
		GBLC:AddLine('Combine items to stacks: ' .. GBLC:BoolText(StackItems))
		if (not UseCSV) then
			GBLC:AddLine('Output CSV: ' .. GBLC:BoolText(UseCSV))
		else
			GBLC:AddLine('Output CSV: ' .. GBLC:BoolText(UseCSV) .. '. The character limiter is off.')
		end
		if ExcludeList ~= nil then

			GBLC:AddLine('\nExcluded items:')
			local excludeTable = {}
			local eic = 0
			for eitemID, ecount in pairs(ExcludeList) do
				eic = eic + 1
				local sName = GBLC:GetItemName(eitemID)
				excludeTable[eic] = sName .. ' (' .. ecount .. ')'
			end
			
			table.sort(excludeTable)
			
			for i=1 , #excludeTable do
				GBLC:AddLine(excludeTable[i])
			end

		end
		GBLC:DisplayExportString(FrameText)
		GBLC:ClearFrameText()
		
		gotcommands = true
	end

	---------------------------------------
	-- Exclude / include items
	---------------------------------------

	if (string.match(lcinput, "exclude")) then
		local ecount = nil
		local eitemid = nil
		local ename = ''

		if (string.match(lcinput, "exclude id ")) then

			---------------------------------------
			-- Exclude with itemID
			---------------------------------------

			eitemid = tonumber(string.match(lcinput, "exclude id (%d+)"))
			ecount = tonumber(string.match(lcinput, "exclude id %d+ (%d+)"))
			
			if ecount == nil then
				ecount = 1
			end
			
			local itemID = GBLC:GetItemID(eitemid)
			local sLink = GBLC:GetItemLink(eitemid)

			if itemID == nil then
				GBLC:Print( "ItemID " .. eitemid .. ' does not exist.')
			else
				GBLC:Print('Adding ' .. ecount .. ' ' .. sLink .. ' to the exclude list.')
				GBLC:ExcludeList(itemID, ecount)
			end
		else

			---------------------------------------
			-- Exclude with itemName
			---------------------------------------

			ecount = tonumber(string.match(lcinput, "exclude [%w%s]+(%d+)"))

			if ecount == nil then
				ecount = 1
			end

			ename = GBLC:WordCase(string.match(lcinput, "exclude ([%w%s]+)"))
			ename = string.gsub(ename, "^ ", "")
			local itemID = GBLC:GetItemID(ename)
			local sLink = GBLC:GetItemLink(ename)
			if itemID == nil then
				GBLC:Print( "'" .. ename .. "'" .. ' does not exist.')
			else
				GBLC:Print('Adding ' .. ecount .. ' ' .. sLink .. ' to the exclude list.')
				GBLC:ExcludeList(itemID, ecount)
			end
		end
		gotcommands = true
	end

	if (string.match(lcinput, "include")) then

		if (string.match(lcinput, "include id ")) then

			---------------------------------------
			-- Include with itemID
			---------------------------------------

			eitemid = tonumber(string.match(lcinput, "include id (%d+)"))
			ecount = tonumber(string.match(lcinput, "include id %d+ (%d+)"))
			
			if ecount == nil then
				ecount = 1
			end
			
			local itemID = GBLC:GetItemID(eitemid)
			local sLink = GBLC:GetItemLink(eitemid)

			if itemID == nil then
				GBLC:Print( "ItemID " .. eitemid .. ' does not exist.')
			else
				GBLC:Print('Removing ' .. ecount .. ' ' .. sLink .. ' from the exclude list.')
				GBLC:IncludeList(itemID, ecount)
			end
		else

			---------------------------------------
			-- Include with itemName
			---------------------------------------

			ecount = tonumber(string.match(lcinput, "include [%w%s]+(%d+)"))

			if ecount == nil then
				ecount = 1
			end

			ename = GBLC:WordCase(string.match(lcinput, "include ([%w%s]+)"))
			ename = string.gsub(ename, "^ ", "")
			local itemID = GBLC:GetItemID(ename)
			local sLink = GBLC:GetItemName(ename)
			if itemID == nil then
				GBLC:Print( "'" .. ename .. "'" .. ' does not exist.')
			else
				GBLC:Print('Removing ' .. ecount .. ' ' .. sLink .. ' from the exclude list.')
				GBLC:IncludeList(itemID, ecount)
			end
		end
		gotcommands = true
	end

	---------------------------------------
	-- Set limit
	---------------------------------------

	if (string.match(lcinput, "limit")) then
		local snumbers = tonumber(string.match(lcinput, "limit (%d+)"))
		
		if (string.match(lcinput, "nolimit")) then
			snumbers = 0
		end
		
		if ((snumbers > 0) and (snumbers < 150)) then
			GBLC:Print('Limiter number too low. Setting to 500.')
			snumbers = 500
		end
		ListLimiter = snumbers
		GBLC:Print('Setting character limit to ' .. ListLimiter)
		gotcommands = true
	end
	
	---------------------------------------
	-- Enable or disable Wowhead links
	---------------------------------------

	if (string.match(lcinput, "links true")) then
		GBLC:Print('Showing Wowhead links')
		ShowLinks = true
		gotcommands = true
	end
	
	if (string.match(lcinput, "links false")) then
		GBLC:Print('Hiding Wowhead links')
		ShowLinks = false
		gotcommands = true
	end

	---------------------------------------
	-- Enable or disable stacking items
	---------------------------------------
	
	if (string.match(lcinput, "stack true")) then
		GBLC:Print('Combining items of same name to stacks')
		StackItems = true
		gotcommands = true
	end
	
	if (string.match(lcinput, "stack false")) then
		GBLC:Print('Showing individual items')
		StackItems = false
		gotcommands = true
	end

	---------------------------------------
	-- Enable or disable CSV format
	---------------------------------------

	if (string.match(lcinput, "csv true")) then
		GBLC:Print('Printing list in CSV format. The character limiter is now off.')
		UseCSV = true
		gotcommands = true
	end
	
	if (string.match(lcinput, "csv false")) then
		GBLC:Print('Printing list in user readable format')
		UseCSV = false
		gotcommands = true
	end

	---------------------------------------
	-- Generate list
	---------------------------------------

	if (not gotcommands) then
		local bags = GBLC:GetBags()
		local bagItems = GBLC:GetBagItems()
		local itemlistsort = {}
		local wowheadlink = ''
		local copper = GetMoney()
		local moneystring = (("%dg %ds %dc"):format(copper / 100 / 100, (copper / 100) % 100, copper % 100));
		local gametimehours, gametimeminutes = GetGameTime()
		local texthours = string.format("%02d", gametimehours)
		local textminutes = string.format("%02d", gametimeminutes)

		---------------------------------------
		-- Generate output normal or CSV format 
		-- depending on user settings
		---------------------------------------

		GBLC:ClearFrameText()

		if (not UseCSV) then
			GBLC:AddLine('Bank list updated on ' .. date("%d.%m.%Y ") .. texthours .. '.' .. textminutes .. ' server time\nCharacter: ' .. UnitName('player') .. '\nGold: ' .. moneystring .. '\n')
		else
			GBLC:AddLine(date("%d.%m.%Y") .. ',' .. texthours .. '.' .. textminutes .. ',' .. UnitName('player') .. ',' .. moneystring)
		end
		
		local exportLength = string.len(FrameText)
		local antii = 0

		for i=1, #bagItems do
		
			local finalCount = 0
			
			wowheadlink = GBLC:WowheadLink(bagItems[i].itemID)
			
			if (ExcludeList[bagItems[i].itemID] == nil) then
				finalCount = bagItems[i].count
			else
				finalCount = bagItems[i].count - ExcludeList[bagItems[i].itemID]			
			end

		---------------------------------------
		-- Add item to list if finalCount is 
		-- larger than zero. In case of nothing
		-- to add, we need to backtrack a step
		-- on the next time we're adding stuff
		---------------------------------------

			if not UseCSV then
				if finalCount > 0 then
					itemlistsort[(i-antii)] = bagItems[i].itemName .. ' (' .. finalCount .. ')' .. wowheadlink
				end
			else
				if finalCount > 0 then
					itemlistsort[(i-antii)] = bagItems[i].itemName .. ',' .. finalCount .. ',' .. wowheadlink
				end
			end

			if finalCount <= 0 then
				antii = antii + 1
			end
		end

		table.sort(itemlistsort);

		for i=1, #itemlistsort do
			if ((ListLimiter > 0) and (not UseCSV)) then
				if ((exportLength + string.len(itemlistsort[i])) > ListLimiter) then
					GBLC:AddLine('\nList continued')
					exportLength = 0
				end
			end
			GBLC:AddLine(itemlistsort[i])
			exportLength = exportLength + string.len(itemlistsort[i])
		end

		local enumber = 0
		for eitemID, ecount in pairs(ExcludeList) do
			if ((eitemID ~= nil) and (eitemID > 0)) then
				enumber = enumber + 1
			end
		end
		
		if enumber > 0 then

			GBLC:AddLine('\nExcluded items')
			exportLength = 0
			local eic = 0
			local excludeTable = {}

			for eitemID, ecount in pairs(ExcludeList) do

				eic = eic +1
				local excludeString = ''
				local sName = GBLC:GetItemName(eitemID)
				wowheadlink = GBLC:WowheadLink(eitemID)

				if not UseCSV then
					excludeTable[eic] = sName .. ' (' .. ecount .. ')' .. wowheadlink
				else
					excludeTable[eic] = sName .. ',' .. ecount .. ',' .. wowheadlink ..','
				end
			end
			
			table.sort(excludeTable)

			for i=1 , #excludeTable do
			
				if ((ListLimiter > 0) and (not UseCSV)) then
					if ((exportLength + string.len(excludeTable[i])) > ListLimiter) then
						GBLC:AddLine('\nList continued')
						exportLength = 0
					end
				end

				GBLC:AddLine(excludeTable[i])

			end

		end

		GBLC:DisplayExportString(FrameText, true)
		GBLC:ClearFrameText()

	end

end

function GBLC:GetItemName(eitemID)

	---------------------------------------
	-- Get Item Name with itemID
	---------------------------------------

	local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(eitemID)
	if sName == nil then
		sName = 'Unseen item with ID ' .. eitemID
	end

	return sName
end

function GBLC:GetItemLink(eitemID)

	---------------------------------------
	-- Get Item Link with itemID
	---------------------------------------

	local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(eitemID)
	if sLink == nil then
		sLink = 'Unseen item with ID ' .. eitemID
	end
	return sLink
end

function GBLC:GetItemID(eitemName)

	---------------------------------------
	-- Get ItemID with item name
	---------------------------------------

	local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(eitemName)
	return itemID
end

function GBLC:WowheadLink(witemID)

	---------------------------------------
	-- Create Wowhead link
	---------------------------------------

	local wowheadlink = ''
	
	if ((ShowLinks) and (witemID ~= nil)) then
		wowheadlink = 'https://classic.wowhead.com/item=' .. witemID
		if (not UseCSV) then
			wowheadlink = '    ' .. wowheadlink
		end
	end

	return wowheadlink
end

function GBLC:WordCase(instring)

	---------------------------------------
	-- Make String Title Case
	---------------------------------------

	local function tchelper(first, rest)
		return first:upper()..rest:lower()
	end

	local newstring = ' ' .. string.gsub(instring, "(%a)([%w_']*)", tchelper)
	newstring = string.gsub(newstring, "^%s+", "") -- just in case there's extra spaces at the start of the string

	return newstring
end

function GBLC:ExcludeList(eitemID, ecount)

	---------------------------------------
	-- Add item count to exclude list
	---------------------------------------

	if (ExcludeList[eitemID] == nil) then
		ExcludeList[eitemID] = ecount
	else
		ExcludeList[eitemID] = ExcludeList[eitemID] + ecount
	end

	return true
end

function GBLC:RemoveItem(eitemID)

	---------------------------------------
	-- Remove item from exclude list
	---------------------------------------

	GBLC:IncludeList(eitemID, 0, true)
end

function GBLC:IncludeList(eitemID, ecount, etrash)

	---------------------------------------
	-- Remove item count from exclude list
	---------------------------------------

	if (ExcludeList[eitemID] == nil) then
		GBLC:Print('There is no itemID ' .. eitemID .. ' in the exclude list')
		return false
	else
		ExcludeList[eitemID] = ExcludeList[eitemID] - ecount
	end

	if (ExcludeList[eitemID] >= 0) then
		GBLC:Print('Exclusion ' .. GBLC:GetItemLink(eitemID) .. ' count reached zero. Removing entry.')
		ExcludeList[eitemID] = nil
		table.remove(ExcludeList, eitemID)
	end
	
	if (etrash) then
		if (ExcludeList[eitemID] >= 0) then
			GBLC:Print('Removing ' .. GBLC:GetItemLink(eitemID) .. ' from the exclusion list.')
			ExcludeList[eitemID] = nil
			table.remove(ExcludeList, eitemID)
		end
	end

	return true
end

function GBLC:GetBags()

	---------------------------------------
	-- Get list of character bags
	---------------------------------------

	local bags = {}

	for container = -1, 12 do
		bags[#bags + 1] = {
			container = container,
			bagName = GetBagName(container)
		}
	end

	return bags;
end

function GBLC:GetBagItems()

	---------------------------------------
	-- Get list of items in the character bags
	---------------------------------------

	local bagItems = {}

	for container = -1, 12 do
		local numSlots = GetContainerNumSlots(container)

		for slot=1, numSlots do
			local texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(container, slot)

			if itemID then
				local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(itemID)
				local stacked = false
				
				if ((StackItems) and (#bagItems > 0)) then
					for stackitem = 1, #bagItems do
						if (bagItems[stackitem].itemID == itemID) then
							bagItems[stackitem].count = bagItems[stackitem].count + count
							stacked = true
							break
						end
					end
				end

				if (not stacked) then
					bagItems[#bagItems + 1] = {					
						itemName = sName,
						itemID = itemID,
						count = count
					}
				end
			end
		end
	end

	return bagItems
end

function GBLC:DisplayExportString(str,highlight)

	---------------------------------------
	-- Display the main frame with list
	---------------------------------------

	gblcFrame:Show();
	gblcFrameScroll:Show()
	gblcFrameScrollText:Show()
	gblcFrameScrollText:SetText(str)
	
	if highlight then
		gblcFrameScrollText:HighlightText()
	end
	
	gblcFrameScrollText:SetScript('OnEscapePressed', function(self)
		gblcFrame:Hide();
		end
	);
	
	gblcFrameButton:SetScript("OnClick", function(self)
		gblcFrame:Hide();
		end
	);
end
