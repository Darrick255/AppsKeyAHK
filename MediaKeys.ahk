#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines, 10ms

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;^!Left::Send   {Media_Prev}
;^!Down::Send   {Media_Play_Pause}
;^!Up::Send   {Media_Stop}
;^!Right::Send  {Media_Next}
;+^!Left::Send  {Volume_Down}
;+^!Down::Send  {Volume_Mute}
;+^!Right::Send {Volume_Up}


; Volume On-Screen-Display (OSD) -- by Rajat
; http://www.autohotkey.com
; This script assigns hotkeys of your choice to raise and lower the
; master and/or wave volume.  Both volumes are displayed as different
; color bar graphs.

;_________________________________________________ 
;_______User Settings_____________________________ 

; Make customisation only in this area or hotkey area only!! 

; The percentage by which to raise or lower the volume each time:
vol_Step = 2

; How long to display the volume level bar graphs:
vol_DisplayTime = 2000

; Master Volume Bar color (see the help file to use more
; precise shades):
vol_CBM = Red

; Wave Volume Bar color
vol_CBW = Blue

; Background color
vol_CW = Silver


;examples for myself
;x1 := A_ScreenWidth - w
;y1 := A_ScreenHeight - h


; Bar's screen position.  Use -1 to center the bar in that dimension:
vol_Width = 150  ; width of bar
vol_Thick = 12   ; thickness of bar
vol_PosX =  % A_ScreenWidth - vol_Width
vol_PosY =  % A_ScreenHeight - vol_Thick - 52

; If your keyboard has multimedia buttons for Volume, you can
; try changing the below hotkeys to use them by specifying
; Volume_Up, ^Volume_Up, Volume_Down, and ^Volume_Down:
HotKey, Appskey & Up, vol_MasterUp      ; Win+UpArrow
HotKey, Appskey & Down, vol_MasterDown
HotKey, +#Up, vol_WaveUp       ; Shift+Win+UpArrow
HotKey, +#Down, vol_WaveDown


;___________________________________________ 
;_____Auto Execute Section__________________ 

; DON'T CHANGE ANYTHING HERE (unless you know what you're doing).

vol_BarOptionsMaster = 1:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBM% CW%vol_CW%
vol_BarOptionsWave   = 2:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBW% CW%vol_CW%

; If the X position has been specified, add it to the options.
; Otherwise, omit it to center the bar horizontally:
if vol_PosX >= 0
{
	vol_BarOptionsMaster = %vol_BarOptionsMaster% X%vol_PosX%
	vol_BarOptionsWave   = %vol_BarOptionsWave% X%vol_PosX%
}

; If the Y position has been specified, add it to the options.
; Otherwise, omit it to have it calculated later:
if vol_PosY >= 0
{
	vol_BarOptionsMaster = %vol_BarOptionsMaster% Y%vol_PosY%
	vol_PosY_wave = %vol_PosY%
	vol_PosY_wave += %vol_Thick%
	vol_BarOptionsWave = %vol_BarOptionsWave% Y%vol_PosY_wave%
}




;******************************************************************************

GroupAdd All

Menu Case, Add, &UPPERCASE, CCase
Menu Case, Add, &lowercase, CCase
Menu Case, Add, &Title Case, CCase
Menu Case, Add, &Sentence case, CCase
Menu Case, Add
Menu Case, Add, &Fix Linebreaks, CCase
Menu Case, Add, &Reverse, CCase

;******************************************************************************



; Retrieves saved clipboard information since when this script last ran
; Set the following to 1 before changing the clipboard to
; make multi-clipboard ignore the change.  This is useful when
; this script is include inside another script that messes
; with the clipboard.
clipindex :=0
IgnoreClipboardChange := True
if(IgnoreClipboardChange = True)
{
	Loop C:\tmp\ahkCliboardHistory\clipvar*.bin
	{
		clipindex += 1
		;  MsgBox, %clipindex% load
		FileRead clipvar%A_Index%, *c %A_LoopFileFullPath%
		FileDelete %A_LoopFileFullPath%
	}
	FileRead HiddenWins, C:\tmp\ahkCliboardHistory\windowHist.txt
	FileDelete C:\tmp\ahkCliboardHistory\windowHist.txt
	maxindex := clipindex
}
OnExit ExitSub
IgnoreClipboardChange := False
Return ;end of auto execute


;___________________________________________ 

vol_WaveUp:
SoundSet, +%vol_Step%, Wave
Gosub, vol_ShowBars
return

vol_WaveDown:
SoundSet, -%vol_Step%, Wave
Gosub, vol_ShowBars
return

vol_MasterUp:
SoundSet, +%vol_Step%
Gosub, vol_ShowBars
return

vol_MasterDown:
SoundSet, -%vol_Step%
Gosub, vol_ShowBars
return

vol_ShowBars:
; To prevent the "flashing" effect, only create the bar window if it
; doesn't already exist:
IfWinNotExist, vol_Wave
	Progress, %vol_BarOptionsWave%, , , vol_Wave
IfWinNotExist, vol_Master
{
	; Calculate position here in case screen resolution changes while
	; the script is running:
	if vol_PosY < 0
	{
		; Create the Wave bar just above the Master bar:
		WinGetPos, , vol_Wave_Posy, , , vol_Wave
		vol_Wave_Posy -= %vol_Thick%
		Progress, %vol_BarOptionsMaster% Y%vol_Wave_Posy%, , , vol_Master
	}
	else
		Progress, %vol_BarOptionsMaster%, , , vol_Master
}
; Get both volumes in case the user or an external program changed them:
SoundGet, vol_Master, Master
SoundGet, vol_Wave, Wave
Progress, 1:%vol_Master%
Progress, 2:%vol_Wave%
SetTimer, vol_BarOff, %vol_DisplayTime%
return

vol_BarOff:
SetTimer, vol_BarOff, off
Progress, 1:Off
Progress, 2:Off
return
;end visuals

AppsKey::
	;Keep AppsKey working (mostly) normally.
	Send {AppsKey}
Return

;beggining of clipboard
; Clears the history by resetting the indices
^+NumpadClear::
^+Numpad5::
^+5::
	tooltip clipboard history cleared
	SetTimer, ReSetToolTip, 1000
	loop, %maxindex%
	{
		clipvar%A_Index% := ""
	}
	maxindex = 0
	clipindex = 0
Return

; Scroll up and down through clipboard history
^+X::
	IgnoreClipboardChange := True
	if (clipindex > 1 and IgnoreClipboardChange = True)
	{
		;  MsgBox, inside
		clipindex -= 1
		thisclip := clipvar%clipindex%
		clipboard := thisclip
		sleep 50
		tooltip %clipindex% - %clipboard%
		SetTimer, ReSetToolTip, 1000
	}
	IgnoreClipboardChange := False
Return

^+C::
	IgnoreClipboardChange := True
	if (clipindex < maxindex and IgnoreClipboardChange = True)
	{
		clipindex += 1
		thisclip := clipvar%clipindex%
		clipboard := thisclip
		sleep 50
		tooltip %clipindex% - %clipboard%
		SetTimer, ReSetToolTip, 1000
	}
	IgnoreClipboardChange := False
Return

;Paste And move Forward one
^+V::
	IgnoreClipboardChange := True
	Send ^v
	if (clipindex < maxindex  and IgnoreClipboardChange = True)
	{
		clipindex += 1
	}
	thisclip := clipvar%clipindex%
	clipboard := thisclip
	IgnoreClipboardChange := False
	tooltip %clipindex% - %clipboard%
	SetTimer, ReSetToolTip, 1000
	Sleep 200
Return

^+1::
	repeat:=50
	tooltip Repeat Timer Changed - %repeat%
	SetTimer, ReSetToolTip, % repeat
return
^+2::
	repeat:= repeat - 25
	tooltip Repeat Timer Changed - %repeat%
	SetTimer, ReSetToolTip, % repeat
return
^+3::
	repeat:=repeat +50
	tooltip Repeat Timer Changed - %repeat%
	SetTimer, ReSetToolTip, % repeat
return
^+4::
	repeat:=200
	tooltip Repeat Timer Changed - %repeat%
	SetTimer, ReSetToolTip,% repeat
return

;Paste And move Forward one
^+R::
	IgnoreClipboardChange := True
	clipboard = %clipboard%
	Clipboard := regexreplace(Clipboard, "\r\n?|\n\r?", "`n")
	Send, {Shift Up}{Ctrl Up}{V Up}
	Send, %clipboard%
	Send, {Shift Down}{Ctrl Down}{V Up}
	if clipindex < %maxindex%
	{
		clipindex += 1
	}
	thisclip := clipvar%clipindex%
	clipboard := thisclip
	IgnoreClipboardChange := False
	tooltip %clipindex% - %clipboard%
	SetTimer, ReSetToolTip, 1000
	sleep repeat
Return
;https://autohotkey.com/board/topic/58230-how-to-slow-down-send-commands/
;send event type slow

;  ^C::
;  ^X::
;  return

OnClipboardChange:
If (IgnoreClipboardChange = False)
{
	clipindex := maxindex
	clipindex += 1
	clipvar%clipindex% := clipboardAll
	thisclip := clipvar%clipindex%
	tooltip %clipindex% - %clipboard%
	SetTimer, ReSetToolTip, 1000
	if clipindex > %maxindex%
	{
		maxindex := clipindex
	}
}
return

; Clear the ToolTip
ReSetToolTip:
	ToolTip
	SetTimer, ReSetToolTip, Off
return

;load into clipboard history
^+Z::
GetText(TempText)
TempText2 := ""
clipindex := maxindex
Loop, parse, TempText, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
{
	clipindex += 1
	clipvar%clipindex% := A_LoopField
}
lineCount:= clipindex-maxindex
	tooltip %clipindex%(total) - %lineCount% lines have been Appened to Clipboard History `r`n %TempText%
	SetTimer, ReSetToolTip, 2500
	maxindex := clipindex
	clipindex := maxindex-lineCount
Return


Appskey & left::
If GetKeyState("Shift","p")
 MouseMove, -1, 0, 0, R
else 
 Send {Media_Prev}
Return 

Appskey & Right::
If GetKeyState("Shift","p")
 MouseMove, 1, 0, 0, R
else 
 Send {Media_Next}
Return

Appskey & space::
Send {Media_Play_Pause}
Return

;AppsKey & Shift & Left::MouseMove, -1, 0, 0, R
;AppsKey & Shift & Right::MouseMove, 1, 0, 0, R
;AppsKey & Shift & Up::MouseMove, 0, -1, 0, R
;AppsKey & Shift & Down::MouseMove, 0, 1, 0, R



Appskey & `::
;^!.::
MsgBox, 0, ,
(
	Guide, appskey + key=
	`` : This help menu.
	a : Always on top on
	A : Always on top off
	b : Powermanager switch off display
	t : Make 50`% transparent
	T : Make fully Visible
	v : Paste clipboard as plain text
	w : Wrap tect at input value(70)
	x : Power state menu
	/ : RegEx replace
	, : input tag and attributes. HTML Format
	[ : input tag and attributes. BB format
	. : Hide window
	S. : reveal windows hidden
	F4: Force close window
	r : Reload Script.

	LA+LS+tilde: restore windows

	LM: allows click draging of window without clicking on tile bar

	UP    : Volume up.
	DOWN  : Volume Down.
	RIGHT : Next Track.
	LEFT  : Previous Track.
	SPACE : Play/Pause.

	ClipBoard Stuff
	Ctrl+C, Ctrl+X             : Add to clipboard history
	Ctrl+Shift+C, Ctrl+Shift+X : Move though Clipboard History
	Ctrl+Shift+5               : Clear history
	Ctrl+Shift+Z               : Load highlighted text into clipboard history line by line

	Ctrl+Shift+V : paste clipboard and go forward one
	Ctrl+Shift+R : paste clipboard(raw? see next link) and go forward one
	https://autohotkey.com/docs/commands/Send.htm

	#	Win (Windows logo key).
	!	Alt    < Use the left key of the pair.
	^	Control    > Use the right key of the pair.
	+	Shift   & between two keys to combine them

	Also See https://github.com/Darrick255/AppsKeyAHK
)
;MsgBox, 0, , % A_ScreenWidth - vol_Width - vol_Width
return
AppsKey & escape::
	if (ShowTray)
		Menu, Tray, NoIcon
	else
		Menu, Tray, Icon
	ShowTray := !ShowTray
	return

AppsKey & F4::
MyWin := WinExist("A")
WinGetTitle TempText, ahk_id %MyWin%
If NOT TempText ;Prevents terminated the taskbar, or the like.
	 Return
If NOT GetKeyState("shift")
{
	 WinGetTitle TempText, ahk_id %MyWin%
	 MsgBox 49, Terminate!, Terminate "%TempText%"?`nUnsaved data will be lost.
	 IfMsgBox Cancel
			Return
}
WinGet MyPID, PID, ahk_id %MyWin%
Process, Close, %MyPID%
Return

AppsKey & CapsLock::
IgnoreClipboardChange:=True
if(IgnoreClipboardChange = True)
	GetText(TempText)
If NOT ERRORLEVEL
	 Menu Case, Show
Return

AppsKey & a::
If NOT IsWindow(WinExist("A"))
	 Return
WinGetTitle, TempText, A
If GetKeyState("shift")
{
	 WinSet AlwaysOnTop, Off, A
	 If (SubStr(TempText, 1, 2) = "† ")
			TempText := SubStr(TempText, 3)
}
else
{
	 WinSet AlwaysOnTop, On, A
	 If (SubStr(TempText, 1, 2) != "† ")
			TempText := "† " . TempText ;chr(134)
}
WinSetTitle, A, , %TempText%
Return

AppsKey & b::
SendMessage, 0x112, 0xF170, -1,, Program Manager
Sleep 1000
SendMessage, 0x112, 0xF170, 1,, Program Manager
Return

AppsKey & t::
If NOT IsWindow(WinExist("A"))
	 Return
If GetKeyState("shift")
	 Winset, Transparent, OFF, A
else
	 Winset, Transparent, 128, A
Return

AppsKey & v::
TempText := ClipBoard
If (TempText != "")
	 PutText(ClipBoard)
Return

AppsKey & w::
GetText(TempText)
If NOT WrapWidth
	 WrapWidth := "70"
If GetKeyState("shift")
	 StringReplace TempText, TempText, %A_Space%`r`n, %A_Space%, All
else
{
	 Temp2 := SafeInput("Enter Width", "Width:", WrapWidth)
	 If ErrorLevel
			Return
	 WrapWidth := Temp2
	 Temp2 := "(?=.{" . WrapWidth + 1 . ",})(.{1," . WrapWidth - 1 . "}[^ ]) +"
	 TempText := RegExReplace(TempText, Temp2, "$1 `r`n")
}
PutText(TempText)
Return

AppsKey & x::
SplashImage, , MC01, (S) Shutdown`n(R) Restart`n(L) Log Off`n(H) Hibernate`n(P) Power Saving Mode`n`nPress ESC to cancel., Press A Key:, Shutdown?, Courier New
Input TempText, L1
SplashImage, Off
If (TempText = "S")
	 ShutDown 8
Else If (TempText = "R")
	 ShutDown 2
Else If (TempText = "L")
	 ShutDown 0
Else If (TempText = "H")
	 DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
Else If (TempText = "P")
	 DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

AppsKey & /::
; RegEx Replace
TempText := SafeInput("Enter Pattern", "RegEx Pattern:", REPatern)
If ErrorLevel
	 Return
Temp2 := SafeInput("Enter Replacement", "Replacement:", REReplacement)
If ErrorLevel
	 Return
REPatern := TempText
REReplacement := Temp2
GetText(TempText)
TempText := RegExReplace(TempText, REPatern, REReplacement)
PutText(TempText)
Return

AppsKey & ,::
TempText := SafeInput("Enter Tag", "Example: a href=""http://www.autohotkey.com/""", HTFormat)
If ErrorLevel
	 Return
If SubStr(TempText, 1, 4) = "http"
	 TempText = a href="%TempText%"
HTFormat := TempText
GetText(Temp2)
Temp2 := "<" . TempText . ">" . Temp2
TempText := RegExReplace(TempText, " .*")
Temp2 := Temp2 . "</" . TempText . ">"
PutText(Temp2)
Return

AppsKey & [::
TempText := SafeInput("Enter Tag", "Example: color=red", BBFormat)
If ErrorLevel
	 Return
If SubStr(TempText, 1, 4) = "http"
	 TempText = url=%TempText%
BBFormat := TempText
GetText(Temp2)
If SubStr(TempText, 1, 4) = "list" AND NOT InStr(Temp2, "[*]")
	 Temp2 := RegExReplace(Temp2, "m`a)^(\*\s*)?", "[*]")
Temp2 := "[" . TempText . "]" . Temp2
TempText := RegExReplace(TempText, "=.*")
Temp2 := Temp2 . "[/" . TempText . "]"
PutText(Temp2)
Return

AppsKey & .::
If GetKeyState("shift")
{
	 Loop Parse, HiddenWins, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins =
}
else
{
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWins .= (HiddenWins ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
}
Return

AppsKey & \::
GetText(TempText)
FullText := 
loop Parse ,TempText, " "
{
MsgBox, %A_LoopField%
	if((A_LoopField is upper) or (A_LoopField is lower))
	{
		StringLower, TempWord, A_LoopField, T
		FullText.=TempWord . " "
		}
	else {
		FullText.=A_LoopField . " "
	}
}
PutText(FullText)
return

AppsKey & c::
Drive Eject,, % GetKeyState("shift")
Return

AppsKey & e::Edit

<^`::
If GetKeyState("shift")
{
	 Loop Parse, HiddenWins3, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins3 =
}
else
{
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWins3 .= (HiddenWins3 ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
}
Return


<^1::
MsgBox,  A_CaretX and A_CaretY
If GetKeyState("shift")
{
	 Loop Parse, HiddenWins3, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins3 =
}
else
{
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWins3 .= (HiddenWins3 ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
}
Return

<!`::
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWins3 .= (HiddenWins3 ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
Return

<!<+~::
	 Loop Parse, HiddenWins, |
			WinShow ahk_id %A_LoopField%
	 Loop Parse, HiddenWins2, |
			WinShow ahk_id %A_LoopField%
	 Loop Parse, HiddenWins3, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins3 =
Return

AppsKey & h::
If GetKeyState("shift")
{
	 Loop Parse, HiddenWinsh, |
			WinShow ahk_id %A_LoopField%
	 HiddenWinsh =
}
else
{
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWinsh .= (HiddenWinsh ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
}
Return

$RButton::
	KeyWait,LButton,DT0.3
	If !ErrorLevel {
		KeyWait,RButton
		If GetKeyState("shift")
{
	 Loop Parse, HiddenWins3, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins3 =
}
else
{
	 MyWin := WinExist("A")
	 if IsWindow(MyWin) 
	 {
			HiddenWins3 .= (HiddenWins3 ? "|" : "") . MyWin
			WinHide ahk_id %MyWin%
			GroupActivate All
	 }
}
Return
	}
	Send {RButton Down}
	KeyWait,RButton
	Send {RButton Up}
Return

AppsKey & r::
KeyWait AppsKey
IfWinActive %A_ScriptName%
	 Send ^s ;Save
Reload
Return


AppsKey & LButton::
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
if EWD_WinState = 0  ; Only if the window isn't maximized 
		SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

AppsKey & z::
DetectHiddenWindows, On
;WinGet, allwins, list,,, Program Manager
;Loop, %allwins%
{
		;thiswin := allwins%A_Index%
		;WinActivate, ahk_id %thiswin%
	;WinShow ahk_id %thiswin%
}
DetectHiddenWindows, Off
return


EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
		SetTimer, EWD_WatchMouse, off
		return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
		SetTimer, EWD_WatchMouse, off
		WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
		return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return



;BEGIN TESTING =======================================================

WTSEnumProcesses( Mode := 1 ) { ;        By SKAN,  http://goo.gl/6Zwnwu,  CD:24/Aug/2014 | MD:25/Aug/2014 
	Local tPtr := 0, pPtr := 0, nTTL := 0, LIST := ""

	If not DllCall( "Wtsapi32\WTSEnumerateProcesses", "Ptr",0, "Int",0, "Int",1, "PtrP",pPtr, "PtrP",nTTL )
		Return "", DllCall( "SetLastError", "Int",-1 )        
				 
	tPtr := pPtr
	Loop % ( nTTL ) 
		LIST .= ( Mode < 2 ? NumGet( tPtr + 4, "UInt" ) : "" )           ; PID
				 .  ( Mode = 1 ? A_Tab : "" )
				 .  ( Mode > 0 ? StrGet( NumGet( tPtr + 8 ) ) "`n" : "," )   ; Process name  
	, tPtr += ( A_PtrSize = 4 ? 16 : 24 )                              ; sizeof( WTS_PROCESS_INFO )  
	
	StringTrimRight, LIST, LIST, 1
	DllCall( "Wtsapi32\WTSFreeMemory", "Ptr",pPtr )      

Return LIST, DllCall( "SetLastError", "UInt",nTTL ) 
}

;END TESTING =========================================================



;=====================================
;  Functions
;=====================================

;******************************************************************************
CCase:
If (A_ThisMenuItemPos = 1)
	 StringUpper, TempText, TempText
Else If (A_ThisMenuItemPos = 2)
	 StringLower, TempText, TempText
Else If (A_ThisMenuItemPos = 3)
	 StringLower, TempText, TempText, T
Else If (A_ThisMenuItemPos = 4)
{
	 StringLower, TempText, TempText
	 TempText := RegExReplace(TempText, "((?:^|[.!?]\s+)[a-z])", "$u1")
} ;Seperator, no 5
Else If (A_ThisMenuItemPos = 6)
{
	 TempText := RegExReplace(TempText, "\R", "`r`n")
}
Else If (A_ThisMenuItemPos = 7)
{
	 Temp2 =
	 StringReplace, TempText, TempText, `r`n, % Chr(29), All
	 Loop Parse, TempText
			Temp2 := A_LoopField . Temp2
	 StringReplace, TempText, Temp2, % Chr(29), `r`n, All
}
PutText(TempText)
Return

;******************************************************************************
;  https://autohotkey.com/board/topic/35566-rapidhotkey/
;  Double tap hotkeys function

RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
	Pattern := Morse(delay*1000)
	If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
		Return
	If (times = "" and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""	
			If (StrLen(Pattern) = A_Index+1)
				continue := A_Index, times := StrLen(Pattern)
	}
	Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
	{
		Loop, Parse, keystroke,""
			If (StrLen(Pattern) = A_Index+times-1)
				times := StrLen(Pattern), continue := A_Index
	}
	Else if InStr(times, """")
	{
		Loop, Parse, times,""
			If (StrLen(Pattern) = A_LoopField)
				continue := A_Index, times := A_LoopField
	}
	Else if (times = "")
		continue := 1, times := 2
	Else if (times = StrLen(Pattern))
		continue = 1
	If !continue
		Return
	Loop, Parse, keystroke,""
		If (continue = A_Index)
			keystr := A_LoopField
	Loop, Parse, IsLabel,""
		If (continue = A_Index)
			IsLabel := A_LoopField
	hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
	IfInString, hotkey, %A_Space%
		StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
	backspace := "{BS " times "}"
	keywait = Ctrl|Alt|Shift|LWin|RWin
	Loop, Parse, keywait, |
		KeyWait, %A_LoopField%
	If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
	, "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Alt|LAlt|RAlt|Escape|BackSpace|F\d\d?|"
	. "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
	. "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
	. "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
	. "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
		Send % backspace
	If (WinExist("AHK_class #32768") and hotkey = "RButton")
		WinClose, AHK_class #32768
	If !IsLabel
		Send % keystr
	else if IsLabel(keystr)
		Gosub, %keystr%
	Return
}	
Morse(timeout = 400) { ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951 (Modified to return: KeyWait %key%, T%tout%)
	 tout := timeout/1000
	 key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
	 IfInString, key, %A_Space%
		StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
	If Key in Shift,Win,Ctrl,Alt
		key1:="{L" key "}{R" key "}"
	 Loop {
			t := A_TickCount
			KeyWait %key%, T%tout%
		Pattern .= A_TickCount-t > timeout
		If(ErrorLevel)
			Return Pattern
		If key in Capslock,LButton,RButton,MButton,ScrollLock,CapsLock,NumLock
			KeyWait,%key%,T%tout% D
		else if Asc(A_ThisHotkey)=36
		KeyWait,%key%,T%tout% D
		else
			Input,pressed,T%tout% L1 V,{%key%}%key1%
	If (ErrorLevel="Timeout" or ErrorLevel=1)
		Return Pattern
	else if (ErrorLevel="Max")
		Return
	 }
}
;  ************************************************************************************
;  Get stack information 
;  fragman https://autohotkey.com/board/topic/76062-ahk-l-how-to-get-callstack-solution/

CallStack(deepness = 5, printLines = 1)
{
	loop % deepness
	{
		lvl := -1 - deepness + A_Index
		oEx := Exception("", lvl)
		oExPrev := Exception("", lvl - 1)
		FileReadLine, line, % oEx.file, % oEx.line
		if(oEx.What = lvl)
			continue
		stack .= (stack ? "`n" : "") "File '" oEx.file "', Line " oEx.line (oExPrev.What = lvl-1 ? "" : ", in " oExPrev.What) (printLines ? ":`n" line : "") "`n"
	}
	return stack
}
;******************************************************************************
; Handy function.
; Copies the selected text to a variable while preserving the clipboard.
GetText(ByRef MyText = "")
{
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange = True)
	{
		SavedClip := ClipboardAll
		Clipboard =
		Send ^c
		ClipWait 0.5
		If ERRORLEVEL
		{
			Clipboard := SavedClip
			MyText =
			IgnoreClipboardChange := False
			Return
		}
		MyText := Clipboard
		Clipboard := SavedClip
	}
	IgnoreClipboardChange := False
	Return MyText
}

; Pastes text from a variable while preserving the clipboard.
PutText(MyText)
{
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange = True)
	{
		sleep 50
		SavedClip := ClipboardAll 
		Clipboard =              ; For Better Compatability
		Sleep 20                 ; with Clipboard History
		Clipboard := MyText
		Send ^v
		Sleep 100
		Clipboard := SavedClip
		IgnoreClipboardChange := False
	}
	Return
}

;This makes sure sure the same window stays active after showing the InputBox.
;Otherwise you might get the text pasted into another window unexpectedly.
SafeInput(Title, Prompt, Default = "")
{
	 ActiveWin := WinExist("A")
	 InputBox OutPut, %Title%, %Prompt%,,, 120,,,,, %Default%
	 WinActivate ahk_id %ActiveWin%
	 Return OutPut
}

;This checks if a window is, in fact a window.
;As opposed to the desktop or a menu, etc.
IsWindow(hwnd) 
{
	 WinGet, s, Style, ahk_id %hwnd% 
	 return s & 0xC00000 ? (s & 0x80000000 ? 0 : 1) : 0
	 ;WS_CAPTION AND !WS_POPUP(for tooltips etc) 
}

; Saves the current clipboard history to hard disk
ExitSub:
SetFormat, float, 06.0
FileCreateDir, C:\tmp\ahkCliboardHistory
;C:\tmp\ahkCliboardHistory\clipvar*.txt
Loop %maxindex%
{
	zindex := SubStr("0000000000" . A_Index, -9)
	thisclip := clipvar%A_Index%
	FileAppend %thisclip%, C:\tmp\ahkCliboardHistory\clipvar%zindex%.bin
}
allWins .= (HiddenWins ? "|" : "") . HiddenWins
allWins .= (HiddenWins2 ? "|" : "") . HiddenWins2
allWins .= (HiddenWins3 ? "|" : "") . HiddenWins3
FileAppend %allWins%, C:\tmp\ahkCliboardHistory\windowHist.txt

ExitApp ;end of clipboard

