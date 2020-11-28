--Entity Component System 
--Yuuwa0519
--November 27th, 2020 

--Services
local RunService = game:GetService("RunService")

--Funcs
local function runSystem (systemArray, ranSystem, AllEntities, AllComponents, AllSystems)
    local name = systemArray.Name 
    local runBefore = systemArray.runBefore
    local queries = systemArray.queries
    local func = systemArray.func 
    local queriedValues = {}

    for _, nameOfSystemRequiredToRunBefore in pairs(runBefore) do 
        if table.find(ranSystem, nameOfSystemRequiredToRunBefore) == nil then
            for _, otherSystemArray in pairs(AllSystems) do 
                if otherSystemArray.name == nameOfSystemRequiredToRunBefore then
                    runSystem(otherSystemArray)
                end 
            end 
        end 
    end 
    
    for _, queriedComponentName in pairs(queries) do 
        for _, entityId in pairs(AllEntities) do 
            for componentName, indexes in pairs(AllComponents) do 
                if componentName == queriedComponentName then 
                    table.insert(queriedValues, indexes[entityId])
                end 
            end 
        end 
    end 

    func(table.unpack(queriedValues))
    table.insert(ranSystem, name)
end 

--Main
local ECS = {}

function ECS.newWorld(Systems) 
    --Var
    local AllEntities = {}
    local AllComponents = {}
    local AllSystems = {}
    local EntityIds = 0;

    local TaskCon

    --Modules
    local Entity = {
        Register = function(components) 
            EntityIds += 1

            local myId = EntityIds
            table.insert(AllEntities, myId)

            for name, value in pairs(components) do 
                local corresComponent = AllComponents[name]

                if corresComponent == nil then 
                    AllComponents[name] = {
                        __newindex = function(_, _, val)
                            if typeof(val) ~= typeof(value) then 
                                error("Tried to Assign Invalid Component Type!")
                            end 
                        end 
                    }
                end 

                corresComponent[myId] = value
            end 
        end;

        Remove = function(id) 
            for componentName, indexes in pairs(AllComponents) do 
                indexes[id] = nil
            end 
        end 
    }

    local System = {
        Register = function(name, runBefore, queries, func) 
            table.insert(AllSystems, {name = name, runBefore = runBefore, queries, func})
        end;
    }

    local World = {
        InitiatedTime = time();

        StopWorld = function() 
            TaskCon:Disconnect()
        end;
    }

    TaskCon = RunService.Heartbeat:Connect(function()
        local ranSystem = {}

    
        for _, thisSystem in pairs (AllSystems) do 
            runSystem(thisSystem, ranSystem, AllEntities, AllComponents, AllSystems)
        end 
    end)

    return {
        Entity = Entity;
        System = System;
        World = World;
    }
end 

return ECS