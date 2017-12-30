local files = file.Find("ghostban/*.lua", "LUA")
for i=1, #files do
	include("ghostban/" .. files[i])
	if SERVER then
		AddCSLuaFile("ghostban/" .. files[i])
	end
end
if SERVER then
	files = file.Find("ghostban/server/*.lua", "LUA")
	for i=1, #files do
		include("ghostban/server/" .. files[i])
	end
	files = file.Find("ghostban/client/*.lua", "LUA")
	for i=1, #files do
		AddCSLuaFile("ghostban/client/" .. files[i])
	end
	return
end
files = file.Find("ghostban/client/*.lua", "LUA")
for i=1, #files do
	include("ghostban/client/" .. files[i])
end