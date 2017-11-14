#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
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
Menu Case, Add, 
; Menu Case, Add, Clipboard by line, CCase






;******************************************************************************


;  MsgRepSQout()
;part of get url use: GetActiveBrowserURL()
ModernBrowsers := "ApplicationFrameWindow,Chrome_WidgetWin_0,Chrome_WidgetWin_1,Chrome_WidgetWin_2,Maxthon3Cls_MainFrm,MozillaWindowClass,Slimjet_WidgetWin_1"
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
ReadIni("C:\tmp\AppsKeyAHK\AppsKeySettings.ini")
repeatTimer:=250
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

AppsKey & i::
	IgnoreClipboardChange := False
	MouseGetPos, xpos, ypos 
	clipboard := "{click, " . xpos . ", " . ypos . "}"
	IgnoreClipboardChange := False
Return

AppsKey::
	;Keep AppsKey working (mostly) normally.
	Send {AppsKey}
Return


AppsKey & p::
	SysGet, VirtualWidth, 78
	SysGet, VirtualHeight, 79
	MouseGetPos, xpos, ypos 
	tooltip, The cursor is at X%xpos% Y%ypos%`n%A_ScreenWidth%w h%A_ScreenHeight%`n%VirtualWidth%w h%VirtualHeight%. 
	SetTimer, ReSetToolTip, 5000
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
	repeatTimer:= repeatTimer - 50
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return
^+2::
	repeatTimer:=250
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return
^+3::
	repeatTimer:=repeatTimer + 50
	tooltip repeat Timer Changed - %repeatTimer%
	SetTimer, ReSetToolTip, % repeatTimer
return


;Paste And move Forward one
; controlcarregex := "({F1.{0,5}?}|{F2.{0,5}?}|{F3.{0,5}?}|{F4.{0,5}?}|{F5.{0,5}?}|{F6.{0,5}?}|{F7.{0,5}?}|{F8.{0,5}?}|{F9.{0,5}?}|{F10.{0,5}?}|{F11.{0,5}?}|{F12.{0,5}?}|{F13.{0,5}?}|{F14.{0,5}?}|{F15.{0,5}?}|{F16.{0,5}?}|{F17.{0,5}?}|{F18.{0,5}?}|{F19.{0,5}?}|{F20.{0,5}?}|{F21.{0,5}?}|{F22.{0,5}?}|{F23.{0,5}?}|{F24.{0,5}?}|{!.{0,5}?}|{#.{0,5}?}|{+.{0,5}?}|{^.{0,5}?}|{{.{0,5}?}|{}.{0,5}?}|{Enter.{0,5}?}|{Escape.{0,5}?}|{Space.{0,5}?}|{Tab.{0,5}?}|{Backspace.{0,5}?}|{Delete.{0,5}?}|{Insert.{0,5}?}|{Up.{0,5}?}|{Down.{0,5}?}|{Left.{0,5}?}|{Right.{0,5}?}|{Home.{0,5}?}|{End.{0,5}?}|{PgUp.{0,5}?}|{PgDn.{0,5}?}|{CapsLock.{0,5}?}|{ScrollLock.{0,5}?}|{NumLock.{0,5}?}|{Control.{0,5}?}|{LControl.{0,5}?}|{RControl.{0,5}?}|{Control Down.{0,5}?}|{Alt.{0,5}?}|{LAlt.{0,5}?}|{RAlt.{0,5}?}|{Alt Down.{0,5}?}|{Shift.{0,5}?}|{LShift.{0,5}?}|{RShift.{0,5}?}|{Shift Down.{0,5}?}|{LWin.{0,5}?}|{RWin.{0,5}?}|{LWin Down.{0,5}?}|{RWin Down.{0,5}?}|{AppsKey.{0,5}?}|{Sleep.{0,5}?}|{ASC nnnnn.{0,5}?}|{U+nnnn.{0,5}?}|{vkXX.{0,5}?}|{scYYY.{0,5}?}|{vkXXscYYY.{0,5}?}|{Numpad0.{0,5}?}|{NumpadDot.{0,5}?}|{NumpadEnter.{0,5}?}|{NumpadMult.{0,5}?}|{NumpadDiv.{0,5}?}|{NumpadAdd.{0,5}?}|{NumpadSub.{0,5}?}|{NumpadDel.{0,5}?}|{NumpadIns.{0,5}?}|{NumpadClear.{0,5}?}|{NumpadUp.{0,5}?}|{NumpadDown.{0,5}?}|{NumpadLeft.{0,5}?}|{NumpadRight.{0,5}?}|{NumpadHome.{0,5}?}|{NumpadEnd.{0,5}?}|{NumpadPgUp.{0,5}?}|{NumpadPgDn.{0,5}?}|{Browser_Back.{0,5}?}|{Browser_Forward.{0,5}?}|{Browser_Refresh.{0,5}?}|{Browser_Stop.{0,5}?}|{Browser_Search.{0,5}?}|{Browser_Favorites.{0,5}?}|{Browser_Home.{0,5}?}|{Volume_Mute.{0,5}?}|{Volume_Down.{0,5}?}|{Volume_Up.{0,5}?}|{Media_Next.{0,5}?}|{Media_Prev.{0,5}?}|{Media_Stop.{0,5}?}|{Media_Play_Pause.{0,5}?}|{Launch_Mail.{0,5}?}|{Launch_Media.{0,5}?}|{Launch_App1.{0,5}?}|{Launch_App2.{0,5}?}|{PrintScreen.{0,5}?}|{CtrlBreak.{0,5}?}|{Pause.{0,5}?}|{Click [Options].{0,5}?}|{WheelDown.{0,5}?}|{Blind.{0,5}?}|{Blind.{0,5}?}|{Blind.{0,5}?}|{Raw})"
F2 Up::
	IgnoreClipboardChange := True
	controlcarregex :="((\{Enter.{0,5}?\})|(\{Escape.{0,5}?\})|(\{Space.{0,5}?\})|(\{Tab.{0,5}?\})|(\{Backspace.{0,5}?\})|(\{Delete.{0,5}?\})|(\{Insert.{0,5}?\})|(\{Up.{0,5}?\})|(\{Down.{0,5}?\})|(\{Left.{0,5}?\})|(\{Right.{0,5}?\})|(\{Home.{0,5}?\})|(\{End.{0,5}?\})|(\{PgUp.{0,5}?\})|(\{PgDn.{0,5}?\})|(\{enter.{0,5}?\})|(\{escape.{0,5}?\})|(\{space.{0,5}?\})|(\{tab.{0,5}?\})|(\{backspace.{0,5}?\})|(\{delete.{0,5}?\})|(\{insert.{0,5}?\})|(\{up.{0,5}?\})|(\{down.{0,5}?\})|(\{left.{0,5}?\})|(\{right.{0,5}?\})|(\{home.{0,5}?\})|(\{end.{0,5}?\})|(\{pgup.{0,5}?\})|(\{pgdn.{0,5}?\})|(\{\})|(\{.?\}))"
	if (IgnoreClipboardChange = True)
	{

Loop, 0
{
; findclick(find, click, timeout=2000, clickbuffer=1)
; waitfound(text, timeout=2000)
; waitclick(text, timeout=2000, clickbuffer=1)
		click, middle, 239, 431
		sleep repeatTimer*2
		SendInputSlow(controlcarregex, repeatTimer, repeatTimer, "^{tab}")	
		waitfound("|<Resolution>*161$53.0000E0001w000U2802800104004FttmFSXZsYIIIWF9gy8QMd4WVFYTilG952X4U3WYG+56BV558YGOABtlmDCbYM", 8000)
		sleep repeatTimer
		waitfound("|<Resolution>*161$53.0000E0001w000U2802800104004FttmFSXZsYIIIWF9gy8QMd4WVFYTilG952X4U3WYG+56BV558YGOABtlmDCbYM", 8000)
		sleep repeatTimer
		waitclick("|<edit>*148$19.00001000Z00EUttQUYcTWI0F+44Z1nmM001zzyU", 5000)
		sleep repeatTimer
		waitfound("|<editoricon>*159$14.Dy3zU301U0M060300l4AP63U0vzPzoM", 5000)
		MouseMove, 0, 50 , 0, R
		click
		sleep repeatTimer
		IgnoreClipboardChange := True
		sleep repeatTimer
		;get the text to put into resolution
		WinGetTitle, CurrentTitle, A
		TicketTitle = DOMO`: Ticket#`:
		If (InStr(CurrentTitle, TicketTitle, 0,1) and IgnoreClipboardChange)
		{
			Send,{Shift Up}{Ctrl Up}
			Send, {Tab}{Ctrl Down}a{Ctrl Up}
			GetText(TempText)
			Send, {Ctrl Down}{Shift Down}{home}{Shift Up}{Ctrl Up}
			ClientID := SubStr(Temptext, inStr(TempText, "Client Id") + 9, inStr(TempText, "Client Type") - inStr(TempText, "Client Id") - 9)
			ClientFname := SubStr(Temptext, inStr(TempText, "First Name") + 10, inStr(TempText, "Last Name") - inStr(TempText, "First Name") - 10)
			ClientLname := SubStr(Temptext, inStr(TempText, "Last Name") + 10, inStr(TempText, "Payroll Status") - inStr(TempText, "Last Name") - 10)
			ClientFname := st_setCase(ClientFname, "t")
			ClientLname := st_setCase(ClientLname, "t")
			; TempText := ClientID "- " ClientFname " " ClientLname " "
			TempText := ClientID "- " ClientFname " " ClientLname " has been created in maximo"
			StringReplace,TempText,TempText,`n,,A
			StringReplace,TempText,TempText,`r,,A
			IgnoreClipboardChange := False
			if(IgnoreClipboardChange = False and StrLen(TempText)>5)
				clipboard := TempText
			Send, +{tab}
			sleep repeatTimer
			Send, ^{a}
			sleep repeatTimer
			Send, ^{v}
		}
		sleep repeatTimer
		Send, {PgDn}
		sleep repeatTimer*2
		waitclick("|<Okaybutton>*183$33.Tzzzzo00001U0000A00001U0000A0D301U36M0A0kH01U43NUA0UPE1U43Q0A0UPk1U62O0A0MnM1U1sNUA00001U0000A00001U0000A00001Tzzzzo", 5000)
		sleep repeatTimer
		Send, {home}
		sleep repeatTimer
		waitfound("|<actions>*152$62.63zzswMXs01lUAAlb9U00wE33ANmM0zBA0kn2Kbk7aP0AAkYsy1tyk33ANC1UAMa0knaFUM3AAyASD4Nw02",5000)
		sleep repeatTimer
		waitclick("|<close>*130$29.wUQDT514UU2451048/Xk8EEo0EUUcWUW1Ftwswy",5000)
		sleep repeatTimer
		waitclick("|<closed>*155$48.VTvzzzzzTTvzzzzzD4MB3zzzXT/BTzzzxQ/B7zzzxP/Bvzzz348V7zzzzzzzzzzzzzzzzzzzzzzzzzzzkNy3kE43X9wFaFwF7dss7FwM7tss1lwM7tssUEAM7tsss1wM7dssS1wMX9wF6FwFkM63Uk43U",5000)
		Send ^{w}
		sleep repeatTimer
		Send {F5}
		tooltip done! looping
		sleep repeatTimer*6
		tooltip

} ;end loop

		; clipboard = %clipboard%
		; Clipboard := regexreplace(Clipboard, "\r\n?|\n\r?", "`n")
		; SendInputSlow(controlcarregex, repeatTimer, repeatTimer, clipboard)
		; if clipindex < %maxindex%
		; {
		; 	clipindex += 1
		; }
		; thisclip := clipvar%clipindex%
		; clipboard := thisclip
		; tooltip %clipindex% - %clipboard%
		; SetTimer, ReSetToolTip, 1000
		; sleep repeatTimer
	}
	IgnoreClipboardChange := False
Return


;https://autohotkey.com/board/topic/58230-how-to-slow-down-send-commands/
;send event type slow
^+R::
	IgnoreClipboardChange := True
	controlcarregex :="((\{Enter.{0,5}?\})|(\{Escape.{0,5}?\})|(\{Space.{0,5}?\})|(\{Tab.{0,5}?\})|(\{Backspace.{0,5}?\})|(\{Delete.{0,5}?\})|(\{Insert.{0,5}?\})|(\{Up.{0,5}?\})|(\{Down.{0,5}?\})|(\{Left.{0,5}?\})|(\{Right.{0,5}?\})|(\{Home.{0,5}?\})|(\{End.{0,5}?\})|(\{PgUp.{0,5}?\})|(\{PgDn.{0,5}?\})|(\{enter.{0,5}?\})|(\{escape.{0,5}?\})|(\{space.{0,5}?\})|(\{tab.{0,5}?\})|(\{backspace.{0,5}?\})|(\{delete.{0,5}?\})|(\{insert.{0,5}?\})|(\{up.{0,5}?\})|(\{down.{0,5}?\})|(\{left.{0,5}?\})|(\{right.{0,5}?\})|(\{home.{0,5}?\})|(\{end.{0,5}?\})|(\{pgup.{0,5}?\})|(\{pgdn.{0,5}?\})|(\{\}))"
	if (IgnoreClipboardChange = True)
	{
		clipboard = %clipboard%
		Clipboard := regexreplace(Clipboard, "\r\n?|\n\r?", "`n")
		; Send, {Shift Up}{Ctrl Up}{R Up}
		SendInputSlow("(\{\})", repeatTimer, repeatTimer, clipboard)
		; Send, {Shift Down}{Ctrl Down}{R Up}
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


^+o:: ; Ctrl+Shift+o
controlcarregex :="((\{Enter.{0,5}?\})|(\{Escape.{0,5}?\})|(\{Space.{0,5}?\})|(\{Tab.{0,5}?\})|(\{Backspace.{0,5}?\})|(\{Delete.{0,5}?\})|(\{Insert.{0,5}?\})|(\{Up.{0,5}?\})|(\{Down.{0,5}?\})|(\{Left.{0,5}?\})|(\{Right.{0,5}?\})|(\{Home.{0,5}?\})|(\{End.{0,5}?\})|(\{PgUp.{0,5}?\})|(\{PgDn.{0,5}?\})|(\{enter.{0,5}?\})|(\{escape.{0,5}?\})|(\{space.{0,5}?\})|(\{tab.{0,5}?\})|(\{backspace.{0,5}?\})|(\{delete.{0,5}?\})|(\{insert.{0,5}?\})|(\{up.{0,5}?\})|(\{down.{0,5}?\})|(\{left.{0,5}?\})|(\{right.{0,5}?\})|(\{home.{0,5}?\})|(\{end.{0,5}?\})|(\{pgup.{0,5}?\})|(\{pgdn.{0,5}?\})|(\{\}))"
msgbox %  "the value is: " . controlcarregex
  p_string = {Tab 4}_CustomerUsername{Tab}_Contac{}tNumber{Tab 2}_Name _Surname{Tab}_CustomerNumber{Tab}^a_Address1{Enter}_City{Enter}_State _Postcode
  p_delimiter := controlcarregex
    p_string_unique := RegExReplace(p_string, p_delimiter, "$1§")
  MsgBox, %p_string%`n`n%p_string_unique%
return


SendInputSlow(p_delimiter, p_sleep, p_initsleep, p_string)
{
;   https://autohotkey.com/board/topic/30752-sendinputslow-delay-function/
  global ; Don't think this is needed, but it might cover any future issues.

; Adds § after each delimiter in string.
  p_string_unique := RegExReplace(p_string, p_delimiter, "$1§")
  
; Process InitSleep.
  if p_initsleep = 1
    Sleep, %p_sleep%
  else if p_initsleep > 1
    Sleep, %p_initsleep%

; Send delimiter seperated values.
  Loop, parse, p_string_unique, §
  {
	  tooltip, %A_LoopField%
	SendInput, %A_LoopField%
	Sleep, %p_sleep%
  }
}

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


; clip_getByLine()
; {
; 	IgnoreClipboardChange := True
; 	if (IgnoreClipboardChange){
; 	GetText(TempText)
; 	clipindex := maxindex
; 	lineCount := clipindex
; 	Loop, parse, TempText, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
; 	{	
; 		clipindex += 1
; 		clipvar%clipindex% := A_LoopField
; 	}
; 	tooltip %clipindex%(total) - %lineCount% lines have been Appened to Clipboard History `r`n %TempText%
; 	SetTimer, ReSetToolTip, 2500
; 	maxindex := clipindex
; 	clipindex := maxindex-lineCount
; 	}
; 	IgnoreClipboardChange := False
; return
; }

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
	maxindex := clipindex
	clipindex := maxindex-lineCount
	tooltip %clipindex%(total) - %lineCount% lines have been Appened to Clipboard History `r`n %TempText%
	SetTimer, ReSetToolTip, 2500

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
	IfWinActive, ahk_class Chrome_WidgetWin_1 
	{
		waitclick(CCAppIconAll)
		waitclick(CC1ClickAll)
		findclick(CCStop, CCPopupClose)
	}
return

waitclick(text, timeout=2000, clickbuffer=1)
{
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,text)
		{
			CoordMode, Mouse
			X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5
			MouseMove, X+W//2, Y+H//2
			sleep clickbuffer
			MouseClick
			break
		}
	}
	return
}

waitfound(text, timeout=2000)
{
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,text)
		{
			CoordMode, Mouse
			X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5
			MouseMove, X+W//2, Y+H//2
			break
		}
	}
	return ok
}


findclick(find, click, timeout=2000, clickbuffer=1)
{
	start := A_TickCount
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,find)
		{
			CoordMode, Mouse
			X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5
			break
		}
	}
	while (A_TickCount-start <= timeout)
	{
		sleep 50
		if ok:=FindText(808,285,150000,150000,0,0,click)
		{
			CoordMode, Mouse
			X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5
			MouseMove, X+W//2, Y+H//2
			sleep clickbuffer
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
		; Else if (A_thismenuitempos = 18)
		; {
		; 	clip_getByLine()
		; 	return
		; }
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

Odd(n){
    return n&1
}
Even(n){
    return mod(n, 2) = 0
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


GetActiveBrowserURL() {
	global ModernBrowsers, LegacyBrowsers
	WinGetClass, sClass, A
	; msgbox, %sClass%
	; msgbox % GetBrowserURL_ACC(sClass)
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
; ruturn is a array, contains the [X,Y,W,H,Comment] results of Each Find.

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
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
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
    VarSetCapacity(ss, sw*sh, Asc("0"))
    VarSetCapacity(allpos, 1024*4, 0)
    ;--------------------------------------------
    if (num:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,ss,s1,s0,len1,len0,e1,e0,w1,h1,allpos))
      or (err1=0 and err0=0
      and (num:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,ss,s1,s0,len1,len0,0.05,0.05,w1,h1,allpos)))
    {
      Loop, % num
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
        , arr.Push([rx,ry,w1,h1,Comment])
    }
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride
  , sx, sy, sw, sh, ByRef ss, ByRef s1, ByRef s0
  , len1, len0, err1, err0, w1, h1, ByRef allpos)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E55383EC408B45200FAF45188B551CC1E20201D0894"
    . "5F88B5524B80000000029D0C1E00289C28B451801D08945D0C"
    . "745F400000000C745F000000000837D08000F85F00000008B4"
    . "50CC1E81025FF0000008945CC8B450CC1E80825FF000000894"
    . "5C88B450C25FF0000008945C4C745E800000000E9AC000000C"
    . "745EC00000000E98A0000008B45F883C00289C28B451401D00"
    . "FB6000FB6C02B45CC8945E48B45F883C00189C28B451401D00"
    . "FB6000FB6C02B45C88945E08B55F88B451401D00FB6000FB6C"
    . "02B45C48945DC837DE4007903F75DE4837DE0007903F75DE08"
    . "37DDC007903F75DDC8B55E48B45E001C28B45DC01D03B45107"
    . "F0B8B55F48B452C01D0C600318345EC018345F8048345F4018"
    . "B45EC3B45240F8C6AFFFFFF8345E8018B45D00145F88B45E83"
    . "B45280F8C48FFFFFFE9A30000008B450C83C00169C0E803000"
    . "089450CC745E800000000EB7FC745EC00000000EB648B45F88"
    . "3C00289C28B451401D00FB6000FB6C069D02B0100008B45F88"
    . "3C00189C18B451401C80FB6000FB6C069C04B0200008D0C028"
    . "B55F88B451401D00FB6000FB6C06BC07201C83B450C730B8B5"
    . "5F48B452C01D0C600318345EC018345F8048345F4018B45EC3"
    . "B45247C948345E8018B45D00145F88B45E83B45280F8C75FFF"
    . "FFF8B45242B454883C0018945C08B45282B454C83C0018945B"
    . "C8B453839453C0F4D453C8945D0C745E800000000E9FB00000"
    . "0C745EC00000000E9DF0000008B45E80FAF452489C28B45EC0"
    . "1D08945F88B45408945D88B45448945D4C745F400000000EB7"
    . "08B45F43B45387D2E8B45F48D1485000000008B453001D08B1"
    . "08B45F801D089C28B452C01D00FB6003C31740A836DD801837"
    . "DD800787B8B45F43B453C7D2E8B45F48D1485000000008B453"
    . "401D08B108B45F801D089C28B452C01D00FB6003C30740A836"
    . "DD401837DD40078488345F4018B45F43B45D07C888B45F08D5"
    . "0018955F08D1485000000008B455001D08B4D208B55E801CA8"
    . "9D3C1E3108B4D1C8B55EC01CA09DA8910817DF0FF0300007F2"
    . "8EB0490EB01908345EC018B45EC3B45C00F8C15FFFFFF8345E"
    . "8018B45E83B45BC0F8CF9FEFFFFEB01908B45F083C4405B5DC"
    . "24C00909090"
    x64:="554889E54883EC40894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945FC8B5548B8000000002"
    . "9D0C1E00289C28B453001D08945D4C745F800000000C745F40"
    . "0000000837D10000F85000100008B4518C1E81025FF0000008"
    . "945D08B4518C1E80825FF0000008945CC8B451825FF0000008"
    . "945C8C745EC00000000E9BC000000C745F000000000E99A000"
    . "0008B45FC83C0024863D0488B45284801D00FB6000FB6C02B4"
    . "5D08945E88B45FC83C0014863D0488B45284801D00FB6000FB"
    . "6C02B45CC8945E48B45FC4863D0488B45284801D00FB6000FB"
    . "6C02B45C88945E0837DE8007903F75DE8837DE4007903F75DE"
    . "4837DE0007903F75DE08B55E88B45E401C28B45E001D03B452"
    . "07F108B45F84863D0488B45584801D0C600318345F0018345F"
    . "C048345F8018B45F03B45480F8C5AFFFFFF8345EC018B45D40"
    . "145FC8B45EC3B45500F8C38FFFFFFE9B60000008B451883C00"
    . "169C0E8030000894518C745EC00000000E98F000000C745F00"
    . "0000000EB748B45FC83C0024863D0488B45284801D00FB6000"
    . "FB6C069D02B0100008B45FC83C0014863C8488B45284801C80"
    . "FB6000FB6C069C04B0200008D0C028B45FC4863D0488B45284"
    . "801D00FB6000FB6C06BC07201C83B451873108B45F84863D04"
    . "88B45584801D0C600318345F0018345FC048345F8018B45F03"
    . "B45487C848345EC018B45D40145FC8B45EC3B45500F8C65FFF"
    . "FFF8B45482B859000000083C0018945C48B45502B859800000"
    . "083C0018945C08B45703945780F4D45788945D4C745EC00000"
    . "000E926010000C745F000000000E90A0100008B45EC0FAF454"
    . "889C28B45F001D08945FC8B85800000008945DC8B858800000"
    . "08945D8C745F800000000E9840000008B45F83B45707D3A8B4"
    . "5F84898488D148500000000488B45604801D08B108B45FC01D"
    . "04863D0488B45584801D00FB6003C31740E836DDC01837DDC0"
    . "00F88910000008B45F83B45787D368B45F84898488D1485000"
    . "00000488B45684801D08B108B45FC01D04863D0488B4558480"
    . "1D00FB6003C30740A836DD801837DD80078568345F8018B45F"
    . "83B45D40F8C70FFFFFF8B45F48D50018955F44898488D14850"
    . "0000000488B85A00000004801D08B4D408B55EC01CAC1E2104"
    . "189D08B4D388B55F001CA4409C28910817DF4FF0300007F28E"
    . "B0490EB01908345F0018B45F03B45C40F8CEAFEFFFF8345EC0"
    . "18B45EC3B45C00F8CCEFEFFFFEB01908B45F44883C4405DC39"
    . "090909090909090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "ptr",&s1, "ptr",&s0, "int",len1, "int",len0
    , "int",Round(len1*err1), "int",Round(len0*err0)
    , "int",w1, "int",h1, "ptr",&allpos)
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
  VarSetCapacity(bits,w*h*4,0), bpp:=32
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  ;-------------------------
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  ;-------------------------
  if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
  {
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteObject", Ptr,hBM)
  }
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
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

; You can put the text library at the beginning of the script,
; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib

Pic(comments, add_to_Lib=0) {
  static Lib:=[]
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]{3,}"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
        Lib[Trim(r1)]:=r
  }
  else
  {
    text:=""
    Loop, Parse, comments, |
      text.="|" . Lib[Trim(A_LoopField)]
    return, text
  }
}

FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=5) {
  OCR:="", Right_X:=nX+nW
  While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text))
  {
    ; For multi text search, This is the number of text images found
    Loop, % ok.MaxIndex()
    {
      ; X is the X coordinates of the upper left corner
      ; and W is the width of the image have been found
      i:=A_Index, x:=ok[i].1, y:=ok[i].2
        , w:=ok[i].3, h:=ok[i].4, comment:=ok[i].5
      ; We need the leftmost X coordinates
      if (A_Index=1 or x<Left_X)
        Left_X:=x, Left_W:=w, Left_OCR:=comment
    }
    ; If the interval exceeds the set value, add "*" to the result
    OCR.=(A_Index>1 and Left_X-Last_X>Interval ? "*":"") . Left_OCR
    ; Update nX and nW for next search
    x:=Left_X+Left_W, nW:=(Right_X-x)//2, nX:=x+nW, Last_X:=x
  }
  Return, OCR
}


/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(int mode
  , unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, int * s1, int * s0
  , int len1, int len0, int err1, int err0
  , int w1, int h1, int * allpos)
{
  int o=sy*Stride+sx*4, j=Stride-4*sw, i=0, num=0;
  int x, y, w, h, r, g, b, rr, gg, bb, e1, e0;
  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
        if (r+g+b<=n) ss[i]='1';
      }
  }
  else  // Gray Threshold Mode
  {
    c=(c+1)*1000;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c)
          ss[i]='1';
  }
  w=sw-w1+1; h=sh-h1+1;
  j=len1>len0 ? len1 : len0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      for (i=0; i<j; i++)
      {
        if (i<len1 && ss[o+s1[i]]!='1' && (--e1)<0)
          goto NoMatch;
        if (i<len0 && ss[o+s0[i]]!='0' && (--e0)<0)
          goto NoMatch;
      }
      allpos[num++]=(sy+y)<<16|(sx+x);
      if (num>=1024) goto MaxNum;
      NoMatch:
      continue;
    }
  }
  MaxNum:
  return num;
}

*/

;================= The End =================

;


ReadIni( filename = 0 )
{
; Read a whole .ini file and creates variables like this:
; %Section%%Key% = %value%
Local s, c, p, key, k

	if not filename
		filename := SubStr( A_ScriptName, 1, -3 ) . "ini"

	FileRead, s, %filename%

	Loop, Parse, s, `n`r, %A_Space%%A_Tab%
	{
		c := SubStr(A_LoopField, 1, 1)
		if (c="[")
			key := SubStr(A_LoopField, 2, -1)
		else if (c=";")
			continue
		else {
			p := InStr(A_LoopField, "=")
			if p {
				k := SubStr(A_LoopField, 1, p-1)
				%key%%k% := SubStr(A_LoopField, p+1)
			}
		}
	}
	return
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

ComWait(IE) {
While IE.readyState != 4 || IE.document.readyState != "complete" || IE.busy
   Sleep 300
   Sleep 300
}