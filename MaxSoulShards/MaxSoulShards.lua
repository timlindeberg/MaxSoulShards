local f = CreateFrame("Frame")
local SOUL_SHARD_ID = 6265

MaxSoulShards_Max = 5

function GetItemsWithId(itemId)
	local items = {}
	local numItems = 0
	for bagId = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bagId) do
			local id = GetContainerItemID(bagId, slot)
			if id == itemId then
				numItems = numItems + 1
				items[numItems] = { bagId = bagId, slot = slot }
				print(bagId .. ", " .. slot)
			end
		end
	end
	return items
end

function DestroyItem(bagId, slot)
	if bagId == -1 or slot == -1 then
		return
	end
	PickupContainerItem(bagId, slot)
	if CursorHasItem() then
		DeleteCursorItem();
		print("Destroyed Soul Shard at (" .. bagId .. ", " .. slot .. ")")
	end
end

function DestroySoulShards()
	local soulShards = GetItemsWithId(SOUL_SHARD_ID)
	local numShards = table.getn(soulShards)
	print(numShards .. " / " .. MaxSoulShards_Max .. " shards")
	local shardsToDestroy = max(0, numShards - MaxSoulShards_Max)
	for i = 1, shardsToDestroy do
		local soulShard = soulShards[i]
		DestroyItem(soulShard.bagId, soulShard.slot)
	end
end	

function SlashCommand(msg)
	local max = tonumber(msg)
	if not max or max <= 0 then
		print("Usage: /maxsoulshards <number>")
		print("Current max is '" .. MaxSoulShards_Max .. "'")
		return
	end

	MaxSoulShards_Max = max
	print("Maximum number of Soul Shard's to keep is set to '" .. max .. "'")
	DestroySoulShards()
end

function f:OnEvent(event, key, state)
	print("Event: " .. event)
	if event == "PLAYER_ENTERING_WORLD" then
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("BAG_UPDATE")
	elseif event == "BAG_UPDATE" then
		DestroySoulShards()
	end
end

SLASH_MAXSOULSHARDS1 = "/maxsoulshards"

SlashCmdList["MAXSOULSHARDS"] = SlashCommand

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", f.OnEvent)
