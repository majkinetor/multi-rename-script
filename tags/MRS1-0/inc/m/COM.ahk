COM_Init(bOLE = False)
{
	Return	bOLE ? COM_OleInitialize() : COM_CoInitialize()
}

COM_Term(bOLE = False)
{
	Return	bOLE ? COM_OleUninitialize() : COM_CoUninitialize()
}

COM_VTable(ppv, idx)
{
	Return	NumGet(NumGet(1*ppv)+4*idx)
}

COM_QueryInterface(ppv, IID)
{
	DllCall(NumGet(NumGet(1*ppv)), "Uint", ppv, "Uint", COM_GUID4String(IID,IID), "UintP", ppv)
	Return	ppv
}

COM_AddRef(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv)+4), "Uint", ppv)
}

COM_Release(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
}

COM_QueryService(ppv, SID, IID = "")
{
	DllCall(NumGet(NumGet(1*ppv)+4*0), "Uint", ppv, "Uint", COM_GUID4String(IID_IServiceProvider,"{6D5140C1-7436-11CE-8034-00AA006009FA}"), "UintP", psp)
	DllCall(NumGet(NumGet(1*psp)+4*3), "Uint", psp, "Uint", COM_GUID4String(SID,SID), "Uint", IID ? COM_GUID4String(IID,IID) : &SID, "UintP", ppv)
	DllCall(NumGet(NumGet(1*psp)+4*2), "Uint", psp)
	Return	ppv
}

COM_FindConnectionPoint(pdp, DIID)
{
	DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", COM_GUID4String(IID_IConnectionPointContainer, "{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
	DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", COM_GUID4String(DIID,DIID), "UintP", pcp)
	DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
	Return	pcp
}

COM_GetConnectionInterface(pcp)
{
	VarSetCapacity(DIID, 16, 0)
	DllCall(NumGet(NumGet(1*pcp)+12), "Uint", pcp, "Uint", &DIID)
	Return	COM_String4GUID(&DIID)
}

COM_Advise(pcp, psink)
{
	DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
	Return	nCookie
}

COM_Unadvise(pcp, nCookie)
{
	Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
}

COM_Enumerate(penum, ByRef Result)
{
	VarSetCapacity(varResult,16,0)
	If (0 =	_hResult_:=DllCall(NumGet(NumGet(1*penum)+12), "Uint", penum, "Uint", 1, "Uint", &varResult, "UintP", 0))
		Result:=(vt:=NumGet(varResult,0,"Ushort"))=8||vt<0x1000&&DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",1,"Ushort",8)=0 ? COM_Ansi4Unicode(bstr:=NumGet(varResult,8)) . SubStr(COM_SysFreeString(bstr),1,0) : NumGet(varResult,8)
	Return	_hResult_
}

COM_Invoke(pdisp, sName, arg1="vT_NoNe",arg2="vT_NoNe",arg3="vT_NoNe",arg4="vT_NoNe",arg5="vT_NoNe",arg6="vT_NoNe",arg7="vT_NoNe",arg8="vT_NoNe",arg9="vT_NoNe")
{
	Global	_hResult_
	nParams:=0
	Loop,	9
		If	(arg%A_Index% == "vT_NoNe")
			Break
		Else	++nParams
	VarSetCapacity(DispParams,16,0), VarSetCapacity(varResult,16,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,nParams*16,0)
		NumPut(&varg,DispParams,0), NumPut(nParams,DispParams,8)
	If	(nFlags := SubStr(sName,0) <> "=" ? 3 : 12) = 12
		NumPut(&varResult,DispParams,4), NumPut(1,DispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
	Loop, %	nParams
		If	arg%A_Index% Is Not Integer
         		NumPut(8,varg,(nParams-A_Index)*16,"Ushort"), NumPut(COM_SysAllocString(arg%A_Index%),varg,(nParams-A_Index)*16+8)
		Else	NumPut(SubStr(arg%A_Index%,1,1)="+" ? 9 : 3,varg,(nParams-A_Index)*16,"Ushort"), NumPut(arg%A_Index%,varg,(nParams-A_Index)*16+8)
	If (0 =	_hResult_:=DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "Uint", &IID_NULL, "UintP", COM_Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID))
	&& (0 =	_hResult_:=DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "Uint", &IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &dispParams, "Uint", &varResult, "Uint", 0, "Uint", 0))
	&& (3 =	nFlags)
		Result:=(vt:=NumGet(varResult,0,"Ushort"))=8||vt<0x1000&&DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",1,"Ushort",8)=0 ? COM_Ansi4Unicode(bstr:=NumGet(varResult,8)) . SubStr(COM_SysFreeString(bstr),1,0) : NumGet(varResult,8)
	Loop, %	nParams
		NumGet(varg,(A_Index-1)*16,"Ushort")=8 ? COM_SysFreeString(NumGet(varg,(A_Index-1)*16+8)) : ""
	Return	Result
}

COM_Invoke_(pdisp, sName, type1="",arg1="",type2="",arg2="",type3="",arg3="",type4="",arg4="",type5="",arg5="",type6="",arg6="",type7="",arg7="",type8="",arg8="",type9="",arg9="")
{
	Global	_hResult_
	nParams:=0
	Loop,	9
		If	(type%A_Index% = "")
			Break
		Else	++nParams
	VarSetCapacity(dispParams,16,0), VarSetCapacity(varResult,16,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,nParams*16,0)
		NumPut(&varg,dispParams,0), NumPut(nParams,dispParams,8)
	If	(nFlags := SubStr(sName,0) <> "=" ? 1|2 : 4|8) & 12
		NumPut(&varResult,dispParams,4), NumPut(1,dispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
	Loop, %	nParams
		NumPut(type%A_Index%,varg,(nParams-A_Index)*16,"Ushort"), type%A_Index%&0x4000=0 ? NumPut(type%A_Index%=8 ? COM_SysAllocString(arg%A_Index%) : arg%A_Index%,varg,(nParams-A_Index)*16+8,type%A_Index%=5||type%A_Index%=7 ? "double" : type%A_Index%=4 ? "float" : "int64") : type%A_Index%=0x400C||type%A_Index%=0x400E ? NumPut(arg%A_Index%,varg,(nParams-A_Index)*16+8) : VarSetCapacity(ref%A_Index%,8,0) . NumPut(&ref%A_Index%,varg,(nParams-A_Index)*16+8) . NumPut(type%A_Index%=0x4008 ? COM_SysAllocString(arg%A_Index%) : arg%A_Index%,ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64")
	If (0 =	_hResult_:=DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "Uint", &IID_NULL, "UintP", COM_Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID))
	&& (0 =	_hResult_:=DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "Uint", &IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &dispParams, "Uint", &varResult, "Uint", 0, "Uint", 0))
	&& (3 =	nFlags)
		Result:=(vt:=NumGet(varResult,0,"Ushort"))=8||vt<0x1000&&DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",1,"Ushort",8)=0 ? COM_Ansi4Unicode(bstr:=NumGet(varResult,8)) . SubStr(COM_SysFreeString(bstr),1,0) : NumGet(varResult,8)
	Loop, %	nParams
		type%A_Index%&0x4000=0 ? (type%A_Index%=8 ? COM_SysFreeString(NumGet(varg,(nParams-A_Index)*16+8)) : "") : type%A_Index%=0x400C||type%A_Index%=0x400E ? "" : type%A_Index%=0x4008 ? (_TEMP_VT_BYREF_%A_Index%:=COM_Ansi4Unicode(NumGet(ref%A_Index%))) . COM_SysFreeString(NumGet(ref%A_Index%)) : (_TEMP_VT_BYREF_%A_Index%:=NumGet(ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64"))
	Return	Result
}

COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
{
	Critical
	If	A_EventInfo = 6
		DllCall(NumGet(NumGet(NumGet(this+8))+28),"Uint",NumGet(this+8),"Uint",prm1,"UintP",pname,"Uint",1,"UintP",0), VarSetCapacity(sfn,63), DllCall("user32\wsprintfA","str",sfn,"str","%s%S","Uint",this+40,"Uint",pname,"Cdecl"), COM_SysFreeString(pname), (pfn:=RegisterCallback(sfn,"C F")) ? (hResult:=DllCall(pfn, "Uint", prm5, "Uint", this, "Cdecl")) . DllCall("kernel32\GlobalFree", "Uint", pfn) : (hResult:=0x80020003)
	Else If	A_EventInfo = 5
		hResult:=DllCall(NumGet(NumGet(NumGet(this+8))+40),"Uint",NumGet(this+8),"Uint",prm2,"Uint",prm3,"Uint",prm5)
	Else If	A_EventInfo = 4
		NumPut(0,prm3+0), hResult:=0x80004001
	Else If	A_EventInfo = 3
		NumPut(0,prm1+0), hResult:=0
	Else If	A_EventInfo = 2
		NumPut(hResult:=NumGet(this+4)-1,this+4), hResult ? "" : COM_Unadvise(NumGet(this+16),NumGet(this+20)) . COM_Release(NumGet(this+16)) . COM_Release(NumGet(this+8)) . COM_CoTaskMemFree(this)
	Else If	A_EventInfo = 1
		NumPut(hResult:=NumGet(this+4)+1,this+4)
	Else If	A_EventInfo = 0
		COM_IsEqualGUID(this+24,prm1)||InStr("{00020400-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",COM_String4GUID(prm1)) ? NumPut(this,prm2+0) . NumPut(NumGet(this+4)+1,this+4) . (hResult:=0) : NumPut(0,prm2+0) . (hResult:=0x80004002)
	Return	hResult
}

COM_DispGetParam(pDispParams, Position = 0, vtType = 8)
{
	VarSetCapacity(varResult,16,0)
	DllCall("oleaut32\DispGetParam", "Uint", pDispParams, "Uint", Position, "Ushort", vtType, "Uint", &varResult, "UintP", nArgErr)
	Return	NumGet(varResult,0,"Ushort")=8 ? COM_Ansi4Unicode(NumGet(varResult,8)) . SubStr(COM_SysFreeString(NumGet(varResult,8)),1,0) : NumGet(varResult,8)
}

COM_CreateIDispatch()
{
	Static	IDispatch
	If Not	VarSetCapacity(IDispatch)
	{
		VarSetCapacity(IDispatch,28,0),   nParams=3112469
		Loop,   Parse,   nParams
		NumPut(RegisterCallback("COM_DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
	}
	Return &IDispatch
}

COM_GetDefaultInterface(pdisp, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp) +12), "Uint", pdisp , "UintP", ctinf)
	If	ctinf
	{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	DllCall(NumGet(NumGet(1*pdisp)+ 0), "Uint", pdisp, "Uint" , pattr, "UintP", ppv)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	If	ppv
	DllCall(NumGet(NumGet(1*pdisp)+ 8), "Uint", pdisp),	pdisp := ppv
	}
	Return	pdisp
}

COM_GetDefaultEvents(pdisp, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	VarSetCapacity(IID,16), DllCall("RtlMoveMemory", "Uint", &IID, "Uint", pattr, "Uint", 16)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Loop, %	DllCall(NumGet(NumGet(1*ptlib)+12), "Uint", ptlib)
	{
		DllCall(NumGet(NumGet(1*ptlib)+20), "Uint", ptlib, "Uint", A_Index-1, "UintP", TKind)
		If	TKind <> 5
			Continue
		DllCall(NumGet(NumGet(1*ptlib)+16), "Uint", ptlib, "Uint", A_Index-1, "UintP", ptinf)
		DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
		nCount:=NumGet(pattr+48,0,"Ushort")
		DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
		Loop, %	nCount
		{
			DllCall(NumGet(NumGet(1*ptinf)+36), "Uint", ptinf, "Uint", A_Index-1, "UintP", nFlags)
			If	!(nFlags & 1)
				Continue
			DllCall(NumGet(NumGet(1*ptinf)+32), "Uint", ptinf, "Uint", A_Index-1, "UintP", hRefType)
			DllCall(NumGet(NumGet(1*ptinf)+56), "Uint", ptinf, "Uint", hRefType , "UintP", prinf)
			DllCall(NumGet(NumGet(1*prinf)+12), "Uint", prinf, "UintP", pattr)
			nFlags & 2 ? DIID:=COM_String4GUID(pattr) : bFind:=COM_IsEqualGUID(pattr,&IID)
			DllCall(NumGet(NumGet(1*prinf)+76), "Uint", prinf, "Uint" , pattr)
			DllCall(NumGet(NumGet(1*prinf)+ 8), "Uint", prinf)
		}
		DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
		If	bFind
			Break
	}
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	bFind ? DIID : "{00000000-0000-0000-0000-000000000000}"
}

COM_GetGuidOfName(pdisp, Name, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf:=0
	DllCall(NumGet(NumGet(1*ptlib)+44), "Uint", ptlib, "Uint", COM_Unicode4Ansi(Name,Name), "Uint", 0, "UintP", ptinf, "UintP", memID, "UshortP", 1)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	GUID := COM_String4GUID(pattr)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Return	GUID
}

COM_GetTypeInfoOfGuid(pdisp, GUID, LCID = 0)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", LCID, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf := 0
	DllCall(NumGet(NumGet(1*ptlib)+24), "Uint", ptlib, "Uint", COM_GUID4String(GUID,GUID), "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	ptinf
}

; A Function Name including Prefix is limited to 63 bytes!
COM_ConnectObject(psource, prefix = "", DIID = "{00020400-0000-0000-C000-000000000046}")
{
	If	(DIID = "{00020400-0000-0000-C000-000000000046}")
		0+(pconn:=COM_FindConnectionPoint(psource,DIID)) ? (DIID:=COM_GetConnectionInterface(pconn))="{00020400-0000-0000-C000-000000000046}" ? DIID:=COM_GetDefaultEvents(psource) : "" : pconn:=COM_FindConnectionPoint(psource,DIID:=COM_GetDefaultEvents(psource))
	Else	pconn:=COM_FindConnectionPoint(psource,SubStr(DIID,1,1)="{" ? DIID : DIID:=COM_GetGuidOfName(psource,DIID))
	If	!pconn || !(ptinf:=COM_GetTypeInfoOfGuid(psource,DIID))
	{
		MsgBox, No Event Interface Exists! Now exit the application.
		ExitApp
	}
	psink:=COM_CoTaskMemAlloc(40+StrLen(prefix)+1), NumPut(1,NumPut(COM_CreateIDispatch(),psink+0)), NumPut(psource,NumPut(ptinf,psink+8))
	DllCall("RtlMoveMemory", "Uint", psink+24, "Uint", COM_GUID4String(DIID,DIID), "Uint", 16)
	DllCall("RtlMoveMemory", "Uint", psink+40, "Uint", &prefix, "Uint", StrLen(prefix)+1)
	NumPut(COM_Advise(pconn,psink),NumPut(pconn,psink+16))
	Return	psink
}

COM_CreateObject(CLSID, IID = "{00020400-0000-0000-C000-000000000046}", CLSCTX = 5)
{
	DllCall("ole32\CoCreateInstance", "Uint", SubStr(CLSID,1,1)="{" ? COM_GUID4String(CLSID,CLSID) : COM_CLSID4ProgID(CLSID,CLSID), "Uint", 0, "Uint", CLSCTX, "Uint", COM_GUID4String(IID,IID), "UintP", ppv)
	Return	ppv
}

COM_ActiveXObject(ProgID)
{
	DllCall("ole32\CoCreateInstance", "Uint", SubStr(ProgID,1,1)="{" ? COM_GUID4String(ProgID,ProgID) : COM_CLSID4ProgID(ProgID,ProgID), "Uint", 0, "Uint", 5, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	Return	COM_GetDefaultInterface(pdisp)
}

COM_GetObject(Moniker)
{
	DllCall("ole32\CoGetObject", "Uint", COM_Unicode4Ansi(Moniker,Moniker), "Uint", 0, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	Return	COM_GetDefaultInterface(pdisp)
}

COM_GetActiveObject(ProgID)
{
	DllCall("oleaut32\GetActiveObject", "Uint", SubStr(ProgID,1,1)="{" ? COM_GUID4String(ProgID,ProgID) : COM_CLSID4ProgID(ProgID,ProgID), "Uint", 0, "UintP", punk)
	DllCall(NumGet(NumGet(1*punk)+0), "Uint", punk, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
	DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)
	Return	COM_GetDefaultInterface(pdisp)
}

COM_CLSID4ProgID(ByRef CLSID, ProgID)
{
	VarSetCapacity(CLSID, 16)
	DllCall("ole32\CLSIDFromProgID", "Uint", COM_Unicode4Ansi(ProgID,ProgID), "Uint", &CLSID)
	Return	&CLSID
}

COM_GUID4String(ByRef CLSID, String)
{
	VarSetCapacity(CLSID, 16)
	DllCall("ole32\CLSIDFromString", "Uint", COM_Unicode4Ansi(String,String,38), "Uint", &CLSID)
	Return	&CLSID
}

COM_ProgID4CLSID(pCLSID)
{
	DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID, "UintP", pProgID)
	Return	COM_Ansi4Unicode(pProgID) . SubStr(COM_CoTaskMemFree(pProgID),1,0)
}

COM_String4GUID(pGUID)
{
	VarSetCapacity(String, 38 * 2 + 1)
	DllCall("ole32\StringFromGUID2", "Uint", pGUID, "Uint", &String, "int", 39)
	Return	COM_Ansi4Unicode(&String, 38)
}

COM_IsEqualGUID(pGUID1, pGUID2)
{
	Return	DllCall("ole32\IsEqualGUID", "Uint", pGUID1, "Uint", pGUID2)
}

COM_CoCreateGuid()
{
	VarSetCapacity(GUID, 16, 0)
	DllCall("ole32\CoCreateGuid", "Uint", &GUID)
	Return	COM_String4GUID(&GUID)
}

COM_CoTaskMemAlloc(cb)
{
	Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}

COM_CoTaskMemFree(pv)
{
	Return	DllCall("ole32\CoTaskMemFree", "Uint", pv)
}

COM_CoInitialize()
{
	Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

COM_CoUninitialize()
{
	Return	DllCall("ole32\CoUninitialize")
}

COM_OleInitialize()
{
	Return	DllCall("ole32\OleInitialize", "Uint", 0)
}

COM_OleUninitialize()
{
	Return	DllCall("ole32\OleUninitialize")
}

COM_SysAllocString(sString)
{
	Return	DllCall("oleaut32\SysAllocString", "Uint", COM_Ansi2Unicode(sString,wString))
}

COM_SysFreeString(bstr)
{
	Return	DllCall("oleaut32\SysFreeString", "Uint", bstr)
}

COM_SysStringLen(bstr)
{
	Return	DllCall("oleaut32\SysStringLen", "Uint", bstr)
}

COM_SafeArrayDestroy(psa)
{
	Return	DllCall("oleaut32\SafeArrayDestroy", "Uint", psa)
}

COM_VariantClear(pvarg)
{
	Return	DllCall("oleaut32\VariantClear", "Uint", pvarg)
}

COM_AtlAxWinInit(Version = "")
{
	COM_CoInitialize()
	If !DllCall("GetModuleHandle", "str", "atl" . Version)
	    DllCall("LoadLibrary"    , "str", "atl" . Version)
	Return	DllCall("atl" . Version . "\AtlAxWinInit")
}

COM_AtlAxWinTerm(Version = "")
{
	COM_CoUninitialize()
	If hModule:=DllCall("GetModuleHandle", "str", "atl" . Version)
	Return	DllCall("FreeLibrary"    , "Uint", hModule)
}

COM_AtlAxGetControl(hWnd, Version = "")
{
	DllCall("atl" . Version . "\AtlAxGetControl", "Uint", hWnd, "UintP", punk)
	pdsp:=COM_QueryInterface(punk,IID_IDispatch:="{00020400-0000-0000-C000-000000000046}")
	COM_Release(punk)
	Return	pdsp
}

COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
{
	punk:=COM_QueryInterface(pdsp,IID_IUnknown:="{00000000-0000-0000-C000-000000000046}")
	DllCall("atl" . Version . "\AtlAxAttachControl", "Uint", punk, "Uint", hWnd, "Uint", 0)
	COM_Release(punk)
}

COM_AtlAxCreateControl(hWnd, Name, Version = "")
{
	VarSetCapacity(IID_NULL, 16, 0)
	DllCall("atl" . Version . "\AtlAxCreateControlEx", "Uint", COM_Unicode4Ansi(Name,Name), "Uint", hWnd, "Uint", 0, "Uint", 0, "UintP", punk, "Uint", &IID_NULL, "Uint", 0)
	pdsp:=COM_QueryInterface(punk,IID_IDispatch:="{00020400-0000-0000-C000-000000000046}")
	COM_Release(punk)
	Return	pdsp
}

COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
{
	Return	DllCall("CreateWindowEx", "Uint",0x200, "str", "AtlAxWin" . Version, "Uint", Name ? &Name : 0, "Uint", 0x54000000, "int", l, "int", t, "int", w, "int", h, "Uint", hWnd, "Uint", 0, "Uint", 0, "Uint", 0)
}

COM_AtlAxGetContainer(pdsp)
{
	DllCall(NumGet(NumGet(1*pdsp)+ 0), "Uint", pdsp, "Uint", COM_GUID4String(IID_IOleWindow,"{00000114-0000-0000-C000-000000000046}"), "UintP", pwin)
	DllCall(NumGet(NumGet(1*pwin)+12), "Uint", pwin, "UintP", hCtrl)
	DllCall(NumGet(NumGet(1*pwin)+ 8), "Uint", pwin)
	Return	DllCall("GetParent", "Uint", hCtrl)
}

COM_Ansi4Unicode(pString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	sString
}

COM_Unicode4Ansi(ByRef wString, sString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

COM_Ansi2Unicode(ByRef sString, ByRef wString, nSize = "")
{
	If (nSize = "")
	    nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
	Return	&wString
}

COM_Unicode2Ansi(ByRef wString, ByRef sString, nSize = "")
{
	pString := wString + 0 > 65535 ? wString : &wString
	If (nSize = "")
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	&sString
}
