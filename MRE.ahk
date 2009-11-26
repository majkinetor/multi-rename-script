/*
 Title:	MRE
		Multi-Rename Engine
 */


/*
 Function:	MRE_Rename
			Rename files using MRE engine.

 Parameters:
			SrcFileList	- List of file paths separated by new line.
			DstFileList or MRS	- List of dst file paths or Multi-Rename Script if parameter contains ">" as the first character.
			Options		- Rename options. See bellow.
			Handler		- Notification function.

 MRS:
			Multi-Rename Script is a domain specific code describing steps in batch file renaming.
			Each line in the script contains one function. MRS syntax is:
			
			MRS					:: ">" { Function "`n" }+
			Function			:: <Mask> | <SR> | <Case> | <UDF>

			Mask				:: <Integrated_Mask> | <Mask_Plugin> | <Litteral>
			Integrated_Mask		:: "[" <Key> <Params> "]"
			Mask_Plugin			:: "[=" Plugin_Name ["." Plugin_Field ["." Plugin_Unit]] [Range] "]"
			Key					:: N | C | P | ....
			Params				:: p1, p2, ... pn
 
 Options:
		S	- Simulate. 
		D	- Create Dirs.
		C	- Stop on collision.
		E	- Stop on source file not exist.
		R	- Stop on error.
		O	- Overwrite files.
		W	- Process window messages in a loop.
		min.max	- Do renaming from min to max from SrcFileList.

 Example:
	(start code)

	MRS=
	(LTrim
		Mask("[C10+5:2]. [N4-]")
		SR("_", " ", "full") 
		Case("Upper") 
		Mask("[N] ([=Hash.SHA1.lower])")
	)

	;rename files
	DstFileList := MRE_Rename(SrcFileList, ">" MRS), ErrFileList := ErrorLevel
	
	;undo rename
	MRE_Rename(DstFileList, SrcFileList)

	(end code)
 */
MRE_Rename(ByRef SrcFileList, MRS, Options="", Handler="") {

	;	loop, parse, Options, %A_Space%
	;		ifEqual, A_LoopField, , continue
	;		else if A_LoopField in S,D,C,E
	;			 opt_%A_LoopField% := true
	;		else if (A_LoopFIeld+0 != "")
	;			 opt_min := floor( A_LoopField), opt_max := 
	
	lineCount := MRE_lineCount( SrcFileList )
	loop, %lineCount%
	{
		#no := A_Index
		srcFilePath := A_LoopField

		dstFilePath := MRE_exec( srcFilePath, MRS )

		;SplitPath, srcFilePath, ,dir
		;newPath := dir "\" newName

	;		res := DllCall("MoveFileEx", "str", oldPath, "str", newpath, "uint", flags)
	;		if !res 
	;			LV_Modify(delRow, "col5", ErrMsg() ), delRow++
	;		else {
	;			LV_Delete(delRow)
	;			FileAppend, "%oldPath%" -> "%newName%"`r`n, %gResultList%
	;		}

	;		if !mod(A_Index, 10)			;do win messages
	;			sleep, -1
	}
}

MREF_Mask(SrcFileName, Mask, Mode="") {
	
}

MREF_SR(SrcFileName, SearchString, ReplaceString="", bRE="",  Mode=""){

}

MREF_Case( Case ) {

}

;==============================================================================================
;		Mask1    "[C10+5:2]. [N4-] [E]
;		Mask2	 bak			
;		SR		"_" " "
;		Case	Upper
;		Mask	[N] ([=Hash.SHA1.lower])
;       UDF		param1 param2 "param with space"
;
MRE_compile( MRS ) {
	loop, parse, MRS, `n
	{
		j := InStr(A_LoopField, "(")
		MRS_%A_Index%f := SubStr(A_LoopField, 1, j-1), MRS_%A_Index%p := SubStr(A_LoopField, j+1)
	}
}

;execute MRS script on FilePath
MRE_exec( ByRef FilePath, ByRef MRS ) {
	
}

/* 
 Function: lineCount
		   Returns number of lines in a text.
 */
MRE_lineCount( ByRef Txt ) {
	StringReplace, _, Txt, `n, , ReplaceAll
	return ErrorLevel + 1
}

/*
 Function:		ErrMsg
				Display description of operating system error
				
 Parameters:
				ErrNum	- Error number (default = A_LastError)

 Returns:
				String
 */
MRE_errMsg( ErrNum="" ){ 
	static FORMAT_MESSAGE_FROM_SYSTEM=0x1000
	ifEqual, ErrNum,, SetEnv, ErrNum, %A_LastError%

	VarSetCapacity(ErrorString, 1024) ;String to hold the error-message.    
	DllCall("FormatMessage", "UINT", FORMAT_MESSAGE_FROM_SYSTEM, "UINT", 0, "UINT", ErrNum, "UINT", 0, "Str", errMsg, "UINT", 1024, "UINT", 0)
    
	StringReplace, errMsg, errMsg,`r`n, %A_Space%, All  ;Replaces newlines by A_Space for inline-output   
	return errMsg 
}

/* Group: About
	o v1.0 by majkinetor.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> .
 */