#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon

weblogicpass = temp
weblogicpass := 
if FileExist("C:\tmp\AppsKeyAHK\transfer.txt")
{
	FileRead weblogicpass, C:\tmp\AppsKeyAHK\transfer.txt
	FileDelete C:\tmp\AppsKeyAHK\transfer.txt
}

MonitorSqOut()

Menu MaximoMsgRe, Add, &Payroll History make sql for history, MaxMenu
Menu MaximoMsgRe, Add, &Sum of Invoices BMXAA1993/1981E, MaxMenu
Menu MaximoMsgRe, Add, &No value for po siteid BMXAA7736E, MaxMenu
Menu MaximoMsgRe, Add,
Menu MaximoMsgRe, Add, &Monitor Sqoutfunc, MaxMenu


;====================================================================================================
;This section is likely only to benefit me as it is my environment specific
;*******************************************************
;Domo Stuff Start
Appskey & Q::	
	IgnoreClipboardChange := True
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
		TempText := ClientID "- " ClientFname " " ClientLname " "
		StringReplace,TempText,TempText,`n,,A
		StringReplace,TempText,TempText,`r,,A
		IgnoreClipboardChange := False
		if(IgnoreClipboardChange = False and StrLen(TempText)>5)
			clipboard := TempText
		Send, +{tab}
	}
Return

;Maximo ===
:B0:pr::
	sURL := GetActiveBrowserURL()
	if((A_EndChar == "`n")  and InStr(sURL ,"kdcmaxw0", 0,1))
	{
		Send, {BackSpace}{BackSpace}
		SendInput, Purchase Requisitions
		sleep 100
		send, {Down} {Down} {Enter}
		
	}
return

:B0:po::
	sURL := GetActiveBrowserURL()
	if((A_EndChar == "`n")  and InStr(sURL ,"kdcmaxw0", 0,1))
	{
		Send, {BackSpace}{BackSpace}
		SendInput, Purchase Orders
		sleep 100
		send, {Down} {Down} {Enter}
		
	}
return

:B0:wo::
	sURL := GetActiveBrowserURL()
	if((A_EndChar == "`n")  and InStr(sURL ,"kdcmaxw0", 0,1))
	{
		Send, {BackSpace}{BackSpace}
		SendInput, Work Order Tracking
		sleep 100
		send, {Down} {Down} {Enter}
		
	}
return
:B0:as::
	sURL := GetActiveBrowserURL()
	if((A_EndChar == "`n")  and InStr(sURL ,"kdcmaxw0", 0,1))
	{
		Send, {BackSpace}{BackSpace}
		SendInput, Automation Script
		sleep 100
		send, {Down} {Down} {Enter}
		
	}
return

Appskey & '::
	IgnoreClipboardChange := True
	goSub MaxMenu		
return

AppsKey & M::
IgnoreClipboardChange:=True
	 Menu MaximoMsgRe, Show
Return


AppsKey & `;::
Text:=""    ; You Can Add OCR Text In The <>
Text.="|<>*188$54.00A00000000Q000000zzz000600U1T000900U3S000KU0U6w000jE0UAs000jc0UNs000To0Unc000Hu0Ub8000Hx0V68003nzUVA80020TkXs80020TsXU8003nzwU08000GDyU08000K7zU3s000S3kU2M00001kU2k00000kU3U00000Ezz0000000U"
; Note: parameters of the X,Y is the center of the coordinates,
; and the W,H is the offset distance to the center,
; So the search range is (X-W, Y-H)-->(X+W, Y+H).

if ok:=FindText(3130,381,150000,150000,0,0,Text)
{
	For index, value in ok
		MsgBox % "Item " index " is '" value "'"
	CoordMode, Mouse
	X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
	MouseMove, X+W//2, Y+H//2
	sleep 1000
	MouseMove, X, Y
	SysGet, VirtualWidth, 78
	SysGet, VirtualHeight, 79
	findTopX := X + W 
	findTopY := Y + H 
	;  findx := ((VirtualWidth - findTopX) / 2) + findTopX
	findx := X
	findy := ((VirtualHeight - findTopY) / 2) + findTopY
	findw := (VirtualWidth - findTopX) / 2
	findh := (VirtualHeight - findTopY) / 2
	sleep 1000
	MouseMove, findx,findy
}
	if ok:=FindText(findx,findy,findw,findh,0,0,Text)
	{
		For index, value in ok
			MsgBox % "Item " index " is '" value "'"
	CoordMode, Mouse
	X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
	MouseMove, X+W//2, Y+H//2
	}
;  listvars
;  Msgbox % ok[2].5
return

FindTextAll(x,y,w,h,err1,err0,text){
	done = False
	While !Done{
		if ok := FindText(x,y,w,h,err1,err0,text){
			FoundList[A_Index] := ok
			;  Gui, Show, W%ok.3% H%ok.4% X%ok.1% Y%ok.2%

		}else{
			Done := True
		}
	}
	return FoundList

}
Appskey & u::
Text:=""
Text.="|<>*188$54.00A00000000Q000000zzz000600U1T000900U3S000KU0U6w000jE0UAs000jc0UNs000To0Unc000Hu0Ub8000Hx0V68003nzUVA80020TkXs80020TsXU8003nzwU08000GDyU08000K7zU3s000S3kU2M00001kU2k00000kU3U00000Ezz0000000U"
	done  := False
	Count := 0
	While (!Done){
		;  msgbox, test
		if ok:=FindText(3130,381,150000,150000,0,0,Text){
			Count := Count+1
			FoundList[A_Index] := ok
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4
			Gui, %Count%:New
			Gui, -Caption +AlwaysOnTop
			Gui, color, Teal
			Gui, Show, W%W% H%H% X%X% Y%Y% NA 

		}else{
			Done := True
		}
	}
	loop, Count
		Gui, %A_Index%: Destroy
return


MaxMenu:
	if (A_ThisMenu == "MaximoMsgRe")
		lastMaxAction := A_ThisMenuItemPos
	;  Msgbox, %lastMaxAction%
	IgnoreClipboardChange := True
	if (IgnoreClipboardChange = True)
	{
		If (lastMaxAction = 1)
		{
			WinGetTitle, CurrentTitle, A
			TicketTitle = Message Reprocessing
			If (InStr(CurrentTitle, TicketTitle, 0,1) and IgnoreClipboardChange)
			{
				Send,{Shift Up}{Ctrl Up}
				Send, {Ctrl Down}a{Ctrl Up}
				GetText(TempText)
				TempSiteId :=
				TempWoNum :=
				RegExMatch(TempText,"<SITEID>(.*?)</SITEID>",TempSiteId)
				RegExMatch(TempText,"<REFWO>(.*?)</REFWO>",TempWoNum)
				TempSiteId := TempSiteId1
				TempWoNum := TempWoNum1
				TempText = select rowid, w.* from wostatus w where wonum = '%TempWoNum%' and siteid='%TempSiteId%' order by changedate desc;
				TempText = %TempText%`nselect rowid, w.wonum, w.status, w.historyflag from workorder w where wonum = '%TempWoNum%' and siteid='%TempSiteId%';
				TempText = %TempText%`ncommit;
				IgnoreClipboardChange := False
				if(IgnoreClipboardChange = False)
					clipboard := TempText
			}
			IgnoreClipboardChange := False
		return
		}
		Else if (lastMaxAction = 2)
		{
						IgnoreClipboardChange := True
			;BMXAA1993E - no matching reciept
			;BMXAA1981E - the sum of all invoice quantities
			WinGetTitle, CurrentTitle, A
			TicketTitle = Message Reprocessing
			If (InStr(CurrentTitle, TicketTitle, 0,1) and IgnoreClipboardChange = True)
			{
				Send,{Shift Up}{Ctrl Up}
				Send, {Ctrl Down}a{Ctrl Up}
				GetText(TempText)
				allLineCost := 
				lineCostSum := 0
			    RegExMatch(TempText,"<DOCUMENTTYPE>(.*?)</DOCUMENTTYPE>",TempDocType)
				;Msgbox, %TempDocType1%
				;  if (TempDocType1 <> "CREDIT")
				;  {
				;  	tooltip, DOCTYPE is not credit `n doctype is %TempDocType1%
				;  	settimer, ReSetToolTip, 3000
				;  	IgnoreClipboardChange := False	
				;  	return
				;  }
				Loop, Parse, TempText, `n, `r
					{
						RegExMatch(A_LoopField,"<LINECOST>(.*?)</LINECOST>",TempLineCost)
						allLineCost .= (TempLineCost1 ? "|" : "") . TempLineCost1
						;Msgbox, %TempLineCost1%
						lineCostSum += TempLineCost1
					}
					if (lineCostSum > 0 and TempDocType1 <> "CREDIT")
						{
							Text:=""    ; You Can Add OCR Text In The <>
							Text.="|<CANCEL>*160$71.00000000000C00000000000Q00000000000s00000000001k00000000003U0000000000700000000000C00000000000Q00000000000s00000000001k00000000003U0000000000700000000000C00008000000S0000E000000swwsQU000001l99F90000003VmG3u0000007YYY44000000D99+9c000000QTGQCE000000s00000000001k00000000003U0000000000700000000000D"
							if ok:=FindText(3273,839,150000,150000,0,0,Text)
							{
								CoordMode, Mouse
								X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
								MouseMove, X+W//2, Y+H//2
								MouseClick, left
							}
							tooltip, Positive LineCost Found do not delete`n`ndoctype= %TempDocType1%`n`nLinecost = %lineCostSum%`nAll lines: %allLineCost%`n`n`, %A_LoopField%.
							settimer, ReSetToolTip, 3000
							IgnoreClipboardChange := False	
							return
						}

				; Msgbox, %lineCostSum% and %allLineCost%
			}
			Text:=""    ; You Can Add OCR Text In The <>
			Text.="|<CANCEL>*160$71.00000000000C00000000000Q00000000000s00000000001k00000000003U0000000000700000000000C00000000000Q00000000000s00000000001k00000000003U0000000000700000000000C00008000000S0000E000000swwsQU000001l99F90000003VmG3u0000007YYY44000000D99+9c000000QTGQCE000000s00000000001k00000000003U0000000000700000000000D"
			if ok:=FindText(3273,839,150000,150000,0,0,Text)
			{
				CoordMode, Mouse
				X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
				MouseMove, X+W//2, Y+H//2
				MouseClick, left
			}
			sleep 500
			Text:=""    ; You Can Add OCR Text In The <>
			Text.="|<CHECKBOX>*236$31.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy03zzz01zzzU0zzzk0Tzzs0Dzzw07zzy03zzz01zzzU0zzzk0Tzzs0Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
			if ok:=FindText(2183,838,150000,150000,0,0,Text)
			{
				CoordMode, Mouse
				X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
				MouseMove, X+W//2, Y+H//2
				MouseClick, left
			}
			tooltip, This One Can be Deleted`nDELETE ME`n`nDELETE OKAY`n`ndoctype= %TempDocType1%`n`nLinecost = %lineCostSum%`nAll lines: %allLineCost%
			settimer, ReSetToolTip, 3000
		IgnoreClipboardChange := False			
		return
		}
		Else if (lastMaxAction = 3)
		{
			
			IgnoreClipboardChange := True
			;BMXAA7736E - No value was specified for Purchase Order Site ID for PO
			WinGetTitle, CurrentTitle, A
			TicketTitle = Message Reprocessing
			If (InStr(CurrentTitle, TicketTitle, 0,1) and IgnoreClipboardChange = True)
			{
				;  Text:=""    ; You Can Add OCR Text In The <>
				;  Text.="|<>*189$41.000000000000000001U0000070000TzzU000U1T000106w00020Pk00041b000086S0000ENo0000Ubc00012AE00024kU0004T100008s20000E040000U08000107k000209U00040K000080s0000TzU0000000000000001"
				;  if ok:=FindText(3112,380,150000,150000,0,0,Text)
				;  {
				;  CoordMode, Mouse
				;  X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
				;  MouseMove, X+W//2, Y+H//2
				;  MouseClick, left
				;  }
				;  sleep 200
				Send,{Shift Up}{Ctrl Up}
				Send, {Ctrl Down}a{Ctrl Up}
				GetText(TempText)
				StringReplace, TempText, Temptext,</INVOICELINE>,&,A
				RegExMatch(TempText,"<PONUM>(.*?)</PONUM>",FirstPoNum)
				TempOut := 
				Loop, Parse, TempText, &
				{ ;one loop for each invoice line line.
					found:= False
					IsvalidInvoice := False
					Loop, Parse, A_LoopField, `n, `r
					{
						RegExMatch(A_LoopField,"<OA_IFACETIMESTAMP>(.*?)</OA_IFACETIMESTAMP>",validInvoiceCheck)
						if(validInvoiceCheck){
							IsvalidInvoice := True
						}
						RegExMatch(A_LoopField,"<PONUM>(.*?)</PONUM>",PonumFound)
						if (PonumFound)
						{
							found := True
						}
					}
					if (found)
					{
						TempOut .= A_LoopField . "&"
						continue
					}
					if (IsvalidInvoice)
						TempOut .= A_LoopField . FirstPoNum . "`n&"
					else
						TempOut .= A_LoopField
				}
				StringReplace, TempOut, TempOut,&,</INVOICELINE>,A
				clipboard = %tempout%
			}
			;  tooltip, The results are on clipboard. Process them?
			;  settimer, ReSetToolTip, 3000
			PutText(TempOut)
			Text:=""    ; You Can Add OCR Text In The <>
			Text.="|<>*145$40.y000002A000008rC77DDXNAaYYbt4G3vXc4F8833UFAaYYa13Vllls"
			if ok:=FindText(2949,865,150000,150000,0,0,Text)
			{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, OCR:=ok.5
			MouseMove, X+W//2, Y+H//2
			MouseClick, left
			}
		IgnoreClipboardChange := False			
		return
		} else if (lastMaxAction = 5)
		{
			MonitorSqOut()
			return
		}
	}
	IgnoreClipboardChange := False
return


MonitorSqOut() {
	global weblogicpass
	username = maxadmin
    if (weblogicpass == "")
		weblogicpass := SafeInput("Enter Weblogic Password", "maxadmin pass:")
	wb := ComObjCreate("{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}") ; create a InternetExplorerMedium instance from https://autohotkey.com/boards/viewtopic.php?t=21015
	;  wb.Visible := True
	wb.Navigate("https://pkdcmaxw01.westfrasertimber.ca:7002/console/console.portal?_nfpb=true&_pageLabel=JMSQueueMonitorBook&handle=com.bea.console.handles.JMXHandle%28%22com.bea%3AName%3Dsqout%2CType%3Dweblogic.j2ee.descriptor.wl.QueueBean%2CParent%3D%5Bmaximodomain%5D%2FJMSSystemResources%5Buijmsmodule%5D%2CPath%3DJMSResource%5Buijmsmodule%5D%2FQueues%5Bsqout%5D%22%29")
	ComWait(wb)
	wb.document.getElementByID("j_username").value := username
	wb.document.getElementByID("j_password").value := weblogicpass
	wb.document.forms[0].submit
	ComWait(wb)
	Name1 := wb.document.getElementByID("Name1").innerText
	MessagesCurrentCount1 := wb.document.getElementByID("MessagesCurrentCount1").innerText
	MessagesPendingCount1 := wb.document.getElementByID("MessagesPendingCount1").innerText
	MessagesReceivedCount1 := wb.document.getElementByID("MessagesReceivedCount1").innerText
	ConsumersCurrentCount1 := wb.document.getElementByID("ConsumersCurrentCount1").innerText
	ConsumersHighCount1 := wb.document.getElementByID("ConsumersHighCount1").innerText
	ConsumersTotalCount1 := wb.document.getElementByID("ConsumersTotalCount1").innerText
	MessagesHighCount1 := wb.document.getElementByID("MessagesHighCount1").innerText
	wb.quit()
	FormatTime, TimeString,, dddd MMMM d, yyyy hh:mm:ss tt
line =
	(
SqOutQueue infor at %TimeString%
Name1 =  %Name1%
MessagesCurrentCount1 = %MessagesCurrentCount1%
MessagesPendingCount1 = %MessagesPendingCount1%
MessagesReceivedCount1 = %MessagesReceivedCount1%
ConsumersCurrentCount1 = %ConsumersCurrentCount1%
ConsumersHighCount1 = %ConsumersHighCount1%
ConsumersTotalCount1 = %ConsumersTotalCount1%
MessagesHighCount1 = %MessagesHighCount1% `n
	)
	SetTimer, MonitorSqOut, Off
	FileAppend %Line%, C:\tmp\AppsKeyAHK\SqOutQueueHist.txt
	messageHistory := Tail(216, "C:\tmp\AppsKeyAHK\SqOutQueueHist.txt") ;216 is 2 hours worth of messages at 5 mins each
	if(MessagesCurrentCount1 <> "")
	{
		SetTimer, MonitorSqOut, % 5 * 1000 * 60
		; r MsgBox, Reloaded monitor
	}
	if (MessagesCurrentCount1 >= 20 and MessagesCurrentCount1 < 100 )
	{
		tooltip, Message In SqOutQueue is at %MessagesCurrentCount1%`n`n%line%
		SetTimer, ReSetToolTip, 4000
	}
	if (MessagesCurrentCount1 >= 100)
	{
		SendEmail("me", "Maximo WebLogic SqOut Queue Stuck?", "This Is An Automated Message`n`nThe Maximo Queue is at: "  MessagesCurrentCount1  "`nIs the queue stuck or processing?`nThe History is below (Newest at bottom)`n`n`"  messageHistory, True )
		tooltip, Message In SqOutQueue is at %MessagesCurrentCount1%`n`n%line%
		SetTimer, ReSetToolTip, 120000
	}


Return
}

;  MsgRepSQout(){
;  	maxpass := SafeInput("Enter Maximo Password", "Maximo pass:")
;  	maxWeb := ComObjCreate("{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}") ; create a InternetExplorerMedium instance from https://autohotkey.com/boards/viewtopic.php?t=21015
;  	maxWeb.Visible := True
;  	;  maxWeb.Navigate("https://pkdcmaxw01.westfrasertimber.ca:7002/DefaultWebApp/")
;  	maxWeb.Navigate("https://pkdcmaxw05.westfrasertimber.ca:7012/maximo/ui/?event=loadapp&value=interror")
;  	ComWait(maxWeb)
;  	maxWeb.document.getElementByID("j_username").value := "DFLETCH"
;  	maxWeb.document.getElementByID("j_password").value := maxpass
;  	maxWeb.document.forms[0].submit()
;  	ComWait(maxWeb)
;  	sleep 1000
;  	ControlSend, Internet Explorer_Server, {Ctrl down}z{Ctrl up}, Message Reprocessing - Internet Explorer
;  	sleep 250
;  	ControlSend, Internet Explorer_Server, {tab}, Message Reprocessing - Internet Explorer
;  	sleep 250
;  	ControlSend, Internet Explorer_Server, sqout, Message Reprocessing - Internet Explorer
;  	sleep 250
;  	ControlSend, Internet Explorer_Server, {enter}, Message Reprocessing - Internet Explorer
;  	;  maxWeb.document.getElementByID("j_username").value := "DFLETCH"
;  	;  maxWeb.document.getElementByID("j_password").value := "maxpass"
;  	;  maxWeb.document.forms[0].submit()
;  	ComWait(maxWeb)
;  }
ComWait(IE) {
While IE.readyState != 4 || IE.document.readyState != "complete" || IE.busy
   Sleep 300
   Sleep 300
}