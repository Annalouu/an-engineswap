function SaveFileData(FileData, Path, Type)
    local result = {}

    if Type == "install" then
        local already = {}
        for plate, data in pairs(FileData) do
            if not already[plate] then
            
              local plate_ = string.gsub(plate, '^%s*(.-)%s*$', '%1')
              result[#result + 1] = ('\t["%s"] = {\n\t    exhaust = "%s",\n\t    category = "%s",\n\t},\n'):format(plate_, data.exhaust, data.category)
            
              already[plate] = true
            end
        end
    elseif Type == "soundlist" then
        for category, data in pairs(FileData) do
            local categoryResult = {}
            for soundName, soundData in pairs(data) do
                categoryResult[#categoryResult + 1] = string.format('\t\t%s = {\n\t\t\tprice = %d,\n\t\t\tlabel = "%s"\n\t\t},\n', soundName, soundData.price, soundData.label)
            end
            result[#result + 1] = string.format('\t%s = {\n%s\t},\n', category, table.concat(categoryResult, ""))
        end
    elseif Type == "zone" then
        for uuid, data in pairs(FileData) do
            local coordsStr = string.format('vector3(%f, %f, %f)', data.coords.x, data.coords.y, data.coords.z)

            local groupsStr = nil

            if data.groups then
                if type(data.groups) == "table" then
                    if table.type(data.groups) == "hash" then
                        groupsStr = '{'
                        for group, level in pairs(data.groups) do
                            groupsStr = groupsStr .. string.format('["%s"] = %s,', group, level)
                        end
                        groupsStr = groupsStr .. '}'
                    elseif table.type(data.groups) == "array" then
                        groupsStr = '{'
                        for _, group in pairs(data.groups) do
                            groupsStr = groupsStr .. string.format('"%s",', group)
                        end
                        groupsStr = groupsStr .. '}'
                    end
                else
                    groupsStr = ('"%s"'):format(data.groups)
                end
            end
        
            local drawTextStr = string.format('drawtext = { inveh = "%s", outveh = "%s" }', data.drawtext.inveh, data.drawtext.outveh)
        
            result[#result + 1] = string.format('\t["%s"] = {\n\t\tcoords = %s,\n\t\tradius = %f,\n\t\tgroups = %s,\n\t\tdebug = %s,\n\t\t%s\n\t},\n',
            uuid, coordsStr, data.radius, groupsStr, tostring(data.debug), drawTextStr)
        end
    end
  
    local DataTable = ('return {\n%s}'):format(table.concat(result, ""))
    SaveResourceFile(cache.resource, ('data/%s.lua'):format(Path), DataTable, -1)
end

