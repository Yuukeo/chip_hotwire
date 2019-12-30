ESX = nil


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		
		if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then  --is player entering a vehicle
			SetVehicleNeedsToBeHotwired(GetVehiclePedIsTryingToEnter(PlayerPedId()), false) -- disable native hotwire
		end
		
		Citizen.Wait(300) -- requires minimum of 1. larger number saves some performance if necessary
	end
	
end)

RegisterNetEvent("chip_hotwire:hotwire")
AddEventHandler("chip_hotwire:hotwire", function()
	local playerVeh = GetVehiclePedIsUsing(PlayerPedId(-1), false)

	local veh = GetVehiclePedIsIn(playerPed)
    local plate = GetVehicleNumberPlateText(veh)

	if IsPedInAnyVehicle(PlayerPedId(-1), false) then
		exports['mythic_notify']:SendAlert('inform', 'Du brukte et dirkesett')
		exports['mythic_progbar']:Progress({
			name = "firstaid_action",
			duration = 10000,
			label = "Tjuvstarter bilen...",
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "veh@plane@cuban@front@ds@base",
				anim = "hotwire",
				flags = 49,
			}
		}, function(cancelled)
			if not cancelled then
				exports['mythic_notify']:SendAlert('success', 'Du er ganske flink du')
			else
				TriggerEvent("chip_hotwire:hotwireFailed")
				exports['mythic_notify']:SendAlert('error', 'Du er en ræva tyv')
			end
		end)
		Citizen.Wait(11000)
		SetVehicleEngineOn(playerVeh, true, false, false)
		
	else
		exports['mythic_notify']:SendAlert('error', 'Du er ikke i en bil')
	end
end)

RegisterNetEvent("chip_hotwire:hotwireFailed")
AddEventHandler("chip_hotwire:hotwireFailed", function()
	local playerVeh = GetVehiclePedIsUsing(PlayerPedId(-1), false)

	if IsPedInAnyVehicle(PlayerPedId(-1), false) then 
		SetVehicleEngineOn(veh, false, true, true)
		Citizen.Wait(200)
	end
end)
