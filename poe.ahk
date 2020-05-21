#MaxThreadsPerHotkey 10

~2::DrinkFlask()
$F1::OpenHideout()
$F2::SwitchDrinkFlaskStatus()
$F3::FastLogOut()
$F4::OpenPortal()
$F5::startCheckLowLife()
$F6::turnOnAuras()
;$F5::switchGems([{ "srcX" : 1855, "srcY" : 726, "dstX": 1587 , "dstY":  314}], true) ; body armour
$F7::startStopPrintMessage()
$f8::reloadScript()

global debugInited := false
global Debug
global charActive := false
global winX
global winY
global winWidth := 0
global winHeight
global drinkFlaskIsActive := true
global printScreamMessage := false
global removeFriend := false
global printScreamMessageInited := false
global printMessageIsRunning
global chrNum := 1
global checkLowLifeStatus := true


translateCoordinatesFrom( ByRef x,  ByRef  y  ) {
	activeMonitorInfo( width , height )
	translateCoordinatesFromWithHeightAndWidth(x, y, width, height)
}

translateXFrom(x, width) {
   return Round(width * x / 2560)
}

translateYFrom(y, height) {
   return Round(height * y / 1440)
}

translateCoordinatesFromWithHeightAndWidth( ByRef x,  ByRef  y , width , height ) {
	x := translateXFrom(x, width)
	y := translateYFrom(y, height)
}

SwitchDrinkFlaskStatus() {
  drinkFlaskIsActive := !drinkFlaskIsActive
}

startStopPrintMessage() {
	if (printMessageIsRunning) {
		printMessageIsRunning := false
	} else {
		printMessage()
	}
}

activeMonitorInfo(ByRef Width,  ByRef  Height  ) { ; retrieves the size of the monitor, the mouse is on
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX , mouseY
	SysGet, monCount, MonitorCount
	Loop %monCount%
    { 	SysGet, curMon, Monitor, %a_index%
        if ( mouseX >= curMonLeft and mouseX <= curMonRight and mouseY >= curMonTop and mouseY <= curMonBottom )
            {
				Height := curMonBottom - curMonTop
				Width  := curMonRight  - curMonLeft
				return
			}
    }
}

startCheckLowLife() {
	if (checkLowLifeStatus) {
		checkLowLifeStatus := false
	} else {
		checkLowLife()
	}
	
}
checkLowLife() {
	
	MsgBox, "checkLowLife is running"
	checkLowLifeStatus := true

    width := 0
    height := 0
	activeMonitorInfo( width , height )
	translateCoordinatesFromWithHeightAndWidth(x, y, width, height)
	
	Loop {
	
		if (not isPoeClosed()) {
			if (not checkLowLifeStatus) {
				MsgBox, "Exiting from checking low life"
				return
			}
			if (isLowHp(width, height)) {
				send {1}
				Sleep, 300
			}
			Sleep, 100
		}
	}
}


getColorRgb(foundColor) {
	Red:="0x" SubStr(foundColor,3,2) ;substr is to get the piece
	Red:=Red+0 ;add 0 is to convert it to the current number format
	Green:="0x" SubStr(foundColor,5,2)
	Green:=Green+0
	Blue:="0x" SubStr(foundColor,7,2)
	Blue:= Blue+0
	difference := 2
	summ := Blue + Red + Green
	if (Blue / difference > Red and Blue / difference > Green) {
	   return "b"
	} else if (Green / difference > Red and Green / difference > Blue) {
		return "g"
	} else if (Red / difference > Blue and Red / difference > Green) {
		return "r"
	} else if ( summ > Red * 2 and summ > Blue * 2 and summ > Green * 2 and summ / 6 < Red and summ / 6 < Blue and summ / 6 < Green)  {
		return "black" 
	} else {
	    return "unknown"
	}

}

isLowHp(width, height) {
	x := 434
	y := 1410
	translateCoordinatesFrom(x,y)
	PixelGetColor, flaskColor, x, y, rgb
	flaskHue := getColorRgb(flaskColor)
	if (flaskHue = "r" ) {
		x := 165
		y := 1345
		translateCoordinatesFromWithHeightAndWidth(x,y, width, height)
		PixelGetColor, lowHpColor, x, y
		lifeHue := getColor(lowHpColor)
		return lifeHue != "r" 
	} else {
		return false
	}
}

PrintLol() {
	o := Object()

	for index, element in o {		
 		send {Enter}		
 		sleep 100		
 		send, %element%		
 		send {Enter}		
 		sleep 2000		
  	}
}

printMessage() {
	o := Object()
	o.Insert(" (6)")
	o.Insert(" (5)")
	o.Insert(" (4)")
	o.Insert(" (3)")
	o.Insert(" (2)")
	o.Insert(" (1)")
	o.Insert("")

	price_path := "empty"
	for index, element in o { 
		p :=  UserProfile "\Downloads\buyItemsList" element ".txt"
		if (FileExist(p)) {
			if (price_path = "empty") {
				price_path := p
			} else {
				FileDelete, %p%
			}
		}
	}
	if (price_path != UserProfile "\Downloads\buyItemsList.txt" and price_path != "empty") {
		FileMove, %price_path%,  %UserProfile%\Downloads\buyItemsList.txt
		price_path := UserProfile "\Downloads\buyItemsList.txt"
	}
	
	printMessageIsRunning := true
	Loop, read, %price_path%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			if not printMessageIsRunning
				Goto, MyLabel
			send {Enter}
			sleep 100
			
			; get utf8 encoding
			vSize := StrPut(A_LoopField, "CP0")
			VarSetCapacity(vUtf8, vSize)
			vSize := StrPut(A_LoopField, &vUtf8, vSize, "CP0")
			StrGet(&vUtf8, "UTF-8")
		    send %  StrGet(&vUtf8, "UTF-8")
			
			send {Enter}
			sleep 100
		}
	}
	;FileDelete, %price_path%
	MyLabel:
	printMessageIsRunning := false
	sleep 1
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
		Loop, %interval% {
			if (A_Index = 1) {
				send {Escape}
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
					ClipWait
					if InStr(Clipboard, "Dread Spell") {
						send {enter}
					} else { 
						send {enter}
						printScreamMessage := false
						MsgBox, %Clipboard%
						return
					}
					sleep 100
				}
				send {enter}
				sleep 100
				;click left 245 293
				click left 257 391
			} 
			if (not printScreamMessage) {
				MsgBox, Trade Off
				return
			}
			sleep 1000
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
	Red:="0x" SubStr(color,3,2) ;substr is to get the piece
	Red:=Red+0 ;add 0 is to convert it to the current number format
	Green:="0x" SubStr(color,5,2)
	Green:=Green+0
	Blue:="0x" SubStr(color,7,2)
	Blue:=Blue+0
	satur := 35
	diff := sqrt((blue - green)*(blue - green) + (blue - red)*(blue - red) + (red - green)*(red - green))
	if (color == 0x000000) {
		colorReal := "black"
	} else if (color == 0xFFFFFF){
		colorReal := "white" 
	} else if (diff < 8) {
		colorReal := "grey"
	} else if (red < 10 and green > 40 and green < 60 and red > 100 and red < 200) {
		colorReal := "brown"
	} else if (red + satur < blue and green + satur < blue) {
		colorReal := "r"
	} else if (blue + satur < green and red + satur < green) {
		colorReal := "g"
	} else if (blue + satur < red and green + satur < red) {
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

turnOnAuras() {
    width := 0
    height := 0
	activeMonitorInfo( width , height )

    xCoord := [translateXFrom(1921, width), translateXFrom(2012, width), translateXFrom(2098, width)]
	yStart := translateYFrom(420, height)
	yDiff := translateYFrom(79, height)
	
	qX := 1923
	qy := 1395

	translateCoordinatesFromWithHeightAndWidth(qX, qY, width, height)

	MouseGetPos, xpos, ypox
	BlockInput On
	
	Loop, 11 {
	    currentYIndex := A_index - 1
        for i, xCurrent in xCoord {
            yCurrent := currentYIndex * yDiff + yStart
			Sleep 50 
			Click left %qx%, %qy%
			Sleep 50
			Click left %xCurrent%, %yCurrent%
			Sleep 20
			Send {q}			
     	}
    }
	MouseMove xpos, ypox 
	BlockInput Off
}

reloadScript() {
	Reload
}

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


FastLogOut(){
	BlockInput On
	SetDefaultMouseSpeed 0
	sendinput {esc}
	sleep 50
	x := 1288
	y := 577
	translateCoordinatesFrom(x, y)
	MouseClick, left, x, y, 1, 1
	;sleep 100
	;MouseClick, left, 959, 432, 1, 1
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
	PixelGetColor, colorKaomBack, 1628, 484
	if (colorKaomBack != 0x200809) {
		Send {i}
		Sleep 30
		return true
	} else {
		return false
	}
}


switchGems(coordinates, isM2) {
	if (isPoeClosed()) {
		send %key%
		return
	}
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	
	for i, element in coordinates {
		srcX := element.srcX
		srcY := element.srcY
		dstX := element.dstX
		dstY := element.dstY
		if (srcY > 587) {
			Click left %srcX%, %srcY%
		} else {
			Click right %srcX%, %srcY%
		}
		if (isM2) {
			Click left %srcX%, %srcY%
		} else {
			Click right %srcX%, %srcY%
		}
		
		Sleep 20
		Click left, %dstX%, %dstY%
		Sleep 20
		Click left, %srcX%, %srcY%
		Sleep 20
	}
	
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


OpenPortal(){
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	x := 2500
	y := 820
	translateCoordinatesFrom(x, y)
	Click right %x%, %y%
	x := 836
	y := 551
	Click left %x%, %y%
	BlockInput Off
	return
}

DrinkFlask() {
    if (not drinkFlaskIsActive) {
		;send {f1}
		return
	}
	send {6}
	send {7}
	Send {8}
	Send {9}
}