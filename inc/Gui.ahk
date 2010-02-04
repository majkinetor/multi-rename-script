GuiCreate(){
	local tf, tw, th, header, footer

	Gui, +LastFound +Resize +MinSize%gGuiWidth%x300
	hGui := WinExist()
	Win_SetIcon(hGui, "res\icon.ico", 1)

	Gui, Margin, , 5

	header := th := 60, footer := tf := 30					;header, footer
	
  ;header
	Gui, Add, GroupBox ,section x5 w305 h50					;mask
	Gui, Add, Text, xs+5 ys, &File name mask
	Gui, Add, Edit, w200 h25 y+5 gOnProcChange veMask, [N]

	Gui, Add, Text, x+10 ys, E&xt mask
	Gui, Add, Edit, xp y+5 h25 w70 gOnProcChange veExt, [E]

	Gui, Font, , Webdings
	Gui, Add, Button, HWNDhBtnMask vbtnMask gOnComboXButton x+0 h25 w15 0x8000, 6
	Gui, Font,

	Gui, Add, GroupBox ,section x+20 ys w222 h50			;search & replace
	Gui, Add, Text, xs+5 ys, Searc&h  &&  Replace
	Gui, Add, Edit, h25 xp  y+5 w95 gOnProcChange veSearch, 
	Gui, Add, Edit, h25 x+5  yp w95 gOnProcChange veReplace, 
	
	Gui, Font, , Webdings
	Gui, Add, Button, HWNDhBtnSR vbtnSR gOnComboXButton x+0 yp h25 w15 0x8000, 6
	Gui, Font,

	Gui, Add, CheckBox, x+10 ym+2 gOnProcChange vcbRE, &RE
	
	Gui, Add, GroupBox ,section x+15 ys w0 h50				;case
	Gui, Add, Text, xs+5 ys, &Case
	Gui, Add, DropDownList, xp r5 y+5 w165 gOnProcChange AltSubmit vddCase, Unchanged||First of each word uppercase|First letter uppercase|All lowercase|All uppercase

  ;expansion
	tw := gGuiWidth // 2 -5 
	Gui, Font, , Webdings
	Gui, Add, Button, vbtnExpand HWNDhbtnExpand x%tw% y+3 h12 w15 g_OnButton, 6
	Gui, Font, ,

	Gui, Add, Tab ,section x5 w0 h0 y+0 vtabExpand, expand0|expand1
	Gui, Tab, 2
	GuiCreateExpansion()
	Gui, Tab

  ;list
	Gui, Font, %cfg_FontStyle%, %cfg_FontFace%
	th := gGuiHeight - header - footer, 	tw  := gGuiWidth - 10
	Gui, Add, ListView, +0x4000000 xs y%header% w%tw% h%th% vlvFiles HWNDhlvFiles AltSubmit gOnListView, Old Name .|New Name|Path .|ProcId|Error
	LV_ModifyCol(4, 0)
	Gui, Font, , 

  ;footer
	Gui, Add, GroupBox, section h0
	Gui, Add, Button, 0x8000 xs ys w80 h20  g_OnButton vbtnStart HWNDhbtnStart, &Start
	Gui, Add, Button, 0x8000 yp x+5 w80 h20 g_OnButton vbtnUndo HWNDhbtnUndo, &Undo
	th := gGuiWidth - 340		
	Gui, Font, ,Webdings
	Gui, Add, Button, 0x8000 h20 xm+200 yp  h20 g_OnButton vbtnReload HWNDhbtnReload, q
	Gui, Font, ,
	Gui, Add, Button, 0x8000 h20 x+10 yp h20 g_OnButton HWNDhbtnResult vbtnResult, Result &List
	Gui, Add, Button, 0x8000 h20 x+30 yp h20 g_OnButton HWNDhbtnInEditor vbtnInEditor, Preview in &Editor

	Gui, Font,,	Verdana
	Gui, Add, Text, 0x8000 h20 x+70 w150 yp+4 h20  HWNDhStatus vtxtStatus,
	Gui, Add, Progress, 0x8000 h20 xp w150 yp-4 h20 border vProgress hidden

  ;combos
	Gui, Add, ListView, vcxMask HWNDhcxMask xm ym+40 w295 r10  -Hdr -Multi altsubmit, FN|Ext
	ComboX_Set( hcxMask, "click esc enter space " hBtnMask+0, "OnComboX" ), LV_ModifyCol(1, 205), LV_ModifyCol(2, 50)

	Gui, Add, ListView, vcxSR HWNDhcxSR xm+320 ym+40 w210 r10 -Hdr -Multi altsubmit, Search|Replace
	ComboX_Set( hcxSR, "click esc enter space " hBtnSR+0, "OnComboX"), LV_ModifyCol(1, 100), LV_ModifyCol(2, 90)

	Gui, ListView, lvFiles
	Gui, Submit, NoHide

  ;hyperlinks
	hlink := HLink_Add(hGui, gGuiWidth - 20,  gGuiHeight - 22,  30, 18, "OnHLink", "<a href=""?"">?</a>" )
}

GuiAttach() {
	global 

  	Attach(hlvFiles,	"w h")
	Attach(hbtnExpand,	"x.5")
	Attach(hbtnStart,	"y")
	Attach(hbtnUndo,	"y")
	Attach(hbtnReload,	"y")
	Attach(hbtnResult,	"y")
	Attach(hbtnInEditor,"y")
	Attach(hStatus,		"y")
	Attach(hlink,		"x y")
}

;-------------------------------------------------------------------------------------
GuiCreateExpansion() {
	global

	Gui, Font,,Verdana
	Gui, Add, Button, xs+5  0x8000 h25 w90 g_OnExpButton vbExpFileName, File &name
	Gui, Add, Button, x+5   0x8000 h25 w90 g_OnExpButton vbExpRange,	R&ange
	Gui, Add, Button, x+5   0x8000 h25 w90 g_OnExpButton vbExpCounter,	C&ounter
	Gui, Add, Button, x+5   0x8000 h25 w90 g_OnExpButton vbExpDateTime, &Date && Time
	Gui, Add, Button, x+5   0x8000 h25 w90 g_OnExpButton vbExpPlugins,	&Plugins
	Gui, Add, Button, x+5   0x8000 h25 w90 g_OnExpButton vbExpCase,		aA

	Gui, Add, ComboBox, x+10 yp w200 HWNDhddPresets vddPresets g_OnPreset sort,

;	Gui, Add, Button, x+2 hp 0x8000 g_OnPresetSave,save
}

;-------------------------------------------------------------------------------------

GuiExpand() {

	local y, h, d
	static size=45

	ifEqual, cfg_Expand, , SetEnv, cfg_Expand, 0
	cfg_Expand := !cfg_Expand, d := cfg_Expand ? 1 : -1

	GuiControl, ChooseString, tabExpand, expand%cfg_Expand%

	ControlGetPos,,y,,h, ,ahk_id %hlvFiles%
	GuiControl,, btnExpand, % 6-cfg_Expand

	y += size*d, h -= size*d
	ControlMove, ,,y, ,h, ahk_id %hlvFiles%
	ControlMove, ,,y-8,,, ahk_id %hbtnExpand%

	Attach()
}


;-------------------------------------------------------------------------------------
GuiInit() {
	local lw
	static LVM_GETCOUNTPERPAGE=0x1028

	Gui, ListView, lvFiles

 ;set up main list view
 	ControlGetPos, , , lw, ,,ahk_id %hlvFiles% 
	LV_ModifyCol(1, lw//2), LV_ModifyCol(2, lw//2 " NoSort"), LV_ModifyCol(3, 200),  LV_ModifyCol(4, "NoSort")
	if cfg_HideHScroll
		HideHScroll( hlvFiles )

 ;determine page
	SendMessage, LVM_GETCOUNTPERPAGE, 0, 0, , ahk_id %hlvFiles%
	gLvPage := ErrorLevel

 ;set up combos
	MRU_Load("FM"), MRU_Load("SR"), Preset_Load()

	if (cfg_Expand)
		cfg_Expand := 0, GuiExpand()

 ;add files to the list or announce that there is no cmd line
	if (%0% > 1)
		 DoLoad()
	else LV_ADD(), LV_ADD("", "        No cmd line !"), 	LV_Add("", "        Drag & Drop Files here")	

  ;subclass main list view to set custom scroll handlers (for preview, key up/down/pgup/pgdown)
	if !Win_SubClass(hlvFiles, "LvWindowProc") {
		MsgBox, 16, %gTitle%, Initialisation failed.`n`nTerminating program.
		ExitApp
	}
}

;-------------------------------------------------------------------------------------
GuiExit() {
	local p
	Gui, Submit

	Ini_ReplaceSection(gConfig, "MRUfm", inis_MRUfm )						;save MRUs
	Ini_ReplaceSection(gConfig, "MRUsr", inis_MRUsr )

	IniWrite, %cfg_Expand%, %gConfig%, Config, Expand						;save expansion

	p := eMask ">" eExt ">" eSearch ">" eReplace ">" cbRE  ">" ddCase 		;save last edit
	IniWrite, %p%, %gConfig%, Config, LastEdit
}

;-------------------------------------------------------------------------------------
GuiEscape:
GuiClose:
	if (gWorking)
		return 

	GuiExit()
	ExitApp
return

;-------------------------------------------------------------------------------------
; Function: GuiSetIcon
;			Set the gui title icon
GuiSetIcon() {
	hIcon := DllCall("LoadImage", "Uint", 0, "str", "res\Icon.ico"
					 ,"uint", 1, "int", 16, "int", 16, "uint", 0x10)	 ; IMAGE_ICON,  LR_LOADFROMFILE

	Gui +LastFound
	SendMessage, 0x80, 0, hIcon		; 0x80 is WM_SETICON; and 1 means ICON_BIG (vs. 0 for ICON_SMALL).
}

;-------------------------------------------------------------------------------------
; Function: HideHScroll
;			Hide horizontal scroll bar of the list view
HideHScroll( hScroll ){
	local h, lvgWidth, lvgHeight, hReg

	SysGet, h, 21	
	
	ControlGetPos, ,,lvgWidth, lvgHeight,, ahk_id %hScroll%
	hReg := DllCall("CreateRectRgn", "uint", 0, "uint", 0, "uint", lvgWidth, "uint", lvgHeight-h-3)
	DllCall("SetWindowRgn", "uint", hScroll, "uint", hReg, "uint", 0)
}

;-------------------------------------------------------------------------------------
; Function: Status
;			Set up status bar (txtStatus)
; 
; Parameters:
;			str		- If empty, status will be set to number of file in the list, otherwise to str
;
Status(str="") {
	local i

	Gui, ListView, lvFiles
	if (str = "") {
		i := LV_GetCount()
		i .= " " (i=1 ? "file" : "files")
		GuiControl, , txtStatus,  %i% in the list
	} else GuiControl, , txtStatus, %str%
}

;-------------------------------------------------------------------------------------
; Function: Progress
;			Set up progress bar or hide it
;
Progress(show=true) {
	local i
	static i

	if (show) {
		i := LV_GetCount()

		if (gCmdPreset != "") {		  ;if run  on cmd line, set up progress here;
			Progress, R1-%i% FM8 FW0 W400,, %gCmdPreset%, %gTitle%, Courier
			return
		}

		GuiControl, +range1-%i%, Progress
  		GuiControl,Show,Progress
		GuiControl,Hide,txtStatus
		GuiControl,,Progress, 0
	} else {
		Progress, off					;this is for cmd line 
		GuiControl,Hide,Progress
		GuiControl,Show,txtStatus
		Status()
	}
}
;-------------------------------------------------------------------------------------
; Function: Progress_Inc
;			Increment progress bar by 1. This is used as MRS have 2 different progresss bar
;			depending on command line. If MRS is run on cmd line, it doesn't display GUI but only
;			progress which is handled differently then in gui progress bar.
;
Progress_Inc(){
		global
		static cmdprog=0

		if (gCmdPreset != "") 
				Progress, % cmdprog++
		else	GuiControl,,Progress, +1
}

;-------------------------------------------------------------------------------------
; Function: LvWindowProc
;			Subclassing procedure for list view to override scrolling and mouse wheel
;
LvWindowProc(Hwnd, UMsg, WParam, LParam){ 		
	static adrCallWindowProc

	if !adrCallWindowProc
		adrCallWindowProc := DllCall("GetProcAddress", "Uint", DllCall("GetModuleHandle", "str", "user32"), a() "str", "CallWindowProcA")	;it works OK with A in both versions.

	if (uMsg = 277) || (uMsg = 522)		;WM_VSCROLL, WM_MOUSEWHEEL
		SetTimer, DelayedPreview, -10		  ;spam protection: Preview() alone here tends to block computer, burning CPU, on scrolling, randomly.

    return DllCall(adrCallWindowProc, "UInt", A_EventInfo, "UInt", Hwnd, "UInt", UMsg, "UInt", WParam, "UInt", LParam, "Uint") 
}