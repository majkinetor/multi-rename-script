Shell_Register() {
	global gShellName, gShellGuid

	RegWrite, REG_SZ, HKCR, *\shell\%gShellName%\DropTarget, CLSID, %gShellGuid%
	RegWrite, REG_SZ, HKCR, Folder\shell\%gShellName%\DropTarget, CLSID, %gShellGuid%
	RegWrite, REG_SZ, HKCR, CLSID\%gShellGuid%\LocalServer32,, "%A_AhkPath%" "%A_ScriptFullPath%"
}

Shell_UnRegister() {
	global gShellName, gShellGuid

	RegDelete, HKCR, *\shell\%gShellName%
	RegDelete, HKCR, Folder\shell\%gShellName%
	RegDelete, HKCR, CLSID\%gShellGuid%
}

Shell_Registred() {
	global gShellName, gShellGuid

	RegRead, x, HKCR, *\shell\%gShellName%\DropTarget, CLSID
	RegRead, y, HKCR, Folder\shell\%gShellName%\DropTarget, CLSID
	RegRead, z, HKCR, CLSID\%gShellGuid%\LocalServer32

	return (x != gShellGuid) or (y != gShellGuid) or (z="") ? 0 : 1
}

Shell_Init(lbl) {
	global gShellGuid, Shell_nRegister
	if !IsLabel(lbl)
		return "Invalid label"
	else IDropTarget(lbl)

	If not Shell_nRegister := DropTargetOpen(gShellGuid) {
		msgbox Shell init failed
		ExitApp
	}
}

DropTargetClose:
	DropTargetClose(Shell_nRegister)
ExitApp


DropTargetOpen(pGuid){
	static	IDropTarget, IClassFactory

	If not VarSetCapacity(IDropTarget)
	{
		VarSetCapacity(IDropTarget,36,0), NumPut(&IDropTarget+4,IDropTarget), nParams=3116516
		Loop, Parse, nParams
			NumPut(RegisterCallback("IDropTarget","",A_LoopField,A_Index-1),IDropTarget,4*A_Index)
	}
	If not VarSetCapacity(IClassFactory)
	{
		VarSetCapacity(IClassFactory,28,0), NumPut(&IClassFactory+4,IClassFactory), nParams=31142
		Loop, Parse, nParams
			NumPut(RegisterCallback("IClassFactory","",A_LoopField,A_Index-1), IClassFactory,4*A_Index)
	}
	NumPut(&IClassFactory,IDropTarget,32),	NumPut(&IDropTarget,IClassFactory,24)

	COM_Init()
	DllCall("ole32\CoRegisterClassObject", "Uint", COM_GUID4String(CLSID, pGuid), "Uint", &IDropTarget, "Uint", 4, "Uint", 1, "UintP", nRegister)
	Return	nRegister
}

DropTargetClose(Shell_nRegister)
{
	m(A_ThisFunc)
	DllCall("ole32\CoRevokeClassObject", "Uint", Shell_nRegister)
	COM_Term()
}

Shell_GetData(this){
	m(A_ThisFunc)
	VarSetCapacity(FormatEtc,20,0), VarSetCapacity(StgMedium,12,0)
	NumPut(DllCall("RegisterClipboardFormat", "str", "Shell IDList Array"),FormatEtc,0), NumPut(0,FormatEtc,4), NumPut(1,FormatEtc,8), NumPut(-1,FormatEtc,12), NumPut(1,FormatEtc,16)
	
	DllCall(NumGet(NumGet(1*this)+12), "Uint", this, "Uint", &FormatEtc, "Uint", &StgMedium)	; GetData
	hData:=	NumGet(StgMedium,4)
	pData:=	DllCall("GlobalLock", "Uint", hData)
	pidlP:=	pData+NumGet(pData+4), VarSetCapacity(sPath, 259)
	Loop, %	NumGet(pData+0)
		pidl:=DllCall("shell32\ILCombine", "Uint", pidlP, "Uint", pData+NumGet(pData+4+4*A_Index)), DllCall("shell32\SHGetPathFromIDListW", "Uint", pidl, "str", sPath), COM_CoTaskMemFree(pidl), sData .= sPath . "`n"
	DllCall("GlobalUnlock", "Uint", hData)
	DllCall("ole32\ReleaseStgMedium", "Uint", &StgMedium)

	COM_Release(this), this := ""
	Return	sData
}

IClassFactory(this, punk="", riid="", ppobj="")
{
	hResult	:= 0
	If	A_EventInfo = 3
		NumPut(NumGet(this+24),ppobj+0)
	Else If	A_EventInfo = 0
		hResult	:= DllCall(NumGet(NumGet(this+24)+4), "Uint", NumGet(this+24), "Uint", punk, "Uint", riid)
	Return	hResult
}

IDropTarget(this, pdata="", key="", x="", y="", peffect=""){
	global Shell_data
	static lbl

	if (lbl="") {
		 lbl := this			
		 return
	}

	hResult	:= 0
	If	A_EventInfo = 6
	{
		NumPut(NumGet(peffect+0)&5,peffect+0)
		COM_AddRef(Shell_data),  Shell_data	:= Shell_GetData(pdata)
		SetTimer, %lbl%, -20
	}
	Else If	A_EventInfo = 3
		NumPut(NumGet(peffect+0)&5,peffect+0)
	Else If	A_EventInfo = 0
		InStr("{00000122-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",IID:=COM_String4GUID(pdata)) ? NumPut(this,key+0) : IID="{00000001-0000-0000-C000-000000000046}" ? NumPut(NumGet(this+32),key+0) : hResult:=0x80004002
	Return	hResult
}