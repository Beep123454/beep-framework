
function BCORE:GetConfig(name,data)
    return BCORE:GetData(  "BCORE_CONFIGS", name, data, true )
end