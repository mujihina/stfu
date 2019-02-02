_addon.name     = 'stfu'
_addon.author   = 'Mujihina'
_addon.version  = '1.1'
_addon.commands = {'stfu'}

local _packets = require('packets')
local mounted = false

function playerIsMounted()
    local _player = windower.ffxi.get_player()
    if _player then
    	-- mounted status = 85
        return mounted or _player.status == 85
    end
    return false 
end


windower.register_event('outgoing chunk', function(id, data)
	-- mounting/unmounting action id = 0x1A
    if id == 0x1A then
        local packet = _packets.parse('outgoing', data)
        -- category: mount = 0x1A; unmount = 0x12
        if packet.Category == 0x1A then
            mounted = true
        elseif packet.Category == 0x12 then
            mounted = false
        end
    end
end)

windower.register_event('incoming chunk', function(id, data)
	-- music change = 0x05F
    if id == 0x05F and playerIsMounted() then
        local packet = _packets.parse('incoming', data)
        -- mounted music = 4		
        if packet['BGM Type'] == 4 then
            packet['Song ID'] = 0 -- 0: default zone music
            return _packets.build(packet)
        end
    end
end)