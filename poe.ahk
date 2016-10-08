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
	return winY + round(1080 * y / winHeight)
}

Rand( a=0.0, b=1 ) {
   IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
   Else Random,r,a,b
   Return r
}


screamTrade() {
	loop {
		interval := Rand(200, 400) 
		Loop, interval {
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
						MsgBox, Trade Off coz wrong clip
						return
					}
					sleep 100
				}
			}
			if (not printScreamMessage) {
				MsgBox, Trade Off
				return
			}
			sleep 2000
		}
	}
}

startScream() {
	if (isPoeClosed()) {
		send {f8}
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


setGemPrice() {
	clip_path :=  A_ScriptDir "\clip.txt"
	FileDelete, %clip_path%
	ClipWait
	Fileappend,%clipboard%, %clip_path%, UTF-8
	priceFinderPath :=  A_ScriptDir "\price-finder.py"
	command := "python " """" priceFinderPath """ price"
	res :=  RunWaitOne(command)
	MsgBox, %res%
	if (res < 3) {
		MsgBox, drop
	} else {
		MsgBox, keep
	}
}


$F1::OpenHideout()
$F2::DrinkFlask()
$F5::SwitchConc()
$F4::OpenPortal()
$f3::FastLogOut()
$F6::getPrice()
$F7::printMessage()
$f8::startScream()
;;$f9::setGemPrice() 

;$`::PhaseRun()
;$A::IceCrash()

lol() {
	HWND := WinExist()
   Static SizeOfWINDOWINFO := 60
   ; Struct WINDOWINFO
   VarSetCapacity(WINDOWINFO, SizeOfWINDOWINFO, 0)
   NumPut(SizeOfWINDOWINFO, WINDOWINFO, "UInt")
   If !DllCall("User32.dll\GetWindowInfo", "Ptr", HWND, "Ptr", &WINDOWINFO, "UInt")
      Return False
   ; Object WI
   WI := {}
   WI.WindowX := NumGet(WINDOWINFO,  4, "Int")                 ; X coordinate of the window
   WI.WindowY := NumGet(WINDOWINFO,  8, "Int")                 ; Y coordinate of the window
   WI.WindowW := NumGet(WINDOWINFO, 12, "Int") - WI.WindowX    ; Width of the window
   WI.WindowH := NumGet(WINDOWINFO, 16, "Int") - WI.WindowY    ; Height of the window
   WI.ClientX := NumGet(WINDOWINFO, 20, "Int")                 ; X coordinate of the client area
   WI.ClientY := NumGet(WINDOWINFO, 24, "Int")                 ; Y coordinate of the client area
   WI.ClientW := NumGet(WINDOWINFO, 28, "Int") - WI.ClientX    ; Width of the client area
   WI.ClientH := NumGet(WINDOWINFO, 32, "Int") - WI.ClientY    ; Height of the client area
   WI.Style   := NumGet(WINDOWINFO, 36, "UInt")                ; The window styles.
   WI.ExStyle := NumGet(WINDOWINFO, 40, "UInt")                ; The extended window styles.
   WI.State   := NumGet(WINDOWINFO, 44, "UInt")                ; The window status (1 = active).
   WI.BorderW := NumGet(WINDOWINFO, 48, "UInt")                ; The width of the window border, in pixels.
   WI.BorderH := NumGet(WINDOWINFO, 52, "UInt")                ; The height of the window border, in pixels.
   WI.Type    := NumGet(WINDOWINFO, 56, "UShort")              ; The window class atom.
   WI.Version := NumGet(WINDOWINFO, 58, "UShort")              ; The Windows version of the application.
   MsgBox, %WI%
}


DrawText(winText) {
	setControlDelay, 500 ; remove this if theres no loop!
	gui, font, cFF0000 s90, arial
	gui, +alwaysOnTop +toolWindow -caption
	gui, color, c000000
	gui, add, text,, % winText
	gui, show, y-300 NA, tDisp

	winWait, tDisp
	winSet, transColor, 000000
	winMove, -90, -70 ; change coordinates!
}

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
	clip_path :=  A_ScriptDir "\clip.txt"
	FileDelete, %clip_path%
	ClipWait
	Fileappend,%clipboard%, %clip_path%, UTF-8
	priceFinderPath :=  A_ScriptDir "\price-finder.py"
	command := "python " """" priceFinderPath """"
	MsgBox, % RunWaitOne(command)
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
		send {f3}
		return
	}
	BlockInput On
	SetDefaultMouseSpeed 0
	sendinput {esc}
	sleep 50
	MouseClick, left, 959, 432, 1, 1
	sleep 100
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
	if (colorKaomBack != 0x1A181C and colorKaomBack != 0x1f2328) {
		Send {i}
		Sleep 30
		return true
	} else {
		return false
	}
}

SwitchConc() {
	if (isPoeClosed()) {
		send {f5}
		return
	}
	concX := calcX(1877)
	concY := calcY(615)
	gemX := calcX(1613)
	gemY := calcY(359)
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	
	Click left %concX%, %concY%
	Sleep 1
	Click left %gemX%, %gemY%
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
	if (isPoeClosed()) {
		send f
		return
	}
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	bloodRGemX := 1766
	bloodRGemY := 199
	Click right %bloodRGemX%, %bloodRGemY%
	sleep 100
	Click left %bloodRGemX%, %bloodRGemY%
	sleep 10
	if (closeInvAfter) {
		Send {i}
	}
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
	Click right 1824,613
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

