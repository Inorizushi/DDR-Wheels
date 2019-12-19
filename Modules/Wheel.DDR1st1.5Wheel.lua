local DiffColors={color("#88ffff"), color("#ffff88"), color("#ff8888"), color("#88ff88"), color("#8888ff"), color("#888888")}
local DiffNames={"Easy", "Basic", "Another", "Maniac", "Extra", "Edit"}

if not CurSong then CurSong = 1 end
if not Joined then Joined = {} end
local CDOffset = 1

local function MoveSelection(self,offset,Songs)
	CurSong = CurSong + offset
	if CurSong > #Songs then CurSong = 1 end
	if CurSong < 1 then CurSong = #Songs end
	
	CDOffset = CDOffset + offset
	if CDOffset > 9 then CDOffset = 1 end
	if CDOffset < 1 then CDOffset = 9 end

	for i = 1,9 do
		self:GetChild("CDBG"):GetChild("BACKGROUNDCD"..i):linear(.1):addrotationz((360/9)*offset)
		for i2 = 1,18 do
			self:GetChild("CDCon"):GetChild("CD"..i..i2):linear(.1):addrotationz((360/9)*offset)
		end
	end
	
	local ChangeOffset = CDOffset
	if offset > 0 then ChangeOffset = ChangeOffset + -1 end
	if ChangeOffset > 9 then CDOffset = 1 end
	if ChangeOffset < 1 then ChangeOffset = 9 end
	
	local pos = CurSong+(4*offset)
	if pos > #Songs then pos = (CurSong+(4*offset))-#Songs end
	if pos < 1 then pos = #Songs+(CurSong+(4*offset)) end
	
	if Songs[pos][1]:HasBanner() then
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(Songs[pos][1]:GetBannerPath()) 
	else
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(THEME:GetPathG("","white.png")) 
	end
	self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):setsize(512,160):SetCustomPosCoords(self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-23,0,self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+23,0):zoom(.4):y(-20)
	self:GetChild("Banner"):Load(Songs[CurSong][1]:GetBannerPath())
	self:GetChild("Banner"):zoom(DDR.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),256,80))
	
	self:GetChild("CDTitle"):Load(Songs[CurSong][1]:GetCDTitlePath())
	self:GetChild("CDTitle"):zoom(DDR.Resize(self:GetChild("CDTitle"):GetWidth(),self:GetChild("CDTitle"):GetHeight(),80,80))
	
	SOUND:StopMusic()
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
end

local function StartSelection(self,Songs)
	for i = 1,9 do
		self:GetChild("CDBG"):GetChild("BACKGROUNDCD"..i):GetChild("CDBG"):linear(.4):y(-1280)
		for i2 = 1,18 do
			self:GetChild("CDCon"):GetChild("CD"..i..i2):GetChild("CDHolder"):linear(.4):y(-1280)
		end
	end
end


local CurDiff = 2

local function MoveDifficulty(self,offset,Songs)	
	
	CurDiff = CurDiff + offset
	
	if CurDiff > #Songs[CurSong] then CurDiff = 2 end
	if CurDiff < 2 then CurDiff = #Songs[CurSong] end


	for i = 1,8 do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]]):diffusealpha(0)
	end
	
	local DiffCount = Songs[CurSong][CurDiff]:GetMeter()
	if DiffCount > 8 then  DiffCount = 8 end
	
	for i = 1,DiffCount do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffusealpha(1):x(30*(i-((DiffCount/2)+.5)))
	end
	
	self:GetChild("Difficulty"):settext(DiffNames[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]])
end

return function(Style)

	local Songs = LoadModule("Songs.Loader.lua")(Style)
	local StartOptions = false
	
	local CDs = Def.ActorFrame{
		Name="CDCon"
	}
	
	local CDslice = Def.ActorFrame{
		Name="Con"
	}
	
	local CDGB = Def.ActorFrame{
		Name="CDBG"
	}
	
	for i = 1,9 do
		local pos = CurSong+i-5
		if pos > #Songs then pos = (CurSong+i-5)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i-5) end
		if pos > #Songs then pos = 1 CurSong = 1 end
		if pos > #Songs then pos = 1 CurSong = 1 end
		
		CDslice[#CDslice+1] = Def.Sprite{
			Name="CDSlice"..i,
			Texture=Songs[pos][1]:GetBannerPath(),
			OnCommand=function(self)
				if not Songs[pos][1]:HasBanner() then self:Load(THEME:GetPathG("","white.png")) end
				self:setsize(512,160):SetCustomPosCoords(self:GetWidth()/2-23,0,self:GetWidth()/2-9,-80,-self:GetWidth()/2+9,-80,-self:GetWidth()/2+23,0):zoom(.4):y(-20)
			end
		}
		
		CDGB[#CDGB+1] = Def.ActorFrame {
			Name="BACKGROUNDCD"..i,
			OnCommand=function(self) self:rotationz(180-((360/9)*(i-5))):CenterX():y(SCREEN_CENTER_Y-80):rotationx(-52):SetFOV(80) end,
			Def.ActorProxy {
				Name="CDBG",
				InitCommand=function(self)
					self:SetTarget(self:GetParent():GetParent():GetParent():GetChild("CDBGCon"):GetChild("CDBG")):y(-180):zoom(.225)
				end
			}
		}
		
		for i2 = 1,18 do
			CDs[#CDs+1] = Def.ActorFrame{ 
				Name="CD"..i..i2,
				OnCommand=function(self)
					self:rotationz(180-((360/9)*(i-5))):CenterX():y(SCREEN_CENTER_Y-80):rotationx(-52):SetFOV(80)
				end,
				Def.ActorFrame{
					Name="CDHolder",
					OnCommand=function(self)
						self:rotationz((360/18)*i2):y(-180)
					end,
					Def.ActorProxy {
						InitCommand=function(self)
							self:SetTarget(self:GetParent():GetParent():GetParent():GetParent():GetChild("Con"):GetChild("CDSlice"..i))
						end
					}
				}
			}
		end
	end
	
	local TriSel = Def.ActorFrame {}
	
	for i = 0,1 do
		TriSel[#TriSel+1] = Def.Sprite {
			Texture=THEME:GetPathG("","Triangle.png"),
			OnCommand=function(self) self:zoom(.06):y(18*i) end,
		}
	end
	
	local Diff = Def.ActorFrame {
		Name="Diffs",
	}
	
	for i = 1,8 do
		Diff[#Diff+1] = Def.Sprite {
			Name="Feet"..i,
			Texture=THEME:GetPathG("","Feet.png"),
			InitCommand=function(self) self:zoomx(-.25):zoomy(.3):x(30*(i-4.5)) end
		}
	end
	
	return Def.ActorFrame{
		OnCommand=function(self) 
			SCREENMAN:GetTopScreen():AddInputCallback(DDR.Input(self))
			self:sleep(0.2):queuecommand("PlayCurrentSong")
			MoveDifficulty(self,0,Songs)
		end,
		PlayCurrentSongCommand=function(self)
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end,
		MenuLeftCommand=function(self) MoveSelection(self,1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Left"):stoptweening()
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
		end,
		MenuRightCommand=function(self) MoveSelection(self,-1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Right"):stoptweening()
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
		end,
		MenuDownCommand=function(self) MoveDifficulty(self,1,Songs) end,
		MenuUpCommand=function(self) MoveDifficulty(self,-1,Songs) end,
		BackCommand=function(self) 
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
				else
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
		end,
		StartCommand=function(self)
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
			if Joined[self.pn] then 
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
				GAMESTATE:SetCurrentSong(Songs[CurSong][1])
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					GAMESTATE:SetCurrentStyle('versus')
					PROFILEMAN:SaveProfile(PLAYER_1)
					PROFILEMAN:SaveProfile(PLAYER_2)
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][CurDiff])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][CurDiff])
				else
					GAMESTATE:SetCurrentStyle('single')
					PROFILEMAN:SaveProfile(self.pn)
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][CurDiff])
				end
				StartOptions = true
				StartSelection(self,Songs)
				self:sleep(0.4):queuecommand("StartSong")
			else
				GAMESTATE:JoinPlayer(self.pn)
				GAMESTATE:LoadProfiles()
				Joined[self.pn] = true
			end			
		end,
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		
		Def.ActorFrame {
			Name="CDBGCon",
			OnCommand=function(self) self:zoom(0) end,
			Def.Sprite {
				Name="CDBG",
				Texture=THEME:GetPathG("","CDCon.png")
			}
		},
		CDslice,
		CDGB,
		CDs,
		Def.Sprite{
			Name="Banner",
			Texture=Songs[CurSong][1]:GetBannerPath(),
			OnCommand=function(self)
				self:CenterX():y(SCREEN_CENTER_Y-80):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),256,80))
			end				
		},
		Def.Sprite{
			Name="CDTitle",
			Texture=Songs[CurSong][1]:GetCDTitlePath(),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+220,SCREEN_CENTER_Y+120):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),80,80))
			end
		},
		Def.BitmapText{
			Name="Difficulty",
			Font="Common Normal",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-220,SCREEN_CENTER_Y+120)
			end
		},
		TriSel..{
			Name="Left", 
			OnCommand=function(self) self:xy(SCREEN_CENTER_X-110,SCREEN_CENTER_Y+50):rotationz(-90):diffuse(1,0,0,1) end,
			ColourCommand=function(self) self:sleep(0.02):diffuse(0,0,1,1):sleep(0.02):diffuse(1,1,1,1):sleep(0.02):diffuse(1,0,0,1) end
		},
		TriSel..{
			Name="Right", 
			OnCommand=function(self) self:xy(SCREEN_CENTER_X+110,SCREEN_CENTER_Y+50):rotationz(90):diffuse(1,0,0,1) end,
			ColourCommand=function(self) self:sleep(0.02):diffuse(0,0,1,1):sleep(0.02):diffuse(1,1,1,1):sleep(0.02):diffuse(1,0,0,1) end
		},
		Diff..{OnCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+110) end}
	}
end