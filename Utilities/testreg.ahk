appTitle = Show Graphic Clipboard
STM_SETIMAGE = 0x0172
IMAGE_BITMAP = 0
GMEM_MOVEABLE = 2
guiWidth  = 400
guiHeight = 300
titleBarHeight = 24
clientHeight := guiHeight - titleBarHeight

Gui -Caption +Border
Gui Add, Picture,  x0 y%titleBarHeight% vimage gChangeImage, KM64.png
Gui Font, s9 Bold, Tahoma
Gui Margin, 0, 0
Gui Add, Text,  x0 y0 w%GuiWidth% h%titleBarHeight% +0x4	; SS_BLACKRECT
Gui Add, Text,  x0 y0 w%GuiWidth% h%titleBarHeight% cFFFFFF Backgroundtrans +0x200 gGuiMove
		, %A_Space%%A_Space%%appTitle%	; SS_CENTERIMAGE?
Gui Show, w%guiWidth% h%guiHeight%, %appTitle%
Gui +LastFound
Return

GuiMove:
	PostMessage 0xA1, 2, , , A	; WM_NCLBUTTONDOWN
Return

ChangeImage:
	If (DllCall("IsClipboardFormatAvailable", "UInt", 2) = 0)
	{
		MsgBox 16, %appTitle%, No Bitmap Available
		Return
	}
	r := DllCall("OpenClipboard", "UInt", 0)
	If (r = 0)
	{
		MsgBox 16, %appTitle%, OpenClipboard
		Return
	}
	hBitmap := DllCall("GetClipboardData"
			, "UInt", 2)	; CF_BITMAP = 2, CF_DIB = 8
	If (r = 0)
	{
		MsgBox 16, %appTitle%, GetClipboardData
		Goto ClipboardCleanUp
	}
	If (hBitmap = 0)
	{
		MsgBox 16, %appTitle%, No Bitmap
		Goto ClipboardCleanUp
	}
	; Make a copy of this data, because the handle points to data that will disappear on CloseClipboard
	r := DllCall("CopyImage"
			, "UInt", hBitmap
			, "UInt", IMAGE_BITMAP
			, "Int", 0, "Int", 0	; Keep same dimensions
			, "UInt", 0)	; No special flag
	If (r = 0)
	{
		MsgBox 16, %appTitle%, CopyImage
		Goto ClipboardCleanUp
	}
	hBitmap := r
	ReplacePictureImage("Static1", hBitmap)

ClipboardCleanUp:
	DllCall("CloseClipboard")
Return

GuiEscape:
ExitApp

; Given a Picture control (_pictureTitle),
; and a bitmap handle (from clipboard, from GDI operations, etc.),
; tell the Picture to change its image.
; Better than BitBlt, because we don't have to manage WM_PAINT...
; Note that the given _hBitmap no longer belongs to the caller,
; either the Picture owns it, or it is destroyed, for consistent behavior.
ReplacePictureImage(_pictureTitle, _hBitmap)
{
	local hOldBitmap, hCurrentBitmap

	; From info taken from http://www.autohotkey.com/forum/viewtopic.php?t=10091
	; and from the source (in script_gui.cpp).
	; Reset the image of the control before deleting it
	SendMessage STM_SETIMAGE, IMAGE_BITMAP, 0, %_pictureTitle%
	; Handle on the previous bitmamp
	hOldBitmap := ErrorLevel
	If (hOldBitmap != "FAIL" and hOldBitmap > 0)
		; Destroy it
		DllCall("DeleteObject", "UInt", hOldBitmap)
	; Set new image
	SendMessage STM_SETIMAGE, IMAGE_BITMAP, _hBitmap, %_pictureTitle%
	; Get the handle on the bitmap stored by the control
	SendMessage STM_GETIMAGE, IMAGE_BITMAP, 0, %_pictureTitle%
	hCurrentBitmap := ErrorLevel
	; If it is different than the sent one, XP made a copy because image has alpha transparency
	If (hCurrentBitmap != "FAIL" and hCurrentBitmap != _hBitmap)
		; So delete the sent image, to avoid a memory leak
		DllCall("DeleteObject", "UInt", _hBitmap)
}