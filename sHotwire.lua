ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterUsableItem("lockpick", function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem("lockpick", 1)
	
	TriggerClientEvent('chip_hotwire:hotwire', source)
end)
