/*
 Title:	TCwdx
		Total Commander Content Plugin API
 */

/*
 Function:	FindIni
			Find full path of the TC wincmd.ini.

 Returns:	
			Path if ini is found or nothing otherwise.

 Remarks:
			Search at Registry and COMMANDER_PATH environment variable.
 */
TCwdx_FindIni() {
	RegRead, ini, HKEY_CURRENT_USER, Software\Ghisler\Total Commander, IniFileName
	if FileExist(ini)
		return ini

	EnvGet COMMANDER_PATH, COMMANDER_PATH
	if (COMMANDER_PATH != ""){
		ini = %COMMANDER_PATH%\wincmd.ini
		if FileExist(ini)
			return ini
	}
}

/*
 Function:	GetPluginsFromDir
			Get list of plugins from directory (no wincmd.ini is used).

 Parameters:
			Path -	Base path. Plugins should be in folders with equal name as their own.

 Returns:	
			String in Ini_ format: name=path
 */
TCwdx_GetPluginsFromDir( Path ) {
	loop, %path%\*, 2
	{
		tcPlug :=  A_LoopFileFullPath "\" A_LoopFileName ".wdx"
		if FileExist(tcPlug)
			res .= A_LoopFileName "=" tcPlug "`n"
	}
	return SubStr(res, 1, -1)
}

/*
 Function:	GetPlugins
			Get list of installed TC plugins using wincmd.ini.

 Parameters:
			IniFile	-	TC wincmd.ini path or "" to try to get ini location using <FindIni> function.

 Returns:	
			String in format: name=path or ERR if ini can not be found
 */
TCwdx_GetPlugins( IniFile="" ) {
	ifEqual, IniFile,, SetEnv, IniFile, % TCwdx_FindIni()
	if !FileExist(IniFile)
		return "ERR"

	VarSetCapacity(dest, 512) 

	inSec := 0
	Loop, read, %IniFile%
	{
		s := A_LoopReadLine
		if (!inSec){
		   inSec := InStr(s,"[ContentPlugins]")
		   continue
		}
		
		if *&s=91				;if next line starts with [
			break

		j:=InStr(s, "="), n := SubStr(s, 1, j-1), v:= SubStr(s, j+1)
		if n is Integer	
		{
			DllCall("ExpandEnvironmentStrings", "str", v, "str", dest, "int", 512), v:=dest
			if !FileExist(v)
				continue
			res .= SubStr(v, InStr(v, "\", false, 0)+1, -4) "=" v "`n"
		}
	}
	return SubStr(res, 1, -1)
}
/*
 Function:	LoadPlugin
			Load plugin dll into the memory	and set its default parameters.

 Parameters:
			PluginPath	- Path to TC content plugin.

 Returns:	
			Handle to the plugin dll.

 */		
TCwdx_LoadPlugin( PluginPath ) {
	h := DllCall("LoadLibrary", "str", PluginPath),  TCwdx_SetDefaultParams(PluginPath)
 	return 	h
}

/*
 Function:  UnloadPlugin
			Unloads plugin dll.

 Parameters:
			HPlugin	- Handle returned by LoadPlugin function.
 */
TCwdx_UnloadPlugin(HPlugin){
	return DllCall("FreeLibrary", "UInt", HPlugin) 
}

/*
 Function:	GetPluginFields
			Get list of plugin fields.

 Parameters:
			Plugin	-	Path to TC content plugin.
			Format	-	If omited, only field names will be returned, if set to "ini" string will be in Ini_ format, field=index|unit1|unit2...|unitN
						or field=index if there is no unit for given field, if "menu", string will be in ShowMenu format with "|" as item separator and root 
						of the menu named "tcFields".

 Returns:	
			String with fields on each line									 
 */
TCwdx_GetPluginPathFields( PluginPath, Format="" ) {
	if Format = ""
		 Format = 0			;def
	else if Format = "ini"
		 Format = 1			;ini
	else Format = 2			;menu

	VarSetCapacity(name,512), VarSetCapacity(units,512)
	loop {
		r := DllCall(PluginPath "\ContentGetSupportedField", "int", A_Index-1, "uint", &name, "uint", &units, "uint", 512)
		IfEqual, r, 0, break										;ft_nomorefields=0
		VarSetCapacity(name,-1) , VarSetCapacity(units,-1)
		IfEqual, r, 7, SetEnv, units								;multiple fields are not units

		if Format = 0
			     res .= name "`n"
		else if Format = 1
			     res .= name "=" A_Index-1 (units !="" ? "|" units : "")  "`n"
		else 
			if (units != "") 
				 res .= name "=<" name ">|",   resu .= "[" name "]`n" units "`n" 				;!!!for show menu mod <> instead []
			else res .= name "|"

	}

	StringTrimRight, res, res, 1
	if Format = 2
		res := "[tcFields]`n" res "`n" resu

	return res
}

/*
 Function:	GetField
			Get field data.

 Parameters:
			FileName	- File name for which info is to be retreived.
			PluginPath  - Path to TC content plugin.
			FieldIndex	- Field index, by default 0.
			UnitIndex	- Unit index, by default 0.

 Returns:	
			Field data.
 */
TCwdx_GetFieldIndexeld(FieldIndexleName, PluginPath, FieldIndex=0, UnitIndex=0){
	static i=0, info, st
	if (!i++)
		VarSetCapacity(info,256), VarSetCapacity(st, 16)		;reserve buffers only on FieldIndexrst call

	type := DllCall(PluginPath "\ContentGetValue", "str", FieldIndexleName, "int", FieldIndex, "int", UnitIndex, "UnitIndexnt", &info, "int", 256, "int", 0)
	if (type <=0 or type=9) 
		return
	goto TCwdx_Type_%type%

	TCwdx_Type_1:									;ft_numeric_32
	TCwdx_Type_6:
		return NumGet(info, 0, "Int")		
	TCwdx_Type_2:									;ft_numeric_64	A 64-bit signed number
		return NumGet(info, 0, "Int64")
	TCwdx_Type_3:									;ft_numeric_floating	A double precision floating point number
		return NumGet(info, 0, "Double")
	TCwdx_Type_4:									;ft_date	A date value (year, month, day)
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCwdx_Type_5:									;A time value (hour, minute, second). Date and time are in local time.
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCWdx_Type_7:
	TCwdx_Type_8:
		VarSetCapacity(info,-1)						;ft_string
		return info
	TCwdx_Type_10:									;A timestamp of type FieldIndexLETIME, as returned e.g. by FieldIndexndFieldIndexrstFieldIndexle(). It is a 64-bit value representing the number of 100-nanosecond.
		r := DllCall("FieldIndexleTimeToSystemTime", "UnitIndexnt", &info, "UnitIndexnt", &st)
		ifEqual r, 0, return
		return NumGet(st, 0, "UShort") "." NumGet(st, 2, "UShort") "." NumGet(st, 6, "UShort") " " NumGet(st, 8, "UShort") "." NumGet(st, 10 ,"UShort") "." NumGet(st, 12, "UShort")
}

/*
 Function:	GetIndices
			Get index of field and optionaly its unit.

 Parameters:
			PluginPath		- Path to TC content plugin
			Field			- Field for which index is to be returned. If unit is to be returned, use "Field.Unit" notation.
			out FieldIndex	- Reference to variable to receive field index or empty string if field is not found.
			out UnitIndex	- Optional Reference to variable to receive unit index or empty string if field is not found.
							  If unit is is not requested UnitIndex will be set to 0.
 */
TCwdx_GetIndices(tcplug, Field, ByRef FieldIndex, ByRef UnitIndex="."){

	FieldIndex := "", UnitIndex = 0
	if j := InStr(Field, ".") 
		unit := SubStr(Field, j+1), Field := SubStr(Field, 1, j-1)

	VarSetCapacity(name,512), VarSetCapacity(units,512)
	loop {
		r := DllCall(tcplug "\ContentGetSupportedField", "int", A_Index-1, "UnitIndexnt", &name, "UnitIndexnt", &units, "UnitIndexnt", 512)
		IfEqual, r, 0, return										;ft_nomoreFields=0
		VarSetCapacity(name,-1)

		if (name=Field) {
			FieldIndex := A_Index - 1
			if (UnitIndex != ".") and (unit != "") {
				VarSetCapacity(units,-1) 
				loop, parse, units, |
					if (A_LoopField=unit) {
						UnitIndex := A_Index - 1
						return
					}
				UnitIndex := ""
			}
			return
		}
	}	
}

/*
 Function: SetDefaultParams
			Mandatory function for some plugins (like ShellDetails)

 Parameters:
			PluginPath	- Path to tc content plugin
 */
TCwdx_SetDefaultParams(PluginPath){
	VarSetCapacity(dps, 272, 0)
	NumPut(272, dps, "Int"), NumPut(30, dps, 4), NumPut(1, dps, 8)

	SplitPath, PluginPath, ,dir, ,name
	name = %dir%\%name%.ini
	DllCall("lstrcpyA", "uint", &dps+12, "uint", &name)
	r := DllCall(PluginPath "\ContentSetDefaultParams", "uint", &dps)
}

/* Group: About
	o v2.0 by majkinetor. 
	o TC Content Plugin Repository: <http://www.ghisler.com/plugins.htm#content> & <http://www.totalcmd.net/directory/content.html> 
	o TC Content Plugin SDK: <http://ghisler.fileburst.com/content/contentpluginhelp2.0.zip>
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.
 */