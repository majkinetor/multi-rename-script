; Title:	HLink
;			Custom HyperLink control
;:
; Created by majkinetor

;----------------------------------------------------------------------------------------------
; Function:		Add
;				Creates hyperlink control
;
; Parameters: 	
;				hGui	- Handle of the parent GUI
;				x,y,w,h - Size & position
;				handler	- Subroutine that will be launched when HyperLink is launched.
;						  HLink_link, HLink_text and HLink_hwnd will be set.
;				txt		- Text of the control. Links is specified as <a> HTML tag.
;
; Notes:		
;				o	Controls have ID's internaly. This is used to recgonised control notfications messages
;					ID's for HLink control start from 5701 (the first one you created will have this ID) and
;					are incremented by 1 for each new HLink control you create
;
;				o	Message monitoring: WM_NOTIFY
;
; Example:
;>		hLink1 := HLink_Add(hGui, 10, 10, 200, 20, "OnHLink", "Click <a href=""http://www.Google.com"">here</a> to go to Google")
;>
;>		OnHLink:
;>			MsgBox Clicked: %HLink_text%`nLink:  %HLink_link% 			
;>		return
;
HLink_Add(hGui, x, y, w, h, handler, txt="<a>HLink Control</a>"){
	local hwnd, WM_NOTIFY
	static ICC_LINK_CLASS=0x8000, WS_CHILD=0x40000000, WS_VISIBLE=0x10000000, WS_TABSTOP=0x10000
	static init=0, id = 5701

	if !init++ 
	  API_InitCommonControlsEx(ICC_LINK_CLASS), OnMessage(WM_NOTIFY := 0x4E, "HLink_OnNotify")

	id++
	hWnd := DllCall("CreateWindowEx"
				  ,"Uint", 0
				  ,"str",  "SysLink"
				  ,"str",  txt
				  ,"Uint", WS_CHILD | WS_VISIBLE | WS_TABSTOP
				  ,"int",  x, "int", y, "int", w, "int", h
				  ,"Uint", hGui
				  ,"Uint", id
				  ,"Uint", 0
				  ,"Uint", 0, "Uint")

	if IsLabel(handler)
		HLink_aHandler_%hwnd% := handler		
	return hWnd
}

;-------------------------------------------------------------------------------------------------------------
HLink_OnNotify(wparam, lparam){
    local hwnd, idCtrl, code, txt, out, out1, out2
   
	hwnd   :=  HLink_DecodeInteger(lparam)
    idCtrl :=  HLink_DecodeInteger(lparam+4)
    code   :=  HLink_DecodeInteger(lparam+8)

    if !(idCtrl >5701 and idCtrl < 5799)
       return

    ControlGetText, txt, ,ahk_id %hwnd%
    RegExmatch(txt, "\Q<a href=""\E(.+?)"">(.+?)</a", out)
   
	if (code = 4294967294) or (code = 4294967292) {   ;"click"  or "return"
		HLink_link := out1, 	HLink_text := out2,   	HLink_hwnd := hwnd
		GoSub % HLink_aHandler_%hwnd%
	}
}

;-------------------------------------------------------------------------------------------------------------
API_InitCommonControlsEx( flags ){
   VarSetCapacity(S, 8), NumPut(8, S, 0), NumPut(flags, S, 4) 
   return DllCall("comctl32.dll\InitCommonControlsEx", "uint", &S)
}

;-------------------------------------------------------------------------------------------------------------
HLink_DecodeInteger(ptr){
   Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
}



;-------------------------------------------------------------------------------------------------------------
HLink_About(){
	static ver=1.0
	
	msg := "HLink  " ver "`n"
		. "Created by majkinetor`n`n"
		. "See http://www.autohotkey.com/forum/topic19508.html"
	
	return msg
}

;-------------------------------------------------------------------------------------------------------------
;About:
;		o By majkinetor. See http://www.autohotkey.com/forum/topic19508.html
;		o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.