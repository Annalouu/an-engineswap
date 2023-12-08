lib.addCommand('createzone', {
    help = 'create a new zone for engine swap',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("an-engineswap:client:creteZone", source)
end)

lib.addCommand('zonelist', {
    help = 'list all engine swap zones',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("an-engineswap:client:listCreatedZone", source)
end)