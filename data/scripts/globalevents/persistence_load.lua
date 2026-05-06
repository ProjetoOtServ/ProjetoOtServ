-- persistence_load.lua
-- Carrega itens construídos persistentes na inicialização do servidor

local startupEvent = GlobalEvent("persistenceLoad")

function startupEvent.onStartup()
    -- Aguarda um pequeno delay para garantir que o mapa e db estejam totalmente prontos
    addEvent(function()
        PersistenceManager.loadAll()
    end, 1000)
    return true
end

startupEvent:register()
