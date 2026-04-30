local MushaTasks = {}

local function GetStore(inst)
    if inst.musha_taskstore == nil then
        inst.musha_taskstore =
        {
            tasks = {},
            events = {},
            worldstates = {},
        }
    end
    return inst.musha_taskstore
end

local function InstallCleanup(inst)
    if inst == nil or inst.musha_task_cleanup_installed then
        return
    end

    inst.musha_task_cleanup_installed = true
    local old_onremove = inst.OnRemoveEntity
    inst.OnRemoveEntity = function(inst)
        MushaTasks.ClearAll(inst)
        if old_onremove ~= nil then
            old_onremove(inst)
        end
    end
end

function MushaTasks.CancelTask(inst, name)
    local store = inst ~= nil and inst.musha_taskstore or nil
    local task = store ~= nil and store.tasks[name] or nil
    if task ~= nil then
        task:Cancel()
        store.tasks[name] = nil
    end
end

function MushaTasks.Periodic(inst, name, interval, fn, initialdelay, ...)
    if inst == nil or name == nil or fn == nil then
        return nil
    end

    InstallCleanup(inst)
    local store = GetStore(inst)
    MushaTasks.CancelTask(inst, name)
    store.tasks[name] = inst:DoPeriodicTask(interval, fn, initialdelay, ...)
    return store.tasks[name]
end

function MushaTasks.Delay(inst, name, delay, fn, ...)
    if inst == nil or name == nil or fn == nil then
        return nil
    end

    InstallCleanup(inst)
    local store = GetStore(inst)
    MushaTasks.CancelTask(inst, name)

    local args = { ... }
    store.tasks[name] = inst:DoTaskInTime(delay or 0, function(inst)
        store.tasks[name] = nil
        fn(inst, unpack(args))
    end)
    return store.tasks[name]
end

function MushaTasks.RemoveListener(inst, name)
    local store = inst ~= nil and inst.musha_taskstore or nil
    local listener = store ~= nil and store.events[name] or nil
    if listener ~= nil then
        inst:RemoveEventCallback(listener.event, listener.fn, listener.source)
        store.events[name] = nil
    end
end

function MushaTasks.Listen(inst, name, event, fn, source)
    if inst == nil or name == nil or event == nil or fn == nil then
        return
    end

    InstallCleanup(inst)
    local store = GetStore(inst)
    MushaTasks.RemoveListener(inst, name)
    inst:ListenForEvent(event, fn, source)
    store.events[name] =
    {
        event = event,
        fn = fn,
        source = source,
    }
end

function MushaTasks.StopWorldState(inst, name)
    local store = inst ~= nil and inst.musha_taskstore or nil
    local watcher = store ~= nil and store.worldstates[name] or nil
    if watcher ~= nil then
        inst:StopWatchingWorldState(watcher.state, watcher.fn)
        store.worldstates[name] = nil
    end
end

function MushaTasks.WatchWorldState(inst, name, state, fn)
    if inst == nil or name == nil or state == nil or fn == nil then
        return
    end

    InstallCleanup(inst)
    local store = GetStore(inst)
    MushaTasks.StopWorldState(inst, name)
    inst:WatchWorldState(state, fn)
    store.worldstates[name] =
    {
        state = state,
        fn = fn,
    }
end

function MushaTasks.ClearAll(inst)
    local store = inst ~= nil and inst.musha_taskstore or nil
    if store == nil then
        return
    end

    for name, task in pairs(store.tasks) do
        if task ~= nil then
            task:Cancel()
        end
        store.tasks[name] = nil
    end

    for name, listener in pairs(store.events) do
        inst:RemoveEventCallback(listener.event, listener.fn, listener.source)
        store.events[name] = nil
    end

    for name, watcher in pairs(store.worldstates) do
        inst:StopWatchingWorldState(watcher.state, watcher.fn)
        store.worldstates[name] = nil
    end
end

return MushaTasks
