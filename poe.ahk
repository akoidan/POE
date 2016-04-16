Loop {
	if (not isPoeClosed() and isLowHp()) {
		send {1}
	}
	Sleep, 100
}

global debugInited := false
global Debug
global charActive := false

isLowHp() {
	PixelGetColor, lowHpColor, 124, 1005
	return isCharacterActive() and getColor(lowHpColor) != "r" 
}

isCharacterActive() {
	PixelGetColor, colorTopManaBorder, 1890, 913
	PixelGetColor, colorShop, 1458, 1000
	colorShopSat := getColor(colorShop)
	colorManaBorderSat := getColor(colorTopManaBorder)
	newCharActiveStatus := colorManaBorderSat == "grey" and colorShopSat == "g"
	if (not charActive and newCharActiveStatus) {
		sleep 1000 ; delay if it wasn't active for outside functions like @isLowHp()
	}
	charActive := newCharActiveStatus
	return charActive
}

getColor(color) {
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
	} else if (blue + satur < red and green + satur < red) {
		colorReal := "r"
	} else if (red + satur < green and blue + satur < green) {
		colorReal := "g"
	} else if (red + satur < blue and green + satur < blue) {
		colorReal := "b"
	} else {
		colorReal := "u" ;unknown
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


$F1::Remaining()
$F2::DrinkFlask()
$F3::SwitchBoth()
$F4::OpenPortal()
$f12::reload

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
	MouseClick, left, 959, 432, 1, 1
	BlockInput Off
	return
}



isPoeClosed() {
	IfWinNotActive , Path of Exile 
	{ 
		return true
	}
}

OpenInventory() {
	PixelGetColor, colorKaomBack, 1581, 366
	if (colorKaomBack != 0x200706) {
		Send {i}
		return true
	} else {
		return false
	}
}

SwitchBoth() {
	if (isPoeClosed()) {
		send {f3}
		return
	}
	MouseGetPos, xpos, ypox
	BlockInput On
	closeInvAfter := OpenInventory()
	Click left 1877, 776
	Sleep 1
	PixelGetColor, middleLeftSocketColor, 1350, 225
	if (getColor(middleLeftSocketColor) != "r") {
		send {x}
		sleep 50
	}
	Click left 1405, 226
	Sleep 1
	Click left 1877, 776
	Click left 1819, 776
	Sleep 1
	Click left 1482, 370
	Sleep 1
	Click left 1819, 776
	if (closeInvAfter) {
		Send {i}
	}
	MouseMove xpos, ypox 
	BlockInput Off
	return
}


OpenPortal(){
	if (isPoeClosed()) {
		send {f4}
		return
	}
	MouseGetPos, xpos, ypox
	BlockInput On
	OpenInventory()
	Click right 1881,838 
	Send {i}
	Sleep 1
	Click left 960, 450 
	BlockInput Off
	return
}

DrinkFlask() {
	if (isPoeClosed()) {
		send {f2}
		return
	}
	Send {2}
	Send {3}
	Send {4}
	Send {5}
}


