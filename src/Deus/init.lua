local Modules = {}
local Deus = shared.Deus

if Deus and type(Deus) == "function" then
    Deus = Deus()
else
    Deus = nil
end

local function __newindex()
    error("[Deus] Attempt to modify loaded module from externally")
end

local function loadModule(module)
    module = require(module)

    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__metatable = "[Deus] Locked Metatable"
    meta.__index = module
    meta.__newindex = __newindex

    return proxy, meta
end

local function registerModule(module, path)
    assert(not Modules[path], ("[Deus] Error on start, module path '%s' already exists"):format(path))

    if module.Name:lower():match("service") then
        Modules[path] = loadModule(module)
    else
        Modules[path] = module
    end
end

return function(deusSettings)
    deusSettings = deusSettings or require(script.Settings)

    if not Deus then
        Deus = {}

        function Deus:Register(addon, addonName)
            addonName = addonName or addon.Name

            if addon:IsA("ModuleScript") then
                registerModule(addon, addonName)
            else
                for _,module in pairs(addon:GetDescendants()) do
                    if module:IsA("ModuleScript") and (not module:FindFirstAncestorWhichIsA("ModuleScript") or not deusSettings.IgnoreSubmodules) then
                        local moduleName = string.split(module.Name, ".")[1]
                        registerModule(module, addonName.. ".".. moduleName)
                    end
                end
            end
        end

        function Deus:Load(path, timeout)
            local module = Modules[path]

            if not module then
                local waitStart = tick()
                repeat
                    module = Modules[path]
                    wait()
                until module or tick() - waitStart > (timeout or 10)
            end

            assert(module, "[Deus] Error finding module ".. path)

            if typeof(module) == "Instance" then
                local proxy, meta = loadModule(module)
                Modules[path] = proxy

                if meta.__index.init then
                    meta.__index.init()
                    meta.__index.init = nil
                end

                return proxy
            else
                return module
            end
        end

        if deusSettings.AttachToShared then
            shared.Deus = Deus
        end
    end

    return Deus
end