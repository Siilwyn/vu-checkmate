local ingameMenuMPGraphGuid = Guid('E4386C4A-D5BB-DE8D-67DA-35456C8C51FD')

Events:Subscribe('Partition:Loaded', function(partition)
    for _, instance in pairs(partition.instances) do
        if instance.instanceGuid == ingameMenuMPGraphGuid and instance ~= nil then
            local graph = UIGraphAsset(instance)
            graph:MakeWritable()

            for i = #graph.connections, 1, -1 do
                local connection = UINodeConnection(graph.connections[i])

                -- Disable buttons for team switching and suicide
                if connection.sourcePort.name == 'ID_M_IGMMP_SQUAD' or connection.sourcePort.name == 'ID_M_IGMMP_SUICIDE' then
                    graph.connections:erase(i)
                end
            end
        end
    end
end)
