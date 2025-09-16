Config = {}

-- [[ GERAL ]]
Config.EnableHUD = true           -- true/false: Habilita ou desabilita o menu (F10)
Config.EnableSounds = true        -- true/false: Habilita ou desabilita os sons de feedback
Config.EnablePresets = true       -- true/false: Habilita ou desabilita os presets no menu
Config.EnableNotifications = true -- true/false: Habilita ou desabilita as notificações na tela

-- [[ RESTRIÇÃO DE VEÍCULOS ]]
Config.RestrictVehicles = false   -- true: Apenas veículos na lista abaixo podem usar o drift. false: todos podem.
Config.AllowedVehicles = {        -- Lista de veículos permitidos se Config.RestrictVehicles for true (use o nome de spawn)
    "sultan",
    "elegy",
    "jester",
    "rt3000",
    "futo"
}

-- [[ TECLAS ]]
-- Visite https://docs.fivem.net/docs/game-references/controls/ para ver a lista de controles
Config.Keys = {
    ToggleKey = 311, -- K
    Hold = 21,    -- LEFT SHIFT
    Menu = 244,    -- M
    CloseMenu = 177 -- U
}

-- [[ VALORES PADRÃO DO DRIFT ]]
-- Estes são os valores que o mod usará como padrão e para o botão de reset
Config.DefaultDriftValues = {
    fTractionCurveMax = 0.1,
    fTractionCurveMin = 0.1,
    fTractionLossMult = 5.0,
    fSteeringLock = 45.0
}

-- [[ PRESETS ]]
-- Valores para os botões de preset no menu
Config.Presets = {
    Iniciante = {
        fTractionCurveMax = 0.4,
        fTractionCurveMin = 0.3,
        fTractionLossMult = 2.5,
        fSteeringLock = 40.0
    },
    Competicao = {
        fTractionCurveMax = 0.15,
        fTractionCurveMin = 0.1,
        fTractionLossMult = 6.0,
        fSteeringLock = 50.0
    },
    Showcase = {
        fTractionCurveMax = 0.05,
        fTractionCurveMin = 0.05,
        fTractionLossMult = 8.0,
        fSteeringLock = 55.0
    },
    -- Novos presets
    DriftExtremo = {
        fTractionCurveMax = 0.02,
        fTractionCurveMin = 0.01,
        fTractionLossMult = 10.0,
        fSteeringLock = 60.0
    },
    DriftSuave = {
        fTractionCurveMax = 0.3,
        fTractionCurveMin = 0.25,
        fTractionLossMult = 3.0,
        fSteeringLock = 35.0
    },
    DriftProfissional = {
        fTractionCurveMax = 0.1,
        fTractionCurveMin = 0.08,
        fTractionLossMult = 7.0,
        fSteeringLock = 52.0
    },
    DriftAgressivo = {
        fTractionCurveMax = 0.05,
        fTractionCurveMin = 0.03,
        fTractionLossMult = 9.0,
        fSteeringLock = 58.0
    },
    DriftControlado = {
        fTractionCurveMax = 0.2,
        fTractionCurveMin = 0.15,
        fTractionLossMult = 5.0,
        fSteeringLock = 45.0
    }
}