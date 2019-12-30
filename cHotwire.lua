ESX = nil

local trackedVehicles = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('chip_hotwire:forceTurnOver')
AddEventHandler('chip_hotwire:forceTurnOver', function(vehicle)
	local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed)
    local plate = GetVehicleNumberPlateText(vehicle)
    TrackVehicle(plate, vehicle)
    trackedVehicles[plate].canTurnOver = true
end)

RegisterNetEvent("chip_hotwire:hotwire")
AddEventHandler("chip_hotwire:hotwire", function()
	local playerVeh = GetVehiclePedIsUsing(PlayerPedId(-1), false)

	local veh = GetVehiclePedIsIn(playerPed)
    local plate = GetVehicleNumberPlateText(veh)

	if IsPedInAnyVehicle(PlayerPedId(-1), false) then
		exports['mythic_notify']:SendAlert('inform', 'Du brukte et Hotwire-Kit')
		exports['mythic_progbar']:Progress({
			name = "firstaid_action",
			duration = 10000,
			label = "Bruker hotwire-kit...",
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
	local playerVeh = GetVehiclePedIsUsing(player, false)

	if IsPedInAnyVehicle(PlayerPedId(-1), false) then 
		SetVehicleEngineOn(veh, false, true, true)
		Citizen.Wait(200)
	end
end)


function TrackVehicle(plate, vehicle)
    if trackedVehicles[plate] == nil then
        trackedVehicles[plate] = {}
        trackedVehicles[plate].vehicle = vehicle
        trackedVehicles[plate].canTurnOver = false
    end
end


--Disable All Cars Not tracked or Turned over
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(trackedVehicles) do
            if not v.state == 0 then
                SetVehicleEngineOn(v.vehicle, false, false)
            elseif v.state == 1 then
                SetVehicleEngineOn(v.vehicle, true, false)
                v.state = -1
            end
        end
    end
end)
