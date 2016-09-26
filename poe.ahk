global chrNum := 1

;Loop {
;	if (not isPoeClosed()) {
;		if (isLowHp()) {
;			send {1}
;		}
;		;Transform, globChar, zChr, % chrNum++
;		;if (chrNum > 10) {
;		;ImageSearch, OutputVarX, OutputVarY, 0, 0, 1409, 80, C:\poe\ahk\endurance.png
;		;if (OutputVarX > 0 and OutputVarY > 0) {
;		;	sleep 1
;		;	DebugAppend("lasdsad")
;		;} else {
;		;	sleep 2
;		;}
;		Sleep, 100
;	}
;}

global debugInited := false
global Debug
global charActive := false
global winX 
global winY
global winWidth := 0
global winHeight
global printScreamMessage := false
global printScreamMessageInited := false

isLowHp() {
	charActive := isCharacterActive()
	PixelGetColor, lowHpColor, 124, 1005
	return charActive and getColor(lowHpColor) != "r" 
}

PrintLol() {
Loop
{
	send /trade 1
	sleep 100
	send, %element%
	send {Enter}
	sleep 100
	}
}
printMessage() {
o := Object()

o.Insert("@_Rua_ Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Flasks""; position: left 3, top 4). My offer is 40 chaos")
o.Insert("@kinxsas Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""rampage 6""; position: left 1, top 6). My offer is 40 chaos")
o.Insert("@___Jackal___ Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""GG Items""; position: left 6, top 0). My offer is 40 chaos")
o.Insert("@BuddyMcBudTheThird Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""sss""; position: left 1, top 4). My offer is 40 chaos")
o.Insert("@GoldenArmadaForever Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""surgeon flasks""; position: left 8, top 0). My offer is 40 chaos")
o.Insert("@PowerCreepBalanceIssues Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard. My offer is 40 chaos")
o.Insert("@DvaergeKasteren Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""H""; position: left 0, top 2). My offer is 40 chaos")
o.Insert("@Quang_ge Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""卖""; position: left 8, top 8). My offer is 40 chaos")
o.Insert("@EmptyBRF Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Gems""; position: left 0, top 6). My offer is 40 chaos")
o.Insert("@FearWillBeMyCloseFriend Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Cards&Surgeon's""; position: left 8, top 10). My offer is 40 chaos")
o.Insert("@BigManTingZ Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""b/o""; position: left 11, top 4). My offer is 40 chaos")
o.Insert("@GODsFinder Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Flask""; position: left 4, top 2). My offer is 40 chaos")
o.Insert("@ToxicBladefall Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Legacy""; position: left 2, top 0). My offer is 40 chaos")
o.Insert("@Cospri_Herself Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""SHOP""; position: left 11, top 4). My offer is 40 chaos")
o.Insert("@FireHC Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""legacy surgeon - make offer""; position: left 10, top 6). My offer is 40 chaos")
o.Insert("@HateItOrLoveIt Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""SUPER EX 2""; position: left 11, top 0). My offer is 40 chaos")
o.Insert("@DieForBloodline Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""EK""; position: left 2, top 9). My offer is 40 chaos")
o.Insert("@Carotton Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""mjolner""; position: left 8, top 7). My offer is 40 chaos")
o.Insert("@LFM Hi, I would like to buy your Surgeon's Ruby Flask of Heat in Standard (stash tab ""Flasks 1""; position: left 9, top 8). My offer is 40 chaos")

for index, element in o ; Recommended approach in most cases.
	{
	send {Enter}
	sleep 100
	send, %element%
	send {Enter}
	sleep 100
	}
}
isCharacterActive() {
	PixelGetColor, colorTopManaBorder, 1890, 913
	PixelGetColor, colorShop, 1458, 1000
	colorShopSat := getColor(colorShop)
	colorManaBorderSat := getColor(colorTopManaBorder)
	newCharActiveStatus := colorManaBorderSat == "grey" and colorShopSat == "g"
	if (not charActive and newCharActiveStatus) {
		sleep 300 ; delay if it wasn't active for outside functions like @isLowHp()
	}
	charActive := newCharActiveStatus
	return charActive
}

getColor(color) {
	return getColorDebug(color, false)
}


calcX(x) {
	return winX + round(1920 * x / winWidth)
}

calcY(y) {
	return winY + round(1920 * y / winHeight)
}

screamTrade() {
	loop {
		Loop, 180 {
			if (A_Index == 1) {
				Loop, 3 {
					send {enter}
					sleep 20
					send ^A
					send {BS}
					send /trade  %A_Index% {enter}
					sleep 2000
					send {enter}
					sleep 200
					send {Up}
					sleep 200
					send {Up}
					sleep 200
					send ^A
					sleep 100
					send ^C
					if InStr(Clipboard, "Morbid Mantle, Vaal Regalia") {
						send {enter}
					} else { 
						return
					}
					sleep 1000
				}
			}
			if (not printScreamMessage) {
				return
			}
			sleep 1000
		}
	}
}

startScream() {
	if ( printScreamMessage ) {
		printScreamMessage := false
	} else {
		screamTrade()
		printScreamMessage := true
	}
}

getColorDebug(color, printDebug) {
	Blue:="0x" SubStr(color,3,2) ;substr is to get the piece
	Blue:=Blue+0 ;add 0 is to convert it to the current number format
	Green:="0x" SubStr(color,5,2)
	Green:=Green+0
	Red:="0x" SubStr(color,7,2)
	Red:=Red+0
	satur := 35
	diff := sqrt((blue - green)*(blue - green) + (blue - red)*(blue - red) + (red - green)*(red - green))
	if (color == 0x000000) {
		colorReal := "black"
	} else if (color == 0xFFFFFF){
		colorReal := "white" 
	} else if (diff < 8) {
		colorReal := "grey"
	} else if (blue < 10 and green > 40 and green < 60 and red > 100 and red < 200) {
		colorReal := "brown"
	} else if (blue + satur < red and green + satur < red) {
		colorReal := "r"
	} else if (red + satur < green and blue + satur < green) {
		colorReal := "g"
	} else if (red + satur < blue and green + satur < blue) {
		colorReal := "b"
	} else {
		colorReal := "u" ;unknown
	}
	if (printDebug) {
		DebugAppend( "R:" red ";G:" green ";B:" blue )
	}
	return colorReal
}

DebugAppend(Data) {
	if (!debugInited) {
		Gui, Add, Edit, Readonly x10 y10 w400 h300 vDebug
		Gui, Show, w420 h320, Debug Window
		debugInited := true
	}
	GuiControlGet, Debug
	GuiControl,, Debug, %Data%`r`n
}



$F2::DrinkFlask()
$F1::OpenHideout()
$F4::OpenPortal()

$F5::startScream()
$F3::FastLogOut()
;$f12::reload
;$`::PhaseRun()
;$A::IceCrash()

OpenHideout() {
	send {Enter}
	send ^A
	send {BS}
	send /hideout
	send {Enter}
}
IceCrash() {
	if (isPoeClosed() or isChatOpen()) {
		send {a}
		return
	}
	PixelGetColor, qSkillColor, 1453, 1056
	rgbQSkill := getColor(qSkillColor)
	DebugAppend(rgbQSkill)
	if (rgbQSkill == "g") {
		send {x}
		sleep 100
		send {q}
	} else if (rgbQSkill == "b") {
		send {q}
	}
}


isChatOpen() {
	PixelGetColor, XChatColor, 679, 392
	PixelGetColor, afterChatTypeColor, 80, 790
	rgbX := getColor(XChatColor)
	rgbName := getColor(afterChatTypeColor)
	return rgbX == "brown" and rgbName == "black"
}

PhaseRun() {
	if (isPoeClosed()  or isChatOpen()) {
		send {`}
		return
	}
	PixelGetColor, qSkillColor, 1453, 1056
	rgbQSkill := getColor(qSkillColor)
	if (rgbQSkill == "g") {
		send {q}
	} else if (rgbQSkill == "b") {
		send {x}
		sleep 100
		send {q}
	}
}

Remaining() {
	if (isPoeClosed()) {
		send {f1}
		return
	}
	BlockInput On
	Send {Enter}
	Sleep 1
	Send /remaining
	Send {Enter}
	BlockInput Off
	return
}

FastLogOut(){
	if (isPoeClosed()) {
		return
	}
	BlockInput On
	SetDefaultMouseSpeed 0
	sendinput {esc}
	sleep 1
	MouseClick, left, 959, 432, 1, 1
	BlockInput Off
	return
}



isPoeClosed() {
	IfWinNotActive , Path of Exile 
	{ 
		return true
	} else if (winWidth = 0) { 
		WinGetPos , winX, winY, winWidth, winHeight,,,, 
	} else {
		sleep 10
	}
}

OpenInventory() {
	PixelGetColor, colorKaomBack, 1581, 366
	if (colorKaomBack != 0x1A181C) {
		Send {i}
		Sleep 30
		return true
	} else {
		return false
	}
}

SwitchConc() {
	concX := 1877
	concY := 615
	
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	
	Click left %concX%, %concY%
	Sleep 1
	;Click left 1613, 305
	Click left 1607, 522
	Sleep 1
	Click left %concX%, %concY%
	Sleep 1
	
	if (closeInvAfter) {
		Send {i}
	}
	MouseMove xpos, ypox 
	BlockInput Off
	return
}


SwitchCurse() {
	yBottomGems := 825
	squareDimension := 54
	leftBottomSquareX := 1870
	warlMarkX := leftBottomSquareX -  squareDimension
	
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	
	Click left %warlMarkX%, %yBottomGems%
	Sleep 1
	Click left 1485, 371 
	Sleep 1
	Click left %warlMarkX%, %yBottomGems%
	Sleep 1
	
	if (closeInvAfter) {
		Send {i}
	}
	MouseMove xpos, ypox 
	BlockInput Off
	return
}


SwitchRarity() {
	yBottomGems := 825
	squareDimension := 54
	leftBottomSquareX := 1870
	IIRX := leftBottomSquareX -  squareDimension*5
	IIQX := leftBottomSquareX - squareDimension*6
	
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	PixelGetColor, middleLeftSocketColor, 1350, 225
	middleLeftSocketColorRgb := getColor(middleLeftSocketColor)
	if (middleLeftSocketColorRgb != "r") {
		send {x}
		sleep 50
	}

	
	Click left %IIRX%, %yBottomGems%
	Sleep 1
	Click left 1406, 228 ; top left staff
	Sleep 1
	Click left %IIRX%, %yBottomGems%
	Sleep 1
	
	Click left %IIQX%, %yBottomGems%
	Sleep 1
	Click left 1355, 176
	Sleep 1
	Click left %IIQX%, %yBottomGems%
	Sleep 1
	
	
	if (closeInvAfter) {
		Send {i}
	}
	MouseMove xpos, ypox 
	BlockInput Off
	return
}

TurnOffBloodRage() {
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	
	Click right 1767, 196
	if (closeInvAfter) {
		Send {i}
	}
	sleep 100
	Click left 1767, 196
	
	MouseMove xpos, ypox 
	BlockInput Off
	return
}

SwitchBoth() {	;if (isPoeClosed()) {
	;	send {f3}
	;	return
	;}
	yBottomGems := 825
	squareDimension := 54
	leftBottomSquareX := 1870
	;firstBottomGemX := leftBottomSquareX -  squareDimension
	secondBottomGemX := firstBottomGemX - squareDimension
	thirdBottomGemX := secondBottomGemX - squareDimension 
	
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()

	;Click left %firstBottomGemX%, %yBottomGems%
	;Sleep 1
	;Click left 1484, 363 ; top left staff
	;Sleep 1
	;Click left %firstBottomGemX%, %yBottomGems%
	;Sleep 1
	
	;Click left %firstBottomGemX%, %yBottomGems%
	;Sleep 1
	;Click left 1406, 228 ; top left staff
	;Sleep 1
	;Click left %firstBottomGemX%, %yBottomGems%
	;Sleep 1
	
	;Click left %thirdBottomGemX%, %yBottomGems%
	;Sleep 1
	;Click left 1355, 176
	;Sleep 1
	;Click left %thirdBottomGemX%, %yBottomGems%
	;Sleep 1
	
	
	;if (closeInvAfter) {
	;	Send {i}
	;}
	;MouseMove xpos, ypox 
	;BlockInput Off
	return
}


OpenPortal(){
	if (isPoeClosed()) {
		send {f4}
		return
	}
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	Click right 1881,838
	Click left 630, 450
	BlockInput Off
	return
}

DrinkTwoFirstFlask() {
	if (isPoeClosed()) {
		send {f1}
		return
	}
	Send {3}
	Send {4}
	Send {5}
}

DrinkFlask() {
	if (isPoeClosed()) {
		send {f2}
		return
	}
	Send {1}
	Send {2}
	Send {3}
	Send {4}
	Send {5}
}

