local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Locale = {}
Locale.BaseUrl = getgenv().DarkHubLocaleUrl or "https://raw.githubusercontent.com/DarkHub-Oficial/GameModules/main/Ultils/Modules/Modules-Blox%20Fruits/Translator/"
Locale.Current = "en"
Locale.Enabled = true
Locale.Table = {}

local RobloxToLocale = {
	["en-us"] = "en",
	["en"] = "en",
	["pt-br"] = "pt-br",
	["pt"] = "pt-br",
	["es-es"] = "es",
	["es-mx"] = "es",
	["es"] = "es",
	["vi-vn"] = "vi",
	["vi"] = "vi",
	["ru-ru"] = "ru",
	["ru"] = "ru",
	["zh-cn"] = "zh",
	["zh-cjv"] = "zh",
	["zh-hans"] = "zh",
	["zh-hant"] = "zh",
	["zh-tw"] = "zh",
	["zh"] = "zh",
	["ar-001"] = "ar",
	["ar-sa"] = "ar",
	["ar-ae"] = "ar",
	["ar"] = "ar",
	["id-id"] = "id",
	["id"] = "id",
	["fr-fr"] = "fr",
	["fr"] = "fr",
}

local Supported = { "pt-br", "es", "vi", "ru", "zh", "ar", "id", "fr" }

function Locale.DetectRobloxLang()
	local code = "en"
	pcall(function()
		local plr = Players.LocalPlayer
		if plr and type(plr.LocaleId) == "string" and plr.LocaleId ~= "" then
			code = string.lower(plr.LocaleId)
		end
	end)
	pcall(function()
		local ls = game:GetService("LocalizationService")
		if ls and type(ls.RobloxLocaleId) == "string" and ls.RobloxLocaleId ~= "" then
			code = string.lower(ls.RobloxLocaleId)
		end
	end)
	if RobloxToLocale[code] then
		return RobloxToLocale[code]
	end
	local short = string.split(code, "-")[1]
	if RobloxToLocale[short] then
		return RobloxToLocale[short]
	end
	return "en"
end

local function fetchJson(lang)
	local url = Locale.BaseUrl .. tostring(lang) .. ".json"
	local body
	pcall(function()
		if game.HttpGet then
			body = game:HttpGet(url)
		elseif request then
			local r = request({ Url = url, Method = "GET" })
			body = r and r.Body
		end
	end)
	if not body or body == "" then
		return nil
	end
	local data
	pcall(function()
		data = HttpService:JSONDecode(body)
	end)
	if type(data) == "table" then
		return data
	end
	return nil
end

function Locale.Load(lang)
	lang = tostring(lang or "en")
	if lang == "auto" then
		lang = Locale.DetectRobloxLang()
	end
	if lang == "en" then
		Locale.Table = {}
		Locale.Current = "en"
		getgenv().DarkHubLang = "en"
		return "en"
	end
	local okLang = false
	for _, v in ipairs(Supported) do
		if v == lang then
			okLang = true
			break
		end
	end
	if not okLang then
		Locale.Table = {}
		Locale.Current = "en"
		getgenv().DarkHubLang = "en"
		return "en"
	end
	local data = fetchJson(lang)
	if not data then
		Locale.Table = {}
		Locale.Current = "en"
		getgenv().DarkHubLang = "en"
		return "en"
	end
	Locale.Table = data
	Locale.Current = lang
	getgenv().DarkHubLang = lang
	return lang
end

function Locale.SetEnabled(v)
	Locale.Enabled = v and true or false
	getgenv().DarkHubTranslate = Locale.Enabled
end

function Locale.T(key)
	key = tostring(key or "")
	if key == "" then
		return key
	end
	if not Locale.Enabled or Locale.Current == "en" then
		return key
	end
	local v = Locale.Table[key]
	if type(v) == "string" and v ~= "" then
		return v
	end
	local k2 = string.gsub(key, "%s+$", "")
	v = Locale.Table[k2]
	if type(v) == "string" and v ~= "" then
		return v
	end
	v = Locale.Table[k2 .. " "]
	if type(v) == "string" and v ~= "" then
		return v
	end
	return key
end

function Locale.Init()
	local translate = getgenv().DarkHubTranslate
	if translate == nil then
		translate = true
	end
	Locale.SetEnabled(translate)
	local lang
	if not translate then
		lang = "en"
	else
		local saved = getgenv().DarkHubLang
		if not saved or saved == "" or saved == "auto" then
			lang = Locale.DetectRobloxLang()
		else
			lang = saved
		end
	end
	Locale.Load(lang)
	getgenv().L = function(key)
		return Locale.T(key)
	end
	getgenv().DarkHubLocale = Locale
	return Locale
end

return Locale
