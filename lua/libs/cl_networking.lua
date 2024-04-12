net.Receive( "BCORE.Chat", function()
    chat.AddText( Color( 73, 122, 214 ), "[" .. BCORE:GetConfig().name .. "]" .. " ", color_white, net.ReadString() or "" )
end )