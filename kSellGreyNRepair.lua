--[[
Name: Auto Sell Grey & Repair
Description: Sells grey items and repairs your items using guild funds if possible

Copyright 2017 Mateusz Kasprzak

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local function OnEvent(self, event)
	-- Auto Sell Grey Items
    if C_MerchantFrame.GetNumJunkItems() > 0 then
		local totalPrice = GetMoney()
        C_MerchantFrame.SellAllJunkItems()
		-- It takes a second for GetMoney() to register the change in money after the PLAYER_MONEY event happens
		-- So we use this timer to wait 1 and then report the result of our junk item sell.
		C_Timer.After(1, function ()
			totalPrice = GetMoney() - totalPrice
			self:Print("Items were sold for "..C_CurrencyInfo.GetCoinTextureString(totalPrice))
		end)
    end

	-- Auto Repair
	if (CanMerchantRepair()) then	
		repairAllCost, canRepair = GetRepairAllCost();
		-- If merchant can repair and there is something to repair
		if (canRepair and repairAllCost > 0) then
			costTextureString = GetCoinTextureString(repairAllCost);
			-- Use Guild Bank
			guildRepairedItems = false
			if (IsInGuild() and CanGuildBankRepair()) then
				-- Checks if guild has enough money
				local amount = GetGuildBankWithdrawMoney()
				local guildBankMoney = GetGuildBankMoney()
				amount = amount == -1 and guildBankMoney or min(amount, guildBankMoney)

				if (amount >= repairAllCost) then
					RepairAllItems(true);
					guildRepairedItems = true
					DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired by your Guild for "..costTextureString, 255, 255, 255)
				end
			end
			
			-- Use own funds
			if (repairAllCost <= GetMoney() and not guildRepairedItems) then
				RepairAllItems(false);
				DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired for "..costTextureString, 255, 255, 255)
			end
		end
	end
end


local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent);
f:RegisterEvent("MERCHANT_SHOW");
