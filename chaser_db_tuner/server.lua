local MySQL = exports['oxmysql']

function CreateNewTable()
    -- The name of the new table to be created
    local newTableName = "chaser_tuning_data"

    -- Prepare the SQL query to create the new table within the server database
    local query = "CREATE TABLE IF NOT EXISTS `chaser_tuning_data` (" ..
    "id INT AUTO_INCREMENT PRIMARY KEY," ..
    "plate VARCHAR(50) NOT NULL UNIQUE KEY," ..
    "model VARCHAR(50) NOT NULL," ..
    "hasflywheel BOOLEAN NOT NULL," ..
    "engine VARCHAR(50) NOT NULL DEFAULT 'stock'," ..
    "weight FLOAT NOT NULL ," ..
    "flywheelweight FLOAT NOT NULL ," ..
    "hasdifferential BOOLEAN NOT NULL," ..
    "frontdifflockprct FLOAT NOT NULL ," ..
    "reardifflockprct FLOAT NOT NULL ," ..
    "transmissiontype INT NOT NULL ," ..
    "finaldrive FLOAT NOT NULL ," ..
    "g0 FLOAT NOT NULL ," ..
    "g1 FLOAT NOT NULL ," ..
    "g2 FLOAT NOT NULL ," ..
    "g3 FLOAT NOT NULL ," ..
    "g4 FLOAT NOT NULL ," ..
    "g5 FLOAT NOT NULL ," ..
    "g6 FLOAT NOT NULL ," ..
    "g7 FLOAT NOT NULL ," ..
    "g8 FLOAT NOT NULL ," ..
    "g9 FLOAT NOT NULL ," ..
    "atshiftpoint FLOAT NOT NULL ," ..
    "tcstate BOOLEAN NOT NULL," ..
    "escstate BOOLEAN NOT NULL," ..
    "gearlockstate BOOLEAN NOT NULL," ..
    "tyretype VARCHAR(50) NOT NULL ," ..
    "compressorsize INT NOT NULL ," ..
    "peakturbodecayboost INT NOT NULL ," ..
    "turbodecaypoint FLOAT NOT NULL ," ..
    "maxtrboostpmax FLOAT NOT NULL ," ..
    "maxtrboostpmin FLOAT NOT NULL ," ..
    "maxtrboostpminprct INT NOT NULL ," ..
    "maxtrboostpmaxprct INT NOT NULL ," ..
    "booststartpoint FLOAT NOT NULL ," ..
    "boosttype INT NOT NULL " ..
    ")"
    
    -- Execute the query to create the new table using oxmysql
    exports['oxmysql']:execute(query, {}, function(rowsChanged)
    end)
end

CreateNewTable()

RegisterNetEvent('chaserdb:fetch')
AddEventHandler('chaserdb:fetch', function(vehdata)
    local sender = tonumber(source)

    local carplate = vehdata.numberplate
    local carid = vehdata.model
    -- Define the SQL query to select data based on plate and model.
    local db_query = [[
        SELECT * FROM `chaser_tuning_data`
        WHERE `plate` = @plate AND `model` = @model;
    ]]

    -- Parameters for the SQL query.
    local parameters = {
        ['@plate'] = carplate,
        ['@model'] = carid
    }

    -- Execute the SQL query and handle the result.
    exports['oxmysql']:execute(db_query, parameters, function(result)
        if result and #result > 0 then
            -- If data is found, result is a table with the records.
            -- Process or return this data as needed. For example:
            TriggerClientEvent('chaserdb:fetchResponse', sender, result[1])
        else
            -- No data found for the given plate and model.
            TriggerClientEvent('chaserdb:fetchResponse', sender, nil)
        end
    end)
end)

RegisterNetEvent('chaserdb:save')
AddEventHandler('chaserdb:save', function(vehdata,savedata)
    -- Get the car plate number from the event parameter 'platenumber'.
    local carplate = vehdata.numberplate
    local carid = vehdata.model
    local flywheeldata = savedata.flywheel
    local diffdata = savedata.diff
    local transmissiondata = savedata.transmission
    local assiststatedata = savedata.assist
    local tyredata = savedata.tyre
    local turbodata = savedata.turbo

    db_query = [[
        INSERT INTO `chaser_tuning_data` (
            `plate`, `model`, `hasflywheel`, `flywheelweight`, `hasdifferential`, 
            `frontdifflockprct`, `reardifflockprct`, `transmissiontype`, `finaldrive`, 
            `g0`, `g1`, `g2`, `g3`, `g4`, `g5`, `g6`, `g7`, `g8`, `g9`, 
            `atshiftpoint`, `tcstate`, `escstate`, `gearlockstate`, `tyretype`, 
            `compressorsize`, `peakturbodecayboost`, `turbodecaypoint`, `maxtrboostpmax`, 
            `maxtrboostpmin`, `maxtrboostpminprct`, `maxtrboostpmaxprct`, `booststartpoint`, `boosttype`
        ) VALUES (
            @plate, @model, @hasflywheel, @flywheelweight, @hasdifferential, 
            @frontdifflockprct, @reardifflockprct, @transmissiontype, @finaldrive, 
            @g0, @g1, @g2, @g3, @g4, @g5, @g6, @g7, @g8, @g9, 
            @atshiftpoint, @tcstate, @escstate, @gearlockstate, @tyretype, 
            @compressorsize, @peakturbodecayboost, @turbodecaypoint, @maxtrboostpmax, 
            @maxtrboostpmin, @maxtrboostpminprct, @maxtrboostpmaxprct, @booststartpoint, @boosttype
        ) ON DUPLICATE KEY UPDATE
            `hasflywheel` = VALUES(`hasflywheel`), `flywheelweight` = VALUES(`flywheelweight`), `hasdifferential` = VALUES(`hasdifferential`), 
            `frontdifflockprct` = VALUES(`frontdifflockprct`), `reardifflockprct` = VALUES(`reardifflockprct`), `transmissiontype` = VALUES(`transmissiontype`), 
            `finaldrive` = VALUES(`finaldrive`), `g0` = VALUES(`g0`), `g1` = VALUES(`g1`), 
            `g2` = VALUES(`g2`), `g3` = VALUES(`g3`), `g4` = VALUES(`g4`), 
            `g5` = VALUES(`g5`), `g6` = VALUES(`g6`), `g7` = VALUES(`g7`), 
            `g8` = VALUES(`g8`), `g9` = VALUES(`g9`), `atshiftpoint` = VALUES(`atshiftpoint`), 
            `tcstate` = VALUES(`tcstate`), `escstate` = VALUES(`escstate`), `gearlockstate` = VALUES(`gearlockstate`), 
            `tyretype` = VALUES(`tyretype`), `compressorsize` = VALUES(`compressorsize`), `peakturbodecayboost` = VALUES(`peakturbodecayboost`), 
            `turbodecaypoint` = VALUES(`turbodecaypoint`), `maxtrboostpmax` = VALUES(`maxtrboostpmax`), `maxtrboostpmin` = VALUES(`maxtrboostpmin`), 
            `maxtrboostpminprct` = VALUES(`maxtrboostpminprct`), `maxtrboostpmaxprct` = VALUES(`maxtrboostpmaxprct`), `booststartpoint` = VALUES(`booststartpoint`), 
            `boosttype` = VALUES(`boosttype`);        
    ]]
    -- Parameters for the SQL query, with the car plate number provided.

    local parameters = {
        ['@plate'] = carplate,
        ['@model'] = carid,
        ['@hasflywheel'] = flywheeldata.flywheel,
        ['@flywheelweight'] =  flywheeldata.flywheelweight,
        ['@hasdifferential'] = diffdata.differential,
        ['@frontdifflockprct'] = diffdata.frontlock,
        ['@reardifflockprct'] = diffdata.rearlock,
        ['@transmissiontype'] = transmissiondata.transmissionid,
        ['@finaldrive'] = transmissiondata.finaldrive + 0.0, -- use + 0.0 to ensure float
        ['@g0'] = transmissiondata.gearratiostable[1] + 0.0,
        ['@g1'] = transmissiondata.gearratiostable[2] + 0.0,
        ['@g2'] = transmissiondata.gearratiostable[3] + 0.0,
        ['@g3'] = transmissiondata.gearratiostable[4] + 0.0,
        ['@g4'] = transmissiondata.gearratiostable[5] + 0.0,
        ['@g5'] = transmissiondata.gearratiostable[6] + 0.0,
        ['@g6'] = transmissiondata.gearratiostable[7] + 0.0,
        ['@g7'] = transmissiondata.gearratiostable[8] + 0.0,
        ['@g8'] = transmissiondata.gearratiostable[9] + 0.0,
        ['@g9'] = transmissiondata.gearratiostable[10] + 0.0,
        ['@atshiftpoint'] = transmissiondata.atshiftpoint + 0.0,
        ['@tcstate'] = assiststatedata.tractionControl,
        ['@escstate'] = assiststatedata.stabilityControl,
        ['@gearlockstate'] = assiststatedata.gearLock,
        ['@tyretype'] = tyredata.tyre,
        ['@compressorsize'] = turbodata.compressorsize,
        ['@peakturbodecayboost'] = turbodata.peakturbodecayboost,
        ['@turbodecaypoint'] = turbodata.turbodecaypoint,
        ['@maxtrboostpmax'] = turbodata.maxtrboostpmax + 0.0,
        ['@maxtrboostpmin'] = turbodata.maxtrboostpmin + 0.0,
        ['@maxtrboostpminprct'] = turbodata.maxtrboostpminprct,
        ['@maxtrboostpmaxprct'] = turbodata.maxtrboostpmaxprct,
        ['@booststartpoint'] = turbodata.booststartpoint + 0.0,
        ['@boosttype'] = turbodata.boosttype
    }

    -- Execute the SQL query using the 'oxmysql' module with the provided parameters.
    exports['oxmysql']:execute(db_query, parameters)
end)


RegisterNetEvent('chaserdb:savecmd')
AddEventHandler('chaserdb:savecmd', function(vehdata,call,data)
    -- Get the car plate number from the event parameter 'platenumber'.
    local sender = tonumber(source)
    local carplate = vehdata.numberplate
    local carid = vehdata.model
    local callid = call

    
    if callid == "engine" then
        local enginename = data
        db_query = [[
            INSERT INTO `chaser_tuning_data` (
                `plate`, `model`, `engine`
            ) VALUES (
                @plate, @model, @engine
            ) ON DUPLICATE KEY UPDATE
                `engine` = VALUES(`engine`)
        ]]
    
        local parameters = {
            ['@plate'] = carplate,
            ['@model'] = carid,
            ['@engine'] = enginename
        }

        exports['oxmysql']:execute(db_query, parameters, function(affectedRows)
            if affectedRows then
                TriggerClientEvent('chaserdb:successreload', sender)
            else
                TriggerClientEvent('chaserdb:failsavecmd', sender, call)
            end
        end)
    elseif callid == "weight" then
        local weightammount = data
        db_query = [[
            INSERT INTO `chaser_tuning_data` (
                `plate`, `model`, `weight`
            ) VALUES (
                @plate, @model, @weight
            ) ON DUPLICATE KEY UPDATE
                `weight` = VALUES(`weight`)
        ]]
    
        local parameters = {
            ['@plate'] = carplate,
            ['@model'] = carid,
            ['@weight'] = weightammount
        }

        exports['oxmysql']:execute(db_query, parameters, function(affectedRows)
            if affectedRows then
                print("hi3",weightammount)
                TriggerClientEvent('chaserdb:successreload', sender)
            else
                print("hi4",weightammount)
                TriggerClientEvent('chaserdb:failsavecmd', sender, call)
            end
        end)
    else
        print("[SAVECMD] Call type not supported")
    end
    -- Execute the SQL query using the 'oxmysql' module with the provided parameters.
end)
