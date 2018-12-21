
Goto, _User_Start
_User_Play:
i:=i

ExitApp


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


