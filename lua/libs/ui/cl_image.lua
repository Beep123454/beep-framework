local materials = {}
file.CreateDir("BUi")

BUi.GetImgur = function(id, callback, useproxy, matSettings)
    if materials[id] then return callback(materials[id]) end

    if file.Exists("BUi" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/BUi/" .. id .. ".png", matSettings or "noclamp smooth mips")

        return callback(materials[id])
    end

    http.Fetch(useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com" or "https://i.imgur.com/" .. id .. ".png", function(body, len, headers, code)
        if len > 2097152 then
            materials[id] = Material("nil")

            return callback(materials[id])
        end

        file.Write("BUi/" .. id .. ".png", body)
        materials[id] = Material("../data/BUi/" .. id .. ".png", matSettings or "noclamp smooth mips")

        return callback(materials[id])
    end, function(error)
        if useproxy then
            materials[id] = Material("nil")

            return callback(materials[id])
        end

        return BUi.GetImgur(id, callback, true)
    end)
end

do
    local min = math.min
    local curTime = CurTime

    BUi.DrawProgressWheel = function(x, y, w, h, col)
        local progSize = min(w, h)
        surface.SetMaterial(progressMat)
        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, curTime() * 50)
    end

    drawProgressWheel = BUi.DrawProgressWheel
end

local materials_img = {}
local grabbingMaterials = {}
local getImgur = BUi.GetImgur

getImgur("9Xg5Q8d", function(mat)
    progressMat = mat
end)

BUi.DrawImgur = function(x, y, w, h, imgurId, col,r)
    if not materials_img[imgurId] then
        drawProgressWheel(x, y, w, h, col)
        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials_img[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end
    BUi.masks.Start()
    surface.SetMaterial(materials_img[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRect(x, y, w, h)
    BUi.masks.Source()
    draw.RoundedBox(r or 0, x, y, w, h, color_white)
    BUi.masks.End()
end

BUi.DrawImgurRotated = function(x, y, w, h, rot, imgurId, col)
    if not materials_img[imgurId] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)
        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials_img[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials_img[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRectRotated(x, y, w, h, rot)
end


local AVATAR_IMAGE_CACHE_EXPIRES = 86400

function BUi.GetAvatar(steamid64, callback)
	local fallback
	if os.time() - file.Time("avatars/" .. steamid64 .. ".png", "DATA") > AVATAR_IMAGE_CACHE_EXPIRES then
		fallback = Material("../data/avatars/" .. steamid64 .. ".png", "smooth")
	elseif os.time() - file.Exists("avatars/" .. steamid64 .. ".jpg", "DATA") > AVATAR_IMAGE_CACHE_EXPIRES then
		fallback = Material("../data/avatars/" .. steamid64 .. ".jpg", "smooth")
	end

	if not fallback or fallback:IsError() then
		fallback = Material("vgui/avatar_default")
	else
		return callback(fallback)
	end

	http.Fetch("https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1", function(body, size, headers, code)
		if size == 0 or code < 200 or code > 299 then return callback(fallback, steamid64)end

		local url, fileType = body:match("<avatarFull>.-(https?://%S+%f[%.]%.)(%w+).-</avatarFull>")
		if not url or not fileType then return callback(fallback, steamid64)end
		if fileType == "jpeg" then fileType = "jpg"end

		http.Fetch(url .. fileType, function(body, size, headers, code)
			if size == 0 or code < 200 or code > 299 then return callback(fallback, steamid64)end

			local cachePath = "avatars/" .. steamid64 .. "." .. fileType
			file.CreateDir("avatars")
			file.Write(cachePath, body)

			local material = Material("../data/" .. cachePath, "smooth")
			if material:IsError() then
				file.Delete(cachePath)
				callback(fallback, steamid64)
			else
				callback(material, steamid64)
			end

		end, function()
			callback(fallback, steamid64)end)
	end, function()
		callback(fallback, steamid64)end)
end

local function clearCachedAvatars()
	for _, f in ipairs(file.Find("avatars/*", "DATA")) do
		file.Delete("avatars/" .. f)
	end

	hook.Remove("InitPostEntity", "clearCachedAvatars")
end
hook.Add("InitPostEntity", "clearCachedAvatars", clearCachedAvatars)