-- [[ FUNÇÕES AUXILIARES ]]
-- Função para copiar tabelas (usado para salvar e restaurar valores)
function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- [[ VARIÁVEIS DE ESTADO ]]
local originalHandling = {}
local currentVehicle = nil
local isDriftToggled = false
local isDriftHolding = false
local isDriftActive = false
local isMenuOpen = false
local currentDriftValues = table.copy(Config.DefaultDriftValues)
local toggleKey = Config.Keys.ToggleKey

-- [[ FUNÇÕES DE FEEDBACK E VERIFICAÇÃO ]]
function ShowNotification(text)
    if not Config.EnableNotifications then return end
    -- Verificação para ESX (se existir, usa o sistema dele, senão, usa o padrão)
    if GetResourceState('es_extended') == 'started' and ESX and ESX.ShowNotification then
        ESX.ShowNotification(text)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
end

function PlaySound(sound)
    if not Config.EnableSounds then return end
    PlaySoundFrontend(-1, sound, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

function isVehicleAllowed(vehicle)
    if not Config.RestrictVehicles then return true end
    local model = GetEntityModel(vehicle)
    for _, allowedModel in ipairs(Config.AllowedVehicles) do
        if model == GetHashKey(allowedModel) then
            return true
        end
    end
    return false
end

-- [[ LÓGICA DE DRIFT ]]
function ApplyDrift(vehicle, values)
    if not DoesEntityExist(vehicle) then return end
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', values.fTractionCurveMax)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', values.fTractionCurveMin)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionLossMult', values.fTractionLossMult)
    isDriftActive = true
end

function RestoreOriginalHandling(vehicle)
    if not DoesEntityExist(vehicle) or not originalHandling[vehicle] then return end
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', originalHandling[vehicle].fTractionCurveMax)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', originalHandling[vehicle].fTractionCurveMin)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionLossMult', originalHandling[vehicle].fTractionLossMult)
    isDriftActive = false
    originalHandling[vehicle] = nil -- Limpa os dados salvos para este veículo
end

function UpdateDriftStatus()
    if not currentVehicle then return end

    local shouldBeActive = isDriftToggled or isDriftHolding
    
    if shouldBeActive and not isDriftActive then
        ApplyDrift(currentVehicle, currentDriftValues)
    elseif not shouldBeActive and isDriftActive then
        -- Quando desativamos, restauramos o handling original salvo na entrada do veículo
        -- Não precisamos regravar os valores, pois eles já estão salvos em `originalHandling`
        if DoesEntityExist(currentVehicle) and originalHandling[currentVehicle] then
            SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionCurveMax', originalHandling[currentVehicle].fTractionCurveMax)
            SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionCurveMin', originalHandling[currentVehicle].fTractionCurveMin)
            SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionLossMult', originalHandling[currentVehicle].fTractionLossMult)
            isDriftActive = false
        end
    end
end

-- [[ INTERFACE (NUI) ]]
function SetMenuState(state)
    isMenuOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = 'updateVisibility',
        status = state,
        config = {
            enablePresets = Config.EnablePresets
        },
        currentValues = currentDriftValues,
        driftStatus = {
            toggle = isDriftToggled,
            hold = isDriftHolding
        }
    })
end

RegisterNUICallback('closeMenu', function(_, cb)
    SetMenuState(false)
    cb('ok')
end)

RegisterNUICallback('updateValue', function(data, cb)
    if data.id and data.value then
        currentDriftValues[data.id] = tonumber(data.value)
        if isDriftActive then
            ApplyDrift(currentVehicle, currentDriftValues)
        end
    end
    cb('ok')
end)

RegisterNUICallback('applyPreset', function(data, cb)
    if data.preset and Config.Presets[data.preset] then
        currentDriftValues = table.copy(Config.Presets[data.preset])
        if isDriftActive then
            ApplyDrift(currentVehicle, currentDriftValues)
        end
        SendNUIMessage({ action = 'updateSliders', values = currentDriftValues })
    end
    cb('ok')
end)

RegisterNUICallback('resetDefaults', function(_, cb)
    currentDriftValues = table.copy(Config.DefaultDriftValues)
    if isDriftActive then
        ApplyDrift(currentVehicle, currentDriftValues)
    end
    SendNUIMessage({ action = 'updateSliders', values = currentDriftValues })
    cb('ok')
end)

RegisterNUICallback('setKey', function(data, cb)
    if data.key then
        toggleKey = tonumber(data.key)
        ShowNotification("Tecla de Toggle redefinida para a sessão atual.")
    end
    cb('ok')
end)


-- [[ THREAD PRINCIPAL E EVENTOS ]]
CreateThread(function()
    while true do
        Wait(0) -- Usar Wait(0) é aceitável quando a lógica interna é bem controlada.
        
        local playerPed = PlayerPedId()
        local isInVehicleNow = IsPedInAnyVehicle(playerPed, false)
        
        -- Lógica do MENU (F10) - funciona sempre
        if Config.EnableHUD and IsControlJustReleased(0, Config.Keys.Menu) then
            SetMenuState(not isMenuOpen)
        end

        -- VERIFICA SE O JOGADOR ENTROU/SAIU/TROCOU DE VEÍCULO
        if isInVehicleNow and not currentVehicle then -- ENTROU NO VEÍCULO
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            currentVehicle = vehicle
            isDriftToggled = false

            if isVehicleAllowed(currentVehicle) then
                originalHandling[currentVehicle] = {
                    fTractionCurveMax = GetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionCurveMax'),
                    fTractionCurveMin = GetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionCurveMin'),
                    fTractionLossMult = GetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionLossMult')
                }
            else
                ShowNotification("Este veículo não é compatível com o mod de drift.")
            end

        elseif not isInVehicleNow and currentVehicle then -- SAIU DO VEÍCULO
            RestoreOriginalHandling(currentVehicle)
            currentVehicle = nil
            isDriftToggled = false
            isDriftHolding = false
        end

        -- Se estiver em um veículo permitido, verifica os controles de drift
        if currentVehicle and isVehicleAllowed(currentVehicle) then
            
            -- Lógica de TOGGLE (K)
            if IsControlJustReleased(0, toggleKey) and not isMenuOpen then
                isDriftToggled = not isDriftToggled
                if isDriftToggled then
                    PlaySound("ON")
                    ShowNotification("Drift Mode: ~g~ON~w~ (Toggle)")
                else
                    PlaySound("OFF")
                    ShowNotification("Drift Mode: ~r~OFF~w~")
                end
                UpdateDriftStatus() -- CHAMADA IMEDIATA APÓS MUDAR ESTADO
            end

            -- Lógica de HOLD (Shift)
            local isHoldingNow = IsControlPressed(0, Config.Keys.Hold)
            if not isDriftToggled then
                if isHoldingNow and not isDriftHolding then
                    isDriftHolding = true
                    UpdateDriftStatus() -- CHAMADA IMEDIATA
                elseif not isHoldingNow and isDriftHolding then
                    isDriftHolding = false
                    UpdateDriftStatus() -- CHAMADA IMEDIATA
                end
            else
                if isDriftHolding then -- Garante que o hold seja desativado se o toggle for ligado
                    isDriftHolding = false
                    UpdateDriftStatus()
                end
            end
            
            -- Atualiza o status no NUI se estiver aberto
            if isMenuOpen then
                SendNUIMessage({ 
                    action = 'updateStatus', 
                    driftStatus = { toggle = isDriftToggled, hold = isDriftHolding }
                })
            end
        end
    end
end)

-- Evento para garantir a restauração quando o recurso para
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if currentVehicle and DoesEntityExist(currentVehicle) then
            RestoreOriginalHandling(currentVehicle)
            print("[DriftMod2.0] Handling original restaurado com segurança.")
        end
    end
end)

-- Adiciona verificação de ESX para notificações
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        while not ESX do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(100)
        end
    end
end)