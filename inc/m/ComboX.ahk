; Title:	ComboX
;			Impose combobox behavior on arbitrary control
;:
; Created by majkinetor

;----------------------------------------------------------------------------
; Function:	ComboX
;			Initialises control as ComboX control
; 
; Parameters:
;			hCombo	- handle of the control which is to get combobox behavior
;
ComboX( hCombo ) {
	DllCall("SetWindowPos", "uint", hCombo, "uint", 0,   "uint", 0, "uint", 0, "uint", 0, "uint", 0,    "uint", 3)
	ComboX_Hide( hCombo )
    ComboX_SetWndProc(hCombo)
}

;----------------------------------------------------------------------------
; Function:	Show
;			Show ComboX control. Sets ComboX_Active to currently shown control.
; 
; Parameters:
;			hCombo	- handle of the combox control to be shown
;
ComboX_Show( hCombo ) {
	global ComboX_Active

	DllCall("ShowWindow", "uint", hCombo, "uint", 5)	;to avoid SetWindDelay config
	Sleep 20

 	ControlFocus, ,ahk_id %hCombo%
	Sleep 20

	ComboX_Redraw( hCombo )
	ComboX_Active := hCombo
}

;----------------------------------------------------------------------------
; Function:	Hide
;			Hide ComboX control 
; 
; Parameters:
;			hCombo	- handle of the combox control to be hidden
;
ComboX_Hide( hCombo ) {
	DllCall("ShowWindow", "uint", hCombo, "uint", 0) 
	ComboX_Active := 0
}

;----------------------------------------------------------------------------
ComboX_setWndProc(hCtrl) {
	static cnt=-1, proc

	if (cnt=-1)
		VarSetCapacity(proc, 40)
	
	cnt++
	if (cnt > 10){
		msgBox Too many combos
		return
	}

	newProcAddr := RegisterCallback("ComboX_WndProc", "", 4, &proc + cnt*4)
    old := DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", newProcAddr, "UInt")
	NumPut(old, &proc+cnt*4)
}


ComboX_wndProc(hwnd, uMsg, wParam, lParam){ 
	global ComboX_Active

	res := DllCall("CallWindowProcA", "UInt", NumGet(A_EventInfo+0), "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam) 
	if (uMsg = 8)
		ComboX_Hide(hwnd), ComboX_Active := "" 
	return res 
}

ComboX_redraw( handle ) {
	static RDW_ALLCHILDREN:=0x80, RDW_ERASE:=0x4, RDW_ERASENOW:=0x200, RDW_FRAME:=0x400, RDW_INTERNALPAINT:=0x2, RDW_INVALIDATE:=0x1, RDW_NOCHILDREN:=0x40, RDW_NOERASE:=0x20, RDW_NOFRAME:=0x800, RDW_NOINTERNALPAINT:=0x10, RDW_UPDATENOW:=0x100, RDW_VALIDATE:=0x8
	return DllCall("RedrawWindow", "uint", handle, "uint", 0, "uint", 0, "uint"
		      ,RDW_INVALIDATE | RDW_ERASE | RDW_FRAME | RDW_ERASENOW | RDW_UPDATENOW | RDW_ALLCHILDREN)
}

ComboX_About(v=""){
	static ver=1.01
	
	msg := "ComboX  " ver "`n"
		. "Created by majkinetor`n`n"
		. "See http://www.autohotkey.com/forum/topic22390.html"
	
	return msg
}