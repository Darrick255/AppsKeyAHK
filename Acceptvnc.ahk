


SetTimer, findtap, 3000

+Q::
	msgBox, Running
return

findtap:
Text:=""    ; You Can Add OCR Text In The <>

Text.="|<>*149$66.00000000000zzzzzzzzzzzzzzzzzzzzzzJJJJJJJJJJJ00000000000000000000000000000000000000000000000k0002000000k0002000001sxvbrU000019X4IG000001927oG000003x244G0000025X64G0000024xvrXU0000000040000003y004000000000000000JJJJJJJJJJJzzzzzzzzzzzzzzzzzzzzzz00000000000U"

if ok:=FindText(981,626,150000,150000,0,0,Text)
{
  CoordMode, Mouse
  X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
  MouseMove, X+W//2, Y+H//2
  MouseClick, left, , , 2
}
Return



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


