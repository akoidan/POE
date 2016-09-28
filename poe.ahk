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
	
	for index, element in o {
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
		Loop, 300 {
			if (A_Index = 1) {
				Loop, 4 {
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
						send {enter}
						printScreamMessage := false
						MsgBox, Trade Off
						return
					}
					sleep 100
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
	if (isPoeClosed()) {
		send {f5}
		return

	}
	if ( printScreamMessage ) {
		printScreamMessage := false
	} else {
		printScreamMessage := true
		screamTrade()
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



$F1::OpenHideout()
$F2::DrinkFlask()
$F3::SwitchConc()
$F4::OpenPortal()
$f5::FastLogOut()
$F6::getPrice()
$F7::printMessage()
;$`::PhaseRun()
;$A::IceCrash()


RunWaitOne(command) {
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	Run "%ComSpec%" /k,, Hide, pid
	while !(hConsole := WinExist("ahk_pid" pid))
		Sleep 10
	DllCall("AttachConsole", "UInt", pid)
	DetectHiddenWindows %dhw%
	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec(command)
	While !objExec.Status
		Sleep 100
	strLine := objExec.StdOut.ReadAll() ;read the output at once
	DllCall("FreeConsole")
	Process Exist, %pid%
	if (ErrorLevel == pid)
		Process Close, %pid%
	return strLine
}


getPrice() {
	FileDelete, e:\clip.txt
	ClipWait
	;;if (clipboard = "R2d2") {
	;;	MsgBox, Doesn't work
	;;} else {
		Fileappend,%clipboard%, e:\clip.txt
		MsgBox % RunWaitOne("python" " C:\Users\Andrew\Documents\djangochat\sd.py")
	;;}
}
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
	sleep 5
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
	Click left 1613, 305
	;Click left 1607, 522
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

