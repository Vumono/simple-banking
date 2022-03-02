bMenuOpen = false 

local isLoggedIn = false
local PlayerJob = {}
local PlayerGang = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
    SendNUIMessage({type = "refresh_accounts"})
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    PlayerJob = ESX.PlayerData.job
    SendNUIMessage({type = "refresh_accounts"})
end)



function ToggleUI()
    local charinfo = ESX.PlayerData.name
    bMenuOpen = not bMenuOpen

    if (not bMenuOpen) then
        SetNuiFocus(false, false)
    else
        ESX.TriggerServerCallback("gb-banking:GetBankData", function(data, transactions)
            local PlayerBanks = json.encode(data)


            SetNuiFocus(true, true)
            SendNUIMessage({type = 'OpenUI', accounts = PlayerBanks, transactions = json.encode(transactions), name = charinfo})
        end)
    end
end

RegisterNUICallback("CloseATM", function()
    ToggleUI()
end)

RegisterNUICallback("DepositCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if (tonumber(data.amount) <= 0) then
        return
    end
    TriggerServerEvent('gb-banking:DepositMoney', data.account, data.amount, (data.note ~= nil and data.note or ""))
    --TriggerServerEvent("gb-banking:Deposit", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("WithdrawCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    TriggerServerEvent("gb-banking:Withdraw", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("TransferCash", function(data, cb)
    if (not data or not data.account or not data.amount or not data.target) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    if(tonumber(data.target) <= 0) then
        return
    end

    TriggerServerEvent("gb-banking:Transfer", data.target, data.account, data.amount, (data.note ~= nil and data.note or ""))
end)



--// Net Events \\--
RegisterNetEvent("gb-banking:Notify")
AddEventHandler("gb-banking:Notify", function(type, msg)
    if (bMenuOpen) then
        SendNUIMessage({type = 'notification', msg_type = type, message = msg})
    end
end)

RegisterNetEvent("gb-banking:UpdateTransactions")
AddEventHandler("gb-banking:UpdateTransactions", function(transactions)
    if (bMenuOpen) then

        SendNUIMessage({type = 'update_transactions', transactions = json.encode(transactions)})

        ESX.TriggerServerCallback("gb-banking:GetBankData", function(data, transactions)
            local PlayerBanks = json.encode(data)
            SendNUIMessage({type = "refresh_balances", accounts = PlayerBanks})
        end)
    end
end)
