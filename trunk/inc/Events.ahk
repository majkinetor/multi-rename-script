OnButton( ctrl ) {
	global 

	if ctrl = btnStart
		if gFiles =
			 MsgBox, 16, %gTitle%, Add some files first :)
		else MRU_Set("FM"), MRU_Set("SR"), DoRename()
	else if ctrl = btnResult 
	{
		if !FileExist( gResultList )
			 MsgBox, 16, %gTitle%, Result List does not exist
		else Run, %gResultList%
	}
	else if ctrl = btnReload
		DoReload()
	else if ctrl = btnUndo
		DoUndo()
	else if ctrl = btnInEditor
		if gFiles =
			 MsgBox, 16, %gTitle%, Add some files first :)
		else ShowMenu("[EditorPreview]`nNew name`nNew path`nOld path -> new name", "EditorPreview")
	else if ctrl = btnExpand
		GuiExpand()
}

EditorPreview:
	DoEditorPreview(A_ThisMenuItemPos)
return

;-------------------------------------------------------------------------------------
OnListView:
	if IsLabel("OnListView_" A_GuiEvent)
		 goto OnListView_%A_GuiEvent% 
	return

	OnListView_ColClick:
		Preview()
		return
	OnListView_K:

		if (A_EventInfo = 46)  
			List_DelSeletion()

		if GetKeyState("CTRL") and ((A_EventInfo = 38) or (A_EventInfo=40))		;ctrl up, ctrl down
			List_MoveSelection( A_EventInfo )
		else if A_EventInfo between 33 and 40  ;up down, pgup, pgdwn, home, end
			Preview()
		return
	OnListView_DoubleClick:
		ifEqual, gFiles, ,return
		SelectRange()
		return
return

;-------------------------------------------------------------------------------------
; Function: DelSeletion
;			Delete selected files from the list. Will change procID because order of the files in the list is important.
;
List_DelSeletion(){
	global 	gProcId

	Gui, ListView, lvFiles
	gProcId++

	c := LV_GetNext()	;save the top of the current selection so the new selection can be set up here.
	GuiControl, -Redraw, lvFiles
	Loop {
		s := LV_GetNext()
		IfEqual, s, 0, break
		LV_Delete(s)
	}
	GuiControl, +Redraw, lvFiles
	l:= LV_GetCount(),	LV_Modify( c>l ? l:c , "Select Focus")
	Status(), Preview()		;update status & preview
}			

;-------------------------------------------------------------------------------------
; Function: MoveSelection
;			Move block selection up or down.  Will change procID because order of the files in the list is important.
;
; Parameters:
;			way - Can be 38 or 30 (up, down ascii codes)
;
List_MoveSelection( way ) {
	global 	gProcId, gTitle

	Gui, ListView, lvFiles
	gProcId++

	s := LV_GetNext()					;get start of the selection 
	IfEqual, s, 0, return 
	e := s + LV_GetCount("Selected")-1		;get end of the selection
	if LV_GetNext(e+1) {					;if this is not block selection abort
		 MsgBox, 16, %gTitle%, You can move only block selection.
		 return
	}

	l := LV_GetCount(), cols := LV_GetCount("Column")
	if (way=38) {
		IfEqual, s, 1, return 

		LV_Insert(++e), s--
		loop, %cols% 
			LV_GetText(txt, s, A_Index), LV_Modify( e, "col" A_Index, txt )
		LV_Delete(s)
	} else {
		IfEqual, e, %l%, return 

 		LV_Insert(s), e+=2
		loop, %cols% 
			LV_GetText(txt, e, A_Index), LV_Modify( s, "col" A_Index, txt )
		LV_Delete(e)
	}
	LV_Modify(LV_GetNext(), "Focus")

	SetTimer, DelayedPreview, -100
}

;-------------------------------------------------------------------------------------
SelectRange() {
	local sid
 	Gui, ListView, lvFiles

	sid := LV_GetNext()
	ifEqual, sid, 0, SetEnv, sid, 1

	LV_GetText( gSelected, sid )
	SplitPath, gSelected, ,,, gSelected

	SetTimer, UpdateRange, 30
	InputBox, sid, Select Range, Select range:, , 400, 180, , , , , %gSelected%
	SetTimer, UpdateRange, off	
	if ErrorLevel
		return

	GuiControl, Focus, eMask
	SendPlay, {RAW}%gSelRange%
}

UpdateRange:
	if !WinExist("Select Range")
		return

	ControlGet, #tmp, Selected, , Edit1, Select Range
	If (#tmp="") {
		ControlGet, #tmp, CurrentCol, , Edit1, Select Range
		gSelRange := "[N" #tmp ",]"
	} else	gSelRange := InStr(gSelected, #tmp), gSelRange := "[N" gSelRange "," StrLen(#tmp) "]"

	ControlSetText, Static1, Select range:`n%gSelRange%, Select Range
return

;-------------------------------------------------------------------------------------
OnComboX( Hwnd, Event) {
	global

	if (Event != "select")
		return

	c := Hwnd = hcxMask ? "cxMask" : "cxSR"
	Gui, ListView, %c%
	LV_GetText(txt1, ss := LV_GetNext(), 1), 		LV_GetText(txt2, LV_GetNext(), 2)
	if !ss 
		return

	if c = cxMask
			c1 := "eMask",   c2 := "eExt"
	else 	c1 := "eSearch", c2 := "eReplace"

	ss := GetKeyState("SHIFT"), sa := GetKeyState("ALT"),	norm := !(ss or sa)
	GuiControlGet, hwnd, HWND, %c1%

	if (ss or norm){
		GuiControl, ,%c1%, %txt1%
	 	GuiControl, Focus, %c1%
	}
	
	if (sa or norm){
	  	GuiControl, ,%c2%, %txt2%
		if !norm {
			GuiControl, Focus, %c2%
			GuiControlGet, hwnd, HWND, %c2%
		}
	}

	ControlSend, ,{END}, ahk_id %hwnd%
}

;-------------------------------------------------------------------------------------
; This subroutine is responsible for updating preview. It gives new unique gProcId to the 
; current file name processor, parsees user input and finaly call Preview to update ListView 
; real time results. If user typed in GUI, some of the adequate fields will be in A_GuiControl
; Otherwise, parse everything as subroutine is called by PresetSet function.
OnProcChange:
		Gui, Submit, NoHide
		gProcId++

		if A_GuiControl in eMask,eExt
			 gParseError := ParseMask(eMask, "FN") || ParseMask(eExt, "Ext")
		else if A_GuiControl in eSearch,eReplace
			 ParseSR()
		else gParseError := ParseMask(eMask, "FN") || ParseMask(eExt, "Ext"), ParseSR()
		
		if (gCmdPreset = "")
			Preview()
return			


;-------------------------------------------------------------------------------------
AppMenu:
	if A_ThisMenuItem = About
		About()

	else if A_ThisMenuItem = Register Shell Extension
		 #tmp := Shell_Registred() ? Shell_Unregister() : Shell_Register()

	else Run % ShowMenu_Data(gAppMenu)
return

;-------------------------------------------------------------------------------------
OnComboXButton:
	ComboX_Show( A_GuiControl="btnMask" ? hcxMask : hcxSR )
return

;-------------------------------------------------------------------------------------
OnHLink() {
	global gAppMenu, gDocsFolder

	if (gAppMenu = ""){
		gAppMenu=
		(LTrim
			[AppMenu]
			Settings=<Settings>
			-
			Help=%gDocsFolder%\MRS.html
			Write Plugin=%gDocsFolder%\Plugins.html
			-
			About
			[Settings]
		)
	}
	set := (Shell_Registred() ? "+":"") "Register Shell Extension"
	res := ShowMenu(gAppMenu "`n" set)
	loop, parse, res, `n
		Menu, %A_LoopField%, delete
}
OnHLink:
	OnHLink()
return

;-------------------------------------------------------------------------------------
OnExpButton( ctrl ) {
	global 

 	if ctrl = Plugins
		return ShowMenu(gPlugMenu, "", "_OnPlugin")

	if gMenus =
		FileRead, gMenus, *t res\Menus.ini
	ShowMenu(gMenus, ctrl, "_OnButton2Menu")
}

OnPlugin() {
	local tcPlug, fields, menus, ahkPlugMenu, ahkPlugMain, mnu, h
	
	if InStr(gAhkPlugins, gSelPlug) {
		if IsLabel(gSelPlug "_GetFields") {
			#Res =
			GoSub %gSelPlug%_GetFields
			if (#Res != "") and (#Res != "*") {
				ahkPlugMain := "[ahkFields]`n"
					
				Loop, parse, #Res, `n, `r
				{
					h := InStr(A_LoopField, "|")
					if (h) {
						mnu := SubStr(A_LoopField, 1, h-1)
						ahkPlugMain .=  mnu "=<" mnu ">`n"
						ahkPlugMenu .= "`n[" mnu "]`n" RegExReplace( SubStr(A_LoopField, h+1), "[|]", "`n")
					} else 	ahkPlugMain .= A_LoopField "`n"
				}
				ahkPlugMenu := ahkPlugMain ahkPlugMenu

				menus := ShowMenu(ahkPlugMenu , "", "OnPluginField" )
				goto OnPlugin_Clear
			}
		}
		GuiControl, Focus, eMask
		SendPlay, {Raw}[=%gSelPlug%]
		return
	}

 	tcPlug := Ini_GetVal(gtcPlugins, gSelPlug)						;get plugin path

	h := TCWdx_LoadPlugin(tcPlug)									;load plugin
	fields := TCWdx_GetPluginFields( tcPlug, 2)						;get all fields and create SHOWMENU definition
	TCWdx_UnloadPlugin(h)

	menus := ShowMenu(fields, "", "OnPluginField", "|" )			;show plugin fields as menu and store menus created

OnPlugin_Clear:
	loop, parse, menus, `n, `n										; !!!! doesnt work suddenly
		Menu, %A_LoopField%, delete									;delete created menus  !!!!
}

_OnPlugin:
	gSelPlug := A_ThisMenuItem, OnPlugin()
return


OnPluginField:
	if A_ThisMenu in tcFields,ahkFields								;base fields menu, user didn't choose some of the units
		 #tmp = [=%gSelPlug%.%A_ThisMenuItem%]
	else #tmp = [=%gSelPlug%.%A_ThisMenu%.%A_ThisMenuItem%]			;unit, menu name is field, menu item unit

	GuiControl, Focus, eMask
	SendPlay, {RAW}%#tmp%
return

;-------------------------------------------------------------------------------------
OnButton2Menu(m, i){
	local re, out, out1

	re = (?:^|\R)\[%m%\].+?\Q%i%\E=(.+?)(?:\R|$)
	RegExMatch( gMenus, re, out)

	GuiControl, Focus, eMask
	SendPlay, {Raw}%out1%
}

;-------------------------------------------------------------------------------------
OnShell:
GuiDropFiles: 
	Gui, ListView, lvFiles
	gFiles := A_ThisLabel="OnShell" ? Shell_data : A_GuiEvent

	LV_GetText(txt, 1)								
	if GetKeyState("SHIFT") or (txt="")		;First item can only be empty if there is startup text in the list, or if list is empty. 
		LV_Delete()							; The startup text must also be removed if drag & droping with shift

	DoLoad(), Preview()
return 
;-------------------------------------------------------------------------------------

_OnButton2Menu:
	OnButton2Menu(A_ThisMenu, A_ThisMenuItem)
return

_OnPreset:
	GuiControlGet,#tmp,,ddPresets
	Preset_Set(#tmp)
return 

_OnButton:
	OnButton( A_GuiControl )
return

_OnPresetSave:
	Preset_Save()
return

_OnExpButton:
	OnExpButton(SubStr(A_GuiControl, 5))
return