
function BCORE:RegisterConfig(name,data)
    self:SaveData( "BCORE_CONFIGS", name, data, true )
end