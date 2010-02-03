; Title:		Plugins
;				*Plugin framework for non compiled scripts*

;------------------------------------------------------------------------
; Function:		Init
;				Must be called at te start of the script. Will check for new plugins.
;				All .ahk files in the "plugins" folder will be considered as plugins.
;				To install plugin simply move ahk script in plugin folder and restart
;				the host script.
;
Plugins_Init() {
	local lastParam

	lastParam := %0%
	if (lastParam = "Plugin_Reload")
		return
	
	Plugins_makeList()
}
;------------------------------------------------------------------------
; Function:		Get
;				Creates array with the names of all loaded plugins
;
; Parameters:
;				out	- String holding variable name which will be the base
;					  for the array. If empty, array will not be created and function will return list of loaded plugins
;
; Returns:		
;				Number of plugins or string with list of plugins. This info will also be available as 
;				array element with index zero.
;
Plugins_Get( out="" ){
	local code, res

  	FileRead code, %A_ScriptDir%\PluginList.ahk
	StringReplace code, code, %A_ScriptDir%\

	loop, parse, code,`n,`r 
		if out != 
			 %out%%A_Index% := SubStr(A_LoopField,InStr(A_LoopField, "\", 0,0)+1, -4), %out%0 := A_Index
		else res .= SubStr(A_LoopField,InStr(A_LoopField, "\", 0,0)+1, -4) "`n"

	StringTrimRight, res, res, 1	
	return (out = "") ? res : %out%0
}

Plugins_makeList() {
	local code, old, param

	loop, plugins\*.ahk,    
		code .= "#include *i " A_ScriptDir "\plugins\" A_LoopFileName "`r`n"
	StringTrimRight,code,code,2

	FileRead old, %A_ScriptDir%\PluginList.ahk
	if (old = code)
		return

	FileDelete, %A_ScriptDir%\PluginList.ahk
	FileAppend, %code%, %A_ScriptDir%\PluginList.ahk
	FileSetAttrib, +H, %A_ScriptDir%\PluginList.ahk

	;re-run the host, with the same command line, add flag as last parameter
	loop, %0% {
		if InStr(%A_Index%, A_Space)
			 param .= """" %A_Index% """" " "
		else param .= %A_Index% " "
	}
	param .= "Plugin_Reload"
		
	Run "%A_AHKPATH%" "%A_ScriptFullPath%" %param%
	ExitApp
}

#include *i %A_ScriptDir%\PluginList.ahk

;---------------------------------------------------------------------------------------------
;About:
;		o Ver 1.0 by majkinetor. See http://www.autohotkey.com/forum/topic22029.html
;		o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.