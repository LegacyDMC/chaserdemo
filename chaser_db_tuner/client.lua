local chaser = exports['legacydmc_chaser']
local isdrivingcar = false
local flywheeldata 
local diffdata 
local transmissiondata 
local assiststatedata 
local tyredata 
local turbodata 
local plate

function getvehplate()
    if GetPedInVehicleSeat(vehicle, -1) == player then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    return plate
end

function printTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            printTable(v, indent+1)
        else
            print(formatting .. tostring(v))
        end
    end
end

function assignVariables(t, ...)
    local vars = {...}
    for i, v in ipairs(vars) do
        t[i] = v
    end
end

function getchaserdata()
    flywheeldata = chaser:chaser_getflywheel() -- flywheeldata.flywheel, flywheeldata.flywheelweight
    diffdata = chaser:chaser_getdifferential() -- diffdata.differential, diffdata.frontlock, diffdata.rearlock
    transmissiondata = chaser:chaser_gettransmission() -- transmissiondata.transmissionid, transmissiondata.originaltransmissionid, transmissiondata.finaldrive, transmissiondata.gearratiostable, transmissiondata.atshiftpoint, transmissiondata.gears, transmissiondata.topspeed
    assiststatedata = chaser:chaser_getassists() -- assiststatedata.tractionControl, assiststatedata.stabilityControl, assiststatedata.gearLock, assiststatedata.launchControl, assiststatedata.hasLaunchControl, assiststatedata.hasAssists, assiststatedata.isAuto
    tyredata = chaser:chaser_gettyre() -- tyredata.tyre, tyredata.maxg, tyredata.ming, tyredata.latcurve
    turbodata = chaser:chaser_getturbo() -- turbodata.size, turbodata.ptdboost, turbodata.tdp, turbodata.mtbpmax, turbodata.mtbpmin, turbodata.mtbpminprct, turbodata.mtbpmaxprct, turbodata.bsp, turbodata.typeid
end

function tobool(myValue)
    if type(myValue) == 'boolean' then
        return myValue
    elseif myValue == 'true' then
        return true
    elseif myValue == 'false' then
        return false
    else
        return nil
    end
end

RegisterNetEvent("chaser:leftVeh", function(vehicleNetId) -- always clear your "global" variables on exit.
    isdrivingcar = false
    engineisrunning = false
end)   

RegisterNetEvent("chaser:enteredVehicle", function(vehicleNetId) -- base form of registering id's/vehicle in sync with chaser, very important to wait it to load
                                                                 -- prior to do anything.
    player = PlayerPedId()
    playerid = PlayerId()
    vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    vehnetid = NetworkGetNetworkIdFromEntity(vehicle)
    while not exports['legacydmc_chaser']:chaser_getloadstatus() do
        Citizen.Wait(0)
    end
    if GetPedInVehicleSeat(vehicle, -1) == player then
        isdrivingcar = true
        while not GetIsVehicleEngineRunning(vehicle) do
            if not isdrivingcar then
                break
            end
            Citizen.Wait(0)
        end
        engineisrunning = true
    end

    local vehuid = {
        numberplate = getvehplate(),
        model = chaser:chaser_getvehname()
    }

    TriggerServerEvent('chaserdb:fetch', vehuid)
end) 

RegisterNetEvent('chaserdb:fetchResponse') -- basic loading system
AddEventHandler('chaserdb:fetchResponse', function(data)
    if data then -- if no data, nothing is needed to do, will save and create the car profile once you submit in the menu.
        Citizen.Wait(135) -- wait to avoid overwriting data, usually 100, 135 ms will do, and are fast enough not to cause issues.
        getchaserdata()

        local assistsdata = {
            tractionControl = tobool(data.tcstate),
            stabilityControl = tobool(data.escstate),
            gearLock = tobool(data.gearlockstate),
            launchControl = assiststatedata.launchControl
        }
        local geartable = {}
        for i = 0, 9 do
            local gearKey = "g" .. i
            geartable[i + 1] = tonumber(data[gearKey])
        end

        --- Very important, please remember to follow this order as of v1.0 Weight>Engine Swap when bulding your own custom loading system, or utilizing/editing this.

        if data.weight ~= 0 then
            chaser:chaser_setweight(data.weight) -- weight is given in kilos.
        end

        if data.engine ~= nil and data.engine ~= "stock" then -- replace this with the desired logic for checking if an engine swap is enabled.
            chaser:chaser_setengine(data.engine,true,true)
        end
        
        chaser:chaser_settransmission(tonumber(data.transmissiontype),geartable,tonumber(data.finaldrive),tonumber(data.atshiftpoint),tonumber(transmissiondata.gears))
    
        chaser:chaser_setflywheel(data.hasflywheel,tonumber(data.flywheelweight))
    
        chaser:chaser_setdifferential(data.hasdifferential,tonumber(data.frontdifflockprct),tonumber(data.reardifflockprct))
    
        chaser:chaser_settyre(data.tyretype)
    
        local sendturbodata = {
            compressorsize = tonumber(data.compressorsize),
            boosttype = tonumber(data.boosttype),
            peakturbodecayboost = tonumber(data.peakturbodecayboost),
            turbodecaypoint = tonumber(data.turbodecaypoint),
            maxtrboostpmax = tonumber(data.maxtrboostpmax),
            maxtrboostpmin = tonumber(data.maxtrboostpmin),
            maxtrboostpminprct = tonumber(data.maxtrboostpminprct),
            maxtrboostpmaxprct = tonumber(data.maxtrboostpmaxprct),
            booststartpoint = tonumber(data.booststartpoint),
        }
    
        chaser:chaser_setturbo(sendturbodata)

        chaser:chaser_setassists(assistsdata)

        if data.weight ~= 0 and data.engine ~= nil and data.engine ~= "stock" then
            local currentweight = tonumber(data.weight)
            local engineswapname = data.engine
            
            local tuningacc = chaser:chaser_calculatetuningacc(chaser:chaser_getvehname(),currentweight,engineswapname)
            
            local performance_table = chaser:chaser_getpp(chaser:chaser_getvehname(),true,tuningacc,sendturbodata)
    
            printTable(performance_table) -- dumps all the data, the data is as follows (when tuning is considered)
    
            -- refer to the user-guide for further details on functions, exports, etc.
    
            --engswap_pp (pp rating, considering turbo, weight and engineswap power) 0 to 1000
            --engswap_acc (acceleration rating, considering turbo, weight and engineswap power) 0 to 100
            --engswap_topspeed (topspeed rating, considering turbo, weight and engineswap power) 0 to 100
            --pp (pp rating, stock) 0 to 1000
            --acc (acceleration rating, stock) 0 to 100
            --topspeed (topspeed rating, stock) 0 to 100
            --handling rating 0 to 100
        end
 
        getchaserdata() -- update data for the menu ui.
    else
        getchaserdata()
    end
end)

RegisterNUICallback('closeVehicleConfigForm', function(data, cb)
    SetNuiFocus(false, false) -- This will hide the cursor and disable NUI focus
    cb('ok')
end)

RegisterNUICallback('submitVehicleConfig', function(data, cb)-- basic saving system + applying, doesn't save engineswaps or weight, those are showed how to in the commands below.
    local assistsdata = {
        tractionControl = tobool(data.tcsstate),
        stabilityControl = tobool(data.escstate),
        gearLock = tobool(data.atglockstate),
        launchControl = assiststatedata.launchControl
    }
    local geartable = {}
    for i = 0, 9 do
        local gearKey = "gear" .. i
        geartable[i + 1] = tonumber(data[gearKey])
    end
    chaser:chaser_settransmission(tonumber(data.transmissiontype),geartable,tonumber(data.finaldrive),tonumber(data.atshiftpoint),tonumber(transmissiondata.gears))

    chaser:chaser_setflywheel(data.hasflywheel,tonumber(data.flywheelweight))

    chaser:chaser_setdifferential(data.hasdifferential,tonumber(data.frontdifflockprct),tonumber(data.reardifflockprct))

    chaser:chaser_settyre(data.tyretype)

    local sendturbodata = {
        compressorsize = tonumber(data.compressorsize),
        boosttype = tonumber(data.turbotype),
        peakturbodecayboost = tonumber(data.peakturbodecayboost),
        turbodecaypoint = tonumber(data.turbodecaypoint),
        maxtrboostpmax = tonumber(data.maxtrboostpmax),
        maxtrboostpmin = tonumber(data.maxtrboostpmin),
        maxtrboostpminprct = tonumber(data.maxtrboostpminprct),
        maxtrboostpmaxprct = tonumber(data.maxtrboostpmaxprct),
        booststartpoint = tonumber(data.booststartpoint),
    }

    chaser:chaser_setturbo(sendturbodata)

    chaser:chaser_setassists(assistsdata)

    Citizen.Wait(50)
    
    getchaserdata()
    
    local vehuid = {
        numberplate = getvehplate(),
        model = chaser:chaser_getvehname()
    }
    local chaserdata = {
        flywheel = flywheeldata,
        diff = diffdata,
        transmission = transmissiondata,
        assist = assistsdata,
        tyre = tyredata,
        turbo = sendturbodata,
    }

    TriggerServerEvent('chaserdb:save', vehuid, chaserdata)

end)

RegisterCommand("engineswap", function(source, args, rawCommand)  -- example on how to do commands, you can follow the same logic for other aspects, remember that not all
    if #args < 1 then                                             -- aspects might require a reload, usually you'll do that just for weight and/or engineswaps.
        print("Please insert an engine..")
        return                                                    -- In order for the commands to work properly, it's expected that an entry already exists in the db.
    end                                                           -- making one as soon as the vehicle is acquired or first time spawn/join is a good idea.
    local enginename = args[1]
    if GetIsVehicleEngineRunning(vehicle) then                    -- reloads will usually happen when setting a important attribute live, but may not be needed on loading
        chaser:chaser_setengine(enginename,true,true)             -- after the car engine starts, study the best approach for your application.
        local vehuid = {
            numberplate = getvehplate(),
            model = chaser:chaser_getvehname()
        }
        TriggerServerEvent('chaserdb:savecmd',vehuid,'engine',enginename) -- after setting the engine, we need to reload, but we will only do this if the save was successful.
    end
end, false)

RegisterCommand("setweight", function(source, args, rawCommand) -- same thing but weight.
    if #args < 1 then
        print("Please insert an weight..")
        return
    end
    local weightinkg = args[1]
    if GetIsVehicleEngineRunning(vehicle) then
        chaser:chaser_setweight(weightinkg)
        local vehuid = {
            numberplate = getvehplate(),
            model = chaser:chaser_getvehname()
        }
        TriggerServerEvent('chaserdb:savecmd',vehuid,'weight',tonumber(weightinkg))
    end
end, false)

RegisterNetEvent('chaserdb:successreload')
AddEventHandler('chaserdb:successreload', function()
    Citizen.Wait(135)
    chaser:chaser_forcereload()
end)

RegisterNetEvent('chaserdb:failsavecmd')
AddEventHandler('chaserdb:failsavecmd', function(data)
    print("Failed on saving the command "..data)
end)

RegisterCommand('showVehicleConfig', function() -- parse data from game to nui
    if isdrivingcar and engineisrunning then
        SetNuiFocus(true, true) -- Enables cursor
        SendNUIMessage({
            action = 'open',
            flywheel = flywheeldata.flywheel,
            flywheelweight = flywheeldata.flywheelweight,
            diff = diffdata.differential,
            diffflock = diffdata.frontlock,
            diffrlock = diffdata.rearlock,
            tcsstate = assiststatedata.tractionControl,
            ecsstate = assiststatedata.stabilityControl,
            glockstate = assiststatedata.gearLock,
            tyre = tyredata.tyre,
            transmissiontype = transmissiondata.transmissionid,
            finaldrive = transmissiondata.finaldrive,
            gearatios = transmissiondata.gearratiostable,
            atshiftpoint = transmissiondata.atshiftpoint,
            gears = transmissiondata.gears,
            topspeed = transmissiondata.topspeed,
            compressorsize = turbodata.size,
            peakturbodecayboost = turbodata.ptdboost,
            turbodecaypoint = turbodata.tdp,
            maxtrboostpmax = turbodata.mtbpmax,
            maxtrboostpmin = turbodata.mtbpmin,
            maxtrboostpminprct = turbodata.mtbpminprct,
            maxtrboostpmaxprct = turbodata.mtbpmaxprct,
            booststartpoint = turbodata.bsp,
            boosttype = turbodata.typeid
        })
    end
end, false)

RegisterKeyMapping('showVehicleConfig', 'Open Demo Tune Menu', 'keyboard', 'PERIOD')


