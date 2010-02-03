;----------------------------------------------------------------
; Function:		ErrMsg
;				Display description of operating system error
;				
; Parameters:
;				ErrNum	- Error number (default = A_LastError)
;
; Returns:
;				String

; About:	
;				v1.0 by majkinetor
;
ErrMsg(ErrNum=""){ 
	if ErrNum=
		ErrNum := A_LastError

	VarSetCapacity(ErrorString, 1024) ;String to hold the error-message.    
	DllCall("FormatMessage" 
         , "UINT", 0x00001000     ;FORMAT_MESSAGE_FROM_SYSTEM: The function should search the system message-table resource(s) for the requested message. 
         , "UINT", 0	          ;A handle to the module that contains the message table to search. 
         , "UINT", ErrNum 
         , "UINT", 0              ;Language-ID is automatically retreived 
         , "Str",  ErrorString 
         , "UINT", 1024           ;Buffer-Length 
         , "str",  "")            ;An array of values that are used as insert values in the formatted message. (not used) 
    
	StringReplace, ErrorString, ErrorString, `r`n, %A_Space%, All      ;Replaces newlines by A_Space for inline-output   
	return %ErrorString% 
}