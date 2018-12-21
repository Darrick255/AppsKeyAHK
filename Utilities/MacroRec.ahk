; https://autohotkey.com/boards/viewtopic.php?t=34184


/*
----------------------------------------
  Mouse And Keyboard Macro Recorder v4.6

  Author: FeiYue

  Introduction:

  1. This script record the mouse and keyboard actions
     and then play back.

  2. Use the mouse to shake on the left edge of the screen
     to show or hide the GUI window, It reduces the use of hotkeys.
     you can change and insert code during the recording process,
     When the GUI window is displayed, the recording is automatically paused,
     and even minimize GUI window, it is paused.
     When the Gui window is hidden,the recording will continue automatically.

  3. If you want to stop playback process,
     please press the [Pause Play] hotkey first,
     and then click the Stop button in the GUI.

  4. You can press the Ctrl key individually to display a menu,
     Press the Ctrl key again to select the items in the menu.
     You can add the picture origin code, add wait
     picture code, mouse movement code, delay code,
     wait color code, and wait cursor position code.

     Note: You can press down the Ctrl key at the target point,
     then move the mouse to another place (Recommend),
     and then release the Ctrl key to display the menu.

  5. If you want to record the mouse action in ControlClick mode,
     You can let the CtrlClick CheckBox be selected.
     Menu, etc. window non client area cannot use ControlClick,
     Even in the window client area, some places are not good.
     Sometimes you need to change the number of Clicks to 2,
     for the first time target control gets the focus, but
     watch for any side effects. (Beginners are not recommended)

  6. If the script is stuck while running, please press the
     [Pause Play] hotkey first, and then click the Debug button
     in the GUI to locate the currently running line,
     this makes it easy to debug and modify. When you fix it,
     You can click the PlayNext button to continue running halfway
     through the line in the edit box's current cursor.

  7. You can use the set origin button and convert button,
     batch conversion to the relative picture coordinates.

  Record   Button  -->  Record Mouse/Keyboard/Window
  Stop     Button  -->  Stop   Record / Play
  Play     Button  -->  Start running from the first line
  PlayNext Button  -->  Start running from the current line
  Debug    Button  -->  Jump to the running line

  Win Titile CheckBox --> Additional title when recording window
  Win Text   CheckBox --> Additional text when recording window
  CtrlClick  CheckBox --> Additional ControlClick code
  Loop Play  CheckBox --> Loop playback, if 0 will Infinite loop

  Hotkey [F1] --> Record
  Hotkey [F2] --> Stop
  Hotkey [F3] --> Play
  Hotkey [F4] --> Pause Play

----------------------------------------
*/

#NoEnv
#SingleInstance force
SetBatchLines, -1
Thread, NoTimers
SetTitleMatchMode, 2
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
Menu, Tray, Add
Menu, Tray, Add, Macro Recorder, Show
Menu, Tray, Default, Macro Recorder
Menu, Tray, Click, 1
Menu, Tray, Icon, Shell32.dll, 44, 1
;----------------------------
LogFile:=A_ScriptDir "\Record.txt"
PlayFile:=A_ScriptDir "\Play.txt"
PlayFileName:=RegExReplace(PlayFile,".*\\") " ahk_class AutoHotkey"
;----------------------------
Gosub, MainGUI
Gosub, CtrlMenuGUI
SwitchGUI()
;----------------------------
UsedKeys:="F1,F2,F3,F4"
For k,v in StrSplit(UsedKeys, ",")
  Hotkey, *%v%, %v%, P10
;----------------------------
return

CtrlMenuGUI:
s:=getfs(), Cmd:=[], ss:="", i:=0
re=\n;@([\w@#$[:^ascii:]]*)([(=])([^\r\n]*)
While i:=RegExMatch(s, re, r, i+=1)
{
  r1:=InStr(r1,"Origin") ? "[" r1 "]" : r1
  v:=r2="(" ? SubStr(r,4) : r3
  Cmd[r1]:=StrReplace(v,"``n","`n"), ss.=r1 "|"
}
s:=SubStr(ss,1,-1)
;---------------------
Gui, CtrlMenu: New
Gui, +AlwaysOnTop -Caption +ToolWindow +Hwndgui2_id +E0x08000000
Gui, Margin, 0, 0
Gui, Color, DDEEFF
Gui, Font, s14, Verdana
For i,v in StrSplit(s, "|")
{
  j:=Mod(i,3)=1 ? "xm" : "x+0"
  Gui, Add, Button, w200 %j%, % Trim(v)
}
Gui, Show, Hide, CtrlMenu
GuiControlGet, p, Pos, MouseMove
CtrlMenuW:=Round(pX+pW//2)
CtrlMenuH:=Round(pY+pH//2)
return


;===== Hotkeys Begin =====


F1:    ;-- Record Mouse and Key and Window
Record:
Suspend, Permit
if Recording
  return
Gosub, ShowSwitch
Gosub, Stop
Gosub, Submit
Gosub, GuiClose
GuiControl, Disable, Record
SetHotkey(1), Recording:=1, LogArr:=[], oldtt:=""
return


F2:    ;-- Stop Recording or Playing
Stop:
Suspend, Permit
Gosub, ShowSwitch
if Recording
{
  IfWinNotExist, ahk_id %gui_id%
    Gosub, ShowOrHide
  GuiControl, Enable, Record
  SetHotkey(0), Recording:=0, LogArr:=""
  ToolTip
  return
}
SetTimer, CheckPlay, Off
ToolTip
DetectHiddenWindows, On
WinGet, list, List, %PlayFileName%
Loop, %list%
{
  id:=list%A_Index%
  if (id=A_ScriptHwnd) or !WinExist("ahk_id " id)
    Continue
  WinGet, pid, PID
  WinClose
  WinWaitClose,,, 3
  if ErrorLevel
    Process, Close, %pid%
}
DetectHiddenWindows, Off
return


F3:    ;-- Play back
Play:
PlayNext:
Suspend, Permit
Gosub, ShowSwitch
Gosub, Stop
Gosub, SaveEdit
Gosub, Submit
Gosub, GuiClose
;----------------------------------
ControlGetText, s,, ahk_id %MyEditHwnd%
Label:=A_ThisLabel="PlayNext" ? "<<" A_TickCount ">>":""
s:=StrReplace(AddDebug(AddLabel(s,Label)), Label, Label ":`n")
s:="`nGoto, _User_Start`n_User_Play:`ni:=i`n"
  . s "`nExitApp`n" getfs()
s:=StrReplace(s,"`r"), JumpLabel:=Label
FileDelete, %PlayFile%
FileAppend, %s%, %PlayFile%
;----------------------------------
ToolTip, % "  Playing  ", 5, 5
SetTimer, CheckPlay, 100
return

CheckPlay:
ListLines, Off
DetectHiddenWindows, On
IfWinExist, %PlayFileName%
  return
if (LoopCount!="") and (--LoopCount<0)
{
  SetTimer, CheckPlay, Off
  ToolTip
}
else
{
  Run, %A_AhkPath% /r "%PlayFile%" %JumpLabel%
  WinWait, %PlayFileName%,, 3
}
return

AddLabel(s, Label) {
  global MyEditHwnd
  r1:=r2:="abcd"
  SendMessage, 0xB0, &r1, &r2,, ahk_id %MyEditHwnd%
  i:=NumGet(r1,"uint"), i:=InStr(SubStr(s,1,i),"`n",0,0)
  s:=SubStr(s,1,i) . Label . SubStr(s,i+1)
  return, s
}

AddDebug(s) {
  ListLines, Off
  ok:=[], comment:=fragment:=0, lastv:="", var:="[%\w@#$[:^ascii:]]+"
  Loop, Parse, s, `n, `r
  {
    i:=A_Index, v:=Trim(A_LoopField), ok2:=1
    if (comment=1)
    {
      if !RegExMatch(v,"^\*/(.*)",r)
        Continue
      v:=r1, comment:=0, ok2:=0
    }
    v:=Trim(RegExReplace(v,"(^|\s);.*"))
    IfEqual, v,, Continue
    if (fragment=1)
    {
      if !RegExMatch(v,"^\)(.*)",r)
        Continue
      lastv.=r1, fragment:=0
      Continue
    }
    if (v~="^/\*")
    {
      comment:=1
      Continue
    }
    if (v~="^\([^)]*$")
    or (v~="i)^\(([^)]*\s)?Join\S*\)[^)]*$")
    {
      fragment:=1
      Continue
    }
    if (v~="i)^([~!+\-*/.?:,&|<=>\^]|and\s|or\s)")
      and !(v~="^(\+\+|--)")
    {
      lastv.=" " v
      Continue
    }
    if RegExMatch(v,"^[{}][{}\s]*(.*)",r)
    {
      lastv:=Trim(r1)
      Continue
    }
    if RegExMatch(lastv,"i)^(else|Try|Finally)\b[,\s]*(.*)",r) and Trim(r2)
      lastv:=Trim(r2)
    if (lastv~="i)^if\s+" var "\s*[<>!=]")
    or (lastv~="i)^if\s+" var "\s+(is|not|in|contains|between)\b")
    or (lastv~="i)^if(Equal|NotEqual|Less|LessOrEqual|Greater"
      . "|GreaterOrEqual|InString|NotInString|Exist|NotExist"
      . "|WinExist|WinNotExist|WinActive|WinNotActive|MsgBox)\b")
    or (lastv~="i)^Loop[,\s]+Parse\b")
    or ((lastv~="i)^(if|else|Loop|While|For|Try|Catch|Finally)\b")
      and SubStr(lastv,0)!="{")
    or (v~="i)^(else|Until|Catch|Finally)\b")
      ok2:=0
    ok[i]:=ok2, lastv:=v
  }
  ss:="", ok2:=1
  Loop, Parse, s, `n, `r
  {
    i:=A_Index, v:=A_LoopField
    ;@(0)-->;@(1) Used to ignore the Timer Subroutine
    if InStr(v, ";@(0)")
      ok2:=0
    else if InStr(v, ";@(1)")
      ok2:=1
    if (ok2=1 and ok[i]=1)
      v:="@(" i ")`n" v
    ss.=v "`n"
  }
  s:=SubStr(ss,1,-1)
  ListLines, On
  return, s
}


F4:    ;-- Pause Playing
Pause:
Suspend, Permit
DetectHiddenWindows, On
WinGet, list, List, %PlayFileName%
Loop, %list%
{
  id:=list%A_Index%
  if (id=A_ScriptHwnd) or !WinExist("ahk_id " id)
    Continue
  PostMessage, 0x111, 65306
}
Sleep, 500
return


SetHotkey(f=0)
{
  ; These keys are already used as hotkeys
  global UsedKeys
  ListLines, Off
  f:=f ? "On":"Off"
  Loop, 254
  {
    k:=GetKeyName(vk:=Format("vk{:X}", A_Index))
    if k not in ,Control,Alt,Shift,%UsedKeys%
      Hotkey, ~*%vk%, LogKey, %f% UseErrorLevel
  }
  For i,k in StrSplit("NumpadEnter|Home|End|PgUp"
    . "|PgDn|Left|Right|Up|Down|Delete|Insert", "|")
  {
    sc:=Format("sc{:03X}", GetKeySC(k))
    if k not in ,Control,Alt,Shift,%UsedKeys%
      Hotkey, ~*%sc%, LogKey, %f% UseErrorLevel
  }
  SetTimer, CheckWindow, %f%
  ListLines, On
}

LogKey:
if (open=1)    ;-- When Main GUI is Show
  return
Critical
k:=GetKeyName(vk:=SubStr(A_ThisHotkey,3))
k:=StrReplace(k,"Control","Ctrl"), r:=SubStr(k,2)
if r in Win,Alt,Ctrl,Shift,Button
  if IsLabel(k)
    Goto, %k%
k:=StrLen(k)>1 ? "{" k "}" : k~="\w" ? k : "{" vk "}"
Log(k, 1)
return

LCtrl:  ; Individually press Ctrl to get multiple information
RCtrl:
;----------------------------
MouseGetPos, px, py
cursor:=A_Cursor
;----------------------------
LWin:
RWin:
LAlt:
RAlt:
LShift:
RShift:
Log("{" . (InStr(k,"Win") ? k:r) . " Down}", 1)
;----------------------------
Critical, Off
KeyWait, %A_ThisLabel%
Critical
;----------------------------
k:=A_ThisLabel, r:=SubStr(k,2), LastTime:=""
Log("{" . (InStr(k,"Win") ? k:r) . " Up}", 1)
;----------------------------
r:=LogArr[LogArr.MaxIndex()]
if InStr(k,"Ctrl") and InStr(r,"{Ctrl Down}{Ctrl Up}")
{
  if (r="Send(""{Ctrl Down}{Ctrl Up}"")")
  {
    LogArr.Pop()
    if InStr(LogArr[LogArr.MaxIndex()], "Sleep(")
      LogArr.Pop()
  }
  else
    LogArr[LogArr.MaxIndex()]:=StrReplace(r,"{Ctrl Down}{Ctrl Up}")
  Goto, CtrlMenu
}
return

LButton:
RButton:
MButton:
MouseGetPos, X, Y
s:="", r:=SubStr(k,1,1), %k%_X:=X, %k%_Y:=Y
if (CtrlClick=1)
{
  WinGetPos, winx, winy,,, A
  i:=X-Round(winx), j:=Y-Round(winy)
  s=; ControlClick, x%i% y%j%, `% "%oldtt%",, %r%, 1, NA`n
}
s=%s%;-- `nClick(%X%, %Y%, "%r% D")
Log(relpos(s))
%k%_T:=A_TickCount
;----------------------------
Critical, Off
KeyWait, %A_ThisLabel%
Critical
;----------------------------
k:=A_ThisLabel
if (A_TickCount - %k%_T)>200
{
  MouseGetPos, X, Y
  i:=X-%k%_X, j:=Y-%k%_Y
}
else i:=j:=0
r:=LogArr[LogArr.MaxIndex()]
if InStr(r,"Click(") and InStr(r," D"")") and Abs(i)+Abs(j)<5
  LogArr[LogArr.MaxIndex()]:=SubStr(r,1,-4) . """)"
else
{
  X:=%k%_X+i, Y:=%k%_Y+j, r:=SubStr(k,1,1)
  s=Click(%X%, %Y%, "%r% U")
  Log(relpos(s))
}
return

CheckWindow:
ListLines, Off
if (open=1)    ;-- When Main GUI is Show
  return
Critical
IfWinActive, ahk_class AutoHotkeyGUI
  return
getwininfo()
if (tt=oldtt and winx=oldwinx and winy=oldwiny)
  return
oldtt:=tt, oldwinx:=winx, oldwiny:=winy
if InStr(LogArr[LogArr.MaxIndex()], "OriginWin(")
{
  LogArr.Pop()
  if InStr(LogArr[LogArr.MaxIndex()], "Sleep(")
    LogArr.Pop()
}
s=OriginWin("", %winx%, %winy%, "%tt%", "%tx%", X, Y)
Log(s)
GuiControl,, Origin, %winx%`,%winy%
ToolTip, CoordMode`, Window, 5, 5
return

getwininfo() {
  global AddTitle, AddText, tt, tx, winx, winy
  id:=WinExist("A")
  WinGetPos, winx, winy
  WinGetClass, tc
  WinGetTitle, tt
  WinGetText, tx
  tc:=tc ? " ahk_class " tc : ""
  tt:=AddTitle=1 ? SubStr(Trim(tt),1,20) : ""
  tx:=AddText=1 ? tx : ""
  tt:=Trim(tt . tc), s:=""
  Loop, Parse, tx, `n, `r `t
    if StrLen(v:=A_LoopField)>StrLen(s)
      s:=v
  tx:=WinExist("ahk_id " id, s) ? SubStr(s,1,20) : ""
  tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
  tx:=StrReplace(RegExReplace(tx,"[;``]","``$0"),"""","""""")
  winx:=Round(winx), winy:=Round(winy)
}

Log(str, Keyboard=0)  ; Add to LogArr[]
{
  global LogArr, LastTime
  NowTime:=A_TickCount
  Delay:=LastTime ? NowTime-LastTime : 0
  LastTime:=NowTime
  r:=LogArr[LogArr.MaxIndex()]
  if (Keyboard and InStr(r,"Send(") and Delay<1000)
  {
    LogArr[LogArr.MaxIndex()]:=SubStr(r,1,-2) . str """)"
    return
  }
  if (Keyboard and Delay>0)
    LogArr.Push("Sleep(500)")
  LogArr.Push(Keyboard ? "Send(""" str """)" : str)
}


;===== Hotkeys End =====


;===== Ctrl Menu =====


CtrlMenu:
Thread, Priority, 10
Critical, Off
getwininfo()
color:="", x:=px-2
Loop, 5 {
  PixelGetColor, c, x++, py, RGB
  color.=color="" ? c : "-" c
}
Sort, color, U D-
;-----------------------
  ww:=20, hh:=8
;-----------------------
GuiControlGet, Threshold
pic:=getpic(px, py, ww, hh, Threshold)
RegExMatch(pic,"<([^>]*)>",r), pic:=StrReplace(pic,r,"<>")
picX:=StrSplit(r1,",")[1], picY:=StrSplit(r1,",")[2]
;--------------------------
MouseGetPos, x, y
x-=CtrlMenuW, y-=CtrlMenuH
Gui, CtrlMenu: Show, NA x%x% y%y%
;--------------------
KeyWait, Ctrl, D
KeyWait, Ctrl
MouseGetPos,,, id, class
Gui, CtrlMenu: Hide
if (id!=gui2_id) or !InStr(class,"Button")
  return
;--------------------
GuiControlGet, k, CtrlMenu: , %class%
if InStr(k,"OriginScreen")
{
  GuiControl,, Origin
  ToolTip, CoordMode`, Screen, 5, 5
  return
}
else if InStr(k,"OriginWin")
{
  GuiControl,, Origin, %winx%`,%winy%
  ToolTip, CoordMode`, Window, 5, 5
}
else if InStr(k,"OriginPic")
{
  GuiControl,, Origin, %picX%`,%picY%
  ToolTip, CoordMode`, Picture, 5, 5
}
s:=Cmd[k]
While RegExMatch(s, "%(\w+)%", r)
  s:=StrReplace(s, r, %r1%)
Log(relpos(s))
return


;===== Switch GUI =====


SwitchGUI() {
  Gui, Switch:+LastFound +AlwaysOnTop -Caption +ToolWindow
    +E0x08000000  ; WS_EX_NOACTIVATE = 0x08000000
  Gui, Switch:Color, White
  WinSet, Transparent, 10
  Gui, Switch:Show, NA x0 y0 w1 h%A_ScreenHeight%
  OnMessage(0x200, "WM_MOUSE_MOVE")
  SetTimer, SwitchOnTop, 2000
  return

  SwitchOnTop:
  ListLines, Off
  Gui, Switch:+AlwaysOnTop
  return
}

WM_MOUSE_MOVE() {
  ListLines, Off
  static Time, OkTime
  if (A_Gui="Switch") and (Time:=A_TickCount)>OkTime
  {
    OkTime:=Time+500
    Pause, Off
    SetTimer, ShowOrHide, -10
  }
}

ShowOrHide:
IfWinExist, ahk_id %gui_id%
  Goto, GuiClose
Gosub, GuiShow
if !Recording
  return
if LogArr.MaxIndex()<1
  return
s:=""
For k,v in LogArr
  s.="`n" v "`n"
add_edit(Trim(s,"`n")), LogArr:=[], s:=""
return


;===== Main GUI =====


MainGUI:
WinColor=DDEEFF
Gui, +AlwaysOnTop +Resize +Hwndgui_id
Gui, Color, %WinColor%
Gui, Margin, 10, 10
Gui, Font, s12, Verdana
s=Record,Stop,Play,PlayNext,Debug,Help,Hide,Reload,Exit
For i,v in StrSplit(s, ",")
  Gui, Add, Button, w120 gRunButton, % Trim(v)
;----------------------------------
Gui, Add, CheckBox, wp h30 vAddTitle gSubmit, Win Title
Gui, Add, CheckBox, wp hp vAddText gSubmit, Win Text
Gui, Add, CheckBox, wp hp vCtrlClick gSubmit, CtrlClick
Gui, Add, CheckBox, wp hp vLoopPlay gSubmit, Loop Play
Gui, Add, Edit, xm+18 y+5 w80 vLoopEdit Disabled
Gui, Add, UpDown, vLoopCount gSubmit Range0-100000000
;----------------------------------
Gui, Add, Text, ym Section, Threshold
Gui, Add, Edit, x+3 w65 vThreshold
Gui, Add, Button, xs w75 gCut, Left
Gui, Add, Button, x+0 wp gCut, Right
Gui, Add, Button, xs y+0 wp gCut, Up
Gui, Add, Button, x+0 wp gCut, Down
Gui, Add, Button, xs y+0 w150 gCut, UpdatePic
;----------------------------------
Gui, Add, Text, wp hp Border
Gui, Add, Progress, xp+2 yp+2 wp-4 hp-4 Background%WinColor% vMyColor
;----------------------------------
Gui, Font, s6 bold
Gui, Add, Edit, ym w440 r17 vMyPic -Wrap -VScroll
;----------------------------------
Gui, Font, s12 norm
s:=", SetOrigin, Convert, ViewPos, ViewPic"
  . ", Clear, Delete, Enter, Edit, Save"
For i,v in StrSplit(s, ",", " ")
{
  j:=i=1 ? "xs vOrigin" : v="Clear" ? "xs" : "x+0"
  Gui, Add, Button, %j% w120 gRunButton, % Trim(v)
}
Gui, Add, Edit, xs w600 h350 -Wrap HScroll vMyEdit HwndMyEditHwnd
GuiControlGet, MyEdit, Pos
Gui, Show,, Mouse And Keyboard Macro Recorder
GuiControl, Focus, MyEdit
OnMessage(0x100, "EditEvents")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents")  ; WM_LBUTTONDOWN
OnExit, SaveEditExit
Gosub, ReadEdit
return

GuiSize:
ListLines, Off
if ErrorLevel=1
  return
GuiControl, Move, MyPic
  , % "w" (A_GuiWidth-MyEditX-170)
GuiControl, Move, MyEdit
  , % "w" (A_GuiWidth-MyEditX-10)
  . " h" (A_GuiHeight-MyEditY-10)
return

GuiClose:
WinMinimize, ahk_id %gui_id%
Gui, Hide
open:=0, LastTime:=""
Suspend, Off
if Recording
  SetTimer, CheckWindow, On
return

GuiShow:
open:=1
Suspend, On
if Recording
  SetTimer, CheckWindow, Off
Gui, Show
GuiControl, Focus, MyEdit
return

EditEvents()
{
  ListLines, Off
  if (A_Gui=1) and (A_GuiControl="MyEdit")
    SetTimer, ShowPic, -100
}

ShowPic:
ListLines, Off
Critical
s:=GetLine()
GuiControl,, MyPic, % Trim(ASCII(s),"`n")
CutLeft:=CutRight:=CutUp:=CutDown:=0
;-----------------------------
c:=RegExMatch(s,"0x\w{6}",p) ? p : WinColor
GuiControl, +Background%c%, MyColor
return

ReadEdit:
FileRead, s, %LogFile%
GuiControl,, MyEdit, %s%
s=
return

Save:
SaveEdit:
GuiControlGet, s,, MyEdit
FileDelete, %LogFile%
FileAppend, %s%, %LogFile%
s=
return

SaveEditExit:
Gosub, SaveEdit
ExitApp

Submit:
GuiControlGet, AddTitle
GuiControlGet, AddText
GuiControlGet, CtrlClick
GuiControlGet, LoopPlay
GuiControlGet, LoopCount
GuiControl, % "Enable" LoopPlay, LoopEdit
if LoopPlay=0
  LoopCount:=1
if LoopCount=0
  LoopCount:=""
return

RunButton:
k:=A_GuiControl
GuiControl, Focus, MyEdit
if IsLabel(k)
  Goto, %k%
return

Debug:
DetectHiddenWindows, On
IfWinExist, @( ahk_class AutoHotkeyGUI
{
  WinGetTitle, Line
  Scroll(Line)
}
return

Scroll(Line) {
  global MyEditHwnd
  RegExMatch(Line,"\w+",n)
  ControlGetText, s,, ahk_id %MyEditHwnd%
  i:=InStr(s,"`n",0,1,n-1)
  SendMessage, 0xB1, i, i,, ahk_id %MyEditHwnd%
  SendMessage, 0xB7,,,, ahk_id %MyEditHwnd%
}

Clear:
GuiControlGet, s,, MyEdit
s:=s="" ? olds : (olds:=s)/0
GuiControl,, MyEdit, %s%
s=
return

Delete:
ControlGet, v, Selected,,, ahk_id %MyEditHwnd%
if (v!="")
  k={Del}
else if (GetLine()="")
  k={Left}{Del}
else
  k={Home}{Shift Down}{End}{Shift Up}{Del}
SendEdit(k)
return

Enter:
SendEdit("{Enter}")
return

Edit:
Gui, -AlwaysOnTop
Gosub, SaveEdit
FileGetTime, time1, %LogFile%
RunWait, notepad.exe "%LogFile%"
FileGetTime, time2, %LogFile%
if (time1!=time2)
  Gosub, ReadEdit
Gui, +AlwaysOnTop
return

Help:
SplitPath, A_AhkPath,, dir
Run, %dir%\AutoHotkey.chm
return

Reload:
Reload
return

Exit:
ExitApp

Hide:
if Recording
  Gosub, Stop
Gosub, GuiClose
Gui, Switch:Hide
return

Show:
Gosub, GuiShow
Gosub, ShowSwitch
return

ShowSwitch:
Gui, Switch:Show, NA
return


;===== Win or Pic Origin =====


newre(re,s) {
  if (s~="i)(Origin|Wait)\S*\(")
    re:=StrReplace(re, "\(", "\([^,]*,", "", 1)
  return, re
}

SetOrigin:
s:=GetLine()
re=(\(\s*)(-?\d+)\s*,\s*(-?\d+)
r:=RegExMatch(s, newre(re,s), p) ? p2 "," p3 : ""
GuiControl,, Origin, %r%
return

Origin:
GuiControlGet, s,, Origin
if !InStr(s,",")
  return
Gui, Hide
Click, %s%, 0
Sleep, 1000
Gui, Show
return

Convert:
ControlGet, s, Selected,,, ahk_id %MyEditHwnd%
if (s="")
{
  SendEdit("{End}{Shift Down}{Home}{Shift Up}")
  Sleep, 100
  ControlGet, s, Selected,,, ahk_id %MyEditHwnd%
  if (s="")
    return
}
add_edit(relpos(s,1), 0), s:=""
return

relpos(s,Toggle=0) {
  GuiControlGet, v,, Origin
  if !RegExMatch(v,"(-?\d+),(-?\d+)",r)
    return, s
  ListLines, % "Off" (lls:=A_ListLines=0?"Off":"On")/0
  ss:=""
  re=i)(\(\s*)(X\d*)?([+\-]?\d+)?\s*,\s*(Y\d*)?([+\-]?\d+)?
  Loop, Parse, s, `n, `r
  {
    v:=A_LoopField
    if RegExMatch(v,newre(re,v),p)
      and !(v~="i)(Origin|Win)\S*\(")
    {
      if InStr(p2,"X")
        x:=Toggle ? r1+Round(p3) : p2 . p3
        , y:=Toggle ? r2+Round(p5) : p4 . p5
      else
        x:="X+" Round(p3-r1), y:="Y+" Round(p5-r2)
      v:=StrReplace(v, p, p1 . x ", " y)
    }
    ss.=v "`n"
  }
  s:=SubStr(ss,1,-1)
  ListLines, %lls%
  return, s
}

ViewPos:
s:=GetLine()
re=i)(\(\s*)(X\d*)?([+\-]?\d+)?\s*,\s*(Y\d*)?([+\-]?\d+)?
if !RegExMatch(s, newre(re,s), p)
  return
if InStr(p2,"X")
{
  GuiControlGet, v,, Origin
  if !RegExMatch(v,"(-?\d+),(-?\d+)",r)
  {
    MsgBox, 4096, Tip, Please Set the Origin first !, 3
    return
  }
  p3:=r1+Round(p3), p5:=r2+Round(p5)
}
Gui, Hide
MouseMove, p3, p5
Sleep, 1000
Gui, Show
return

ViewPic:
s:=GetLine()
re=\|<[^$]+\$[\w+/.]+
if !RegExMatch(s,re,r)
  return
WinMinimize, ahk_id %gui_id%
Gui, Hide
Sleep, 100
if ok:=FindText(0,0,150000,150000,0,0,r)
{
  all:=ok.MaxIndex()
  For i,v in ok
  {
    x:=v.1+v.3//2, y:=v.2+v.4//2
    MsgBox, 4096, OK, The %i% / %all% Pos : %x%`, %y%, 3
    MouseMove, x, y
  }
  Sleep, 1000
}
else MsgBox, 4096, Error, Can't Find Pic !
Gui, Show
return


Cut:
k:=A_GuiControl
GuiControlGet, s,, MyPic
s:=Trim(s,"`n") . "`n"
if k=Left
  s:=RegExReplace(s,"m`n)^[^\n]"), CutLeft++
else if k=Right
  s:=RegExReplace(s,"m`n)[^\n]$"), CutRight++
else if k=Up
  s:=RegExReplace(s,"^[^\n]+\n"), CutUp++
else if k=Down
  s:=RegExReplace(s,"[^\n]+\n$"), CutDown++
else if StrLen(s)>1
{
  v:=s, s:=GetLine()
  re=(\|<[^$]+\$)([\w+/.]+)
  if !RegExMatch(s,re,r)
    return
  w:=InStr(v,"`n")-1, h:=StrLen(v)//(w+1)
  x:=(CutLeft+w//2)-(w+CutLeft+CutRight)//2
  y:=(CutUp+h//2)-(h+CutUp+CutDown)//2
  CutLeft:=CutRight:=CutUp:=CutDown:=0
  v:=StrReplace(StrReplace(v,"0","1"),"_","0")
  s:=StrReplace(s,r,r1 . Format("{:d}",w) "." bit2base64(v))
  ;----------------------
  re=i)(\(\s*)(X\d*)?([+\-]?\d+)?\s*,\s*(Y\d*)?([+\-]?\d+)?
  if RegExMatch(s, newre(re,s), p)
  {
    x+=Round(p3), y+=Round(p5)
    if InStr(p2,"X")
      x:=p2 "+" x, y:=p4 "+" y
    s:=StrReplace(s, p, p1 . x ", " y)
  }
  SetLine(s)
  return
}
GuiControl,, MyPic, % Trim(s,"`n")
return


;===== Edit Control Functions =====


add_edit(s, newline=1) {
  global MyEditHwnd
  IfEqual, s,, return
  if (newline=1)
    s:="`n" s "`n", SendEdit("{End}")
  s:=RegExReplace(StrReplace(s,"+-","-"), "\R", "`r`n")
  GuiControl, Focus, MyEdit
  Control, EditPaste, %s%,, ahk_id %MyEditHwnd%
  if (newline!=1)
    SendEdit("{Home}")
}

SendEdit(k) {
  global MyEditHwnd
  GuiControl, Focus, MyEdit
  ControlSend,, %k%, ahk_id %MyEditHwnd%
}

SetLine(s) {
  SendEdit("{End}{Shift Down}{Home}{Shift Up}")
  add_edit(s,0)
}

GetLine() {
  global MyEditHwnd
  ControlGet, i, CurrentLine,,, ahk_id %MyEditHwnd%
  ControlGet, s, Line, %i%,, ahk_id %MyEditHwnd%
  return, s
}


;===== FindText Functions =====


getpic(x, y, w, h, Threshold="") {
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return
  ListLines, % "Off" (lls:=A_ListLines=0?"Off":"On")/0
  SetBatchLines, % "-1" (bch:=A_BatchLines)/0
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  gc:=[], i:=-4
  Loop, % w*h
    gc[A_Index]:=((((c:=NumGet(bits,i+=4,"uint"))>>16)&0xFF)*299
    +((c>>8)&0xFF)*587+(c&0xFF)*114)//1000
  Threshold:=StrReplace(Threshold,"*")
  if (Threshold="")
  {
    pp:=[]
    Loop, 256
      pp[A_Index-1]:=0
    Loop, % w*h
      pp[gc[A_Index]]++
    IP:=IS:=0
    Loop, 256
      k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
    NewThreshold:=Floor(IP/IS)
    Loop, 20 {
      Threshold:=NewThreshold
      IP1:=IS1:=0
      Loop, % Threshold+1
        k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
      IP2:=IP-IP1, IS2:=IS-IS1
      if (IS1!=0 and IS2!=0)
        NewThreshold:=Floor((IP1/IS1+IP2/IS2)/2)
      if (NewThreshold=Threshold)
        Break
    }
  }
  VarSetCapacity(s, w*h*(1+!!A_IsUnicode))
  Loop, % w*h
    s.=gc[A_Index]<=Threshold ? "1":"0"
  ;-------------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  re1=(^0{%w%}|^1{%w%})
  re2=(0{%w%}$|1{%w%}$)
  While RegExMatch(s,re1)
    s:=RegExReplace(s,re1), CutUp++
  While RegExMatch(s,re2)
    s:=RegExReplace(s,re2), CutDown++
  x+=w//2, y+=CutUp+(h-CutUp-CutDown)//2
  ;-------------------------
  pic:="|<" x "," y ">*" Threshold "$" w "." bit2base64(s)
  SetBatchLines, %bch%
  ListLines, %lls%
  return, pic
}


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
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
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
    mode:=InStr(color,"*") ? 1:0
    color:=StrReplace(color,"*") . "@"
    StringSplit, r, color, @
    color:=mode=1 ? r1 : ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4
    n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    VarSetCapacity(allpos, 1024*4, 0), k:=StrLen(v)*4
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    ;--------------------------------------------
    if (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*e1),Round(len0*e0),w1,h1,allpos))
      or (err1=0 and err0=0
      and (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*0.1),Round(len0*0.1),w1,h1,allpos)))
    {
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride, sx, sy, sw, sh
  , ByRef text, ByRef s1, ByRef s0
  , err1, err0, w1, h1, ByRef allpos)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC488B4424782B8424940000008B742470894"
    . "4242083C001894424348B44247C2B842498000000894424188"
    . "3C0018944241C8B4424740FAF44246C8D04B0894424148B842"
    . "49800000085C00F8E9F04000031ED31FF31F6892C248BAC248"
    . "800000031DB897C24048D7426008B84249400000085C07E568"
    . "B8424800000008B8C24800000008B54240401D8039C2494000"
    . "00001D9895C2408EB13669083C0018954B50083C60183C2043"
    . "9C1741C80383175EA8B9C248400000083C0018914BB83C7018"
    . "3C20439C175E48B5C2408830424018B54246C8B04240154240"
    . "439842498000000758789F839F7897C24100F4CC68944240C8"
    . "B44245C85C00F85E90100008B44241C85C00F8EDE0300008B4"
    . "4241403442460034424688B7C2418897424148B742468C7442"
    . "43000000000894424408B442474894424388D4407018B7C247"
    . "0894424448B4424208D4438018B7C24608944242C8B4424680"
    . "1F8894424288B7C243485FF0F8E560100008B442438C1E0108"
    . "944243C8B442470894424188B442440894424248DB42600000"
    . "0008B4424248B6C240C0FB6580289C72B7C242885ED891C240"
    . "FB658010FB600895C2404894424080F84D50200008B8424900"
    . "0000031DB894424208B84248C0000008944241CEB778D76008"
    . "DBC27000000003B5C24147D5A8B8424880000008B149801FA0"
    . "FB64C16020FB64416012B0C242B4424040FB614162B5424088"
    . "9CDC1FD1F31E929E989C5C1FD1F31E829E889D5C1FD1F01C13"
    . "1EA29EA01CA395424647C10836C242001787589F68DBC27000"
    . "0000083C3013B5C240C0F8444020000395C24107E8D8B8C248"
    . "40000008B049901F80FB64C06020FB65406012B0C242B54240"
    . "40FB604062B44240889CDC1FD1F31E929E989D5C1FD1F31EA2"
    . "9EA89C5C1FD1F01D131E829E801C83B4424640F8E3FFFFFFF8"
    . "36C241C010F8934FFFFFF834424180183442424048B4424183"
    . "944242C0F85CCFEFFFF83442438018B7C246C8B442438017C2"
    . "4403B4424440F8583FEFFFF8B44243083C4485B5E5F5DC2440"
    . "08B4424608B5C247C83C00169E8E80300008B4424140344246"
    . "889C78B442478C1E00289042431C085DB7E548974240489FE8"
    . "9C78B4C247885C97E338B042489F18D1C060FB651020FB6410"
    . "169D22B01000069C04B02000001C20FB6016BC07201D039C50"
    . "F9F410383C10439CB75D583C7010374246C397C247C75B88B7"
    . "424048B4424148B54241C83C00385D20F8E6F0100008B7C241"
    . "88944242489F58B4424748B7424108B5C240CC744241800000"
    . "0008944241C8D4407018B7C2470894424288B4424208D44380"
    . "1894424148B44243485C00F8EA80000008B44241CC1E010894"
    . "424108B4424708904248B4424248944240C9085DB0F84D8000"
    . "0008B8424900000008B94248C0000008B4C240C034C2468894"
    . "424088954240431C0EB318DB60000000039E87D1C8B9424880"
    . "000008B3C8201CF803F00740B836C240801782B8D74260083C"
    . "00139D80F848500000039C67ED18B9424840000008B3C8201C"
    . "F803F0174C0836C24040179B9830424018344240C048B04243"
    . "B4424140F8573FFFFFF8344241C018B7C246C8B44241C017C2"
    . "424394424280F8531FFFFFF8B442418E952FEFFFF8B7C24308"
    . "B5424180B54243C8B9C249C00000089F883C0013DFF0300008"
    . "914BB0F8F2CFEFFFF89442430E9ECFDFFFF8B7C24188B14240"
    . "B5424108B8C249C00000089F883C0013DFF0300008914B90F8"
    . "FFEFDFFFF89442418E969FFFFFF31C0E9EEFDFFFFC744240C0"
    . "000000031F6C744241000000000E9ECFBFFFF90909090"
    x64:="4157415641554154555756534883EC488BAC24000100008"
    . "B8424C80000008BBC24080100008BB424B80000004D89CC898"
    . "C24900000008994249800000029E844898424A00000004C8BA"
    . "C24E00000008944240883C001488B9C24E8000000894424148"
    . "B8424D000000029F88944240C83C001894424048B8424C0000"
    . "0000FAF8424B000000085FF8D04B08904240F8E320500004C8"
    . "9A424A80000004C8BA424D80000008D34AD000000004531C94"
    . "531D24531F64531FF4531DB0F1F800000000085ED7E454963D"
    . "3468D040E4489C84C01E2EB164963CE4883C2014183C601890"
    . "48B83C0044139C0741D803A3175E54963CF4883C2014183C70"
    . "14189448D0083C0044139C075E34101EB4183C20144038C24B"
    . "00000004439D775A64C8BA424A80000004539F74489F5410F4"
    . "DEF448B9424900000004585D20F8547020000448B4C2404458"
    . "5C90F8E73040000486304244863BC24B00000008BB424B8000"
    . "000C7442410000000004C89AC24E000000048899C24E800000"
    . "08944243848897C243048894424208B7C240C8B8424C000000"
    . "0894424188D4407018944243C4863842498000000488944242"
    . "88B4424088D4430018944240C448B4424144585C00F8E85010"
    . "0008B442418448B5C2438C1E0108944241C488B44242048034"
    . "424284D8D2C048B8424B8000000890424660F1F44000085ED4"
    . "10FB65D02410FB67501410FB67D000F84490300008B8424F80"
    . "000004531C0894424088B8424F000000089442404E98800000"
    . "04539CE7E76488B8C24E8000000428B04814401D88D5002486"
    . "3D2410FB60C148D50014898410FB604044863D2410FB614142"
    . "9D94189C929F841C1F91F29F24431C94429C94189D141C1F91"
    . "F4431CA4429CA4189C141C1F91F01D14431C84429C801C8398"
    . "424A00000007C10836C2408010F88930000000F1F440000498"
    . "3C0014439C50F8EA30200004539C74589C10F8E6CFFFFFF488"
    . "B8C24E0000000428B04814401D88D50024863D2410FB60C148"
    . "D50014898410FB604044863D2410FB6141429D94189CA29F84"
    . "1C1FA1F29F24431D14429D14189D241C1FA1F4431D24429D24"
    . "189C241C1FA1F01D14431D04429D001C83B8424A00000000F8"
    . "E02FFFFFF836C2404010F89F7FEFFFF830424014983C504418"
    . "3C3048B04243944240C0F85A9FEFFFF83442418018BBC24B00"
    . "000008B442418017C2438488B7C243048017C24203B44243C0"
    . "F8545FEFFFF8B4424104883C4485B5E5F5D415C415D415E415"
    . "FC38B8424980000008B8C24D0000000448D48014569C9E8030"
    . "00085C90F8E9F00000048638424B00000004C6314244531DB4"
    . "4897C24104489742418448BBC24D0000000448BB424C800000"
    . "04889C78B8424C80000004D01E283E801488D3485040000006"
    . "62E0F1F8400000000004585F67E394E8D04164C89D10F1F400"
    . "00FB651020FB6410169D22B01000069C04B02000001C20FB60"
    . "16BC07201D04139C10F9F41034883C1044939C875D24183C30"
    . "14901FA4539DF75B6448B7C2410448B7424188B04248B54240"
    . "483C00385D20F8E680100008B7C240C894424108B8424C0000"
    . "0008BB424B8000000894424048D44070131FF893C248BBC24F"
    . "80000008944240C8B442408448D5C30018B44241485C00F8E8"
    . "E0000008B4424048BB424B8000000448B442410C1E01089442"
    . "40885ED0F84C80000004189FA448B8C24F000000031C0EB356"
    . "60F1F8400000000004439F17D1B8B14834401C24863D241803"
    . "C1400740B4183EA0178300F1F4400004883C00139C50F8E840"
    . "000004439F889C17DCD418B5485004401C24863D241803C140"
    . "174BB4183E90179B583C6014183C0044439DE7589834424040"
    . "18BB424B00000008B442404017424103B44240C0F8548FFFFF"
    . "F8B3C2489F8E924FEFFFF9048635424108B0C240B4C241C488"
    . "BBC241001000089D083C001890C973DFF0300000F8FFCFDFFF"
    . "F89442410E9AEFDFFFF486314248B4C24084C8B94241001000"
    . "009F189D041890C9283C0013DFF0300000F8FCDFDFFFF83C60"
    . "14183C0048904244439DE0F85F7FEFFFFE969FFFFFF31C0E9A"
    . "EFDFFFF31ED4531F64531FFE95AFBFFFF9090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "AStr",text, "ptr",&s1, "ptr",&s0
    , "int",err1, "int",err0, "int",w1, "int",h1, "ptr",&allpos)
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
    NumPut("0x" . SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
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
  if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
  {
    s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return, s
}


;===== Add To PlayFile =====


getfs() {
  fs=
(` %

;===== My Functions Begin =====

_User_Start:
#NoEnv
#Persistent
#SingleInstance force
Menu, Tray, Click, 1
Menu, Tray, Icon, Shell32.dll, 15
SetTitleMatchMode, 2
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
TempFile:=A_Temp "\~SaveVars.tmp"
Gosub, LoadVars
OnExit, SaveVars
if 0>0
  k:=%True%
else
  k:="_User_Play"
if IsLabel(k)
  SetTimer, %k%, -10
Exit

LoadVars:
IniRead, X,  %TempFile%, SaveVars, X,  0
IniRead, Y,  %TempFile%, SaveVars, Y,  0
IniRead, X1, %TempFile%, SaveVars, X1, 0
IniRead, Y1, %TempFile%, SaveVars, Y1, 0
return

SaveVars:
IniWrite, %X%,  %TempFile%, SaveVars, X
IniWrite, %Y%,  %TempFile%, SaveVars, Y
IniWrite, %X1%, %TempFile%, SaveVars, X1
IniWrite, %Y1%, %TempFile%, SaveVars, Y1
ExitApp

@(Line) {  ; For Debug
  ListLines, Off
  Gui, Debug:Show, Hide, @(%Line%)
  ListLines, On
}

;-----------------------------

;@OriginScreen=

;@OriginWin("", %winx%, %winy%, "%tt%", "%tx%", X, Y)

;@OriginPic("", %picX%, %picY%, 150000, 150000, "%pic%", X, Y)

;@WaitWin("3", %winx%, %winy%, "%tt%", "%tx%", X1, Y1)

;@WaitPic("3", %picX%, %picY%, 150, 150, "%pic%", X1, Y1)

;@WaitColor("3", %px%, %py%, 20, 1, "%color%")

;@Sleep(1000)

;@MouseMove(%px%, %py%)

;@ClickPic=WaitPic("", %picX%, %picY%, 150, 150, "%pic%", X1, Y1)`nClick("" X1, Y1)

;@WaitCursor("3", %px%, %py%, "%cursor%")

;@WaitCaret("1", %px%, %py%, 20, 1)

;@WaitChange()`n`nWaitChange("3", %px%, %py%, 20, 1)

;-----------------------------

MouseMove(x, y) {
  Click(x, y, 0)
}

Click(x, y, other="")
{
  bak:=A_CoordModeMouse
  CoordMode, Mouse, Screen
  Click, %x%, %y%, %other%
  Sleep, InStr(other,"R") ? 500 : 100
  CoordMode, Mouse, %bak%
}

Send(key="")
{
  IfEqual, key,, return
  SendInput, {Blind}%key%
  Sleep, 200
}

Sleep(ms=0)
{
  Sleep, ms
}

OriginWin(timeout, winx, winy, title, text="", ByRef rx="", ByRef ry="")
{
  lastx:=lasty:=""
  Loop {
    WaitWin("", winx, winy, title, text, rx, ry)
    if (rx=lastx) and (ry=lasty)
      return, 1
    lastx:=rx, lasty:=ry
    Sleep, 200
  }
}

WaitWin(timeout, winx, winy, title, text="", ByRef rx="", ByRef ry="")
{
  endt:=A_TickCount+Round(Abs(timeout)*1000)
  Loop {
    IfWinExist, %title%, %text%
    {
      IfWinNotActive, %title%, %text%
      {
        WinActivate
        WinWaitActive,,, 3
        Sleep, 500
      }
      WinGetPos, rx, ry
      return, 1
    }
    if (timeout!="" and A_TickCount>=endt)
      Break
    Sleep, 100
  }
  return, 0
}

OriginPic(timeout, x, y, w, h, pic, ByRef rx="", ByRef ry="")
{
  lastx:=lasty:=""
  Loop {
    if !WaitPic(0, x, y, 150, 150, pic, rx, ry)
      WaitPic("", x, y, w, h, pic, rx, ry)
    if (rx=lastx) and (ry=lasty)
      return, 1
    lastx:=rx, lasty:=ry
    Sleep, 200
  }
}

WaitPic(timeout, x, y, w, h, pic, ByRef rx="", ByRef ry="")
{
  endt:=A_TickCount+Round(Abs(timeout)*1000)
  Loop {
    if ok:=FindText(x, y, w, h, 0, 0, pic)
    {
      For i,v in ok
      {
        tx:=v.1+v.3//2, ty:=v.2+v.4//2
        k:=(tx-x)**2+(ty-y)**2
        if (A_Index=1 or k<min)
          min:=k, rx:=tx, ry:=ty
      }
      return, 1
    }
    if (timeout!="" and A_TickCount>=endt)
      Break
    Sleep, 200
  }
  return, 0
}

WaitColor(timeout, x, y, w, h, color)
{
  bak:=A_CoordModePixel
  CoordMode, Pixel, Screen
  endt:=A_TickCount+Round(Abs(timeout)*1000)
  Loop {
    Loop, Parse, color, -
    {
      PixelSearch,,, x-w, y-h, x+w, y+h
        , A_LoopField, 16, Fast RGB
      if (!ErrorLevel)
      {
        CoordMode, Pixel, %bak%
        return, 1
      }
    }
    if (timeout!="" and A_TickCount>=endt)
      Break
    Sleep, 100
  }
  CoordMode, Pixel, %bak%
  return, 0
}

WaitCursor(timeout, x, y, cursor)
{
  bak:=A_CoordModeMouse
  CoordMode, Mouse, Screen
  endt:=A_TickCount+Round(Abs(timeout)*1000)
  Loop {
    MouseMove, x+5, y+5
    Sleep, 100
    MouseMove, x, y
    Sleep, 100
    if (A_Cursor=cursor)
    {
      CoordMode, Mouse, %bak%
      return, 1
    }
    if (timeout!="" and A_TickCount>=endt)
      Break
  }
  CoordMode, Mouse, %bak%
  return, 0
}

WaitCaret(arg*)
{
  WaitChange()
  Sleep, 100
  return, WaitChange(arg*)
}

WaitChange(timeout="ScreenShot", x=0, y=0, w=0, h=0)
{
  static ScreenShot, nX, nY, nW, nH
  if (timeout="ScreenShot")
  {
    n:=150000, xywh2xywh(-n,-n,2*n+1,2*n+1,nX,nY,nW,nH)
    GetBitsFromScreen(nX,nY,nW,nH,Scan0,Stride,ScreenShot)
    return
  }
  if !VarSetCapacity(ScreenShot)
    WaitChange()
  hash:=GetPicHash(x,y,w,h,ScreenShot,nX,nY,nW,nH)
  endt:=A_TickCount+Round(Abs(timeout)*1000)
  Loop {
    if GetPicHash(x,y,w,h)!=hash
      return, 1
    if (timeout!="" and A_TickCount>=endt)
      Break
    Sleep, 100
  }
  return, 0
}

GetPicHash(x,y,w,h,ByRef bits="",nX="",nY="",nW="",nH="")
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  if (nX!="") and (x<nX or y<nY or x+w>nX+nW or y+h>nY+nH)
    return, 0
  ListLines, % "Off" (lls:=A_ListLines=0?"Off":"On")/0
  SetBatchLines, % "-1" (bch:=A_BatchLines)/0
  if !IsByRef(bits)
  {
    GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
    nX:=x, nY:=y, nW:=w
  }
  hash:=0, i:=((y-nY)*nW+(x-nX))*4-4, j:=(nW-w)*4
  Loop, %h% {
    Loop, %w%
      hash:=(hash*31+NumGet(bits,i+=4,"uint"))&0xFFFFFFFF
    i+=j
  }
  SetBatchLines, %bch%
  ListLines, %lls%
  return, hash
}


;===== My Functions End =====

)
fs=%fs%
(` %

;===== FindText Functions =====


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
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
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
    mode:=InStr(color,"*") ? 1:0
    color:=StrReplace(color,"*") . "@"
    StringSplit, r, color, @
    color:=mode=1 ? r1 : ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4
    n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    VarSetCapacity(allpos, 1024*4, 0), k:=StrLen(v)*4
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    ;--------------------------------------------
    if (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*e1),Round(len0*e0),w1,h1,allpos))
      or (err1=0 and err0=0
      and (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*0.1),Round(len0*0.1),w1,h1,allpos)))
    {
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride, sx, sy, sw, sh
  , ByRef text, ByRef s1, ByRef s0
  , err1, err0, w1, h1, ByRef allpos)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC488B4424782B8424940000008B742470894"
    . "4242083C001894424348B44247C2B842498000000894424188"
    . "3C0018944241C8B4424740FAF44246C8D04B0894424148B842"
    . "49800000085C00F8E9F04000031ED31FF31F6892C248BAC248"
    . "800000031DB897C24048D7426008B84249400000085C07E568"
    . "B8424800000008B8C24800000008B54240401D8039C2494000"
    . "00001D9895C2408EB13669083C0018954B50083C60183C2043"
    . "9C1741C80383175EA8B9C248400000083C0018914BB83C7018"
    . "3C20439C175E48B5C2408830424018B54246C8B04240154240"
    . "439842498000000758789F839F7897C24100F4CC68944240C8"
    . "B44245C85C00F85E90100008B44241C85C00F8EDE0300008B4"
    . "4241403442460034424688B7C2418897424148B742468C7442"
    . "43000000000894424408B442474894424388D4407018B7C247"
    . "0894424448B4424208D4438018B7C24608944242C8B4424680"
    . "1F8894424288B7C243485FF0F8E560100008B442438C1E0108"
    . "944243C8B442470894424188B442440894424248DB42600000"
    . "0008B4424248B6C240C0FB6580289C72B7C242885ED891C240"
    . "FB658010FB600895C2404894424080F84D50200008B8424900"
    . "0000031DB894424208B84248C0000008944241CEB778D76008"
    . "DBC27000000003B5C24147D5A8B8424880000008B149801FA0"
    . "FB64C16020FB64416012B0C242B4424040FB614162B5424088"
    . "9CDC1FD1F31E929E989C5C1FD1F31E829E889D5C1FD1F01C13"
    . "1EA29EA01CA395424647C10836C242001787589F68DBC27000"
    . "0000083C3013B5C240C0F8444020000395C24107E8D8B8C248"
    . "40000008B049901F80FB64C06020FB65406012B0C242B54240"
    . "40FB604062B44240889CDC1FD1F31E929E989D5C1FD1F31EA2"
    . "9EA89C5C1FD1F01D131E829E801C83B4424640F8E3FFFFFFF8"
    . "36C241C010F8934FFFFFF834424180183442424048B4424183"
    . "944242C0F85CCFEFFFF83442438018B7C246C8B442438017C2"
    . "4403B4424440F8583FEFFFF8B44243083C4485B5E5F5DC2440"
    . "08B4424608B5C247C83C00169E8E80300008B4424140344246"
    . "889C78B442478C1E00289042431C085DB7E548974240489FE8"
    . "9C78B4C247885C97E338B042489F18D1C060FB651020FB6410"
    . "169D22B01000069C04B02000001C20FB6016BC07201D039C50"
    . "F9F410383C10439CB75D583C7010374246C397C247C75B88B7"
    . "424048B4424148B54241C83C00385D20F8E6F0100008B7C241"
    . "88944242489F58B4424748B7424108B5C240CC744241800000"
    . "0008944241C8D4407018B7C2470894424288B4424208D44380"
    . "1894424148B44243485C00F8EA80000008B44241CC1E010894"
    . "424108B4424708904248B4424248944240C9085DB0F84D8000"
    . "0008B8424900000008B94248C0000008B4C240C034C2468894"
    . "424088954240431C0EB318DB60000000039E87D1C8B9424880"
    . "000008B3C8201CF803F00740B836C240801782B8D74260083C"
    . "00139D80F848500000039C67ED18B9424840000008B3C8201C"
    . "F803F0174C0836C24040179B9830424018344240C048B04243"
    . "B4424140F8573FFFFFF8344241C018B7C246C8B44241C017C2"
    . "424394424280F8531FFFFFF8B442418E952FEFFFF8B7C24308"
    . "B5424180B54243C8B9C249C00000089F883C0013DFF0300008"
    . "914BB0F8F2CFEFFFF89442430E9ECFDFFFF8B7C24188B14240"
    . "B5424108B8C249C00000089F883C0013DFF0300008914B90F8"
    . "FFEFDFFFF89442418E969FFFFFF31C0E9EEFDFFFFC744240C0"
    . "000000031F6C744241000000000E9ECFBFFFF90909090"
    x64:="4157415641554154555756534883EC488BAC24000100008"
    . "B8424C80000008BBC24080100008BB424B80000004D89CC898"
    . "C24900000008994249800000029E844898424A00000004C8BA"
    . "C24E00000008944240883C001488B9C24E8000000894424148"
    . "B8424D000000029F88944240C83C001894424048B8424C0000"
    . "0000FAF8424B000000085FF8D04B08904240F8E320500004C8"
    . "9A424A80000004C8BA424D80000008D34AD000000004531C94"
    . "531D24531F64531FF4531DB0F1F800000000085ED7E454963D"
    . "3468D040E4489C84C01E2EB164963CE4883C2014183C601890"
    . "48B83C0044139C0741D803A3175E54963CF4883C2014183C70"
    . "14189448D0083C0044139C075E34101EB4183C20144038C24B"
    . "00000004439D775A64C8BA424A80000004539F74489F5410F4"
    . "DEF448B9424900000004585D20F8547020000448B4C2404458"
    . "5C90F8E73040000486304244863BC24B00000008BB424B8000"
    . "000C7442410000000004C89AC24E000000048899C24E800000"
    . "08944243848897C243048894424208B7C240C8B8424C000000"
    . "0894424188D4407018944243C4863842498000000488944242"
    . "88B4424088D4430018944240C448B4424144585C00F8E85010"
    . "0008B442418448B5C2438C1E0108944241C488B44242048034"
    . "424284D8D2C048B8424B8000000890424660F1F44000085ED4"
    . "10FB65D02410FB67501410FB67D000F84490300008B8424F80"
    . "000004531C0894424088B8424F000000089442404E98800000"
    . "04539CE7E76488B8C24E8000000428B04814401D88D5002486"
    . "3D2410FB60C148D50014898410FB604044863D2410FB614142"
    . "9D94189C929F841C1F91F29F24431C94429C94189D141C1F91"
    . "F4431CA4429CA4189C141C1F91F01D14431C84429C801C8398"
    . "424A00000007C10836C2408010F88930000000F1F440000498"
    . "3C0014439C50F8EA30200004539C74589C10F8E6CFFFFFF488"
    . "B8C24E0000000428B04814401D88D50024863D2410FB60C148"
    . "D50014898410FB604044863D2410FB6141429D94189CA29F84"
    . "1C1FA1F29F24431D14429D14189D241C1FA1F4431D24429D24"
    . "189C241C1FA1F01D14431D04429D001C83B8424A00000000F8"
    . "E02FFFFFF836C2404010F89F7FEFFFF830424014983C504418"
    . "3C3048B04243944240C0F85A9FEFFFF83442418018BBC24B00"
    . "000008B442418017C2438488B7C243048017C24203B44243C0"
    . "F8545FEFFFF8B4424104883C4485B5E5F5D415C415D415E415"
    . "FC38B8424980000008B8C24D0000000448D48014569C9E8030"
    . "00085C90F8E9F00000048638424B00000004C6314244531DB4"
    . "4897C24104489742418448BBC24D0000000448BB424C800000"
    . "04889C78B8424C80000004D01E283E801488D3485040000006"
    . "62E0F1F8400000000004585F67E394E8D04164C89D10F1F400"
    . "00FB651020FB6410169D22B01000069C04B02000001C20FB60"
    . "16BC07201D04139C10F9F41034883C1044939C875D24183C30"
    . "14901FA4539DF75B6448B7C2410448B7424188B04248B54240"
    . "483C00385D20F8E680100008B7C240C894424108B8424C0000"
    . "0008BB424B8000000894424048D44070131FF893C248BBC24F"
    . "80000008944240C8B442408448D5C30018B44241485C00F8E8"
    . "E0000008B4424048BB424B8000000448B442410C1E01089442"
    . "40885ED0F84C80000004189FA448B8C24F000000031C0EB356"
    . "60F1F8400000000004439F17D1B8B14834401C24863D241803"
    . "C1400740B4183EA0178300F1F4400004883C00139C50F8E840"
    . "000004439F889C17DCD418B5485004401C24863D241803C140"
    . "174BB4183E90179B583C6014183C0044439DE7589834424040"
    . "18BB424B00000008B442404017424103B44240C0F8548FFFFF"
    . "F8B3C2489F8E924FEFFFF9048635424108B0C240B4C241C488"
    . "BBC241001000089D083C001890C973DFF0300000F8FFCFDFFF"
    . "F89442410E9AEFDFFFF486314248B4C24084C8B94241001000"
    . "009F189D041890C9283C0013DFF0300000F8FCDFDFFFF83C60"
    . "14183C0048904244439DE0F85F7FEFFFFE969FFFFFF31C0E9A"
    . "EFDFFFF31ED4531F64531FFE95AFBFFFF9090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "AStr",text, "ptr",&s1, "ptr",&s0
    , "int",err1, "int",err0, "int",w1, "int",h1, "ptr",&allpos)
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
    NumPut("0x" . SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code
    , Ptr,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
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

;===== FindText End =====


)
  return, "`n" fs "`n"
}

;============ The End =============

;