/*
===========================================
  FindText - Catch screen image into text and then find it

  Author  :  FeiYue
  Version :  5.0
  Date    :  2017-03-20

  Useage:
  1. Catch the image to text string.
  2. Test find the text string on full Screen.
  3. When test is successful, copy the code
     and paste it into your own script.
     Note: Copy the "FindText()" function and the following
     functions and paste it into your own script Just once.

===========================================
  Introduction of function parameters:

  returnArray := FindText( center point X, center point Y
    , Left and right offset to the center point W
    , Up and down offset to the center point H
    , Character "0" fault-tolerant in percentage
    , Character "_" fault-tolerant in percentage, text )

  parameters of the X,Y is the center of the coordinates,
  and the W,H is the offset distance to the center,
  So the search range is (X-W, Y-H)-->(X+W, Y+H).

  The fault-tolerant parameters allow the loss of specific
  characters, very useful for gray threshold model.

  Text parameters can be a lot of text to find, separated by "|".

  ruturn is a array, contains the X,Y,W,H,OCR results of Each Find.

===========================================
*/

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
;----------------------------
; The capture range can be changed by adjusting the numbers
  ww:=35, hh:=12
  nW:=2*ww+1, nH:=2*hh+1
;----------------------------
Gosub, MakeCatchWindow
Gosub, MakeMainWindow
OnExit, savescr
Gosub, readscr
Return


F12::    ; Hotkey --> Reload
SetTitleMatchMode, 2
SplitPath, A_ScriptName,,,, name
IfWinExist, %name%
{
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  Sleep, 500
}
Reload
Return


readscr:
f=%A_Temp%\~scr.tmp
FileRead, s, %f%
GuiControl, Main:, scr, %s%
s=
Return

savescr:
f=%A_Temp%\~scr.tmp
GuiControlGet, s, Main:, scr
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

Main_Window:
Gui, Main:Show, Center
Return

MakeMainWindow:
Gui, Main:Default
Gui, +AlwaysOnTop +HwndMain_ID
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s6 bold, Verdana
Gui, Add, Edit, xm w660 r25 vMyEdit -Wrap -VScroll
Gui, Font, s12 norm, Verdana
Gui, Add, Button, w220 gMainRun, Catch
Gui, Add, Button, x+0 wp gMainRun, Test
Gui, Add, Button, x+0 wp gMainRun, Copy
Gui, Font, s12 cBlue, Verdana
Gui, Add, Edit, xm w660 h350 vscr Hwndhscr -Wrap HScroll
Gui, Show, NA, Catch Image To Text And Find Text Tool
;---------------------------------------
OnMessage(0x100, "EditEvents1")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents2")  ; WM_LBUTTONDOWN
Return

EditEvents1() {
  ListLines, Off
  if (A_Gui="Main") and (A_GuiControl="scr")
    SetTimer, ShowText, -100
}

EditEvents2() {
  ListLines, Off
  if (A_Gui="Catch")
    WM_LBUTTONDOWN()
  else
    EditEvents1()
}

ShowText:
ListLines, Off
Critical
ControlGet, i, CurrentLine,,, ahk_id %hscr%
ControlGet, s, Line, %i%,, ahk_id %hscr%
if RegExMatch(s,"(\d+)\.([\w+/]{3,})",r)
{
  s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
  s:=StrReplace(StrReplace(s,"0","_"),"1","0")
}
else s=
GuiControl, Main:, MyEdit, % Trim(s,"`n")
Return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Main_ID%
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, scr
Return

Copy:
GuiControlGet, s,, scr
Clipboard:=StrReplace(s,"`n","`r`n")
s=
Return

Catch:
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow
  +E0x08000000 -DPIScale
WinSet, Transparent, 100
Gui, Color, Red
Gui, Show, Hide w%nW% h%nH%
;------------------------------
ListLines, Off
Loop {
  MouseGetPos, px, py
  if GetKeyState("LButton","P")
    Break
  Gui, Show, % "NA x" (px-ww) " y" (py-hh)
  ToolTip, % "The Mouse Pos : " px "," py
    . "`nPlease Move and Click LButton"
  Sleep, 20
}
KeyWait, LButton
Gui, Color, White
Loop {
  MouseGetPos, x, y
  if Abs(px-x)+Abs(py-y)>100
    Break
  Gui, Show, % "NA x" (x-ww) " y" (y-hh)
  ToolTip, Please Move Mouse > 100 Pixels
  Sleep, 20
}
ToolTip
ListLines, On
Gui, Destroy
WinWaitClose
cors:=getc(px,py,ww,hh)
Gui, Catch:Default
Loop, 2
  GuiControl,, Edit%A_Index%
GuiControl,, Modify, % Modify:=0
GuiControl, Focus, Gray2Two
Gosub, Load
Gui, Show, Center
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Catch_ID%
Return

WM_LBUTTONDOWN() {
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  if !InStr(mclass,"progress")
    Return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (Modify and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : WindowColor
        Gosub, SetColor
      }
      else
        GuiControl, Catch:, Edit1, % cors[k]
      Return
    }
}

getc(px, py, ww, hh) {
  xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
  if (w<1 or h<1)
    Return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh-y+A_Index-1
    Loop, %nW% {
      i:=px-ww-x+A_Index-1, k++
      if (i>=0 and i<w and j>=0 and j<h)
        c:=NumGet(Scan0+0,i*4+j*Stride,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  cors.left:=Abs(px-ww-x)
  cors.right:=Abs(px+ww-(x+w-1))
  cors.up:=Abs(py-hh-y)
  cors.down:=Abs(py+hh-(y+h-1))
  SetBatchLines, %bch%
  Return, cors
}

Test:
GuiControlGet, s, Main:, scr
text=
While RegExMatch(s,"i)Text[.:]=""([^""]+)""",r)
  text.=r1, s:=StrReplace(s,r,"","",1)
if !RegExMatch(s,"i)FindText\(([^)]+)\)",r)
  Return
StringSplit, r, r1, `,, ""
if r0<7
  Return
t1:=A_TickCount
ok:=FindText(r1,r2,r3,r4,r5,r6,text)
t1:=A_TickCount-t1
X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
X+=W//2, Y+=H//2
MsgBox, 4096, Tip
  , %   "  Find Result   `t:  " (ok ? "OK":"NO")
  . "`n`n  Find Time     `t:  " t1  " ms`t`t"
  . "`n`n  Find Position `t:  " (ok ? X ", " Y:"")
  . "`n`n  Find OCR in <>`t:  " OCR
if ok
{
  MouseMove, X, Y
  Sleep, 1000
}
Return

MakeCatchWindow:
WindowColor:="0xCCDDEE"
Gui, Catch:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow +HwndCatch_ID
Gui, Margin, 15, 15
Gui, Color, %WindowColor%
Gui, Font, s14, Verdana
ListLines, Off
w:=800//nW+1, h:=(A_ScreenHeight-300)//nH+1, w:=h<w ? h:w
Loop, % nH*nW {
  j:=A_Index=1 ? "" : Mod(A_Index,nW)=1 ? "xm y+-1" : "x+-1"
  Gui, Add, Progress, w%w% h%w% %j% -Theme
}
ListLines, On
Gui, Add, Button, xm+95  w45 gUpCut Section, U
Gui, Add, Button, x+0    wp gUpCut3, U3
Gui, Add, Text,   xm+310 yp+6 Section, Color Similarity  0
Gui, Add, Slider
  , x+0 w250 vSimilar Page1 NoTicks ToolTip Center, 100
Gui, Add, Text,   x+0, 100
Gui, Add, Button, xm     w45 gLeftCut, L
Gui, Add, Button, x+0    wp gLeftCut3, L3
Gui, Add, Button, x+15   w70 gRun, Auto
Gui, Add, Button, x+15   w45 gRightCut, R
Gui, Add, Button, x+0    wp gRightCut3, R3
Gui, Add, Text,   xs     w160 yp, Selected Color
Gui, Add, Edit,   x+15   w140
Gui, Add, Button, x+15   w150 gRun, Color2Two
Gui, Add, Button, xm+95  w45 gDownCut, D
Gui, Add, Button, x+0    wp gDownCut3, D3
Gui, Add, Text,   xs     w160 yp, Gray Threshold
Gui, Add, Edit,   x+15   w140
Gui, Add, Button, x+15   w150 gRun Default, Gray2Two
Gui, Add, Button, xm     w100 gRun, Load
Gui, Add, Button, x+15   w120 gRun, Exchange
Gui, Add, Checkbox, x+15 yp+6 gRun, Modify
Gui, Add, Button, xs+90  w120 yp-6 gRun, OK
Gui, Add, Button, x+15   wp gRun, Insert
Gui, Add, Button, x+15   wp gCancel, Close
Gui, Show, Hide, Catch Image To Text
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
Return

Run:
Critical
k:=A_GuiControl
if IsLabel(k)
  Goto, %k%
Return

Modify:
GuiControlGet, Modify,, %A_GuiControl%
Return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
Return

Load:
if !IsObject(cc)
  cc:=[], gc:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nH*nW {
  cc[++k]:=1, c:=cors[k], gc[k]:=(((c>>16)&0xFF)*299
    +((c>>8)&0xFF)*587+(c&0xFF)*114)//1000
  Gosub, SetColor
}
Loop, % cors.left
  Gosub, LeftCut
Loop, % cors.right
  Gosub, RightCut
Loop, % cors.up
  Gosub, UpCut
Loop, % cors.down
  Gosub, DownCut
Return

Color2Two:
GuiControlGet, Similar
GuiControlGet, r,, Edit1
if r=
{
  MsgBox, 4096, Tip
    , `n  Please Select a Color First !  `n, 1
  Return
}
Similar:=Round(Similar/100,2), n:=Floor(255*3*(1-Similar))
color:=r "@" Similar, k:=i:=0
rr:=(r>>16)&0xFF, gg:=(r>>8)&0xFF, bb:=r&0xFF
Loop, % nH*nW {
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
Return

Gray2Two:
GuiControl, Focus, Edit2
GuiControlGet, Threshold,, Edit2
if Threshold=
{
  Loop, 256
    pp[A_Index-1]:=0
  Loop, % nH*nW
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
  GuiControl,, Edit2, %Threshold%
}
color:="*" Threshold, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  if (gc[k]<Threshold+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
Return

gui_del:
cc[k]:="", c:=WindowColor
Gosub, SetColor
Return

LeftCut3:
Loop, 3
  Gosub, LeftCut
Return

LeftCut:
if (left+right>=nW)
  Return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

RightCut3:
Loop, 3
  Gosub, RightCut
Return

RightCut:
if (left+right>=nW)
  Return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

UpCut3:
Loop, 3
  Gosub, UpCut
Return

UpCut:
if (up+down>=nH)
  Return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

DownCut3:
Loop, 3
  Gosub, DownCut
Return

DownCut:
if (up+down>=nH)
  Return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

getwz:
wz=
if bg=
  Return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
Return

Auto:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  Return
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
Return

OK:
Insert:
Exchange:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  Return
}
if A_ThisLabel=Exchange
{
  wz:="", k:=0, bg:=bg="0" ? "_":"0"
  color:=InStr(color,"-") ? StrReplace(color,"-"):"-" color
  Loop, % nH*nW
    if (c:=cc[++k])!=""
    {
      cc[k]:=c="0" ? "_":"0", c:=c="0" ? "White":"Black"
      Gosub, SetColor
    }
  Return
}
Gui, Hide
if A_ThisLabel=Insert
{
  add(towz(color,wz))
  Return
}
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
s:="`nText:=""""    `; You Can Add OCR Text In The <>`n"
  . towz(color,wz) . "`nif ok:=FindText(" px1 "," py1
  . ",150000,150000,0,0,Text)`n"
  . "{`n  CoordMode, Mouse"
  . "`n  X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5"
  . "`n  MouseMove, X+W//2, Y+H//2`n}`n"
if !A_IsCompiled
{
  FileRead, fs, %A_ScriptFullPath%
  fs:=SubStr(fs,fs~="i)\n[;=]+ Copy The")
  fs:=SubStr(fs,1,fs~="i)\n[/*]+ the C")
}
GuiControl, Main:, scr, %s%`n%fs%
s:=wz:=fs:=""
Return

towz(color,wz) {
  SetFormat, IntegerFast, d
  wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
  wz:=InStr(wz,"`n")-1 . "." . bit2base64(wz)
  Return, "`nText.=""|<>" color "$" wz """`n"
}

add(s) {
  global hscr
  s:=RegExReplace("`n" s "`n","\R","`r`n")
  ControlGet, i, CurrentCol,,, ahk_id %hscr%
  if i>1
    ControlSend,, {Home}{Down}, ahk_id %hscr%
  Control, EditPaste, %s%,, ahk_id %hscr%
}


;===== Copy The Following Functions To Your Own Code Just once =====


; Note: parameters of the X,Y is the center of the coordinates,
; and the W,H is the offset distance to the center,
; So the search range is (X-W, Y-H)-->(X+W, Y+H).
; err1 is the character "0" fault-tolerant in percentage.
; err0 is the character "_" fault-tolerant in percentage.
; Text can be a lot of text to find, separated by "|".
; ruturn is a array, contains the X,Y,W,H,OCR results of Each Find.

FindText(x,y,w,h,err1,err0,text)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    Return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h
  if (err1=0 and err0=0)
    err1:=0.05, err0:=0.05
  arr:=[]
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    OCR:="", e1:=err1, e0:=err0
    ; You Can Add OCR Text In The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), OCR:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r2:=""
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or w1>sw or h1>sh or h1<1 or StrLen(v)!=w1*h1)
      Continue
    if PicFind(Scan0,Stride,sx,sy,sw,sh
      ,v,color,w1,h1,rx,ry,e1,e0)
    {
      rx+=x, ry+=y
      arr.Push(rx,ry,w1,h1,OCR)
    }
  }
  SetBatchLines, %bch%
  Return, arr.MaxIndex() ? arr:0
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
  hBM:=DllCall("CreateCompatibleBitmap", Ptr,hDC
    , "int",w, "int",h, Ptr)
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

PicFind(Scan0,Stride,sx,sy,sw,sh,text,color
  , w, h, ByRef rx, ByRef ry, err1, err0)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E583EC408B45200FAF45188B551CC1E20201D08945F"
    . "48B5524B80000000029D0C1E00289C28B451801D08945DCC74"
    . "5F000000000837D08000F85210100008B450CC1E81025FF000"
    . "0008945D88B450CC1E80825FF0000008945D48B450C25FF000"
    . "0008945D0C745F800000000E9DD000000C745FC00000000E9B"
    . "B0000008B45F483C00289C28B451401D00FB6000FB6C08945C"
    . "C8B45F483C00189C28B451401D00FB6000FB6C08945C88B55F"
    . "48B451401D00FB6000FB6C08945C48B45CC2B45D889C28B45C"
    . "C3B45D87E07B801000000EB05B8FFFFFFFF0FAFD08B45C82B4"
    . "5D489C18B45C83B45D47E07B801000000EB05B8FFFFFFFF0FA"
    . "FC18D0C028B45C42B45D089C28B45C43B45D07E07B80100000"
    . "0EB05B8FFFFFFFF0FAFC201C83B45107F0B8B55F08B452C01D"
    . "0C600318345FC018345F4048345F0018B45FC3B45240F8C39F"
    . "FFFFF8345F8018B45DC0145F48B45F83B45280F8C17FFFFFFE"
    . "9A30000008B450C83C00169C0E803000089450CC745F800000"
    . "000EB7FC745FC00000000EB648B45F483C00289C28B451401D"
    . "00FB6000FB6C069D02B0100008B45F483C00189C18B451401C"
    . "80FB6000FB6C069C04B0200008D0C028B55F48B451401D00FB"
    . "6000FB6C06BC07201C83B450C730B8B55F08B452C01D0C6003"
    . "18345FC018345F4048345F0018B45FC3B45247C948345F8018"
    . "B45DC0145F48B45F83B45280F8C75FFFFFFC745E8000000008"
    . "B45E88945EC8B45EC8945F0C745F800000000EB7CC745FC000"
    . "00000EB678B45F08D50018955F089C28B453001D00FB6003C3"
    . "175278B45EC8D50018955EC8D1485000000008B453401C28B4"
    . "5F80FAF452489C18B45FC01C88902EB258B45E88D50018955E"
    . "88D1485000000008B453801C28B45F80FAF452489C18B45FC0"
    . "1C889028345FC018B45FC3B453C7C918345F8018B45F83B454"
    . "00F8C78FFFFFF8B45242B453C83C00189453C8B45282B45408"
    . "3C0018945408B45EC3945E80F4D45E88945DCC745F80000000"
    . "0E9E3000000C745FC00000000E9C70000008B45F80FAF45248"
    . "9C28B45FC01D08945F48B45448945E48B45488945E0C745F00"
    . "0000000EB708B45F03B45EC7D2E8B45F08D1485000000008B4"
    . "53401D08B108B45F401D089C28B452C01D00FB6003C31740A8"
    . "36DE401837DE40078638B45F03B45E87D2E8B45F08D1485000"
    . "000008B453801D08B108B45F401D089C28B452C01D00FB6003"
    . "C30740A836DE001837DE00078308345F0018B45F03B45DC7C8"
    . "88B551C8B45FC01C28B454C89108B55208B45F801C28B45508"
    . "910B801000000EB3B90EB01908345FC018B45FC3B453C0F8C2"
    . "DFFFFFF8345F8018B45F83B45400F8C11FFFFFF8B454CC700F"
    . "FFFFFFF8B4550C700FFFFFFFFB800000000C9C24C0090"
    x64:="554889E54883EC40894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945F48B5548B8000000002"
    . "9D0C1E00289C28B453001D08945DCC745F000000000837D100"
    . "00F85310100008B4518C1E81025FF0000008945D88B4518C1E"
    . "80825FF0000008945D48B451825FF0000008945D0C745F8000"
    . "00000E9ED000000C745FC00000000E9CB0000008B45F483C00"
    . "24863D0488B45284801D00FB6000FB6C08945CC8B45F483C00"
    . "14863D0488B45284801D00FB6000FB6C08945C88B45F44863D"
    . "0488B45284801D00FB6000FB6C08945C48B45CC2B45D889C28"
    . "B45CC3B45D87E07B801000000EB05B8FFFFFFFF0FAFD08B45C"
    . "82B45D489C18B45C83B45D47E07B801000000EB05B8FFFFFFF"
    . "F0FAFC18D0C028B45C42B45D089C28B45C43B45D07E07B8010"
    . "00000EB05B8FFFFFFFF0FAFC201C83B45207F108B45F04863D"
    . "0488B45584801D0C600318345FC018345F4048345F0018B45F"
    . "C3B45480F8C29FFFFFF8345F8018B45DC0145F48B45F83B455"
    . "00F8C07FFFFFFE9B60000008B451883C00169C0E8030000894"
    . "518C745F800000000E98F000000C745FC00000000EB748B45F"
    . "483C0024863D0488B45284801D00FB6000FB6C069D02B01000"
    . "08B45F483C0014863C8488B45284801C80FB6000FB6C069C04"
    . "B0200008D0C028B45F44863D0488B45284801D00FB6000FB6C"
    . "06BC07201C83B451873108B45F04863D0488B45584801D0C60"
    . "0318345FC018345F4048345F0018B45FC3B45487C848345F80"
    . "18B45DC0145F48B45F83B45500F8C65FFFFFFC745E80000000"
    . "08B45E88945EC8B45EC8945F0C745F800000000E989000000C"
    . "745FC00000000EB748B45F08D50018955F04863D0488B45604"
    . "801D00FB6003C31752C8B45EC8D50018955EC4898488D14850"
    . "0000000488B45684801C28B45F80FAF454889C18B45FC01C88"
    . "902EB2A8B45E88D50018955E84898488D148500000000488B4"
    . "5704801C28B45F80FAF454889C18B45FC01C889028345FC018"
    . "B45FC3B45787C848345F8018B45F83B85800000000F8C68FFF"
    . "FFF8B45482B457883C0018945788B45502B858000000083C00"
    . "18985800000008B45EC3945E80F4D45E88945DCC745F800000"
    . "000E908010000C745FC00000000E9EC0000008B45F80FAF454"
    . "889C28B45FC01D08945F48B85880000008945E48B859000000"
    . "08945E0C745F000000000E9800000008B45F03B45EC7D368B4"
    . "5F04898488D148500000000488B45684801D08B108B45F401D"
    . "04863D0488B45584801D00FB6003C31740A836DE401837DE40"
    . "078778B45F03B45E87D368B45F04898488D148500000000488"
    . "B45704801D08B108B45F401D04863D0488B45584801D00FB60"
    . "03C30740A836DE001837DE000783C8345F0018B45F03B45DC0"
    . "F8C74FFFFFF8B55388B45FC01C2488B859800000089108B554"
    . "08B45F801C2488B85A00000008910B801000000EB4690EB019"
    . "08345FC018B45FC3B45780F8C08FFFFFF8345F8018B45F83B8"
    . "5800000000F8CE9FEFFFF488B8598000000C700FFFFFFFF488"
    . "B85A0000000C700FFFFFFFFB8000000004883C4405DC39090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  v:=text
  if InStr(color,"-")
  {
    r:=err1, err1:=err0, err0:=r, v:=StrReplace(v,"1","_")
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
  }
  if err1!=0
    err1:=Round(StrLen(StrReplace(v,"0"))*err1)
  if err0!=0
    err0:=Round(StrLen(StrReplace(v,"1"))*err0)
  mode:=InStr(color,"*") ? 1:0
  color:=RegExReplace(color,"[*\-]") . "@"
  StringSplit, r, color, @
  color:=Round(r1), n:=Round(r2,2)+(!r2)
  text:=v, k:=StrLen(text)*4, n:=Floor(255*3*(1-n))
  VarSetCapacity(ss, sw*sh, Asc("0"))
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(rx, 8, 0), VarSetCapacity(ry, 8, 0)
  Return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "Astr",text, "ptr",&s1, "ptr",&s0
    , "int",w, "int",h, "int",err1, "int",err0
    , "int*",rx, "int*",ry)
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2)
      , code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}

base64tobit(s) {
  ListLines, Off
  s:=RegExReplace(s,"\s+")
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
  ListLines, On
  Return, s
}

bit2base64(s) {
  ListLines, Off
  s:=RegExReplace(s,"\s+")
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
  Return, s
}


/****** the C source code of machine code ******

int __attribute__((__stdcall__)) findstr(int mode
  , unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int w, int h, int err1, int err0
  , int * rx, int * ry)
{
  int x, y, o=sy*Stride+sx*4, j=Stride-4*sw, i=0;
  int r, g, b, rr, gg, bb, len1, len0, e1, e0;

  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]; g=Bmp[1+o]; b=Bmp[o];
        if ((r-rr)*((r>rr)*2-1)+(g-gg)*((g>gg)*2-1)
          +(b-bb)*((b>bb)*2-1)<=n)
            ss[i]='1';
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

  i=len1=len0=0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (text[i++]=='1')
        s1[len1++]=y*sw+x;
      else
        s0[len0++]=y*sw+x;
    }
  }

  w=sw-w+1; h=sh-h+1;
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
      rx[0]=sx+x; ry[0]=sy+y;
      return 1;
      NoMatch:
      continue;
    }
  }
  rx[0]=-1; ry[0]=-1;
  return 0;
}

*/


;================= The End =================

;