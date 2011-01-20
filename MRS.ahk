#include %A_ScriptDir%
#NoTrayIcon
#SingleInstance, force
#NoEnv
#MaxThreads, 255
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8

	;-- GLOBALS --------------------------
	gTitle		:= "Multi-Rename Script"  
	gVersion	:= "1.5c"
	gGuiHeight	:= 500,  gGuiWidth	:= 800
	gResultList	:= "res\ResultList.txt"
	gPreviewFile:= "res\Preview.txt"
	gConfig		:= "MRS.ini"
	gShellName  := "Add to Multi-Rename Lis&t"
	gShellGuid	:= "{0F60CC03-F4D6-464C-8D59-FD919FF14E26}"
	gDocsFolder	:= "docs"
	;------------------------------------
	
	InitApp(), GuiCreate(), GuiInit(), GuiAttach(), Shell_Init("OnShell")

	if (gCmdPreset != "")
		goto DoCmdRun
	
	Gui, show, h%gGuiHeight% w%gGuiWidth%, %gTitle%
	Win_Recall("< -Min", "", gConfig)
 
	if (cfg_LastEdit != "") && !cfg_NoLastEdit
		 Preset_Set(cfg_LastEdit, false) 
	else Preset_Set("[N]>[E]", false) 
return


;-------------------------------------------------------------------------------------
;If 2 arguments are specified on cmd line - file list & preset - don't show GUI initialy, 
;just rename files showing progress bar and exit imediately if no errors. If errors ocure
;show GUI and continue as if the user started MRS without cmd line
DoCmdRun:
		Preset_Set( gCmdPreset, false )
		OnButton( "btnStart" )	

		if ( LV_GetCount() = 0 )
			ExitApp
		
		gCmdPreset =
		Gui, show, h%gGuiHeight% w%gGuiWidth%, %gTitle%	
return

;-------------------------------------------------------------------------------------
; Initialise plugins, get command line, load configuration, set gui icon
InitApp() {
	global 

	#include inc\Errors
	GuiSetIcon()			;set title icon
	Plugins_Init()			;load plugins

	Ini_LoadSection( gConfig )
	Ini_LoadKeys( "", inis_Config, "", "cfg"), inis_Config := ""

	if (cfg_tcIni != "")
		 cfg_tcIni := FileExist(cfg_tcIni) ? ExpandEnvVar(cfg_tcIni) : cfg_tcIni

	GetCmdLine()

	gtcPlugins := TCWdx_GetPlugins(cfg_tcIni),	gahkPlugins := Plugins_Get()
	if (gtcPlugins = "ERR") 
		gtcPlugins := TCWdx_GetPluginsFromDir("plugins")
	gPlugMenu := "[Plugins]`n" Ini_LoadKeys("", gtcPlugins, "keys") "`n-`n" gahkPlugins
	
	gProcId := 0			;id of the current proc 
}

;-------------------------------------------------------------------------------------
; Function: GetCmdLine
;			Get command line 
GetCmdLine() {
	local file

 	if (%0% < 1)
		return
	
	file       = %1%
	gCmdPreset = %2%

	if (file = "Plugin_Reload")
		return
	if (gCmdPreset = "Plugin_Reload") 			;Plugin module uses last parameter for itself
		gCmdPreset := ""

	if !FileExist( file ) {
		MsgBox, 16, %gTitle%, File doesn't exist:`n`n%file%
	} else, FileRead, gFiles, %file%

	if (*&gCmdPreset = 62){	;">"
		gCmdPreset := Preset_GetDef( SubStr(gCmdPreset, 2) )		
		if (gCmdPreset = "")
			MsgBox 16, %gTitle%, Preset doesn't exist:`n`n%2%
	}
}

;-------------------------------------------------------------------------------------
; Function: Proc
;			Envoke all processors on a file name.
;
; Parameters:
;			fn	- file name
;
; Returns:
;			New file name
;
; Remarks:
;			Processing diagram is as follows:
;
;>				     Fn_Mask 
;>			FN --> /          \  --> SR --> Case --> FN'
;>			       \          /
;>				     Ext_Mask
Proc( fn ) {
	local n, e
	n := ProcMask(fn, "FN"), e := ProcMask(fn, "Ext")
	fn := (e !="") ? n "." e : n
	return ProcCase( ProcSR( fn ), ddCase )
}															  

;-------------------------------------------------------------------------------------
; Function: ProcMask
;			Process file name mask
;
; Parameters:
;			fn	- file name
;			a	- array storing parsed mask, as there are 2 unrelated masks ("FN" or "Ext")
;
; Returns:
;			Processed file name
;
ProcMask( fpath, a ) {
	local fun, res, fe, dir, fn, z := "a" a "_0"			
	local cp, U=5, L=4, F=2, _n=0, case := "_n"				
	
	SplitPath, fpath,,dir, fe, fn
	loop, % %z%
	{
		fun := a%a%_%A_Index%
		if fun in U,L,F,_n
		{	
			GoSub %fun%
			continue
		}

		#1:= a%a%_%A_Index%_1, #2:= a%a%_%A_Index%_2, #3:= a%a%_%A_Index%_3
		#fp := fpath,  #fe := fe,  #fn := fn,  #fd := dir,  #Res :=""		;set always as plugin can change them
		if IsLabel(fun)
			GoSub %fun%

		if (a%a%_%A_Index%_rng1 != "") {
			#fn := #Res, #1:= a%a%_%A_Index%_rng1, #2:= a%a%_%A_Index%_rng2, #3:= a%a%_%A_Index%_rng3
			goSub N
		}

		cp .= #Res
	}
	goSub %case%
	return res

 ;casing switches 
  U:
  L:
  F:
 _n:
	res .= ProcCase(cp, %case%), cp := ""
	case := A_ThisLabel
  return
}

;-------------------------------------------------------------------------------------
; Function: ProcSR
;			Process search & replace
;
; Parameters:
;			fn		- file name
;
; Returns:
;			Processed file name
;
ProcSR( fn ) {
	local res, s,r

	if (cbRE)
		return RegExReplace(fn, aSearch1, aReplace1)

	;check for | for multi replace
	res := fn
	loop, %aSearch0%
	{
		s := aSearch%A_Index%, r :=aReplace%A_Index%
		StringReplace, res, res, %s%, %r%, A
	}

	return res
}

;-------------------------------------------------------------------------------------
; Function: ProcCase
;			Process case 
;
; Parameters:
;			fn		- file name
;			case	- desired case, 2-5 (other numbers will cause fn to be returned unchanged)
; Returns:
;			Processed file name
;
ProcCase( fn, case) {
	if (case=2)						;first of each letter uppercase		F=2
		StringUpper, fn, fn, T
	else if (case=3) {  			;first word uppercase				 3
		StringLower, fn, fn
		c := *&fn
		if c between 97 and 122
			c -=32
		fn := chr(c) SubStr(fn, 2)
	} 
	else if (case=4) 				;lowsercase							L=4
		StringLower, fn, fn
	else if (case=5)				;uppercase							U=5
		StringUpper, fn, fn		

	return fn	
}

;-------------------------------------------------------------------------------------
; Function: ParseMask
;			Parses file or extension mask into array
;
; Parameters:
;			pMask	- mask
;			a		- array used to hold mask data with 0 element pointing to number of functions in the mask 
;					  ("FN"  or "Ext")
; Returns:
;			Postive number if error occured while parsing, otherwise 0 (also sets global gParseMak)
;
; Remarks:
;			Parsing is done using grammar:
;>				Mask    :: Mask_i					(i e No)
;>				Mask_i	:: Fun_i Mask_i-1			(i e No)
;>				Fun		:: [F{params}] | Const
;>				F		:: N | E | C | Y | = | .... 
;>				Const   :: sentence without [ char
;>				params  :: C_param | N_param | plug_param
;>			plug_param  :: plug_name{.plugField{.fieldUnit}}{:N_param}
;
ParseMask( pMask, a ) {
	local i, r, k, c, token, b, param, cnt, fun, fi, ui, re,	z := "a" a "_0",	 out, out1, out2, out3,		rng, rng1, rng2, rng3
	%z% := 0 
	
	StringReplace, pMask, pMask, ]], >]							; replace [ ]] with [ >] for easier parsing 
	loop {
	;extract token
		c := SubStr(pMask, 1, 1), b := 0
		if ( c="[" AND  b := 1)									;b keeps branch that is executed (function=1, constant=0)
			 if ( i := InStr(pMask, "]")) {						;check for ]]
				token := SubStr(pMask, 2, i-2), pMask := SubStr(pMask, i+1)
			 } else return ERR_OPENMASK							;error1 - syntax error
		else if (i := InStr(pMask, "["))
			 	token := SubStr(pMask, 1, i-1), pMask := SubStr(pMask, i)
			 else token := pMask, pMask := ""

    ;fix [[] []]
		if b and ((token = "[") or (token = ">")) {
			b := 0
			if (token=">")
				token := "]"
		}

   ;Parse token (out1,2,3 hold #1 #2 #3)
		cnt := %z% + 1,		a%a%_%cnt%_rng1 := "" ;plugins may have range.
		if !b		;constant function
			a%a%_%cnt% := "_Const",  a%a%_%cnt%_1 := token
		else {
			c := chr(*&token)
			if (c="") {			; [] - empty mask
	  			a%a%_%cnt% := "_Const"
				continue
			}
			
			a%a%_%cnt% := c, param := 1, r := 0
			r := (c = "N")		  ?	RegExMatch(token, "^N\s*(?:(-?\d+)(?:(-|,)?(-?\d+)?)?)?$", out) : r
			r := !r and (c = "E") ? RegExMatch(token, "^E\s*(?:(-?\d+)(?:(-|,)?(-?\d+)?)?)?$", out) : r
			r := !r and (c = "C") ? RegExMatch(token, "^C\s*(\d*)(?:\+(\d*))*(?:\:(\d+))*", out)	: r

		;check plugin
			if (!r and c="=") {
				r := 1

				;check for range
				if k := InStr(token, ":") {
					if RegExMatch(SubStr(token, k+1), "^(?:(-?\d+)(?:(-|,)?(-?\d+)?)?)?$", rng)
						loop, 3
							a%a%_%cnt%_rng%A_Index% := rng%A_Index%
					else return ERR_PLUGRANGE
					token := SubStr(token, 1, k-1)
				}

				k := InStr(token, ".")
				IfEqual, k, 0, SetEnv, k, 1000								;if no dot, just make k large enough to go over end of the token
																									
				fun := SubStr(token, 2, k-2), out3 := SubStr(token, k+1)	;out3 keeps everything after first dot

				;is this AHK plugin ?
				if IsLabel(fun)								
				{
 					 k := InStr(out3, ".")									;if there is unit, there is another dot
	 				 IfEqual, k, 0, SetEnv, k, 100
					 out1 := SubStr(out3, 1, k-1), out2 := SubStr(out3, k+1) ;out1=field, out2=unit
					 if (out3 != "") and IsLabel(fun "_GetFields")			 ;if out3 is not empty check the fields 
					 {
						GoSub, %fun%_GetFields								 ;#Res contains fields here
						if (*&#Res != 42) 			; chr(42) = "*"
						{							; check if fields are valid
							re = `aim)^\Q%out1%\E([|]|\s*$)
							if (out2 != "") 
								re = `aim)^\Q%out1%\E.*?[|]\Q%out2%\E([|]|\s*$)
						
							if !RegExMatch(#Res, re)
								return ERR_PLUGFIELD
						}
					 }
					 a%a%_%cnt% := fun
				} 
				else {	;check for TC plugin
					k := Ini_GetVal(gtcPlugins, fun)	
					IfEqual, k, , return ERR_PLUG

					if !TCWdx_LoadPlugin(k)							;loadlibrary returns the same handle if it is previously loaded
						return ERR_PLUGLOAD							

					TCWdx_GetIndices(k, out3, fi, ui)

					if (fi = "" or ui = "")					
						return ERR_PLUGFIELD						
	
					a%a%_%cnt% := "_TC", out1 := k, out2:= fi, out3 := ui
				}
			}					
 		;check parameterless functions
			if !r and InStr("P,G,Y,M,D,U,L,F", c, true) and token=c
				a%a%_%cnt% := c, param := 0, r:=1

			if !r and InStr("t,h,m,s,n,y", c, true)	 and token=c	;those will have _ as sub prefix (little letters)
				a%a%_%cnt% := "_" c, param := 0, r:=1

		;check for full path fun [d1-d2]
			if !r and (r := RegExMatch(token, "^\s*(?:(-?\d+)(?:(-|,)?(-?\d+)?)?)?$", out))
				if (out1 out2 out3 = "") ; [    ]
			  			a%a%_%cnt% := "_Const", param := 0
				else	a%a%_%cnt% := "_FN"

		;set args - out1, out2, out3
			if r and param
				loop, 3
					a%a%_%cnt%_%A_Index% := out%A_Index%
			
		;no match
			ifEqual r, 0, return ERR_UNKNOWN									;Unknown token
		}
		%z% := cnt
		IfEqual, pMask, , break
	}
	return 0
}

;-------------------------------------------------------------------------------------
; Function: ParseSR
;			Parses search & replace fields
;
; Remarks:	
;			Parser for multiple renames with ("|" notation). Stores parsed data in aSearch & aReplace arrays
;
ParseSR() {
	local dif, i

	if (cbRE) {
		aSearch1 := eSearch,  aReplace1 := eReplace
		return
	}
	

	aSearch1 := aReplace1 := ""

	StringSplit, aSearch, eSearch, |	   
	StringSplit, aReplace, eReplace, |

	dif := aSearch0 - aReplace0, i := aReplace0
	if dif > 0
		Loop, %dif% 
			i++, aReplace%i% := (aReplace0=0) ? "" : aReplace%aReplace0%
}

;-------------------------------------------------------------------------------------
; Function: Preview
;			Preview function for files in the list.
;
; Remarks:
;			Only files currently visible in the list view will be previewed. Preview
;			works according to ProcID which is unique number for current Mask.
;			Files in the list for which preview is already done, will not be previewd 
;			again until ProcId changes.
Preview(){
		local topIndex, page, fpath, cnt, procid, pid, fid
		static 	LVM_GETTOPINDEX=0x1027, LVM_GETCOUNTPERPAGE=0x1028, funcID=0

		IfEqual, gFiles, , return

		fid := ++funcID, pid := gProcId
		Gui, ListView, lvFiles

		SendMessage, LVM_GETTOPINDEX, 0, 0, ,ahk_id  %hlvFiles%
		topIndex := ErrorLevel

		SendMessage, LVM_GETCOUNTPERPAGE, 0, 0, , ahk_id %hlvFiles%
		gLvPage := ErrorLevel

		cnt := LV_GetCount()
		loop, % gLvPage+1
		{
			sleep -1												;read windows quiue
			if (pid != gProcId) or (fid != funcID) or gWorking		;if (proc changed while in preview) or (preview is launched again while it is still runing) or (user started some operation)
				break

			#no := A_Index + topIndex
			if (#no > cnt)
				break

			LV_GetText(procid, #no, 4)
			if (procid != pid)		;if already calculated, don't do it again (remember procID which is unique number of each change)
				#flag := "prev", LV_GetText(fpath, #no, 3), LV_Modify(#no, "col2", (!gParseError) ? Proc( fpath ) : "<Error!>"), LV_Modify(#no, "col4", pid)
			
		}
}

; This subroutine is called by SetTimer on some places where there is a need for preview spam protection
DelayedPreview:
	Preview()
return 

;-------------------------------------------------------------------------------------
; Function: SetCtrlHandler
;			Enable/Desable OnProcChange handler for array of gui controls
;
; Parameter: 
;			state	- true or false
;
SetCtrlHandler( state ) {
	param := state ? "+gOnProcChange" : "-g" 
	ctrls := "eMask,eExt,eSearch,eReplace,cbRE,ddCase"

	Loop, parse,ctrls,`,
		GuiControl, %param%, %A_LoopField%
}

;-------------------------------------------------------------------------------------
;Function:	Preset_Set
;			Load preset from ini (by its name), or from string
;
;Example:
;			Preset_Set("My Preset")				;load preset "My Preset"
;			Preset_Set("[N]>[E].bak", false)	;use first param as preset definition	
;
Preset_Set( preset, flag=true ) {
	p := flag ? Preset_GetDef(preset) : preset
	StringSplit, x, p, >

	SetCtrlHandler( false )						;desable handler so OnProcChange isn't called 6 times
	GuiControl, , eMask,	%x1%
	GuiControl, , eExt,		%x2%
	GuiControl, , eSearch,  %x3%
	GuiControl, , eReplace, %x4%
	GuiControl, , cbRe,		%x5%
	GuiControl, Choose, ddCase, %x6%
	SetCtrlHandler( true )

	gosub OnProcChange
}


;-------------------------------------------------------------------------------------
; Function: Preset_Exists
;			Check if preset exists
Preset_Exists( name ) {
	local s

	s := Ini_LoadSection( gConfig, "Presets") 
	return  RegExMatch(s, "`amiS)^name[0-9]+=\Q" name "\E$")
}

;-------------------------------------------------------------------------------------
; Function: Preset_Load
;			Load presets from ini file and add them to combo box list	
Preset_Load() {
	local p
	p := Ini_LoadKeys("", inis_Presets, "vals", "", "name"), inis_Presets := ""
	StringReplace, p, p,`n,|,A
	GuiControl, , ddPresets, %p%
}

;-------------------------------------------------------------------------------------
; Function: Preset_Save
;			Save preset in Ini and add it to combobox
;
; Remarks:
;			Preset is saved as single line, with preset elements separated by ">" symbol.
;			This symbol is not used in file renaming as it is illegal in file name.
;
Preset_Save() {
	local name, def, idx, sec
	Gui, submit, nohide

	GuiControlGet,name,,ddPresets
	name = %name%			;trim

	sec := Ini_LoadSection(gConfig, "Presets")
	idx := SubStr(Ini_GetKeyName( sec, name ), 5)

	if (idx) {
		MsgBox 36, Save preset, Name already in the preset list.`n`nOverwrite ?
		ifMsgBox No
			return 
		Preset_Delete( name )
	}

	GuiControl, , ddPresets, %name%||
	def := eMask ">" eExt ">" eSearch ">" eReplace ">" cbRE  ">" ddCase

	;get next free number
	sec := Ini_LoadKeys("", sec, "keys", "", "name")
	idx := (sec="") ? 0 : SubStr(sec, InStr("`n" sec, "`nname", false, 0) +4) 
	idx++	

	IniWrite, %name%, %gConfig%, Presets, name%idx%
	IniWrite, %def%, %gConfig%, Presets, def%idx%

	MsgBox Preset saved: `n`n%name%
}
;-------------------------------------------------------------------------------------
; Function: Preset_GetDef
;			Get preset definition or id
;
; Parameters:
;			name - preset name to search for in ini file
;			idx	 - if set to true, function will return preset ID instead definition
;
Preset_GetDef( name, idx=false ) {
	global gConfig

	sec := Ini_LoadSection(gConfig, "Presets")

	if !RegExMatch(sec, "`aim)^\s*name(\d+)\s*=\Q" name "\E$", out)
		return
	return idx ? out1 : Ini_GetVal(sec, "def" out1)
}

;-------------------------------------------------------------------------------------
; Function: Preset_Delete
;			Delete preset by name, or if its not given, use selected item in Presets combo box
;
Preset_Delete(name="") {
	local i, focus, idx

	if (name = "") {
		GuiControlGet,name,,ddPresets
		GuiControlGet, focus, FOCUSV
		if focus != ddPresets
			return
	}
	
	ControlGet, i, FindString, %name%, ,ahk_id %hddPresets%
	Control,  Delete, %i%, , ahk_id %hddPresets%

	idx := Preset_GetDef(name, true)			;get preset idx
	IniDelete, %gConfig%, Presets, name%idx%
	IniDelete, %gConfig%, Presets, def%idx%

	Send {Space}	;refresh
}

;-------------------------------------------------------------------------------------
; Function:	DoLoad
;			Load from gFiles into ListView
DoLoad() {
	local fn, path

	Gui, ListView, lvFiles
	loop, Parse, gFiles, `n, `r 
	{
		if (A_LoopField = "")		;skip empty lines
			continue
		else path := A_LoopField
		
		;TC puts trailing \ on dirs, remove them
		if SubStr(path, 0, 1) = "\"
			StringTrimRight, path, path, 1

		SplitPath, path, fn
		LV_Add("", fn, "", path, 0)
	}
	Status()
}

;-------------------------------------------------------------------------------------
; Function:	DoReload
;			Loads previously processed files (previous result is saved in ResultList)
DoReload(){
	local fn, fpath, re
	Gui, ListView, lvFiles

	re = ([^\\>]+\> )"(.+)$

	if !FileExist( gResultList ) {
		MsgBox, 16, %gTitle%, Result List is not available.
		return
	}
	FileRead, gFiles, %gResultList%
	
	LV_Delete()
	loop, Parse, gFiles, `n, `r 
	{
		if (A_LoopField = "")		;skip empty lines
			continue

		fpath :=  SubStr(RegExReplace( A_LoopField, re, "$2" ), 2, -1)
		SplitPath, fpath, fn
		LV_Add("", fn, "", fpath)
	}
	Preview()
}

; Function: DoRename 
;         Rename files using current processor 
DoRename(){ 
   local newName, oldPath, newPath, dir, cnt, res, delRow := 1, flags := 0, dire,ext,name_no_ext 
   static adrMoveFileEx

   if !adrMoveFileEx
	  adrMoveFileEx := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "Kernel32.dll"), "astr", "MoveFileExW")

   if (gParseError)    {    
      MsgBox Mask Error. 
      return 
   } 

   SetWorking( true ) 

   FileDelete, %gResultList% 

   Gui, ListView, lvFiles 
   GuiControl, -Redraw, lvFiles 
   cnt := LV_GetCount(), res := 1, Progress(true) 
   loop, %cnt% 
   { 
      #flag := "real", #no := A_Index +  delRow - 1,  LV_GetText(oldPath, delRow, 3),  newName := Proc( oldPath ) 
      SplitPath, oldPath, ,dir 
      newPath := dir "\" newName 

      SplitPath, newPath, ,dir 
      IfNotExist, %dir% 
		 FileCreateDir, %dir% 
		 
      res := DllCall(adrMoveFileEx, "str", oldPath, "str", newpath, "uint", flags) 
      if !res 
         LV_Modify(delRow, "col5", ErrMsg() ), delRow++ 
      else { 
         LV_Delete(delRow) 
         FileAppend, "%oldPath%" -> "%newName%"`r`n, %gResultList% 
      } 

      Progress_Inc() 
      if !mod(A_Index, 10)         ;do win messages 
         sleep, -1 
   } 
   Progress(false) 
   GuiControl, +Redraw, lvFiles 
   SetWorking( false ), Preview()      ;call preview in case of errors 
}

;-------------------------------------------------------------------------------------
; Function: DoEditorPreview
;			Preview processed file names in editor
;
; Parameters:
;			mode	- type of output (1,2,3)
;
DoEditorPreview( Mode = 1 ){
	local newName, oldPath, newPath, dir, cnt, res, delRow := 1, flags := 0

	if (gParseError) 	{	
		MsgBox Mask Error.
		return
	}

	SetWorking( true )
	FileDelete, %gPreviewFile%

	Gui, ListView, lvFiles
	cnt := LV_GetCount(), Progress(true)
	loop, %cnt%
	{
		#flag := "real", #no := A_Index,  LV_GetText(oldPath, #no, 3),  newName := Proc( oldPath )
		SplitPath, oldPath, ,dir
		newPath := dir "\" newName

		GuiControl,,Progress, +1

		if Mode = 1 
			res = %res%%newName%`n
		else if Mode = 2
			res = %res%%newPath%`n
		else if Mode = 3
			res = %res%"%oldPath%" -> "%newName%"`n
	}
	res := SubStr(res, 1, -1)
	FileAppend, %res%, %gPreviewFile%
	Progress(false), SetWorking( false )
	Run, %gPreviewFile%
}


;-------------------------------------------------------------------------------------
; Function: DoUndo
;			Undo previous file renames according to data saved in ResultList
;
DoUndo(){
	local oldPath, newPath, reNew, reOld, fnOld, fnNew, msg, res, flags := 0

	reNew = ([^\\>]+\> )"(.+)$
	reOld := " ->.+$"

	if !FileExist( gResultList ) {
		MsgBox, 16, %gTitle%, Undo data is not available.
		return
	}
 
	FileRead, gFiles, %gResultList%

 ;create preview msg
	msg := "Undo previous operation:`n"	
	Loop, Parse, gFiles, `n, `r
	{
		if (A_LoopField = "")		;skip empty lines
			continue

		if (A_Index = 6){
			msg .= "`n..."	
			break
		}

		oldPath :=  SubStr(RegExReplace( A_LoopField, reOld), 2, -1),	newPath :=  SubStr(RegExReplace( A_LoopField, reNew, "$2" ), 2, -1)
		SplitPath, oldPath, fnOld
		SplitPath, newPath, fnNew
		msg .= "`n" fnOld " -> " fnNew
	}

	MsgBox, 36, %gTitle%, %msg%
	IfMsgBox No
		return

	SetWorking( true ), Progress(true)

	loop, Parse, gFiles, `n, `r 
	{
		if (A_LoopField = "")		;skip empty lines
			continue
		
		oldPath :=  SubStr(RegExReplace( A_LoopField, reOld), 2, -1)
		newPath :=  SubStr(RegExReplace( A_LoopField, reNew, "$2" ), 2, -1)
		res := DllCall("MoveFileEx", "str", newPath, "str", oldPath, "uint", flags)
		if (!res){
			SplitPath, oldPath, fnOld
			SplitPath, newPath, fnNew
			MsgBox Rename failed:`n`n%fnNew% -> %fnOld%
		}

		GuiControl,,Progress, +1
		if !mod(A_Index, 10)			;check the quie
			sleep, -1
	}
	FileDelete, %gResultList%

	SetWorking( false ), Progress(false)
}

;-------------------------------------------------------------------------------------
SetWorking( flag ) {
	global
	
	if (flag)
			critical on
	else	critical off

	GuiControl, Disable%flag%, eMask
	GuiControl, Disable%flag%, eExt
	GuiControl, Disable%flag%, eSearch
	GuiControl, Disable%flag%, eReplace
	GuiControl, Disable%flag%, cbRE
	GuiControl, Disable%flag%, ddCase

	GuiControl, Disable%flag%, btnStart
	GuiControl, Disable%flag%, btnUndo
	GuiControl, Disable%flag%, btnResult
	GuiControl, Disable%flag%, btnReload
	GuiControl, Disable%flag%, btnInEditor

	GuiControl, Disable%flag%, lvFiles

	gWorking := flag
}

;-------------------------------------------------------------------------------------
; Function: MRU_Load
;			Load mru list for file mask & extension mask
;
; Parameters:
;			target - "FM" or "Ext"
;
MRU_Load( target ) {
	local mru, lw

	if (target = "FM")
			mru := "inis_MRUfm" , lv := "cxMask"
	else	mru := "inis_MRUsr" , lv := "cxSR"

	Gui, ListView, %lv%
	mru := Ini_LoadKeys("", %mru%, "vals")
	loop, Parse, mru, `n, `r
		lw := InStr(A_LoopField, ">"), LV_Add("", SubStr(A_LoopField, 1, lw-1), SubStr(A_LoopField, lw+1))

	Gui, ListView, lvFiles    
}

;-------------------------------------------------------------------------------------
; Function: MRU_Set
;			Set mru list for file mask & extension mask
;
; Parameters:
;			target	- "FM" or "Ext"
;			max		- maximum number of MRU enteries
;
MRU_Set( target, max=10 ) {
	 local j, c1, c2, def, lv, section

	 if (target = "FM")
			c1 := eMask,   c2 := eExt,		def:="[N][E]",	lv:="cxMask"
	 else	c1 := eSearch, c2 := eReplace,	def:="",		lv:="cxSR"
	
	 section := "inis_MRU" target  
	 if (c1 c2 != def)
		if (j := Ini_AddMRU(%section%, c1 ">" c2, 10)) {
			Gui, ListView, %lv%
			if (j > 1)		  ;duplicate is moved to top
				LV_Delete(j)

			LV_Insert(1, "", c1, c2), LV_Delete(max+1)
		}
	
	Gui, ListView, lvFiles    
}

;------------------------------------------------------------------------------------
; Function: ExpandEnvVar
;			Expand environment variables in a path
ExpandEnvVar(pPath){
	VarSetCapacity(dest, 512) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, "int", 512)
	return dest
}

;------------------------------------------------------------------------------------
About(){
	global
	static txt

	if !txt
	{
		txt = 
		(LTrim
		[About]
		*%gTitle% %gVersion%* 
		_by majkinetor_

		"Visit Project Page":http://code.google.com/p/multi-rename-script &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; "Check for new version":http://code.google.com/p/multi-rename-script/downloads/list


		!http://www.autohotkey.net/~majkinetor/-Avatars/scaryroboo3k.gif!
		[Links]
		"Total Commander Content Plugins":http://www.totalcmd.net/directory/content.html
		"AutoHotKey":http://www.autohotkey.com
		
		[Modules]
		"COM":http://www.autohotkey.com/forum/viewtopic.php?t=22923 - COM library.
		"Accordion":http://www.autohotkey.com/forum/topic27182.html - Accordion dialog.
		"ComboX":http://www.autohotkey.com/forum/topic22390.html - Impose combobox behavior on control.
		"HLink":http://www.autohotkey.com/forum/topic19508.html - Custom HyperLink control.
		"ShowMenu":http://www.autohotkey.com/forum/topic23138.html - Show menu from the text.
		"Ini":http://www.autohotkey.com/forum/topic22495.html - Helper functions for easier ini file handling.
		"Plugins":http://www.autohotkey.com/forum/topic22029.html - Plugin framework for non compiled scripts.
		"Attach":http://www.autohotkey.com/forum/topic48298.html - Attach controls in the window.
		"Win":http://www.autohotkey.com/forum/topic47856.html - Window functions.

		[Shortcuts]
		@F12@	- Load default preset.
		@DEL@   - Delete current preset if presets combo box is focused.
		@ENTER@ - Save preset if presets combo box is focused.
		@SHIFT click@ - Select left column of ComboX.
		@ALT click@  - Select right column of ComboX.

		)
	}
	Accordion("About", "Multi-Rename Script", txt, 1, 500, 440)
}

;-------------------------------------------------------------------------------------
#IfWinActive Multi-Rename Script

F12:: Preset_Set("[N]>[E]>>>0>1", false)	;reset
~^A:: 
	GuiControlGet, focus, FOCUSV
	if focus != lvFiles 
		return
	LV_Modify(0, "Select")
return

~del:: 
	GuiControlGet, focus, FOCUSV
	if (focus != "ddPresets")
		return

	GuiControlGet,name,,ddPresets
	if !Preset_Exists( name )
		return

	MsgBox, 4, Preset, Delete preset ?`n`n%name%
	ifMsgbox, Yes
		Preset_Delete( name )
return

ENTER::
	GuiControlGet, focus, FOCUSV
	if focus != ddPresets
		return

	Preset_Save()
return

#IfWinActive

;==================================== INCLUDES =====================================

#include inc\IFun.ahk			;definition of native masks
#include inc\Gui.ahk			;gui related stuff
#include inc\Events.ahk			;gui events
#include inc\TCwdx.ahk			;TC content plugin functions
#include inc\Shell.ahk			;Register shell extension

;================== modules ======================
#include inc\m\COM.ahk
#include inc\m\Plugins.ahk		
#include inc\m\Ini.ahk			
#include inc\m\ComboX.ahk		
#include inc\m\ErrMsg.ahk		
#include inc\m\ShowMenu.ahk
#include inc\m\Accordion.ahk

;================== Forms ========================
#include inc\m\Win.ahk
#include inc\m\Attach.ahk
#include inc\m\HLink.ahk