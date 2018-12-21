;/*
;===========================================
;  FindText - Capture screen image into text and then find it
;  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  Author  :  FeiYue
;  Version :  6.3
;  Date    :  2018-12-18
;
;  Usage:
;  1. Capture the image to text string.
;  2. Test find the text string on full Screen.
;  3. When test is successful, you may copy the code
;     and paste it into your own script.
;     Note: Copy the "FindText()" function and the following
;     functions and paste it into your own script Just once.
;
;  Note:
;     After upgrading to v6.0, the search scope using WinAPI's
;     upper left corner X, Y coordinates, and width, height.
;     This will be better understood and used.
;
;===========================================
;  Introduction of function parameters:
;
;  returnArray := FindText(
;      X --> the search scope's upper left corner X coordinates
;    , Y --> the search scope's upper left corner Y coordinates
;    , W --> the search scope's Width
;    , H --> the search scope's Height
;    , Character -->  "0" fault-tolerant in percentage --> 0.1=10%
;    , Character -->  "_" fault-tolerant in percentage --> 0.1=10%
;    , text --> The Base64 encoding string for the text to find
;    , ScreenShot --> if the value is 0, the last screenshot will be used
;  )
;
;  The range used by AHK is determined by the upper left
;  corner and the lower right corner: (x1, y1, x2, y2),
;  it can be converted to: (x1, y1, x2-x1+1, y2-y1+1).
;
;  The fault-tolerant parameters allow the loss of specific characters.
;
;  Text parameters can be a lot of text to find, separated by "|".
;
;  ScreenShot if the value is 0, the last screenshot will be used.
;
;  return is a array, contains the [X,Y,W,H,Comment] results of Each Find,
;  if no image is found, the function returns 0.
;
;===========================================
;*/


#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, Shell32.dll, 23
Menu, Tray, Add
Menu, Tray, Add, Main_Window
Menu, Tray, Default, Main_Window
Menu, Tray, Click, 1
; The capture range can be changed by adjusting the numbers
;----------------------------
  ww:=35, hh:=12
;----------------------------
nW:=2*ww+1, nH:=2*hh+1
Gosub, MakeCaptureWindow
Gosub, MakeMainWindow
Gosub, Load_ToolTip_Text
OnExit, savescr
Gosub, readscr
return

Load_ToolTip_Text:
ToolTip_Text=
(LTrim
Capture   = Initiate Image Capture Sequence
Test      = Test Results of Code
Copy      = Copy Code to Clipboard
AddFunc   = Additional FindText() in Copy
U         = Cut the Upper Edge by 1
U3        = Cut the Upper Edge by 3
L         = Cut the Left Edge by 1
L3        = Cut the Left Edge by 3
R         = Cut the Right Edge by 1
R3        = Cut the Right Edge by 3
D         = Cut the Lower Edge by 1
D3        = Cut the Lower Edge by 3
Auto      = Automatic Cutting Edge`r`nOnly after Color2Two or Gray2Two
Similar   = Adjust color similarity as Equivalent to The Selected Color
SelCol    = Selected Image Color which Determines Black or Pixel White Conversion (Hex of Color)
Gray      = Grayscale Threshold which Determines Black or White Pixel Conversion (0-255)
Color2Two = Converts Image Pixels from Color to Black or White
Gray2Two  = Converts Image Pixels from Grays to Black or White
UsePos    = Use position instead of color value to suit any color
Modify    = Allows for Pixel Cleanup of Black and White Image`r`nOnly After Gray2Two or Color2Two
Reset     = Reset to Original Captured Image
Comment   = Optional Comment used to Label Code ( Within <> )
SplitAdd  = Using Markup Segmentation to Generate Text Library
AllAdd    = Append Another FindText Search Text into Previously Generated Code
OK        = Create New FindText Code for Testing
Close     = Close the Window Don't Do Anything
)
return

readscr:
f=%A_Temp%\~scr.tmp
FileRead, s, %f%
GuiControl, Main:, scr, %s%
s=
return

savescr:
f=%A_Temp%\~scr.tmp
GuiControlGet, s, Main:, scr
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

Main_Window:
Gui, Main:Show, Center
return

MakeMainWindow:
Gui, Main:Default
Gui, +AlwaysOnTop
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s6 bold, Verdana
Gui, Add, Edit, xm w660 r25 vMyEdit -Wrap -VScroll
Gui, Font, s12 norm, Verdana
Gui, Add, Button, w220 gMainRun, Capture
Gui, Add, Button, x+0 wp gMainRun, Test
Gui, Add, Button, x+0 wp gMainRun Section, Copy
Gui, Font, s10
Gui, Add, Text, xm, Click Text String to See ASCII Search Text in the Above
Gui, Add, Checkbox, xs yp w220 r1 -Wrap Checked vAddFunc, Additional FindText() in Copy
Gui, Font, s12 cBlue, Verdana
Gui, Add, Edit, xm w660 h350 vscr Hwndhscr -Wrap HScroll
Gui, Show,, Capture Image To Text And Find Text Tool
;---------------------------------------
OnMessage(0x100, "EditEvents1")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents2")  ; WM_LBUTTONDOWN
OnMessage(0x200, "WM_MOUSEMOVE") ; Show ToolTip
return

EditEvents1()
{
  ListLines, Off
  if (A_Gui="Main") and (A_GuiControl="scr")
    SetTimer, ShowText, -100
}

EditEvents2()
{
  ListLines, Off
  if (A_Gui="Capture")
    WM_LBUTTONDOWN()
  else
    EditEvents1()
}

ShowText:
ListLines, Off
Critical
ControlGet, i, CurrentLine,,, ahk_id %hscr%
ControlGet, s, Line, %i%,, ahk_id %hscr%
s := ASCII(s)
GuiControl, Main:, MyEdit, % Trim(s,"`n")
return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
Gui, +LastFound
WinWaitClose, % "ahk_id " WinExist()
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, scr
return

Copy:
GuiControlGet, s,, scr
GuiControlGet, AddFunc
if AddFunc != 1
  s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
Clipboard:=StrReplace(s,"`n","`r`n")
s=
return

Capture:
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x08000000
Gui, Color, Red
d:=2, w:=nW+2*d, h:=nH+2*d, i:=w-d, j:=h-d
Gui, Show, Hide w%w% h%h%
WinSet, Region
  , 0-0 %w%-0 %w%-%h% 0-%h% 0-0  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
;------------------------------
Hotkey, $*RButton, _RButton_Off, On
ListLines, Off
oldx:=oldy:=""
Loop {
  MouseGetPos, x, y
  if (oldx=x and oldy=y)
    Continue
  oldx:=x, oldy:=y
  ;---------------
  Gui, Show, % "NA x" (x-w//2) " y" (y-h//2)
  ToolTip, % "The Capture Position : " x "," y
    . "`nFirst click RButton to start capturing"
    . "`nSecond click RButton to end capture"
  Sleep, 50
} Until GetKeyState("RButton","P")
KeyWait, RButton
px:=x, py:=y, oldx:=oldy:=""
Loop {
  MouseGetPos, x, y
  if (oldx=x and oldy=y)
    Continue
  oldx:=x, oldy:=y
  ;---------------
  ToolTip, % "The Capture Position : " px "," py
    . "`nFirst click RButton to start capturing"
    . "`nSecond click RButton to end capture"
  Sleep, 50
} Until GetKeyState("RButton","P")
KeyWait, RButton
ToolTip
ListLines, On
Gui, Destroy
WinWaitClose
cors:=getc(px,py,ww,hh)
Hotkey, $*RButton, _RButton_Off, Off
Goto, ShowCaptureWindow
_RButton_Off:
return

ShowCaptureWindow:
cors.Event:="", cors.Result:=""
;--------------------------------
Gui, Capture:Default
k:=nW*nH+1
Loop, % nW
  GuiControl,, % C_[k++], 0
GuiControl,, SelCol
GuiControl,, Gray
GuiControl,, Modify, % Modify:=0
GuiControl,, UsePos, % UsePos:=0
GuiControl, Focus, Gray
Gosub, Reset
Gui, Show, Center
DetectHiddenWindows, Off
Gui, +LastFound
WinWaitClose, % "ahk_id " WinExist()
;--------------------------------
if InStr(cors.Event,"OK")
{
  if !A_IsCompiled
  {
    FileRead, fs, %A_ScriptFullPath%
    fs:=SubStr(fs,fs~="i)\n[;=]+ Copy The")
  }
  GuiControl, Main:, scr, % cors.Result "`n" fs
  cors.Result:=fs:=""
  return
}
if InStr(cors.Event,"Add")
  add(cors.Result, 0), cors.Result:=""
return

WM_LBUTTONDOWN()
{
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  IfNotInString, mclass, progress
    return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (k>nW*nH)
      {
        GuiControlGet, i, Capture:, %v%
        GuiControl, Capture:, %v%, % i ? 0:100
      }
      else if (Modify and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : WindowColor
        Gosub, SetColor
      }
      else
      {
        GuiControl, Capture:, SelCol, % cors[k]
        cors.Color:=cors[k]
      }
      return
    }
}

getc(px, py, ww, hh)
{
  xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,1)
  ;--------------------------------------
  cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh+A_Index-1
    Loop, %nW% {
      i:=px-ww+A_Index-1, k++
      if (i>=x and i<=x+w-1 and j>=y and j<=y+h-1)
        c:=NumGet(Scan0+0,(j-y)*Stride+(i-x)*4,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  cors.LeftCut:=Abs(px-ww-x)
  cors.RightCut:=Abs(px+ww-(x+w-1))
  cors.UpCut:=Abs(py-hh-y)
  cors.DownCut:=Abs(py+hh-(y+h-1))
  SetBatchLines, %bch%
  return, cors
}

Test:
GuiControlGet, s, Main:, scr
s:="`n#NoEnv`nMenu, Tray, Click, 1`n"
  . "Gui, _ok_:Show, Hide, _ok_`n"
  . s "`nExitApp`n#SingleInstance off`n"
if (!A_IsCompiled) and InStr(s,"MCode(")
{
  Exec(s)
  DetectHiddenWindows, On
  WinWait, _ok_ ahk_class AutoHotkeyGUI,, 3
  WinWaitClose, _ok_ ahk_class AutoHotkeyGUI,, 3
}
else
{
  t1:=A_TickCount
  RegExMatch(s,"=""\K[^$\n]+\$\d+\.[\w+/]+",Text)
  ok:=FindText(0, 0, 150000, 150000, 0, 0, Text)
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  MsgBox, 4096,, % "Time:`t" (A_TickCount-t1) " ms`n`n"
    . "Pos:`t" X ", " Y "`n`n"
    . "Result:`t" (ok ? "Success !":"Failed !"), 3
  MouseMove, X, Y
  (ok) && MouseTip()
}
return

Exec(s)
{
  Ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
  s:=RegExReplace(s, "\R", "`r`n")
  Try {
    oExec:=ComObjCreate("WScript.Shell").Exec(Ahk " /r *")
    oExec.StdIn.Write(s)
    oExec.StdIn.Close()
  }
  catch {
    f:=A_Temp "\~test1.tmp"
    s=`r`nFileDelete, %f%`r`n%s%
    FileDelete, %f%
    FileAppend, %s%, %f%
    Run, %Ahk% /r "%f%"
  }
}

MakeCaptureWindow:
WindowColor:="0xCCDDEE"
Gui, Capture:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow
Gui, Margin, 15, 15
Gui, Color, %WindowColor%
Gui, Font, s14, Verdana
ListLines, Off
Gui, -Theme
w:=800//nW, h:=(A_ScreenHeight-300)//nH, w:=h<w ? h-1:w-1
Loop, % nW*(nH+1) {
  i:=A_Index, j:=i=1 ? "" : Mod(i,nW)=1 ? "xm y+1" : "x+1"
  j.=i>nW*nH ? " cRed BackgroundFFFFAA":""
  Gui, Add, Progress, w%w% h%w% %j%
}
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
Loop, % nW*(nH+1)
  Control, ExStyle, -0x20000,, % "ahk_id " C_[A_Index]
Gui, +Theme
ListLines, On
Gui, Add, Button, xm+95  w45 gUpCut Section, U
Gui, Add, Button, x+0    wp gUpCut3, U3
Gui, Add, Text,   xm+310 yp+6 Section, Color Similarity  0
Gui, Add, Slider
  , x+0 w150 vSimilar Page1 NoTicks ToolTip Center, 100
Gui, Add, Text,   x+0, 100
Gui, Add, Checkbox, x+15 gRun vUsePos, UsePos
Gui, Add, Button, xm     w45 gLeftCut, L
Gui, Add, Button, x+0    wp gLeftCut3, L3
Gui, Add, Button, x+15   w70 gRun, Auto
Gui, Add, Button, x+15   w45 gRightCut, R
Gui, Add, Button, x+0    wp gRightCut3, R3
Gui, Add, Text,   xs     w160 yp, Selected  Color
Gui, Add, Edit,   x+15   w140 vSelCol
Gui, Add, Button, x+15   w145 gRun, Color2Two
Gui, Add, Button, xm+95  w45 gDownCut, D
Gui, Add, Button, x+0    wp gDownCut3, D3
Gui, Add, Text,   xs     w160 yp, Gray Threshold
Gui, Add, Edit,   x+15   w140 vGray
Gui, Add, Button, x+15   w145 gRun Default, Gray2Two
Gui, Add, Checkbox, xm   y+21 gRun vModify, Modify
Gui, Add, Button, x+5    yp-6 gRun, Reset
Gui, Add, Text,   x+20   yp+6, Comment
Gui, Add, Edit,   x+5    w132 vComment
Gui, Add, Button, x+10   yp-6 gRun, SplitAdd
Gui, Add, Button, x+10   gRun, AllAdd
Gui, Add, Button, x+10   w80 gRun, OK
Gui, Add, Button, x+10   gCancel, Close
Gui, Show, Hide, Capture Image To Text
return

Run:
Critical
k:=A_GuiControl
Gui, +OwnDialogs
if IsLabel(k)
  Goto, %k%
return

Modify:
GuiControlGet, Modify
return

UsePos:
GuiControlGet, UsePos
return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
return

Reset:
if !IsObject(cc)
  cc:=[], gc:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nW*nH {
  cc[++k]:=1, c:=cors[k], gc[k]:=(((c>>16)&0xFF)*299
    +((c>>8)&0xFF)*587+(c&0xFF)*114)//1000
  Gosub, SetColor
}
Loop, % cors.LeftCut
  Gosub, LeftCut
Loop, % cors.RightCut
  Gosub, RightCut
Loop, % cors.UpCut
  Gosub, UpCut
Loop, % cors.DownCut
  Gosub, DownCut
return

Color2Two:
GuiControlGet, Similar
GuiControlGet, r,, SelCol
if r=
{
  MsgBox, 4096, Tip
    , `n  Please Select a Color First !  `n, 1
  return
}
Similar:=Round(Similar/100,2), n:=Floor(255*3*(1-Similar))
color:=r "@" Similar, k:=i:=0
rr:=(r>>16)&0xFF, gg:=(r>>8)&0xFF, bb:=r&0xFF
Loop, % nW*nH {
  if (cc[++k]="")
    Continue
  c:=cors[k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
  if Abs(r-rr)+Abs(g-gg)+Abs(b-bb)<=n
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

Gray2Two:
GuiControl, Focus, Gray
GuiControlGet, Threshold,, Gray
if Threshold=
{
  Loop, 256
    pp[A_Index-1]:=0
  Loop, % nW*nH
    if (cc[A_Index]!="")
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
  GuiControl,, Gray, %Threshold%
}
color:="*" Threshold, k:=i:=0
Loop, % nW*nH {
  if (cc[++k]="")
    Continue
  if (gc[k]<Threshold+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

gui_del:
cc[k]:="", c:=WindowColor
Gosub, SetColor
return

LeftCut3:
Loop, 3
  Gosub, LeftCut
return

LeftCut:
if (left+right>=nW)
  return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

RightCut3:
Loop, 3
  Gosub, RightCut
return

RightCut:
if (left+right>=nW)
  return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

UpCut3:
Loop, 3
  Gosub, UpCut
return

UpCut:
if (up+down>=nH)
  return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

DownCut3:
Loop, 3
  Gosub, DownCut
return

DownCut:
if (up+down>=nH)
  return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

getwz:
wz=
if bg=
  return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
return

Auto:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
While InStr(wz,bg) {
  if (wz~="^" bg "+\n")
  {
    wz:=RegExReplace(wz,"^" bg "+\n")
    Gosub, UpCut
  }
  else if !(wz~="m`n)[^\n" bg "]$")
  {
    wz:=RegExReplace(wz,"m`n)" bg "$")
    Gosub, RightCut
  }
  else if (wz~="\n" bg "+\n$")
  {
    wz:=RegExReplace(wz,"\n\K" bg "+\n$")
    Gosub, DownCut
  }
  else if !(wz~="m`n)^[^\n" bg "]")
  {
    wz:=RegExReplace(wz,"m`n)^" bg)
    Gosub, LeftCut
  }
  else Break
}
wz=
return

OK:
AllAdd:
SplitAdd:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
if InStr(color,"@") and (UsePos)
{
  StringSplit, r, color, @
  k:=i:=j:=0
  Loop, % nW*nH {
    if (cc[++k]="")
      Continue
    i++
    if (cors[k]=r1)
    {
      j:=i
      Break
    }
  }
  if (j=0)
  {
    MsgBox, 4096, Tip
      , Please select the core color again !, 2
    return
  }
  color:="#" . j . "@" . r2
}
GuiControlGet, Comment
Gui, Hide
cors.Event:=A_ThisLabel
if A_ThisLabel=SplitAdd
{
  SetFormat, IntegerFast, d
  bg:=StrLen(StrReplace(wz,"_"))
    > StrLen(StrReplace(wz,"0")) ? "0":"_"
  s:="", k:=nW*nH+1+left, i:=0, w:=nW-left-right
  Loop, % w {
    i++
    GuiControlGet, j,, % C_[k++]
    if (j=0 and A_Index<w)
      Continue
    v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
    wz:=RegExReplace(wz,"m`n)^.{" i "}"), i:=0
    While InStr(v,bg) {
      if (v~="^" bg "+\n")
        v:=RegExReplace(v,"^" bg "+\n")
      else if !(v~="m`n)[^\n" bg "]$")
        v:=RegExReplace(v,"m`n)" bg "$")
      else if (v~="\n" bg "+\n$")
        v:=RegExReplace(v,"\n\K" bg "+\n$")
      else if !(v~="m`n)^[^\n" bg "]")
        v:=RegExReplace(v,"m`n)^" bg)
      else Break
    }
    if v!=
      s.=towz(color,v,SubStr(Comment,1,1))
    Comment:=SubStr(Comment,2)
  }
  cors.Result:=s
  return
}
s:=towz(color,wz,Comment)
if A_ThisLabel=AllAdd
{
  cors.Result:=s
  return
}
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
s:=StrReplace(s, "Text.=", "Text:=")
s=
(

t1:=A_TickCount
%s%
if (ok:=FindText(%px1%-150000//2, %py1%-150000//2, 150000, 150000, 0, 0, Text))
{
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  ; Click, `%X`%, `%Y`%
}

MsgBox, 4096,, `% "Time:``t" (A_TickCount-t1) " ms``n``n"
  . "Pos:``t" X ", " Y "``n``n"
  . "Result:``t" (ok ? "Success !":"Failed !"), 3
MouseMove, X, Y
(ok) && MouseTip()

)
cors.Result:=s
return

towz(color,wz,comment="")
{
  SetFormat, IntegerFast, d
  wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
  wz:=(InStr(wz,"`n")-1) "." bit2base64(wz)
  return, "`nText.=""|<" comment ">" color "$" wz """`n"
}

add(s, rn=1)
{
  global hscr
  if (rn=1)
    s:="`n" s "`n"
  s:=RegExReplace(s,"\R","`r`n")
  ControlGet, i, CurrentCol,,, ahk_id %hscr%
  if i>1
    ControlSend,, {Home}{Down}, ahk_id %hscr%
  Control, EditPaste, %s%,, ahk_id %hscr%
}

WM_MOUSEMOVE()
{
  ListLines, Off
  static CurrControl, PrevControl
  CurrControl := A_GuiControl
  if (CurrControl!=PrevControl)
  {
    PrevControl := CurrControl
    ToolTip
    if CurrControl !=
      SetTimer, DisplayToolTip, -1000
  }
  return

  DisplayToolTip:
  ListLines, Off
  k:="ToolTip_Text"
  TT_:=RegExMatch(%k%, "m`n)^" CurrControl "\K\s*=.*", r)
    ? Trim(r,"`t =") : ""
  MouseGetPos,,, k
  WinGetClass, k, ahk_id %k%
  if k = AutoHotkeyGUI
  {
    ToolTip, %TT_%
    SetTimer, RemoveToolTip, -5000
  }
  return

  RemoveToolTip:
  ToolTip
  return
}


;===== Copy The Following Functions To Your Own Code Just once =====


; FindText() used to find images restored by Base64 text on screen.
; X is the search scope's upper left corner X coordinates
; Y is the search scope's upper left corner Y coordinates
; W is the search scope's Width
; H is the search scope's Height.
; err1 is the character "0" fault-tolerant in percentage.
; err0 is the character "_" fault-tolerant in percentage.
; Text can be a lot of text to find, separated by "|".
; ScreenShot if the value is 0, the last screenshot will be used.
; ruturn is a array, contains the [X,Y,W,H,Comment] results of Each Find.

FindText(x, y, w, h, err1, err0, text, ScreenShot=1)
{
  xywh2xywh(x,y,w,h,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,ScreenShot,zx,zy)
  ;--------------------------------------
  sx:=x-zx, sy:=y-zy, sw:=w, sh:=h, arr:=[]
  Loop, 2 {
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
    ;--------------------------------------
    mode:=InStr(color,"*") ? 2 : !InStr(color,"#") ? 1 : 0
    color:=RegExReplace(color,"[*#]") . "@"
    StringSplit, r, color, @
    color:=mode=0 ? ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4 : r1
    n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    VarSetCapacity(ss, sw*sh, 0), k:=StrLen(v)*4
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    VarSetCapacity(allpos, 1024*4, 0)
    ;--------------------------------------
    if (ok:=PicFind(mode,color,n,Scan0,Stride
      ,sx,sy,sw,sh,ss,v,s1,s0,e1,e0,w1,h1,allpos))
    {
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
  }
  if (err1=0 and err0=0 and !arr.MaxIndex())
    err1:=err0:=0.1
  else Break
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride, sx, sy, sw, sh
  , ByRef ss, ByRef text, ByRef s1, ByRef s0
  , err1, err0, w1, h1, ByRef allpos)
{
  static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
  if !MyFunc
  {
    x32:="5557565383EC3C8B9C24900000008B7C245085DB0F8EF20"
    . "60000C744241400000000C74424100000000031F6C744240C0"
    . "0000000C744240800000000C7442418000000008B4C24108BA"
    . "C248C0000008B5C24188B54241401CD89C829CB8B8C248C000"
    . "000035C247885C97E67892C2489F989D5895C2404EB1F8DB42"
    . "6000000008B9C248000000083C50483C0018914B383C601390"
    . "424742E8B7C240485C989EA0F45D0803C073175D78B5C24088"
    . "B7C247C83C50483C00139042489149F8D7B01897C240875D28"
    . "B9C248C000000015C241889CF8344240C018B4C246C8B44240"
    . "C014C24108B4C2460014C2414398424900000000F854BFFFFF"
    . "F8B44240839F00F4CC689042485FF0F85D80100008B44246C0"
    . "34424642B84248C000000894424288B442468034424702B842"
    . "49000000039442468894424380F8F960500008B4424608B7C2"
    . "4640FAF442468897424148B74245CC744242C000000008D04B"
    . "803442454894424348B442428394424640F8F4E0100008B442"
    . "468C1E010894424308B442434894424248B442464894424186"
    . "6908B4424248B2C240FB65C060289C72B7C245485ED895C240"
    . "40FB65C06010FB60406895C240C894424100F84B60300008B8"
    . "4248800000031DB894424208B8424840000008944241CEB738"
    . "DB426000000003B5C24147D5A8B8424800000008B149801FA0"
    . "FB64C16020FB64416012B4C24042B44240C0FB614162B54241"
    . "089CDC1FD1F31E929E989C5C1FD1F31E829E889D5C1FD1F01C"
    . "131EA29EA01CA395424587C0F836C2420017871908DB426000"
    . "0000083C3013B1C240F84290300003B5C24087D8E8B4C247C8"
    . "B049901F80FB64C06020FB65406012B4C24042B54240C0FB60"
    . "4062B44241089CDC1FD1F31E929E989D5C1FD1F31EA29EA89C"
    . "5C1FD1F01D131E829E801C83B4424580F8E42FFFFFF836C241"
    . "C010F8937FFFFFF834424180183442424048B4424183944242"
    . "80F8DCFFEFFFF83442468018B7C24608B442438017C24343B4"
    . "424680F8D89FEFFFF8B54242CE90A0200008B4424608B5C246"
    . "40FAF4424688B54246CF7DA83FF018D04988B5C24608D1C938"
    . "95C24140F84D90200008B7C2454C744240400000000C744240"
    . "C000000008D570169FAE80300008B54247089FB8B7C246CC1E"
    . "70285D2897C24107E7B8974241889DF89C58DB426000000008"
    . "B44246C85C07E4D8B4C245C8B5C240C8B74245C035C247401E"
    . "9036C241001EE0FB651020FB6410169D22B01000069C04B020"
    . "00001C20FB6016BC07201D039C70F970383C10483C30139F17"
    . "5D38B74246C0174240C8344240401036C24148B44240439442"
    . "47075988B7424188B44246C2B84248C000000894424188B442"
    . "4702B842490000000894424300F88F30200008B4424688B542"
    . "40889F78B6C247CC744241C00000000C744242C00000000C74"
    . "4242000000000894424288B44241885C00F88B50000008B442"
    . "428C744240400000000C1E010894424248B442464894424148"
    . "B4424040344241C39BC248800000089C3894424100F84B4000"
    . "0008B8424880000008B3424035C24748B8C248400000089442"
    . "40C31C085F60F8434010000894C2408EB2839F87D188B8C248"
    . "00000008B348101DE803E007407836C240C01782283C0013B0"
    . "4240F840601000039D07DD48B74850001DE803E0174C9836C2"
    . "4080179C2834424040183442414018B442404394424180F8D6"
    . "6FFFFFF8344242C018B5C246C8B44242C015C241C834424280"
    . "1394424300F8D1FFFFFFF8B54242083C43C89D05B5E5F5DC24"
    . "800908D74260085D20F84D20100008B7424748B5C241031C08"
    . "B8C248400000001F38B74850001DE803E01740583E90178888"
    . "3C00139D075E98B7424208B8C249400000089F083C00189442"
    . "4208B4424140B442424817C2420FF0300008904B17F9031C08"
    . "D76008B4C850083C00101D939D0C601007CF0E93EFFFFFF8B7"
    . "C242C8B4424300B4424188B9C24940000008D570181FAFF030"
    . "0008904BB0F8F55FFFFFF8954242CE906FDFFFF8B7424208B9"
    . "C249400000089F083C00189C1894424208B4424140B4424248"
    . "1F9FF0300008904B30F8F1BFFFFFF85D20F84DBFEFFFF8B442"
    . "4748B7424108D1C30E973FFFFFF8B5424548B5C2454C744241"
    . "800000000C744241C00000000C1EA100FB6FA897C24040FB6F"
    . "F8B5C2470897C240C0FB67C2454897C24108B7C246CC1E7028"
    . "5DB897C24240F8E8BFDFFFF897424288B4C246C85C97E768B5"
    . "C245C8B74241C8B6C245C0374247401C303442424894424200"
    . "1C58DB426000000000FB64B020FB653012B4C24042B54240C0"
    . "FB6032B44241089CFC1FF1F31F929F989D7C1FF1F31FA29FA8"
    . "9C7C1FF1F01D131F829F801C8394424580F9D0683C30483C60"
    . "139DD75B98B74246C0174241C8B44242083442418010344241"
    . "48B7C2418397C24700F856BFFFFFF8B742428E9E9FCFFFF31D"
    . "2E915FEFFFF8B7424208B9C249400000089F083C00189C1894"
    . "424208B4424140B44242481F9FF0300008904B30F8EACFDFFF"
    . "FE9DFFDFFFFC704240000000031F6C744240800000000E9E3F"
    . "9FFFF9090909090909090909090909090"
    x64:="4157415641554154555756534883EC38448BA424B800000"
    . "04C8BBC24E00000004C89CD448B8C240001000089542410448"
    . "98424900000004585C90F8ED10700004889AC2498000000448"
    . "9A424B800000031FF488BAC24D8000000448BA424F80000003"
    . "1DB31F64531F64531EDC7442408000000004585E47E6248635"
    . "42408458D1C1C89D848039424D00000004189F8EB1B83C0014"
    . "D63D64183C0044183C6014883C2014139C347890C97742A85C"
    . "94589C1440F45C8803A3175D783C0014D63D54183C0044183C"
    . "5014883C2014139C346894C950075D6440164240883C601039"
    . "C24B800000003BC24A000000039B424000100000F857BFFFFF"
    . "F4539F54489F0488BAC2498000000448BA424B8000000410F4"
    . "DC58944242485C90F854F0200008B8424B0000000038424C00"
    . "000004403A424A80000002B842400010000442BA424F800000"
    . "0398424B00000008944242C448964241C0F8F800600008B842"
    . "4A00000008BB424A80000000FAF8424B0000000448B6424244"
    . "C89BC24E00000004589EFC7442420000000008D04B00344241"
    . "0894424288B44241C398424A80000000F8F910100008B8424B"
    . "0000000448B6C2428C1E010894424248B8424A800000089442"
    . "408418D45024489EF2B7C24104585E44898440FB65C0500418"
    . "D450148980FB65C05004963C50FB67405000F846F0400008B8"
    . "424F00000004531C0894424188B8424E80000008944240CE98"
    . "E000000904539CE7E7B488B8C24E0000000428B048101F88D5"
    . "0024863D20FB64C15008D500148980FB64405004863D20FB65"
    . "415004429D94189C929F041C1F91F29DA4431C94429C94189D"
    . "141C1F91F4431CA4429CA4189C141C1F91F01D14431C84429C"
    . "801C8398424900000007C15836C2418010F8898000000662E0"
    . "F1F8400000000004983C0014539C40F8EC30300004539C7458"
    . "9C10F8E67FFFFFF488B8C24D8000000428B048101F88D50024"
    . "863D20FB64C15008D500148980FB64405004863D20FB654150"
    . "04429D94189CA29F041C1FA1F29DA4431D14429D14189D241C"
    . "1FA1F4431D24429D24189C241C1FA1F01D14431D04429D001C"
    . "83B8424900000000F8EFDFEFFFF836C240C010F89F2FEFFFF8"
    . "3442408014183C5048B4424083944241C0F8D8DFEFFFF83842"
    . "4B0000000018BB424A00000008B44242C017424283B8424B00"
    . "000000F8D3AFEFFFF8B4424204883C4385B5E5F5D415C415D4"
    . "15E415FC38B8424A00000008BB424A80000000FAF8424B0000"
    . "0008D04B08BB424A000000089C24489E0F7D883F9018D04868"
    . "94424080F842B030000448B5424108B8C24C00000004531DB3"
    . "1F6428D3CA5000000004183C2014569D2E803000085C90F8EA"
    . "500000044896C240C448974241889D34C89BC24E0000000448"
    . "B6C2408448BB424C00000004C8BBC24C8000000660F1F44000"
    . "04585E47E534863C34C63CE4531C0488D4C05024D01F9662E0"
    . "F1F8400000000000FB6110FB641FF69D22B01000069C04B020"
    . "00001C20FB641FE6BC07201D04139C2430F9704014983C0014"
    . "883C1044539C47FCD01FB4401E64183C3014401EB4539DE759"
    . "C448B6C240C448B7424184C8BBC24E00000004489E58B8424C"
    . "00000002BAC24F80000002B8424000100008944242C0F88420"
    . "300008B8424B0000000488BB424D800000031FF897C240C448"
    . "B5C24244C8B8C24C80000008BBC24F000000089442420418D4"
    . "5FF896C2408C744242800000000C7442418000000004889F54"
    . "88D4486044489A424B800000048894424108B44240885C00F8"
    . "89E0000008B442420448BA424A800000031DBC1E0108944241"
    . "C8B44240C4439F7448D04030F84AC00000031C04585DB89FE4"
    . "48B9424E80000007538E957010000660F1F4400004439F17D1"
    . "B418B14874401C24863D241803C1100740A83EE0178300F1F4"
    . "400004883C0014139C30F8E240100004439E889C17DCC8B548"
    . "5004401C24863D241803C110174BB4183EA0179B583C301418"
    . "3C401395C24080F8D77FFFFFF83442428018B9C24B80000008"
    . "B442428015C240C83442420013944242C0F8D33FFFFFF8B442"
    . "418E995FDFFFF0F1F8400000000004585ED0F84080200008B8"
    . "C24E80000004C8B5424104889EA8B024401C0489841803C010"
    . "1740583E90178904883C2044C39D275E448635424188B4C241"
    . "C488BB424080100004409E189D0890C9683C0013DFF0300000"
    . "F8F32FDFFFF8944241831C08B5485004883C0014401C24139C"
    . "54863D241C60411007FE883C3014183C401395C24080F8DB9F"
    . "EFFFFE93DFFFFFF9048635424208B4C24240B4C2408488BB42"
    . "40801000089D083C001890C963DFF0300000F8FD5FCFFFF894"
    . "42420E98DFCFFFF48635424188B4C241C488BB424080100004"
    . "409E189D0890C9683C0013DFF0300000F8FA5FCFFFF4585ED8"
    . "94424180F856AFFFFFFE9C1FEFFFF660F1F4400008B7424104"
    . "48B8424C000000031C94531DB4889F089F3400FB6F60FB6FC4"
    . "28D04A500000000C1EB104585C00FB6DB8944240C0F8E6EFDF"
    . "FFF4889AC24980000008BAC249000000044896C24184489742"
    . "4104189D54C89BC24E00000004189CE4589DF4585E47E75488"
    . "B8C24980000004D63DF4C039C24C80000004963C54531C94C8"
    . "D440102410FB608410FB650FF410FB640FE29D929FA4189CA2"
    . "9F041C1FA1F4431D14429D14189D241C1FA1F4431D24429D20"
    . "1CA89C1C1F91F31C829C801D039C5430F9D040B4983C101498"
    . "3C0044539CC7FB144036C240C4501E74183C60144036C24084"
    . "439B424C00000000F856FFFFFFF448B6C2418448B7424104C8"
    . "BBC24E0000000E99CFCFFFF31C0E97CFBFFFF48635424188B4"
    . "C241C488BB424080100004409E189D0890C9683C0013DFF030"
    . "0000F8F55FBFFFF89442418E97AFDFFFFC7442424000000004"
    . "531F64531EDE9F3F8FFFF909090909090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc
    , "int",mode, "uint",color, "int",n, Ptr,Scan0
    , "int",Stride, "int",sx, "int",sy, "int",sw, "int",sh
    , Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
    , "int",err1, "int",err0, "int",w1, "int",h1, Ptr,&allpos)
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

GetBitsFromScreen(x, y, w, h, ByRef Scan0, ByRef Stride
  , ScreenShot=1, ByRef zx="", ByRef zy="")
{
  static bits, bpp, oldx, oldy, oldw, oldh
  if (ScreenShot or x<oldx or y<oldy
    or x+w>oldx+oldw or y+h>oldy+oldh)
  {
    oldx:=x, oldy:=y, oldw:=w, oldh:=h, ScreenShot:=1
    VarSetCapacity(bits, w*h*4), bpp:=32
  }
  Scan0:=&bits, Stride:=((oldw*bpp+31)//32)*4
  zx:=oldx, zy:=oldy
  if (!ScreenShot or w*h<1)
    return
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
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, len:=StrLen(hex)//2)
  Loop, % len
    NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
  DllCall("VirtualProtect",Ptr,&code, Ptr,len,"uint",0x40,PtrP,0)
  SetBatchLines, %bch%
}

base64tobit(s)
{
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
  return, s
}

bit2base64(s)
{
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

; You can put the text library at the beginning of the script,
; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib

Pic(comments, add_to_Lib=0)
{
  static Lib:=[]
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
        Lib[Trim(r1)]:=r
    Lib[""]:=""
  }
  else
  {
    Text:=""
    Loop, Parse, comments, |
      Text.="|" . Lib[Trim(A_LoopField)]
    return, Text
  }
}

PicN(number)
{
  return, Pic(Trim(RegExReplace(number,".","$0|"),"|"))
}

; Use PicX(Text) to automatically cut into multiple characters

PicX(Text)
{
  if !RegExMatch(Text,"\|([^$]+)\$(\d+)\.([\w+/]+)",r)
    return, Text
  w:=r2, v:=base64tobit(r3), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  wz:=RegExReplace(v,".{" w "}","$0`n")
  SetFormat, IntegerFast, d
  While InStr(wz,c) {
    While !(wz~="m`n)^" c)
      wz:=RegExReplace(wz,"m`n)^.")
    i:=0
    While (wz~="m`n)^.{" i "}" c)
      i++
    v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
    wz:=RegExReplace(wz,"m`n)^.{" i "}")
    if v!=
      Text.="|" r1 "$" i "." bit2base64(v)
  }
  return, Text
}

; Screenshot and retained as the last screenshot.

ScreenShot()
{
  n:=150000
  xywh2xywh(-n,-n,2*n+1,2*n+1,x,y,w,h)
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,1)
}

FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=20)
{
  OCR:="", RightX:=nX+nW-1, ScreenShot()
  While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text, 0))
  {
    For k,v in ok
    {
      ; X is the X coordinates of the upper left corner
      ; and W is the width of the image have been found
      x:=v.1, y:=v.2, w:=v.3, h:=v.4, comment:=v.5
      ; We need the leftmost X coordinates
      if (A_Index=1 or x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
      else if (x=LeftX)
      {
        Loop, 100
        {
          err:=A_Index/100
          if FindText(x, y, w, h, err, err, Text, 0)
          {
            LeftX:=x, LeftY:=y, LeftW:=w, LeftH:=h, LeftOCR:=comment
            Break
          }
          if FindText(LeftX, LeftY, LeftW, LeftH, err, err, Text, 0)
            Break
        }
      }
    }
    ; If the interval exceeds the set value, add "*" to the result
    OCR.=(A_Index>1 and LeftX-nX-1>Interval ? "*":"") . LeftOCR
    ; Update nX and nW for next search
    nX:=LeftX+LeftW-1, nW:=RightX-nX+1
  }
  return, OCR
}

; Reordering the objects returned from left to right,
; from top to bottom, ignore slight height difference

SortOK(ok, dy=10) {
  if !IsObject(ok)
    return, ok
  SetFormat, IntegerFast, d
  For k,v in ok
  {
    x:=v.1+v.3//2, y:=v.2+v.4//2
    y:=A_Index>1 and Abs(y-lasty)<dy ? lasty : y, lasty:=y
    n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
  }
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return, ok2
}

; Reordering according to the nearest distance

SortOK2(ok, px, py) {
  if !IsObject(ok)
    return, ok
  SetFormat, IntegerFast, d
  For k,v in ok
  {
    x:=v.1+v.3//2, y:=v.2+v.4//2
    n:=((x-px)**2+(y-py)**2) "." k
    s:=A_Index=1 ? n : s "-" n
  }
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return, ok2
}

; Prompt mouse position in remote assistance

MouseTip() {
  VarSetCapacity(Point, 16, 0)
  DllCall("GetCursorPos", "ptr",&Point)
  x:=NumGet(Point,0,"uint")
  y:=NumGet(Point,4,"uint")+NumGet(Point,8,"uint")
  x:=Round(x)-10, y:=Round(y)-10
  Gui, _MouseTip_: Destroy
  Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
  Gui, _MouseTip_: Color, Red
  Gui, _MouseTip_: Show, Hide w21 h21
  ;-------------------------
  dhw:=A_DetectHiddenWindows
  DetectHiddenWindows, On
  d:=4, w:=h:=21, i:=w-d, j:=h-d
  WinSet, Region
    , 0-0 %w%-0 %w%-%h% 0-%h% 0-0  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
    , ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  Gui, _MouseTip_: Show, NA x%x% y%y%
  Sleep, 500
  Gui, _MouseTip_: Color, Blue
  Sleep, 500
  Gui, _MouseTip_: Color, Red
  Sleep, 500
  Gui, _MouseTip_: Color, Blue
  Sleep, 500
  Gui, _MouseTip_: Destroy
}

; Note: This function is used for combination lookup,
; for example, a 0-9 text library has been set up,
; then any ID number can be found.
; Use Pic(Text,1) and PicN(number) when using.
; Use PicX(Text) to automatically cut into multiple characters.
; Color position mode is not supported.

FindText2(x, y, w, h, err1, err0, text, ScreenShot=1, Interval=20)
{
  xywh2xywh(x,y,w,h,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,ScreenShot,zx,zy)
  ;--------------------------------------
  sx:=x-zx, sy:=y-zy, sw:=w, sh:=h, arr:=[]
  info:=[], allw:=-1, allv:=allcolor:=allcomment:=""
  if (err1=0 and err0=0)
    err1:=err0:=0.1
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
    IfInString, color, #, Continue
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    if (allcolor="")
    {
      mode:=InStr(color,"*") ? 1 : 0
      color:=StrReplace(color,"*") . "@"
      StringSplit, r, color, @
      allcolor:=r1, n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    }
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    info.Push(StrLen(allv),w1,h1,len1,len0,e1,e0)
    allv.=v, allw+=w1+1, allcomment.=comment
  }
  if (allv="")
  {
    SetBatchLines, %bch%
    return, 0
  }
  num:=info.MaxIndex(), VarSetCapacity(in,num*4,0)
  Loop, % num
    NumPut(info[A_Index], in, 4*(A_Index-1), "int")
  VarSetCapacity(ss, sw*sh, 0), k:=StrLen(allv)*4
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(allpos, 1024*4, 0)
  offsetX:=Interval, offsetY:=5
  ;--------------------------------------
  if (ok:=PicFind2(mode,allcolor,n,Scan0,Stride,sx,sy,sw,sh
    ,ss,allv,s1,s0,in,num,offsetX,offsetY,allpos))
  {
    Loop, % ok
      pos:=NumGet(allpos, 4*(A_Index-1), "uint")
      , rx:=(pos&0xFFFF)+zx, ry:=(pos>>16)+zy
      , arr.Push( [rx,ry,allw,h1,allcomment] )
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind2(mode, color, n, Scan0, Stride, sx, sy, sw, sh
  , ByRef ss, ByRef text, ByRef s1, ByRef s0
  , ByRef in, num, offsetX, offsetY, ByRef allpos)
{
  static MyFunc, Ptr:=A_PtrSize ? "UPtr" : "UInt"
  if !MyFunc
  {
    x32:="5557565383EC7C8B8424C8000000C7442414000000008BB"
    . "C24C000000085C00F8EBA0000008B4424148BB424C40000008"
    . "B3486897424088BB424C40000008B5486048B44860885C0895"
    . "42404894424107E778B74240831EDC704240000000089F28B4"
    . "4240485C07E4C8B4C24088D1C28896C240C89E829E9038C24B"
    . "8000000EB0D89049783C00183C20139C3741B803C013175ED8"
    . "BAC24BC0000008944B50083C00183C60139C375E58B5C24040"
    . "15C24088B6C240C8304240103AC24AC0000008B04243944241"
    . "0759883442414078B442414398424C80000000F8F46FFFFFF8"
    . "B8424A80000008BB424A40000000FAF8424A00000008B9424A"
    . "00000008D3CB08B8424AC000000F7D88D0482894424108B842"
    . "49000000085C00F85440500008B842494000000C744240C000"
    . "00000C744241400000000C1E8100FB6C08904248B842494000"
    . "0000FB6C4894424040FB6842494000000894424088B8424AC0"
    . "00000C1E0028944241C8B8424B000000085C00F8E9E0000008"
    . "B8424AC00000085C07E798B9C249C0000008B7424148BAC249"
    . "C00000003B424B400000001FB037C241C897C241801FD0FB64"
    . "B020FB653012B0C242B5424040FB6032B44240889CFC1FF1F3"
    . "1F929F989D7C1FF1F31FA29FA01D19931D029D001C83B84249"
    . "80000000F9E0683C30483C60139DD75BB8B9424AC000000015"
    . "424148B7C24188344240C01037C24108B44240C398424B0000"
    . "0000F8562FFFFFF8B9C24C40000008B8424C40000008BB424C"
    . "40000008B9424C40000008B5B148B40048B760C8B5210895C2"
    . "42C8B9C24C400000089742428895424108B5B18895C24248B9"
    . "C24AC00000029C339D60F4DD68BB424C4000000895C2420895"
    . "424088B9424B00000002B56088954246C0F889B0400008B942"
    . "4BC0000008B74242883E801C744241C00000000C7442460000"
    . "00000C744247400000000894424648D14B2895424788B44242"
    . "085C00F88E70000008B5424608B8424A8000000C7442404000"
    . "0000001D0C1E0108944247089D02B9424D000000089D6BA000"
    . "000000F49D6895424580FAF9424AC0000008954245C8B9424D"
    . "000000001C289542468908B4424040344241C89C1894424188"
    . "B442424394424100F84B40000008B5C240889C6038C24B4000"
    . "00031C08B54242C85DB0F8ED10000008934248B5C24288B6C2"
    . "410EB2939C57E188BB424C00000008B3C8601CF803F0074078"
    . "32C240178289083C001394424080F849B00000039C37ED38BB"
    . "424BC0000008B3C8601CF803F0174C283EA0179BD834424040"
    . "18B442404394424200F8D66FFFFFF83442460018B9424AC000"
    . "0008B4424600154241C3944246C0F8DEFFEFFFF8B4C247483C"
    . "47C89C85B5E5F5DC24800908DB426000000008B7C242885FF7"
    . "E308BB424B40000008B5C241831C08B54242C01F38BB424BC0"
    . "000008B0C8601D9803901740583EA01788683C00139C775EA8"
    . "B4424640344240483BC24C800000007894424300F8EB901000"
    . "08B8424C4000000C744244C0700000083C020894424348B442"
    . "4348B9424AC0000008B7424308B0029C2894424508B8424CC0"
    . "0000001F039C20F4EC289C28944245439F20F8C1CFFFFFF8B4"
    . "424348B5424688B700C8B6808897424408B70108974241489C"
    . "68B4014894424448B8424B00000002B460439C20F4EC289442"
    . "40C8B46FC8BB424BC000000890424C1E00201C6038424C0000"
    . "000894424488B4424588B7C2430037C245C3B44240C8904240"
    . "F8FA50000008D76008DBC270000000085ED7E258B9C24B4000"
    . "0008B54241431C001FB8B0C8601D9803901740583EA0178618"
    . "3C00139C575EA8B4C244085C90F8E9B0000008B54244439D10"
    . "F848F0000008B9C24B4000000896C243831C0897C243C8B6C2"
    . "44801FB89CFEB0F8D74260083C00139FA746939C77E658B4C8"
    . "50001D980390074EA83EA0179E58B6C24388B7C243C8304240"
    . "103BC24AC0000008B04243944240C0F8D65FFFFFF834424300"
    . "18B442430394424540F8D2FFFFFFF83442404018B442404394"
    . "424200F8D5FFDFFFFE9F4FDFFFF8D76008DBC27000000008B4"
    . "424308B7424508344244C07834424341C8D4430FF894424308"
    . "B44244C398424C80000000F8F5DFEFFFF8B5C24748B4424040"
    . "38424A40000008BB424D40000000B4424708D4B0181F9FF030"
    . "00089049E0F8FB5FDFFFF8B54242885D27E278B7424188B942"
    . "4B40000008B8424BC0000008D1C328B7424788B1083C00401D"
    . "A39F0C6020075F28344240401894C24748B442404394424200"
    . "F8DB3FCFFFFE948FDFFFF8B8424940000008BAC24B0000000C"
    . "7042400000000C74424040000000083C00169C0E803000089C"
    . "38B8424AC000000C1E00285ED894424080F8E73FBFFFF89DD8"
    . "BB424AC00000085F67E5B8B8C249C0000008B5C24048BB4249"
    . "C000000039C24B400000001F9037C240801FE66900FB651020"
    . "FB6410169D22B01000069C04B02000001C20FB6016BC07201D"
    . "039C50F970383C10483C30139F175D38B9424AC00000001542"
    . "40483042401037C24108B0424398424B00000007586E9F2FAF"
    . "FFF83C47C31C95B89C85E5F5DC2480090"
    x64:="4157415641554154555756534881EC88000000488B84243"
    . "80100004C8BB424180100004C898C24E8000000448B8C24400"
    . "10000898C24D00000008954241444898424E00000004C8BAC2"
    . "4200100004585C94C8BBC24280100004C8BA42430010000488"
    . "9442408C7442410000000000F8EA10000004C89B4241801000"
    . "0448BB42408010000488B4424088B68088B308B780485ED7E5"
    . "C89F14189F24531DB31DB9085FF7E434863D6468D0C1F4489D"
    . "84C01EAEB164C63C14883C20183C1014389048483C0014139C"
    . "1741C803A3175E54D63C24883C2014183C2014389048783C00"
    . "14139C175E401FE83C3014501F339DD75AF834424100748834"
    . "424081C8B442410398424400100000F8F77FFFFFF4C8BB4241"
    . "80100008B8424000100008B9C24F80000000FAF8424F000000"
    . "0448B8424D00000008D2C988B8424080100008B9C24F000000"
    . "0F7D84585C08D0483894424100F855A0500008B7424148B8C2"
    . "41001000031D24531ED4889F089F3400FB6F60FB6FC8B84240"
    . "8010000C1EB100FB6DBC1E00285C9894424080F8ED70000004"
    . "C89BC24280100004C89A42430010000448BBC24E0000000448"
    . "BA424080100004C89B424180100004189D64585E47E79488B9"
    . "424E80000004D63DD4C039C24180100004863C54531C94C8D4"
    . "402020F1F4000410FB608410FB650FF410FB640FE29D929FA4"
    . "189CA29F041C1FA1F4431D14429D14189D241C1FA1F4431D24"
    . "429D201CA89C1C1F91F31C829C801D04439F8430F9E040B498"
    . "3C1014983C0044539CC7FB0036C24084501E54183C601036C2"
    . "4104439B424100100000F856CFFFFFF4C8BB424180100004C8"
    . "BBC24280100004C8BA42430010000488B9C2438010000488B8"
    . "42438010000448B6B108B5B148B50048B400C895C241C488B9"
    . "C243801000089C68B5B18895C24188B9C240801000029D3443"
    . "9E8895C2414488B9C2438010000410F4CC589C78B842410010"
    . "0002B4308894424740F889404000089F04C89BC24280100004"
    . "C89A4243001000083E8014D89F4C744240800000000498D448"
    . "7044589EE48C744245800000000C744247C000000004189F74"
    . "189FD48894424488D42FF894424688B44241485C00F88EB000"
    . "000488B5C24588B84240001000001D8C1E0108944247889D82"
    . "B84245001000089C6B8000000000F49C631ED894424500FAF8"
    . "42408010000894424548B84245001000001D88944246C4889E"
    . "84489ED4989C58B44240844896C2410428D3C288B442418413"
    . "9C60F84BB0000004189C131C085ED448B44241C0F8EDA00000"
    . "04C8B9424280100004C8B9C2430010000EB2E66904139CE7E1"
    . "B418B148301FA4863D241803C1400740B4183E901782E0F1F4"
    . "400004883C00139C50F8E9A0000004139C789C17ECD418B148"
    . "201FA4863D241803C140174BD4183E80179B74983C50144396"
    . "C24140F8D68FFFFFF4189ED4883442458018BB424080100004"
    . "88B44245801742408394424740F8DE9FEFFFF8B4C247C89C84"
    . "881C4880000005B5E5F5D415C415D415E415FC34585FF7E2C4"
    . "88B9424280100008B4C241C4C8B4424488B0201F8489841803"
    . "C0401740583E901788C4883C2044939D075E58B44246803442"
    . "41083BC2440010000070F8EB4010000488B9C2438010000896"
    . "C24408BAC240801000044897C24304C896C2438C7442428070"
    . "000004189C54883C3204489742434897C24704989DF418B078"
    . "9EA29C28944242C8B8424480100004401E839C20F4EC24439E"
    . "8894424440F8CEF000000418B47148BBC2410010000412B7F0"
    . "4418B5708418B770C458B771089C38B44246C4C897C246039C"
    . "70F4FF8496347FC4189DF48C1E0024989C0480384243001000"
    . "04C0384242801000048894424208B5C24508B4424544401E83"
    . "9FB4189DA0F8F7C0000009085D27E254589F34531C9438B0C8"
    . "801C14863C941803C0C0174064183EB0178504983C1014439C"
    . "A7FE185F60F8E800000004439FE747B4C8B4C24204489FB453"
    . "1DBEB114183C3014983C10439F374624439DE7E5D418B0901C"
    . "14863C941803C0C0074E083EB0179DB0F1F840000000000418"
    . "3C20101E84439D77D854183C50144396C24440F8D5FFFFFFF4"
    . "C8B6C2438448B7C2430448B7424348B6C24404983C50144396"
    . "C24140F8D74FDFFFFE907FEFFFF8B44242C4C8B7C246083442"
    . "42807458D6C05FF4983C71C8B442428398424400100000F8F9"
    . "BFEFFFF448B7C2430448B7424348B6C24404C8B6C24388B7C2"
    . "470486344247C8B542410039424F8000000488B9C245801000"
    . "00B5424788D480181F9FF0300008914830F8FC1FDFFFF4585F"
    . "F7E22488B8424280100004C8B4424488B104883C00401FA493"
    . "9C04863D241C604140075EB4983C50144396C2414894C247C0"
    . "F8DC8FCFFFFE95BFDFFFF0F1F00448B5424148B94241001000"
    . "031DB8B84240801000031F64183C2014569D2E803000085D28"
    . "D3C85000000000F8E84FBFFFF4C8BAC24E8000000448B9C240"
    . "80100004585DB7E524863C54C63CE4531C0498D4C05024D01F"
    . "1660F1F8400000000000FB6110FB641FF69D22B01000069C04"
    . "B02000001C20FB641FE6BC07201D04139C2430F9704014983C"
    . "0014883C1044539C37FCD01FD4401DE83C301036C2410399C2"
    . "4100100007599E908FBFFFF31C9E9CBFCFFFF9090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc
    , "int",mode, "uint",color, "int",n, Ptr,Scan0
    , "int",Stride, "int",sx, "int",sy, "int",sw, "int",sh
    , Ptr,&ss, "AStr",text, Ptr,&s1, Ptr,&s0
    , Ptr,&in, "int",num, "int",offsetX, "int",offsetY, Ptr,&allpos)
}


/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int err1, int err0, int w1, int h1, int * allpos)
{
  int o, i, j, x, y, sx1, sy1, ok=0;
  int r, g, b, rr, gg, bb, e1, e0, len1, len0, max;
  // Generate Lookup Table
  o=len1=len0=0;
  for (y=0; y<h1; y++)
  {
    for (x=0; x<w1; x++)
    {
      i=mode==0 ? y*Stride+x*4 : y*sw+x;
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  // Color Position Mode
  // This mode will not clear the image that has been found
  if (mode==0)
  {
    sx1=sx+sw-w1; sy1=sy+sh-h1; max=len1>len0 ? len1 : len0;
    for (y=sy; y<=sy1; y++)
    {
      for (x=sx; x<=sx1; x++)
      {
        o=y*Stride+x*4; e1=err1; e0=err0;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b>n && (--e1)<0) goto NoMatch2;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b<=n && (--e0)<0) goto NoMatch2;
          }
        }
        allpos[ok++]=y<<16|x;
        if (ok>=1024) goto Return1;
        NoMatch2:
        continue;
      }
    }
    goto Return1;
  }
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-4*sw; i=0;
  if (mode==1)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
        ss[i]=r+g+b<=n ? 1:0;
      }
  }
  else  // Gray Threshold Mode
  {
    c=(c+1)*1000;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ss[i]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
  }
  // Start Lookup
  sx1=sw-w1; sy1=sh-h1; max=len1>len0 ? len1 : len0;
  for (y=0; y<=sy1; y++)
  {
    for (x=0; x<=sx1; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      if (e0==len0)
      {
        for (i=0; i<len1; i++)
          if (ss[o+s1[i]]!=1 && (--e1)<0) goto NoMatch1;
      }
      else
      {
        for (i=0; i<max; i++)
        {
          if (i<len1 && ss[o+s1[i]]!=1 && (--e1)<0) goto NoMatch1;
          if (i<len0 && ss[o+s0[i]]!=0 && (--e0)<0) goto NoMatch1;
        }
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      // Clear the image that has been found
      for (i=0; i<len1; i++) ss[o+s1[i]]=0;
      NoMatch1:
      continue;
    }
  }
  Return1:
  return ok;
}


int __attribute__((__stdcall__)) PicFind2(
  int mode, unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int * in, int num, int offsetX, int offsetY, int * allpos )
{
  int o, i, j, x, y, r, g, b, rr, gg, bb, max, e1, e0, ok=0;
  int o1, x1, y1, w1, h1, sx1, sy1, len1, len0, err1, err0;
  int o2, x2, y2, w2, h2, sx2, sy2, len21, len20, err21, err20;
  // Generate Lookup Table
  for (j=0; j<num; j+=7)
  {
    o=o1=o2=in[j]; w1=in[j+1]; h1=in[j+2];
    for (y=0; y<h1; y++)
    {
      for (x=0; x<w1; x++)
      {
        i=y*sw+x;
        if (text[o++]=='1')
          s1[o1++]=i;
        else
          s0[o2++]=i;
      }
    }
  }
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-4*sw; i=0;
  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
        ss[i]=r+g+b<=n ? 1:0;
      }
  }
  else  // Gray Threshold Mode
  {
    c=(c+1)*1000;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ss[i]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
  }
  // Start Lookup
  w1=in[1]; h1=in[2]; len1=in[3]; len0=in[4]; err1=in[5]; err0=in[6];
  sx1=sw-w1; sy1=sh-h1; max=len1>len0 ? len1 : len0;
  for (y=0; y<=sy1; y++)
  {
    for (x=0; x<=sx1; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      if (e0==len0)
      {
        for (i=0; i<len1; i++)
          if (ss[o+s1[i]]!=1 && (--e1)<0) goto NoMatch1;
      }
      else
      {
        for (i=0; i<max; i++)
        {
          if (i<len1 && ss[o+s1[i]]!=1 && (--e1)<0) goto NoMatch1;
          if (i<len0 && ss[o+s0[i]]!=0 && (--e0)<0) goto NoMatch1;
        }
      }
      x1=x+w1-1; y1=y-offsetY; if (y1<0) y1=0;
      for (j=7; j<num; j+=7)
      {
        o2=in[j]; w2=in[j+1]; h2=in[j+2];
        len21=in[j+3]; len20=in[j+4]; err21=in[j+5]; err20=in[j+6];
        sx2=sw-w2; i=x1+offsetX; if (i<sx2) sx2=i;
        sy2=sh-h2; i=y+offsetY; if (i<sy2) sy2=i;
        for (x2=x1; x2<=sx2; x2++)
        {
          for (y2=y1; y2<=sy2; y2++)
          {
            o1=y2*sw+x2; e1=err21; e0=err20;
            for (i=0; i<len21; i++)
              if (ss[o1+s1[o2+i]]!=1 && (--e1)<0) goto NoMatch2;
            for (i=0; e0!=len20 && i<len20; i++)
              if (ss[o1+s0[o2+i]]!=0 && (--e0)<0) goto NoMatch2;
            goto MatchOK;
            NoMatch2:
            continue;
          }
        }
        goto NoMatch1;
        MatchOK:
        x1=x2+w2-1;
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      // Clear the image that has been found
      for (i=0; i<len1; i++) ss[o+s1[i]]=0;
      NoMatch1:
      continue;
    }
  }
  Return1:
  return ok;
}

*/


;================= The End =================

;