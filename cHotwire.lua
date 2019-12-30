ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local hotwiring = false

Citizen.CreateThread(function()
	while true do
		
		if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then  --is player entering a vehicle
			SetVehicleNeedsToBeHotwired(GetVehiclePedIsTryingToEnter(PlayerPedId()), false) -- disable native hotwire
		end
		
		Citizen.Wait(300) -- requires minimum of 1. larger number saves some performance if necessary
	end
	
end)
local vehicle
function disableEngine()
	Citizen.CreateThread(function()
		while hotwiring do
			SetVehicleEngineOn(vehicle, false, true, false)
			if not hotwiring then
				break
			end
			Citizen.Wait(0)
		end
	end)
end


--[[ Main Thread --]]
Citizen.CreateThread(function()
	local player_entity = PlayerPedId()
	while true do
		Citizen.Wait(0)
		if GetSeatPedIsTryingToEnter(player_entity) == -1 then
	        Citizen.Wait(10)
			vehicle = GetVehiclePedIsTryingToEnter(player_entity)
			if IsVehicleNeedsToBeHotwired(vehicle) then
				disableEngine()
				hotwiring = true
				Citizen.Wait(7000)
				ClearPedTasks(player_entity)
			end
		end
	end
end)


RegisterNetEvent("chip_hotwire:hotwire")
AddEventHandler("chip_hotwire:hotwire", function()

	
	local playerVeh = GetVehiclePedIsUsing(PlayerPedId(-1), false)

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
                hotwiring = false
                SetVehicleEngineOn(playerVeh, true, false, false)
			else
				TriggerEvent("chip_hotwire:hotwireFailed")
				exports['mythic_notify']:SendAlert('error', 'Du er en ræva tyv')
			end
		end)	
	else
		exports['mythic_notify']:SendAlert('error', 'Du er ikke i en bil')
	end
end)

RegisterNetEvent("chip_hotwire:hotwireFailed")
AddEventHandler("chip_hotwire:hotwireFailed", function()
	local playerVeh = GetVehiclePedIsUsing(PlayerPedId(-1), false)

	if IsPedInAnyVehicle(PlayerPedId(-1), false) then 
		SetVehicleEngineOn(playerVeh, false, true, true)
		Citizen.Wait(200)
	end
end)
