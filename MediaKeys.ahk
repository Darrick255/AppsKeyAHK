#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
;  #InstallKeybdHook	;Hooks required to get A_TimeIdlePhysical
;  #InstallMouseHook
;Period of Inactivity in minutes after which to display the message;
;	Run,%A_WinDir%\System32\Rundll32.exe User32.dll`,LockWorkStation
;  InactivityPeriod_mins=25
;  SetTimer,CheckPeriod,1000



; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetBatchLines, 10ms
;special characters for string replace to parse loop ¢¤¥¦§©ª«®µ¶.
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
vol_Width = 300  ; width of bar
vol_Thick = 24   ; thickness of bar
vol_PosX =  % A_ScreenWidth - vol_Width
vol_PosY =  % A_ScreenHeight - vol_Thick - 64

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
Menu Case, Add
Menu Case, Add, &1 Count, CCase
Menu Case, Add, &2 Word Wrap, CCase
Menu Case, Add, &3 Compress Repeats, CCase
Menu Case, Add, &4 CSV to Column, CCase
Menu Case, Add, &5 Center Align, CCase
Menu Case, Add, &6 Right Alighn, CCase
Menu Case, Add, &7 Set Case, CCase
Menu Case, Add, &8 Remove Duplicates, CCase






;******************************************************************************


;  MsgRepSQout()
;part of get url use: GetActiveBrowserURL()
ModernBrowsers := "ApplicationFrameWindow,Chrome_WidgetWin_0,Chrome_WidgetWin_1,Maxthon3Cls_MainFrm,MozillaWindowClass,Slimjet_WidgetWin_1"
LegacyBrowsers := "IEFrame,OperaWindowClass"

; Retrieves saved clipboard information since when this script last ran
; Set the following to 1 before changing the clipboard to
; make multi-clipboard ignore the change.  This is useful when
; this script is include inside another script that messes
; with the clipboard.
clipindex :=0
IgnoreClipboardChange := True
if(IgnoreClipboardChange = True)
{
	;  Loop C:\tmp\AppsKeyAHK\clipvar*.bin
	;  {
	;  	clipindex += 1
	;  	;  MsgBox, %clipindex% load
	;  	FileRead clipvar%A_Index%, *c %A_LoopFileFullPath%
	;  	FileDelete %A_LoopFileFullPath%
	;  }
	;  sleep 100 ;why this fixes the double entry of the last value i have no idea.
	FileRead HiddenWins, C:\tmp\AppsKeyAHK\windowHist.txt
	FileDelete C:\tmp\AppsKeyAHK\windowHist.txt
	;  maxindex := clipindex
		FileRead MaxIndex, C:\tmp\AppsKeyAHK\AppsKeyClipData.bin
	Loop %MaxIndex%
	{
		zindex := SubStr("0000000000" . A_Index, -9)
		FileRead clipvar%A_Index%, *c C:\tmp\AppsKeyAHK\AppsKeyClipData.bin:ClipStream%zindex%:$DATA
	}
	clipindex := maxindex
	;FileDelete C:\tmp\AppsKeyAHK\AppsKeyClipData.bin
}
OnExit ExitSub
Gosub CCsetVars
IgnoreClipboardChange := False
#Include WorkSpecific.ahk

Return ;end of auto execute


;___________________________________________ 
;  CheckPeriod:
;  	If (A_TimeIdle >= InactivityPeriod_mins*60*1000)
;  	{	
;  		Run,%A_WinDir%\System32\Rundll32.exe User32.dll`,LockWorkStation
;  	}
;  Return

;  -------------------------------------
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


AppsKey & p::
	SysGet, VirtualWidth, 78
	SysGet, VirtualHeight, 79
	MouseGetPos, xpos, ypos 
	tooltip, The cursor is at X%xpos% Y%ypos%`n%A_ScreenWidth%w h%A_ScreenHeight%`n%VirtualWidth%w h%VirtualHeight%. 
	SetTimer, ReSetToolTip, 1000
return 



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
		;  if(CurrentClipType==1)
		;  {
			tooltip %clipindex% - %clipboard%
			SetTimer, ReSetToolTip, 1000
		;  } else if (CurrentClipType==2)
		;  {
		;  	CoordMode, Mouse, Screen
		;  	mousegetpos,x,y
		;  	imagex:=x+20
		;  	imagey:=y+20
		;  	splashimage,ClipboardAll,b x%imagex% y%imagey%,,,MouseImageID
		;  	SetTimer, ReSetToolTipImage, 1000
		;  }
	}
	IgnoreClipboardChange := False
Return



;Paste And move Forward one
^+E::
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange = True)
	{
		Send, {Shift Up}{Ctrl Up}{V Up}
		Send ^v
		Send, {Shift Down}{Ctrl Down}
		sleep 100
		Send, %PasteSeperator%
		if (clipindex < maxindex)
		{
			clipindex += 1
		}
		thisclip := clipvar%clipindex%
		clipboard := thisclip
		tooltip %clipindex% - %clipboard%
		SetTimer, ReSetToolTip, 1000
		Sleep repeatTimer
	}
	IgnoreClipboardChange := False
return


;paste plain text
^+V::
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange)
	{
		clipboard = %clipboard%
		;  Send, {Shift Up}{Ctrl Up}{V Up}
		Send ^v
		;  Send, {Shift Down}{Ctrl Down}
		sleep 50
		thisclip := clipvar%clipindex%
		clipboard := thisclip
		tooltip %clipindex% - %clipboard%
		SetTimer, ReSetToolTip, 1000
		Sleep repeatTimer
	}
	IgnoreClipboardChange := False
	
Return

^+1::
	repeatTimer:=250
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return
^+2::
	repeatTimer:= repeatTimer - 50
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return
^+3::
	repeatTimer:=repeatTimer + 50
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return


;Paste And move Forward one
^+R::
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange = True)
	{
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
		tooltip %clipindex% - %clipboard%
		SetTimer, ReSetToolTip, 1000
		sleep repeatTimer
	}
	IgnoreClipboardChange := False
Return
;https://autohotkey.com/board/topic/58230-how-to-slow-down-send-commands/
;send event type slow

;  ^C::
;  ^X::
;  return

OnClipboardChange:
	;  CurrentClipType = %A_EventInfo%
	;  SetTimer, ReSetToolTip, 1000
If (!IgnoreClipboardChange)
{
	SetTitleMatchMode 2
	IfWinNotActive, Microsoft Excel
	;ahk_exe EXCEL.EXE ;https://autohotkey.com/docs/commands/WinActive.htm
	;  Microsoft Excel - Book1
	;  ahk_class XLMAIN
	;  ahk_exe EXCEL.EXE
	{
		clipindex := maxindex
		clipindex += 1
		clipvar%clipindex% := clipboardAll
		thisclip := clipvar%clipindex%
		tooltiptext := SubStr(clipboard, 1, 1500)
		tooltip %clipindex% - %tooltiptext%
		SetTimer, ReSetToolTip, 1000
		if clipindex > %maxindex%
		{
			maxindex := clipindex
		}
	}
}
return

; Clear the ToolTip
ReSetToolTip:
	ToolTip
	SetTimer, ReSetToolTip, Off
return

; Clear the ToolTip image
ReSetToolTipImage:
	SplashImage, Off
	SetTimer, ReSetToolTipImage, Off
return

;load into clipboard history
^+Z::
	GetText(TempText)
	clipindex := maxindex
	lineCount := clipindex
	Loop, parse, TempText, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
	{	
		clipindex += 1
		clipvar%clipindex% := A_LoopField
	}
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


;hotkey to activate ocr
;alternate way of adding third hotkey https://autohotkey.com/docs/Hotkeys.htm
Appskey & O::
	getSelectionCoords(x_start, x_end, y_start, y_end)
	OCR_Width := x_end - x_start
	OCR_Height := y_end - y_start
	RunWait, C:\Users\DFLETCH\Apps\Capture2Text\Capture2Text.exe %x_start% %y_start% %x_end% %y_end%
	tooltip, OCR DONE`n`n%clipboard%
	settimer, ReSetToolTip, 2500
return



Appskey & `::
;^!.::
	SplashImage, , MC01 W1000, 
	(
	Guide| appskey + key=
	``  : This help menu.
	a  : Always on top on
	A  : Always on top off
	b  : Powermanager switch off display
	t  : Make 50`% transparent
	T  : Make fully Visible
	v  : Paste clipboard as plain text
	w  : Wrap text at input value(70)
	x  : Power state menu
	/  : RegEx replace
	,  : input tag and attributes. HTML Format
	[  : input tag and attributes. BB format
	.  : Hide window
	S. : reveal windows hidden
	F4 : Force close window
	r  : Reload Script.

	LA+LS+tilde: restore windows

	LM: allows click draging of window without clicking on tile bar

	UP    : Volume up.
	DOWN  : Volume Down.
	RIGHT : Next Track.
	LEFT  : Previous Track.
	SPACE : Play/Pause.

	------ ClipBoard Stuff ------
	Ctrl+C, Ctrl+X             : Add to clipboard history while performing normal action
	Ctrl+Shift+C, Ctrl+Shift+X : Move though Clipboard History
	Ctrl+Shift+5               : Clear history
	Ctrl+Shift+Z               : Load highlighted text into clipboard history line by line
	AppsKey+V 				   : Set an Incremental Paste Delimiter
	Ctrl+Shift+E               : Paste value, Play deliminator and increment clipboard

	Ctrl+Shift+V : paste clipboard and go forward one
	Ctrl+Shift+R : paste clipboard(raw? see next link) and go forward one
	https://autohotkey.com/docs/commands/Send.htm

	#	Win (Windows logo key).
	!	Alt    < Use the left key of the pair.
	^	Control    > Use the right key of the pair.
	+	Shift   & between two keys to combine them

	Appskey + Insert : make a file into an ahk function.

	Also See https://github.com/Darrick255/AppsKeyAHK
) , , Help Page, Courier New
	Input TempText, L1
	SplashImage, Off
return

AppsKey & escape::
	if (ShowTray)
		Menu, Tray, NoIcon
	else
		Menu, Tray, Icon
		;Menu, Tray, Icon, % A_WinDir "\system32\setupapi.dll", 1 ; Shows a world icon in the system tray

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
	;  TempText := ClipBoard
	;  If (TempText != "")
	;   PutText(ClipBoard)
	PasteSeperator := SafeInput("Paste Seperator", "Enter paste Seperator", ", ")
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
	If GetKeyState("shift")
	{
		TempText := SafeInput("Enter Pattern", "RegEx Pattern:", "(.*?)()(.*?)()(.*?)()(.*?)")
		If ErrorLevel
			Return
		Temp2 := SafeInput("Enter Replacement", "Replacement:", "$1$3$5$7")
		If ErrorLevel
			Return
	}
	else{
		TempText := SafeInput("Enter Pattern", "RegEx Pattern:", REPatern)
		If ErrorLevel
			Return
		Temp2 := SafeInput("Enter Replacement", "Replacement:", REReplacement)
		If ErrorLevel
			Return
	}
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
;hide and restore windows.
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
			;  GroupActivate, All, R
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

; Disabled for ChromeCast
; AppsKey & c::
; Drive Eject,, % GetKeyState("shift")
; Return


<^`::
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
			;  GroupActivate, All, R
	 }
}
Return


<!<+~::
	;show all hidden windows
	 Loop Parse, HiddenWins, |
			WinShow ahk_id %A_LoopField%
	 HiddenWins =
Return

<!`::
	topWindow := AHKStack_Poop(HiddenWins)
	WinShow ahk_id %topWindow%
	WinActivate ahk_id %topWindow%
	WinSet, Top,,ahk_id %topWindow%
Return

  ;https://autohotkey.com/board/topic/27584-ahk-stacks/
AHKStack_Poop(ByRef Stack, AHKStack_Delimiter="|") ; Tweaked by [VxE]
  {
    EnvSet, ERRORLEVEL, 0
    Position := InStr(Stack, AHKStack_Delimiter, 0, 0)
    If Position
      {
        Element := SubStr(Stack, Position+1)
        Stack := SubStr(Stack, 1, Position-1)
        Return Element
      }
    If Stack
      {
        Element := Stack
        Stack := ""
        Return Element
      }
    StringGetPos, Position, Position, SearchText ;Sets ERRORLEVEL To 1
  }

~$RButton::
	KeyWait,LButton,DT0.3
	If !ErrorLevel {
		KeyWait,RButton
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
				;  GroupActivate, All, R
			}
		}
		Return
	}
Return

AppsKey & r::
KeyWait AppsKey
FileDelete C:\tmp\AppsKeyAHK\transfer.txt
FileAppend %weblogicpass%, C:\tmp\AppsKeyAHK\transfer.txt
IfWinActive %A_ScriptName%
	 Send ^s ;Save
Reload
Return

; =======================================================================================
; Chromecast stuff
CCsetVars:
	CCIconIsCasting.="|<Chromecast button While Casting>*194$32.0000000000000000000000000000Tzs00Dzz00300k00rzg001zv0027yk00wzg003bv002Ayk00tjg0039v002P0k00qrw00AYy0000000000000000000000000000000008"
	CCIconNotCasting.="|<chromecast icon>*183$30.00000000000000000000000000Dzw00Tzy00M0600M060000600E0600S060070600FU600Qk6006E600HM600PPy00N9w000000000000000000000U"
	CCIconError.="|<Chromecast Error icon >*207$18.000DzwTzyM06M0K00KE0KS0K70KFU6QkK6E6HM6PPyN9w000U"
	CCCastNewTab.="|<Pig Benis Not casting>*176$71.0000000000000000000000000000000000000000000000000000000000001s0000000000Dw007k01w000sA008K0340030A00EU068006Ds00V9wAlnkOYM01wKMT4I0q4k020cklDc1Y9U041FVWkE34X0082n34UU37400E4y7kt064M00008000079U0002E00007y00007000003k00000000000000000000000000000000000000000000000000000000000000000000000000000001"
	CCCastToDevice:="|<Pig Benis while Casting. Taken from desktop cast use after left arrow>*185$71.0000000000000000000000000M00000000007y003s00y000M6004/01a001U6008E0340037w00EYy6Mts5G800y/ADWO8N2M010IMMjoEm4k020cklM8UWF0041NVWEF13W0082T3sQW32A00006000034k0001800003z00003k00000k000000000000000000000000000000000U"
	CCPopUp.="|<chromecast window is availiable>*144$59.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzDbzzzzzzzyCDzzzzzzzy8zzzzzzzzy3zzzzzzzzyDzzzzzzzzsDzzzzzzzzWDzzzzzzzyCDzzzzzzzwyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
	CCPopupClose.="|<chromecast close button>*144$59.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzDbzzzzzzzyCDzzzzzzzy8zzzzzzzzy3zzzzzzzzyDzzzzzzzzsDzzzzzzzzWDzzzzzzzyCDzzzzzzzwyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
	CCCastDiffTab.="|<chromecast window is Cast New Tab button>*201$71.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000D11ty0000000X76Mk00000032+8FU00000060IM30000000A1AC60000000M286A0000000kjm4M0000000XMqMk0000000wUbVU00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
	CCStop:="|<chromecast window Stop Cast button>*197$53.00000000000000000000000000000000000000000000007bssT0000NX28X0000V6A920001UAEGA0000sMUbk0000Ml1800008FX2E0000MX28U0000S63V00000000000000000000000000000000000000000000001"
	CCLeftArrow.="|<From Casting to List of devices>*165$59.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzszzzzDzzzznzzzwzzzzzbzzznzzzzzDzzzDzzzzyTzzwzzzzzwTzzk07zzztzzzU0DzzznzzzbzzzzzbzzzbzzzzzDzzzbzzzzzzzzzbzzzzzzzzzbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
	CCDropDownArrow.="|<Chromecast drop down arrow above devices>*165$71.zzzzzzzzzzzy7zzzzzzzzzzxbzzzzzzzzzzzbzzzy0TzzzzzDzzzy1zzzzzyTzzzy7zzzzzNzzzzyTzzzzy7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
	CCDesktop.="|<Cast Desktop>*166$71.000000000000000000000000000000000000Tzs00Q0000U0k0k03400E101U1U04800U203030083lnUwQ60600E0YG394A0A00U7a44HsM0M012H388Y0k0k034aWENA0zz001lwskSC7zzU00000000000000000000000000000000000000000008"
	TVIcon.="|<Tv extension icon>*185$29.00000000000000000000000000z0003z000Dz000wD003kD0078C00C0Q00Q0s00s1k01s7U01sS001zs001zU001y0000000000000000000000000000001"
	TVConnected.="|<TV Connected string>*182$71.000000000000000000000003zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz7UswMwS3sw7wC0lslss71kDsMFXlXlVg3WTUlX7X7W7s76y1V2D6041yCBwX04SA081wMvl70MwMwEVskrU3slklsXXllj05VVXXl2DXWTss7U77X0T70zlkTUSD71yD1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU00000000000000000000001"
	TVPowerOff.="|<TV Power of icon >*170$71.00000000000000000000000000000000000003zzzzzzz0000Tzzzzzzz0000k0000000000300000000000600000000000A00000000000M001y0000000k00000000001U0000000000300000000000600000000000A00000000000M00000000000k00000000001U007s000000300000000000600000000000A000000000008000000000000000000000000000000000000000000001"

	CCAppIconAll := CCIconIsCasting . CCIconNotCasting . CCIconError
	CC1ClickAll := CCCastNewTab . CCCastToDevice . CCCastDiffTab
return

AppsKey & S::
	IfWinNotActive, ahk_exe chrome.exe
	WinActivate, ahk_exe chrome.exe
	IfWinActive, ahk_class Chrome_WidgetWin_1
	{
		waitclick( CCAppIconAll )
		waitclick( CCStop )
		findclick( CCCastNewTab, CCPopupClose )
		waitclick( TVIcon )
		findclick( TVConnected, TVPowerOff )
		send, {escape}
	}
return

AppsKey & D::
	IfWinNotActive, ahk_exe chrome.exe
    WinActivate, ahk_exe chrome.exe
	IfWinActive, ahk_class Chrome_WidgetWin_1 
	{
		waitclick( CCAppIconAll )
		waitclick( CCLeftArrow )
		waitclick( CCDropDownArrow )
		waitclick( CCDesktop )
		waitclick( CC1ClickAll )
		waitclick( CC1ClickAll, 500 )
	}
return

AppsKey & C::
	;cast tab
	msgbox ran

	IfWinActive, ahk_class Chrome_WidgetWin_1 
	{
		waitclick(CCAppIconAll)
		waitclick(CC1ClickAll)
		findclick(CCStop, CCPopupClose)
	}
return

waitclick(text, timeout=2000)
{
	msgbox, %text%
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,text)
		{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
			MouseMove, X+W//2, Y+H//2
			MouseClick
			break
		}
	}
	return
}

waitfound(text, timeout=500)
{
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,text)
		{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
			MouseMove, X+W//2, Y+H//2
			MouseClick
			break
		}
	}
	return ok
}


findclick(find, click, timeout=2000)
{
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,find)
		{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
			break
		}
	}
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,click)
		{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
			MouseMove, X+W//2, Y+H//2
			MouseClick
			break
		}
	}
	return
}
; End Chromecast Stuff
; =======================================================================================
AppsKey & LButton::
	CoordMode, Mouse  ; Switch to screen/absolute coordinates.
	MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
	WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
	WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
	if EWD_WinState = 0  ; Only if the window isn't maximized 
			SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
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
IgnoreClipboardChange := True
if (IgnoreClipboardChange)
{
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
	
		If (A_ThisMenuItemPos = 9)
		{
			;st_count(string [, searchFor])
			option := "`n"
			If GetKeyState("Shift","p")
				option := SafeInput("Enter Count Character", "Count String:", option)
			res := st_count(TempText, option)
			MsgBox, %option% matched %res% times
			Return
		}
		Else If (A_ThisMenuItemPos = 10)
		{
			;st_wordWrap(string [, column, indent])
			option := 120
			If GetKeyState("Shift","p")
				option := SafeInput("Enter Line Length", "Max line Length:", option)
			TempText := st_wordWrap(TempText, option)
		}
		Else If (A_ThisMenuItemPos = 11)
		{
			;st_removeDuplicatesDelims(string [, delim])
			option := "`n"
			If GetKeyState("Shift","p")
				option := SafeInput("Enter Delimiter", "String Delimiter:", option)
			TempText := st_removeDuplicatesDelims(TempText, option)
			
		}
		Else If (A_ThisMenuItemPos = 12)
		{
			;st_columnize(data [, delim, justify, pad, colsep])
			delim := "csv"
			justify := 1
			pad := " "
			colsep := " | "
			If GetKeyState("Shift","p")
			{
				delim := SafeInput("Enter Delimiter", "String Delimiter:", delim)
				justify := SafeInput("Justify Text", "1-left,2-right,3-center,|-column=1|2|3", justify)
				pad := SafeInput("Enter Pad Character", "String pad:", pad)
				colsep := SafeInput("Enter Column Seperator", "Column Seperator:", colsep)
			}
			TempText := st_columnize(TempText, delim, justify, pad, colsep)
			
		}
		Else If (A_ThisMenuItemPos = 13)
		{
			;st_center(text [, fill, symFIll, delim, exclude])
			TempText := st_center(TempText)
		}
		Else If (A_ThisMenuItemPos = 14)
		{
			;st_right(text [, fill, delim, exclude])
			Temptext := St_right(temptext)
		}
		Else if (A_thismenuitempos = 15)
		{
			;St_setcase(string [, Case])
			Option := "t"
			if Getkeystate("shift","p")
				Option := Safeinput("enter Case", "|    Use any cell as a name. CaSE-InSEnsitIVe.    |`n|----|-----|---------|------------|---------------|`n| 1  |  U  |   UP    |   UPPER    |   UPPERCASE   |`n|----|-----|---------|------------|---------------|`n| 2  |  l  |   low   |   lower    |   lowercase   |`n|----|-----|---------|------------|---------------|`n| 3  |  T  |  Title  |  TitleCase |               |`n|----|-----|---------|------------|---------------|`n| 4  |  S  |   Sen   |  Sentence  |  Sentencecase |`n|----|-----|---------|------------|---------------|`n| 5  |  i  |   iNV   |   iNVERT   |   iNVERTCASE  |`n|----|-----|---------|------------|---------------|`n| 6  |  r  |  rANd   |   rAnDOm   |   RAndoMcASE  |", Option,350)
			Temptext := St_setcase(TempText, option)
		}
		Else if (A_thismenuitempos = 16)
		{
			option := "`n"
			If GetKeyState("Shift","p")
				option := SafeInput("Enter Delimiter", "String Delimiter:", option)
			TempText := st_removeDuplicates(TempText, option)
		}
	}
	PutText(TempText)
	IgnoreClipboardChange := False
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
SafeInput(Title, Prompt, Default = "", Height = 120)
{
	 ActiveWin := WinExist("A")
	 ;InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default]
	 InputBox OutPut, %Title%, %Prompt%,,, Height,,,,, %Default%
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


/*
Name: String Things - Common String & Array Functions
Version 2.6 (Fri May 30, 2014)
Created: Sat March 02, 2013
Author: tidbit
Credit:
   AfterLemon  --- st_insert(), st_overwrite() bug fix. st_strip(), and more.
   Bon         --- word(), leftOf(), rightOf(), between() - These have been replaced
   faqbot      --- jumble()
   Lexikos     --- flip()
   MasterFocus --- Optimizing LineWrap and WordWrap.
   rbrtryn     --- group()
   Rseding91   --- Optimizing LineWrap and WordWrap.
   Verdlin     --- st_concat(), A couple nifty forum-only functions.
   
Description:
   A compilation of commonly needed function for strings and arrays.

No functions rely on eachother. You may simply copy/paste the ones you want or need.
.-==================================================================-.
|Function                                                            |
|====================================================================|
| st_count(string [, searchFor])                                     |+
| st_insert(insert, into [, pos])                                    |
| st_delete(string [, start, length])                                |
| st_overwrite(overwrite, into [, pos])                              |
| st_format(string, param1, param2, param3, ...)                     |
| st_word(string [, wordNu, Delim, temp])                            |
| st_subString(string, searchFor [, direction, instance, searchFor2])|
| st_jumble(Text[, Weight, Delim , Omit])                            |
| st_concat(delim, as*)                                              |
|                                                                    |
| st_lineWrap(string [, column, indent])                             |
| st_wordWrap(string [, column, indent])                             |+
| st_readLine(string, line [, delim, exclude])                       |
| st_deleteLine(string, line [, delim, exclude])                     |
| st_insertLine(insert, into, line [, delim, exclude])               |
|                                                                    |
| st_flip(string)                                                    |
| st_setCase(string [, case])                                        |+
| st_contains(mixed [, lookFor*])                                    |
| st_removeDuplicatesDelims(string [, delim])                              |+
| st_pad(string [, left, right, LCount, RCount])                     |
|                                                                    |
| st_group(string, size, separator [, perLine, startFromFront])      |
| st_columnize(data [, delim, justify, pad, colsep])                 |+
| st_center(text [, fill, symFIll, delim, exclude])                  |+
| st_right(text [, fill, delim, exclude])                            |+
|----------------------------------------------------------------    |
|array stuff:                                                        |
|   st_split(string [, delim, exclude])                              |
|   st_glue(array [, delim])                                         |
|   st_printArr(array [, depth])                                     |
|   st_countArr(array [, depth])                                     |
|   st_randomArr(array [, min, max, timeout])                        |
'-==================================================================-'
*/
/*
Count
   Counts the number of times a tolken exists in the specified string.

   string    = The string which contains the content you want to count.
   searchFor = What you want to search for and count.

   note: If you're counting lines, you may need to add 1 to the results.

example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
output:  4
*/
st_count(string, searchFor="`n")
{
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}

/*
WordWrap
   Wrap the specified text so each line is never more than a specified length.
  
   Unlike st_lineWrap(), this function tries to take into account for words (separated by a space).
   
   string     = What text you want to wrap.
   column     = The column where you want to split. Each line will never be longer than this.
   indentChar = You may optionally indent any lines that get broken up. Specify
                What character or string you would like to define as the indent.
                
example: st_wordWrap("Apples are a round fruit, usually red.", 20, "---")
output:
Apples are a round
---fruit, usually
---red.
*/
st_wordWrap(string, column=56, indentChar="")
{
    indentLength := StrLen(indentChar)
     
    Loop, Parse, string, `n, `r
    {
        If (StrLen(A_LoopField) > column)
        {
            pos := 1
            Loop, Parse, A_LoopField, %A_Space%
                If (pos + (loopLength := StrLen(A_LoopField)) <= column)
                    out .= (A_Index = 1 ? "" : " ") A_LoopField
                    , pos += loopLength + 1
                Else
                    pos := loopLength + 1 + indentLength
                    , out .= "`n" indentChar A_LoopField
             
            out .= "`n"
        } Else
            out .= A_LoopField "`n"
    }
     
    Return SubStr(out, 1, -1)
}
StrX( H,  BS="",BO=0,BT=1,   ES="",EO=0,ET=1,  ByRef N="" ) { ;    | by Skan | 19-Nov-2009
Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
 <0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
 +(0-ET)):(X+P)):(X)))-P) ; v1.0-196c 21-Nov-2009 www.autohotkey.com/forum/topic51354.html
}


/*
SetCase
   Set the case (Such as UPPERCASE or lowercase) for the specified text.

   string = The text you want to modify.
   case   = The case you would like the specified text to be.

   The following types of Case are aloud:
   .-===============================================-.
   |    Use any cell as a name. CaSE-InSEnsitIVe.    |
   |----|-----|---------|------------|---------------|
   | 1  |  U  |   UP    |   UPPER    |   UPPERCASE   |
   |----|-----|---------|------------|---------------|
   | 2  |  l  |   low   |   lower    |   lowercase   |
   |----|-----|---------|------------|---------------|
   | 3  |  T  |  Title  |  TitleCase |               |
   |----|-----|---------|------------|---------------|
   | 4  |  S  |   Sen   |  Sentence  |  Sentencecase |
   |----|-----|---------|------------|---------------|
   | 5  |  i  |   iNV   |   iNVERT   |   iNVERTCASE  |
   |----|-----|---------|------------|---------------|
   | 6  |  r  |  rANd   |   rAnDOm   |   RAndoMcASE  |
   '-===============================================-'

example: st_setCase("ABCDEFGH", "l")
output:  abcdefgh
*/
st_setCase(string, case="s")
{
   if (case=1 || case="u" || case="up" || case="upper" || case="uppercase")
      StringUpper, new, string
   else if (case=2 || case="l" || case="low" || case="lower" || case="lowercase")
      StringLower, new, string
   else if (case=3 || case="t" || case="title" || case="titlecase")
   {
      StringLower, string, string, T
      string:=RegExReplace(string, "i)(with|amid|atop|from|into|onto|over|past|plus|than|till|upon|are|via|and|but|for|nor|off|out|per|the|\b[a-z]{1,2}\b)", "$L1")
      new:=RegExReplace(string, "^(\w)|(\bi\b)|(\w)(\w+)$", "$U1$U2$U3$4")
   }
   else if (case=4 || case="s" || case="sen" || case="sentence" || case="sentencecase")
   {
      StringLower string, string
      new:=RegExReplace(string, "([.?\s!(]\s\w)|^(\b\w)|(\.\s*[(]\w)|(\bi\b)", "$U0")
   }
   else if (case=5 || case="i" || case="inv" || case="invert" || case="invertcase")
   {
      Loop, parse, string
      {
         if A_LoopField is upper
            new.= Chr(Asc(A_LoopField) + 32)
         else if A_LoopField is lower
            new.= Chr(Asc(A_LoopField) - 32)
         else
            new.= A_LoopField
      }
   }
   else if (case=6 || case="r" || case="rand" || case="random" || case="randomcase")
   {
      loop, parse, string
      {
         random, rcase, 0, 1
         if (rcase==0)
            StringUpper, out, A_LoopField
         Else
            StringLower, out, A_LoopField
         new.=out
      }
      return new
   }
   Else
      return -1
   return new
}


/*
RemoveDuplicates
   Remove any and all consecutive lines. A "line" can be determined by
   the delimiter parameter. Not necessarily just a `r or `n. But perhaps
   you want a | as your "line".

   string = The text or symbols you want to search for and remove.
   delim  = The string which defines a "line".

example: st_removeDuplicatesDelims("aaa|bbb|||ccc||ddd", "|")
output:  aaa|bbb|ccc|ddd
*/
st_removeDuplicatesDelims(string, delim="`n")
{
	delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
	Return RegExReplace(string, "(" delim ")+", "$1")
}




st_removeDuplicates(string, delim= "`n", exclude="`r")
{
Loop, Parse, string, %delim%, %exclude% ; a parsing loop operates on a copy of the list
	If ( A_Index = 1 ) ; make the list contain only the first item
		MyUniqueList := delim . A_LoopField . delim ; put delimiters in front and back
	Else IfNotInString, MyUniqueList, %delim%%A_LoopField%%delim% ; check for a duplicate
		MyUniqueList .= A_LoopField . delim ; the new item has a delimiter in front and back
StringMid, MyUniqueList, MyUniqueList, 2, StrLen( MyUniqueList ) - 2 ; trim the first and last delimiters
return rtrim(MyUniqueList,"`r`n")


}

/*
st_columnize
   Take a set of data with a common delimiter (csv, tab, |, "a string", anything) and
   nicely organize it into a column structure, like an EXCEL spreadsheet.

	data    = [String] Your input data to be organized.
	delim   = [Optional] What separates each set of data? It can be a string or it can
	          be the word "csv" to treat it as a CSV document.
	justify = [Optional] Specify 1 to align the data to the left of the column, 2 for
	          aligning to the right or 3 to align centered. You may enter a 
	          string such as "2|1|3" to adjust columns specifically. Columns are 
	          separeted by |.
	pad     = [Optional] The string that should fill in shorter column items to match
	          the longest item.
	colsep  = [Optional] What string should go between every column?

example: 
	data=
	(
	"Date","Pupil","Grade"
	----,-----,-----
	"25 May","Bloggs, Fred","C"
	"25 May","Doe, Jane","B"
	"15 July","Bloggs, Fred","A"
	"15 April","Muniz, Alvin ""Hank""","A"
	)
	output:=Columnize(data, "csv", 2)  

output:
	    Date |               Pupil | Grade
	    ---- |               ----- | -----
	  25 May |        Bloggs, Fred |     C
	  25 May |           Doe, Jane |     B
	 15 July |        Bloggs, Fred |     A
	15 April | Muniz, Alvin "Hank" |     A
*/
st_columnize(data, delim="csv", justify=1, pad=" ", colsep=" | ")
{		
	widths:=[]
	dataArr:=[]
	
	if (instr(justify, "|"))
		colMode:=strsplit(justify, "|")
	else
		colMode:=justify
	; make the arrays and get the total rows and columns
	loop, parse, data, `n, `r
	{
		if (A_LoopField="")
			continue
		row:=a_index
		
		if (delim="csv")
		{
			loop, parse, A_LoopField, csv
			{
				dataArr[row, a_index]:=A_LoopField
				if (dataArr.maxindex()>maxr)
					maxr:=dataArr.maxindex()
				if (dataArr[a_index].maxindex()>maxc)
					maxc:=dataArr[a_index].maxindex()
			}
		}
		else
		{
			dataArr[a_index]:=strsplit(A_LoopField, delim)
			if (dataArr.maxindex()>maxr)
				maxr:=dataArr.maxindex()
			if (dataArr[a_index].maxindex()>maxc)
				maxc:=dataArr[a_index].maxindex()
		}
	}
	; get the longest item in each column and store its length
	loop, %maxc%
	{
		col:=a_index
		loop, %maxr%
			if (strLen(dataArr[a_index, col])>widths[col])
				widths[col]:=strLen(dataArr[a_index, col])
	}
	; the main goodies.
	loop, %maxr%
	{
		row:=a_index
		loop, %maxc%
		{
			col:=a_index
			stuff:=dataArr[row,col]
			len:=strlen(stuff)
			difference:=abs(strlen(stuff)-widths[col])

			; generate a repeating string about the length of the longest item
			; in the column.
			loop, % ceil(widths[col]/((strlen(pad)<1) ? 1 : strlen(pad)))
    			padSymbol.=pad

			if (isObject(colMode))
				justify:=colMode[col]
			; justify everything correctly.
			; 3 = center, 2= right, 1=left.
			if (strlen(stuff)<widths[col])
			{
				if (justify=3)
					stuff:=SubStr(padSymbol, 1, floor(difference/2)) . stuff
					. SubStr(padSymbol, 1, ceil(difference/2))
				else
				{
					if (justify=2)
						stuff:=SubStr(padSymbol, 1, difference) stuff
					else ; left justify by default.
						stuff:= stuff SubStr(padSymbol, 1, difference) 
				}
			}
			out.=stuff ((col!=maxc) ? colsep : "")
		}
		out.="`r`n"
	}
	stringTrimRight, out, out, 2 ; remove the last blank newline
	return out
}


/*
Center
   Centers a block of text to the longest item in the string.

   text    = The text you would like to center.
   fill    = A single character to use as the padding to center text.
   symFIll = 0: Just fill in the left half. 1: Fill in both sides.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

  
example: st_center("aaa`na`naaaaaaaa")
output:
  aaa
   a
aaaaaaaa
*/
st_center(text, fill=" ", symFIll=0, delim= "`n", exclude="`r")
{
	fill:=SubStr(fill,1,1)
	loop, parse, text, %delim%, %exclude%
		if (StrLen(A_LoopField)>longest)
			longest:=StrLen(A_LoopField)
	loop, parse, text, %delim%, %exclude%
	{
		filled:=""		
		loop, % floor((longest-StrLen(A_LoopField))/2)
			filled.=fill
		new.= filled A_LoopField ((symFIll=1) ? filled : "") "`n"
	}
	return rtrim(new,"`r`n")
}


/*
right
   Align a block of text to the right side.

   text    = The text you would like to right-justify.
   fill    = A single character to use as to push the text to the right.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

example: st_center("aaa`na`naaaaaaaa")
output:
     aaa
       a
aaaaaaaa
*/
st_right(text, fill=" ", delim= "`n", exclude="`r")
{
	fill:=SubStr(fill,1,1)
	loop, parse, text, %delim%, %exclude%
		if (StrLen(A_LoopField)>longest)
			longest:=StrLen(A_LoopField)
	loop, parse, text, %delim%, %exclude%
	{
		filled:=""
		loop, % abs(longest-StrLen(A_LoopField))
			filled.=fill
		new.= filled A_LoopField "`n"
	}
	return rtrim(new,"`r`n")
}

; creates a click-and-drag selection box to specify an area
;https://autohotkey.com/boards/viewtopic.php?t=18677 nicstella
getSelectionCoords(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end) {
	;Mask Screen
	Gui, Color, FFFFFF
	Gui +LastFound
	WinSet, Transparent, 50
	Gui, -Caption 
	Gui, +AlwaysOnTop
	SysGet, VirtualWidth, 78
    SysGet, VirtualHeight, 79
	Gui, Show, x0 y0 h%VirtualHeight% w%VirtualWidth%,"AutoHotkeySnapshotApp"     

	;Drag Mouse
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	WinGet, hw_frame_m,ID,"AutoHotkeySnapshotApp"
	hdc_frame_m := DllCall( "GetDC", "uint", hw_frame_m)
	KeyWait, LButton, D 
	MouseGetPos, scan_x_start, scan_y_start 
	Loop
	{
		Sleep, 10   
		KeyIsDown := GetKeyState("LButton")
		if (KeyIsDown = 1)
		{
			MouseGetPos, scan_x, scan_y 
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", 0,"int",0,"int", A_ScreenWidth,"int",A_ScreenWidth)
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", scan_x_start,"int",scan_y_start,"int", scan_x,"int",scan_y)
		} else {
			break
		}
	}

	;KeyWait, LButton, U
	MouseGetPos, scan_x_end, scan_y_end
	Gui Destroy
	
	if (scan_x_start < scan_x_end)
	{
		x_start := scan_x_start
		x_end := scan_x_end
	} else {
		x_start := scan_x_end
		x_end := scan_x_start
	}
	
	if (scan_y_start < scan_y_end)
	{
		y_start := scan_y_start
		y_end := scan_y_end
	} else {
		y_start := scan_y_end
		y_end := scan_y_start
	}

}
;https://autohotkey.com/board/topic/5545-base64-coderdecoder/
;base 64 stuff Laszlo
Base64Encode(ByRef bin, n=0) {
   m := VarSetCapacity(bin)
   Loop % n<1 || n>m ? m : n
      A := *(&bin+A_Index-1)
     ,m := Mod(A_Index,3)
     ,b := m=1 ? A << 16 : m=2 ? b+(A<<8) : b+A
     ,out .= m ? "" : Code(b>>18) Code(b>>12) Code(b>>6) Code(b)
   Return out (m ? Code(b>>18) Code(b>>12) (m=1 ? "==" : Code(b>>6) "=") : "")
}
Code(i) {   ; <== Chars[i & 63], 0-base index
   Static Chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   Return SubStr(Chars,(i&63)+1,1)
}

Base64Decode(ByRef bin, code) {
   Static Chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   StringReplace code, code, =,, All
   VarSetCapacity(bin, 3*StrLen(code)//4, 0)
   pos = 0
   Loop Parse, code
      m := A_Index&3, d := InStr(Chars,A_LoopField,1) - 1
     ,b := m ? (m=1 ? d<<18 : b+(d<<24-6*m)) : b+d
     ,Append(bin, pos, 3*!m, b>>16, 255 & b>>8, 255 & b)
   Append(bin, pos, !!m+(m&1), b>>16, 255 & b>>8, 0)
}
Append(ByRef bin, ByRef pos, k, c1,c2,c3) {
   Loop %k%
      DllCall("RtlFillMemory",UInt,&bin+pos++, UInt,1, UChar,c%A_Index%)
}


;Created by Robert Eding: Rseding91@yahoo.com
;Current version 2.6 
;https://autohotkey.com/board/topic/64481-include-virtually-any-file-in-a-script-exezipdlletc/page-4
 AppsKey & Insert::
Loop
{
	FileSelectFile, From_File,,, Select file to convert.
	
	IfNotExist, %From_File%
	{
		MsgBox, 1,, Error! invalid file.
		IfMsgBox Ok
		{
			From_File := "" 
			Continue
		}
		IfMsgBox Cancel
			ExitApp
	} else
		Break
}

InputBox, T_Function_Name, Please enter a name for the recreate function.
If (T_Function_Name = "")
	ExitApp
Extract_%T_Function_Name% = If you see this you entered a invalid function name.

E := Convert_File(From_File, T_Function_Name)

If (E)
	MsgBox Error converting file: %E%


Convert_File(_From_File, _Function_Name, _SplitLength = 16000)
{
	ST1 := A_TickCount
	, Ptr := A_IsUnicode ? "Ptr" : "UInt"
	, H := DllCall("CreateFile", Ptr, &_From_File, "UInt", 0x80000000, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
	, VarSetCapacity(FileSize, 8, 0)
	, DllCall("GetFileSizeEx", Ptr, H, "Int64*", FileSize)
	, DllCall("CloseHandle", Ptr, H)
	, FileSize := FileSize = -1 ? 0 : FileSize
	
	If (!FileSize)
		Return -1
	If (_SplitLength < 65)
		_SplitLength := 65
	
	SplitPath, _From_File, F_Name, F_Directory, F_Extension
	
	Needed_Capacity := Ceil((FileSize * 1.38) + (((FileSize * 1.38) / _SplitLength) * 15) + (5 * 1024))
	, VarSetCapacity(Bin_D, A_IsUnicode ? Needed_Capacity * 2 : Needed_Capacity)
	
	, Bin_D .= _Function_Name "_Get(_What)`r`n"
	, Bin_D .= "{`r`n"
	;, Bin_D .= A_Tab "Static Size = " FileSize ", Name = """ F_Name """, Extension = """ F_Extension """, Directory = """ F_Directory """`r`n"
	, Bin_D .= A_Tab "Static Size = " FileSize ", Name = """ F_Name """, Extension = """ F_Extension """, Directory = ""C:\tmp\AppsKeyAHK\""`r`n"
	, Bin_D .= A_Tab ", Options = ""Size,Name,Extension,Directory""`r`n"
	, Bin_D .= A_Tab ";This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.`r`n"
	, Bin_D .= A_Tab "If (InStr("","" Options "","", "","" _What "",""))`r`n"
	, Bin_D .= A_Tab A_Tab "Return %_What%`r`n}`r`n"
	, Bin_D .= "`r`n"
	, Bin_D .= "Extract_" _Function_Name "(_Filename, _DumpData = 0)`r`n"
	, Bin_D .= "{`r`n"
	
	, H := DllCall("CreateFile", Ptr, &_From_File, "UInt", 0x80000000, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
	, VarSetCapacity(InData, FileSize, 0)
	, DllCall("ReadFile", Ptr, H, Ptr, &InData, "UInt", FileSize, "UInt*", 0, "UInt", 0)
	, DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), Ptr, &InData, UInt, FileSize, UInt, 1, UInt, 0, UIntP, Bytes, "CDECL Int")
	, VarSetCapacity(OutData, Bytes *= (A_IsUnicode ? 2 : 1))
	, DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), Ptr, &InData, UInt, FileSize, UInt, 1, Str, OutData, UIntP, Bytes, "CDECL Int")
	, ET1 := A_TickCount
	, NumPut(0, OutData, VarSetCapacity(OutData) - (A_IsUnicode ? 6 : 4), (A_IsUnicode ? "UShort" : "UChar")) ;Removes the final "`r`n" that gets auto added to the string
	, VarSetCapacity(InData, FileSize, 0)
	, VarSetCapacity(InData, 0)
	
	, Bin_D .= A_Tab ";This function ""extracts"" the file to the location+name you pass to it.`r`n"
	, Bin_D .= A_Tab "Static HasData = 1, Out_Data, Ptr, ExtractedData`r`n"
	, N := 1, I := 0
	, Bin_D .= A_Tab "Static " N ++ " = """
	
	Loop, Parse, OutData, `n, `r
		If (I + 64 > _SplitLength)
			Bin_D .= """`r`n	Static " N ++ " = """, I := 0
			, Bin_D .= A_LoopField, I += 64
		Else
			Bin_D .= A_LoopField, I += 64
	
	If (I != 0)
		Bin_D .= """`r`n"
	If (N != 1)
		N --
	
	Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (!HasData)`r`n"
	, Bin_D .= A_Tab A_Tab "Return -1`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (!ExtractedData){`r`n"
	, Bin_D .= A_Tab A_Tab "ExtractedData := True`r`n"
	, Bin_D .= A_Tab A_Tab ", Ptr := A_IsUnicode ? ""Ptr"" : ""UInt""`r`n"
	, Bin_D .= A_Tab A_Tab ", VarSetCapacity(TD, " Ceil(FileSize * 1.37) " * (A_IsUnicode ? 2 : 1))`r`n"
	, Bin_D .= A_Tab A_Tab "`r`n"
	, Bin_D .= A_Tab A_Tab "Loop, " N "`r`n"
	, Bin_D .= A_Tab A_Tab A_Tab "TD .= %A_Index%, "
	If (_SplitLength < 4096)
		Bin_D .= "VarSetCapacity(%A_Index%, 0)`r`n"
	Else
		Bin_D .= "%A_Index% := """"`r`n"
	, Bin_D .= A_Tab A_Tab "`r`n"
	, Bin_D .= A_Tab A_Tab "VarSetCapacity(Out_Data, Bytes := " FileSize ", 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", DllCall(""Crypt32.dll\CryptStringToBinary"" (A_IsUnicode ? ""W"" : ""A""), Ptr, &TD, ""UInt"", 0, ""UInt"", 1, Ptr, &Out_Data, A_IsUnicode ? ""UIntP"" : ""UInt*"", Bytes, ""Int"", 0, ""Int"", 0, ""CDECL Int"")`r`n"
	, Bin_D .= A_Tab A_Tab ", TD := """"`r`n"
	, Bin_D .= A_Tab "}`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "IfExist, %_Filename%`r`n"
	, Bin_D .= A_Tab A_Tab "FileDelete, %_Filename%`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "h := DllCall(""CreateFile"", Ptr, &_Filename, ""Uint"", 0x40000000, ""Uint"", 0, ""UInt"", 0, ""UInt"", 4, ""Uint"", 0, ""UInt"", 0)`r`n"
	, Bin_D .= A_Tab ", DllCall(""WriteFile"", Ptr, h, Ptr, &Out_Data, ""UInt"", " FileSize ", ""UInt"", 0, ""UInt"", 0)`r`n"
	, Bin_D .= A_Tab ", DllCall(""CloseHandle"", Ptr, h)`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (_DumpData)`r`n"
	, Bin_D .= A_Tab A_Tab "VarSetCapacity(Out_Data, " FileSize ", 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", VarSetCapacity(Out_Data, 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", HasData := 0`r`n"
	, Bin_D .= "}`r`n"
	, ET2 := A_TickCount
	
	MsgBox, 0x4, Conversion Finished, % "Conversion Finished.`n`nTook " Round((ET1 - ST1)/1000, 3) " seconds to convert the file and " Round((ET2 - ET1)/1000, 3) " seconds to format the functions.`n`nWould you like to save the functions as " Function_Name ".ahk in the scripts current directory?"
	IfMsgBox, Yes
	{
		IfExist, %A_ScriptDir%\%_Function_Name%.ahk
		{
			FileExists := 1
			Msgbox, 0x4, File Already Exists,Error! %A_ScriptDir%\%_Function_Name%.ahk`n`nFile already exists. Do you want to overwrite it?
			IfMsgBox, Yes
			{
				FileDelete, %A_ScriptDir%\%_Function_Name%.ahk
				FileExists := 0
			}
		}
		
		If (!FileExists)
		{
			If A_IsUnicode
				FileAppend, %Bin_D%, *%A_ScriptDir%\%_Function_Name%.ahk, UTF-8
			Else
				FileAppend, %Bin_D%, *%A_ScriptDir%\%_Function_Name%.ahk
		}
	}
	MsgBox, 0x4, Conversion Finished, % "Conversion Finished.`n`nTook " Round((ET1 - ST1)/1000, 3) " seconds to convert the file and " Round((ET2 - ET1)/1000, 3) " seconds to format the function.`n`nWould you like to copy the functions to the clipboard?"
	IfMsgBox, Yes
		Clipboard := Bin_D
}
Return

;  https://autohotkey.com/board/topic/6416-tail-the-last-lines-of-a-text-file/page-2
;  Read tail of file
Tail(k,file) {  ; Return the last k lines of file
   Loop Read, %file%
      i := Mod(A_Index,k), L%i% := A_LoopReadLine
   Loop % k
      i := Mod(i+1,k), L .= L%i% "`n"
   Return L
}

; AutoHotkey Version: AutoHotkey 1.1
; Language:           English
; Platform:           Win7 SP1 / Win8.1 / Win10
; Author:             Antonio Bueno <user atnbueno of Google's popular e-mail service>
; Short description:  Gets the URL of the current (active) browser tab for most modern browsers
; Last Mod:           2016-05-19
;https://autohotkey.com/boards/viewtopic.php?t=3702 -- atnbueno

;Menu, Tray, Icon, % A_WinDir "\system32\netshell.dll", 86 ; Shows a world icon in the system tray


^+!u::
	nTime := A_TickCount
	sURL := GetActiveBrowserURL()
	WinGetClass, sClass, A
	If (sURL != "")
		MsgBox, % "The URL is """ sURL """`nEllapsed time: " (A_TickCount - nTime) " ms (" sClass ")"
	Else If sClass In % ModernBrowsers "," LegacyBrowsers
		MsgBox, % "The URL couldn't be determined (" sClass ")"
	Else
		MsgBox, % "Not a browser or browser not supported (" sClass ")"
Return



;Monitor Weblogic console for sqout
;Maximo function


GetActiveBrowserURL() {
	global ModernBrowsers, LegacyBrowsers
	WinGetClass, sClass, A
	If sClass In % ModernBrowsers
		Return GetBrowserURL_ACC(sClass)
	Else If sClass In % LegacyBrowsers
		Return GetBrowserURL_DDE(sClass) ; empty string if DDE not supported (or not a browser)
	Else
		Return ""
}

; "GetBrowserURL_DDE" adapted from DDE code by Sean, (AHK_L version by maraskan_user)
; Found at http://autohotkey.com/board/topic/17633-/?p=434518

GetBrowserURL_DDE(sClass) {
	WinGet, sServer, ProcessName, % "ahk_class " sClass
	StringTrimRight, sServer, sServer, 4
	iCodePage := A_IsUnicode ? 0x04B0 : 0x03EC ; 0x04B0 = CP_WINUNICODE, 0x03EC = CP_WINANSI
	DllCall("DdeInitialize", "UPtrP", idInst, "Uint", 0, "Uint", 0, "Uint", 0)
	hServer := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", sServer, "int", iCodePage)
	hTopic := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "WWW_GetWindowInfo", "int", iCodePage)
	hItem := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "0xFFFFFFFF", "int", iCodePage)
	hConv := DllCall("DdeConnect", "UPtr", idInst, "UPtr", hServer, "UPtr", hTopic, "Uint", 0)
	hData := DllCall("DdeClientTransaction", "Uint", 0, "Uint", 0, "UPtr", hConv, "UPtr", hItem, "UInt", 1, "Uint", 0x20B0, "Uint", 10000, "UPtrP", nResult) ; 0x20B0 = XTYP_REQUEST, 10000 = 10s timeout
	sData := DllCall("DdeAccessData", "Uint", hData, "Uint", 0, "Str")
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hServer)
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hTopic)
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hItem)
	DllCall("DdeUnaccessData", "UPtr", hData)
	DllCall("DdeFreeDataHandle", "UPtr", hData)
	DllCall("DdeDisconnect", "UPtr", hConv)
	DllCall("DdeUninitialize", "UPtr", idInst)
	csvWindowInfo := StrGet(&sData, "CP0")
	StringSplit, sWindowInfo, csvWindowInfo, `" ;"; comment to avoid a syntax highlighting issue in autohotkey.com/boards
	Return sWindowInfo2
}

GetBrowserURL_ACC(sClass) {
	global nWindow, accAddressBar
	If (nWindow != WinExist("ahk_class " sClass)) ; reuses accAddressBar if it's the same window
	{
		nWindow := WinExist("ahk_class " sClass)
		accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindow))
	}
	Try sURL := accAddressBar.accValue(0)
	If (sURL == "") {
		WinGet, nWindows, List, % "ahk_class " sClass ; In case of a nested browser window as in the old CoolNovo (TO DO: check if still needed)
		If (nWindows > 1) {
			accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindows2))
			Try sURL := accAddressBar.accValue(0)
		}
	}
	If ((sURL != "") and (SubStr(sURL, 1, 4) != "http")) ; Modern browsers omit "http://"
		sURL := "http://" sURL
	If (sURL == "")
		nWindow := -1 ; Don't remember the window if there is no URL
	Return sURL
}

; "GetAddressBar" based in code by uname
; Found at http://autohotkey.com/board/topic/103178-/?p=637687

GetAddressBar(accObj) {
	Try If ((accObj.accRole(0) == 42) and IsURL(accObj.accValue(0)))
		Return accObj
	Try If ((accObj.accRole(0) == 42) and IsURL("http://" accObj.accValue(0))) ; Modern browsers omit "http://"
		Return accObj
	For nChild, accChild in Acc_Children(accObj)
		If IsObject(accAddressBar := GetAddressBar(accChild))
			Return accAddressBar
}

IsURL(sURL) {
	Return RegExMatch(sURL, "^(?<Protocol>https?|ftp)://(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+)(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$")
}

; The code below is part of the Acc.ahk Standard Library by Sean (updated by jethrow)
; Found at http://autohotkey.com/board/topic/77303-/?p=491516

Acc_Init()
{
	static h
	If Not h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromWindow(hWnd, idObject = 0)
{
	Acc_Init()
	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return ComObjEnwrap(9,pacc,1)
}
Acc_Query(Acc) {
	Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
Acc_Children(Acc) {
	If ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	Else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			Return Children.MaxIndex()?Children:
		} Else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
}


; Saves the current clipboard history to hard disk
ExitSub:
	SetFormat, float, 06.0
	FileCreateDir, C:\tmp\AppsKeyAHK
	;C:\tmp\AppsKeyAHK\clipvar*.txt
	;  Loop %maxindex%
	;  {
	;  	zindex := SubStr("0000000000" . A_Index, -9)
	;  	thisclip := clipvar%A_Index%
	;  	FileAppend %thisclip%, C:\tmp\AppsKeyAHK\clipvar%zindex%.bin
	;  }
	FileDelete C:\tmp\AppsKeyAHK\AppsKeyClipData.bin
	FileAppend %maxindex%, C:\tmp\AppsKeyAHK\AppsKeyClipData.bin
	Loop %maxindex%
	{
		zindex := SubStr("0000000000" . A_Index, -9)
		thisclip := clipvar%A_Index%
		FileAppend %thisclip%, C:\tmp\AppsKeyAHK\AppsKeyClipData.bin:ClipStream%zindex%:$DATA
	}
	FileAppend %HiddenWins%, C:\tmp\AppsKeyAHK\windowHist.txt

	ExitApp ;end of clipboard
return

;===== Copy The Following Functions To Your Own Code Just once =====


; Note: parameters of the X,Y is the center of the coordinates,
; and the W,H is the offset distance to the center,
; So the search range is (X-W, Y-H)-->(X+W, Y+H).
; err1 is the character "0" fault-tolerant in percentage.
; err0 is the character "_" fault-tolerant in percentage.
; Text can be a lot of text to find, separated by "|".
; ruturn is a array, contains the X,Y,W,H,Comment results of Each Find.

FindText(x,y,w,h,err1,err0,text)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h, arr:=[]
  Loop, 2 {
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    Comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), Comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    ;--------------------------------------------
    if InStr(color,"-")
    {
      r:=e1, e1:=e0, e0:=r, v:=StrReplace(v,"1","_")
      v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    }
    mode:=InStr(color,"*") ? 1:0
    color:=RegExReplace(color,"[*\-]") . "@"
    StringSplit, r, color, @
    color:=Round(r1), n:=Round(r2,2)+(!r2)
    n:=Floor(255*3*(1-n)), k:=StrLen(v)*4
    VarSetCapacity(ss, sw*sh, Asc("0"))
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    VarSetCapacity(rx, 8, 0), VarSetCapacity(ry, 8, 0)
    len1:=len0:=0, j:=sw-w1+1, i:=-j
    ListLines, Off
    Loop, Parse, v
    {
      i:=Mod(A_Index,w1)=1 ? i+j : i+1
      if A_LoopField
        NumPut(i, s1, 4*len1++, "int")
      else
        NumPut(i, s0, 4*len0++, "int")
    }
    ListLines, On
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    ;--------------------------------------------
    if PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,ss,s1,s0,len1,len0,e1,e0,w1,h1,rx,ry)
    {
      rx+=x, ry+=y
      arr.Push(rx,ry,w1,h1,Comment)
    }
  }
  if (arr.MaxIndex())
    Break
  if (A_Index=1 and err1=0 and err0=0)
    err1:=0.05, err0:=0.05
  else Break
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride
  , sx, sy, sw, sh, ByRef ss, ByRef s1, ByRef s0
  , len1, len0, err1, err0, w, h, ByRef rx, ByRef ry)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E583EC408B45200FAF45188B551CC1E20201D08945F"
    . "48B5524B80000000029D0C1E00289C28B451801D08945D8C74"
    . "5F000000000837D08000F85F00000008B450CC1E81025FF000"
    . "0008945D48B450CC1E80825FF0000008945D08B450C25FF000"
    . "0008945CCC745F800000000E9AC000000C745FC00000000E98"
    . "A0000008B45F483C00289C28B451401D00FB6000FB6C02B45D"
    . "48945EC8B45F483C00189C28B451401D00FB6000FB6C02B45D"
    . "08945E88B55F48B451401D00FB6000FB6C02B45CC8945E4837"
    . "DEC007903F75DEC837DE8007903F75DE8837DE4007903F75DE"
    . "48B55EC8B45E801C28B45E401D03B45107F0B8B55F08B452C0"
    . "1D0C600318345FC018345F4048345F0018B45FC3B45240F8C6"
    . "AFFFFFF8345F8018B45D80145F48B45F83B45280F8C48FFFFF"
    . "FE9A30000008B450C83C00169C0E803000089450CC745F8000"
    . "00000EB7FC745FC00000000EB648B45F483C00289C28B45140"
    . "1D00FB6000FB6C069D02B0100008B45F483C00189C18B45140"
    . "1C80FB6000FB6C069C04B0200008D0C028B55F48B451401D00"
    . "FB6000FB6C06BC07201C83B450C730B8B55F08B452C01D0C60"
    . "0318345FC018345F4048345F0018B45FC3B45247C948345F80"
    . "18B45D80145F48B45F83B45280F8C75FFFFFF8B45242B45488"
    . "3C0018945488B45282B454C83C00189454C8B453839453C0F4"
    . "D453C8945D8C745F800000000E9E3000000C745FC00000000E"
    . "9C70000008B45F80FAF452489C28B45FC01D08945F48B45408"
    . "945E08B45448945DCC745F000000000EB708B45F03B45387D2"
    . "E8B45F08D1485000000008B453001D08B108B45F401D089C28"
    . "B452C01D00FB6003C31740A836DE001837DE00078638B45F03"
    . "B453C7D2E8B45F08D1485000000008B453401D08B108B45F40"
    . "1D089C28B452C01D00FB6003C30740A836DDC01837DDC00783"
    . "08345F0018B45F03B45D87C888B551C8B45FC01C28B4550891"
    . "08B55208B45F801C28B45548910B801000000EB2990EB01908"
    . "345FC018B45FC3B45480F8C2DFFFFFF8345F8018B45F83B454"
    . "C0F8C11FFFFFFB800000000C9C25000"
    x64:="554889E54883EC40894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945F48B5548B8000000002"
    . "9D0C1E00289C28B453001D08945D8C745F000000000837D100"
    . "00F85000100008B4518C1E81025FF0000008945D48B4518C1E"
    . "80825FF0000008945D08B451825FF0000008945CCC745F8000"
    . "00000E9BC000000C745FC00000000E99A0000008B45F483C00"
    . "24863D0488B45284801D00FB6000FB6C02B45D48945EC8B45F"
    . "483C0014863D0488B45284801D00FB6000FB6C02B45D08945E"
    . "88B45F44863D0488B45284801D00FB6000FB6C02B45CC8945E"
    . "4837DEC007903F75DEC837DE8007903F75DE8837DE4007903F"
    . "75DE48B55EC8B45E801C28B45E401D03B45207F108B45F0486"
    . "3D0488B45584801D0C600318345FC018345F4048345F0018B4"
    . "5FC3B45480F8C5AFFFFFF8345F8018B45D80145F48B45F83B4"
    . "5500F8C38FFFFFFE9B60000008B451883C00169C0E80300008"
    . "94518C745F800000000E98F000000C745FC00000000EB748B4"
    . "5F483C0024863D0488B45284801D00FB6000FB6C069D02B010"
    . "0008B45F483C0014863C8488B45284801C80FB6000FB6C069C"
    . "04B0200008D0C028B45F44863D0488B45284801D00FB6000FB"
    . "6C06BC07201C83B451873108B45F04863D0488B45584801D0C"
    . "600318345FC018345F4048345F0018B45FC3B45487C848345F"
    . "8018B45D80145F48B45F83B45500F8C65FFFFFF8B45482B859"
    . "000000083C0018985900000008B45502B859800000083C0018"
    . "985980000008B45703945780F4D45788945D8C745F80000000"
    . "0E90B010000C745FC00000000E9EC0000008B45F80FAF45488"
    . "9C28B45FC01D08945F48B85800000008945E08B85880000008"
    . "945DCC745F000000000E9800000008B45F03B45707D368B45F"
    . "04898488D148500000000488B45604801D08B108B45F401D04"
    . "863D0488B45584801D00FB6003C31740A836DE001837DE0007"
    . "8778B45F03B45787D368B45F04898488D148500000000488B4"
    . "5684801D08B108B45F401D04863D0488B45584801D00FB6003"
    . "C30740A836DDC01837DDC00783C8345F0018B45F03B45D80F8"
    . "C74FFFFFF8B55388B45FC01C2488B85A000000089108B55408"
    . "B45F801C2488B85A80000008910B801000000EB2F90EB01908"
    . "345FC018B45FC3B85900000000F8C05FFFFFF8345F8018B45F"
    . "83B85980000000F8CE6FEFFFFB8000000004883C4405DC390"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "ptr",&s1, "ptr",&s0
    , "int",len1, "int",len0, "int",err1, "int",err0
    , "int",w, "int",h, "int*",rx, "int*",ry)
}

xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
{
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits)
{
  VarSetCapacity(bits, w*h*4, 0)
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  hBM:=DllCall("CreateCompatibleBitmap", Ptr,hDC, "int",w, "int",h, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
    , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
  ;--------------------------
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp:=32, bi, 14, "short")
  ;--------------------------
  DllCall("GetDIBits", Ptr,mDC, Ptr,hBM
    , "int",0, "int",h, Ptr,&bits, Ptr,&bi, "int",0)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteObject", Ptr,hBM)
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
}

base64tobit(s)
{
  ListLines, Off
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  StringCaseSense, On
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,A_LoopField,v)
  }
  StringCaseSense, Off
  s:=SubStr(s,1,InStr(s,"1",0,0)-1)
  s:=RegExReplace(s,"[^01]+")
  ListLines, On
  return, s
}

bit2base64(s)
{
  ListLines, Off
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,v,A_LoopField)
  }
  ListLines, On
  return, s
}

ASCII(s)
{
  if RegExMatch(s,"(\d+)\.([\w+/]{3,})",r)
  {
    s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return, s
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}




SendEmail(ToAddress, subject ="No Subject", Body = "Automated Message: No Content", send=False )
{
	m := ComObjCreate("Outlook.Application").CreateItem(0)
	m.Subject := subject
	m.To := ToAddress
	m.Body := Body
	if (Send = True)
		m.Send ;to automatically send and CLOSE that new email window...  
	else 
		m.Display ;to display the email message...
	return
}