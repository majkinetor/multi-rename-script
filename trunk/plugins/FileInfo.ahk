;Author:		majkinetor
;Version:		1.0
;Description: 	FileInfo associates lines from the "FileInfo.txt" file with the files in the rename list.
;				To treat FileInfo.txt as CSV file pass number of column that you want returned as parameter
;				for instance [FileInfo.5].
FileInfo:
	if (FileInfo_file = "")
		FileInfo_Set()
	
	;if in preview we don't know where we are so, always search from the beginning
	;if in real renaming, the order is sequential so we can use last index to increase speed.
	if (#flag = "prev")
	   FileInfo_j := 1
	else IfEqual, #no, 1, SetEnv, FileInfo_j, 1

	if !(FileInfo_j := InStr(FileInfo_file, "`n" #no, false, FileInfo_j))
		return
	
	FileInfo_j += StrLen(#no)+2
	#tmp := #Res := SubStr(FileInfo_file, FileInfo_j, InStr(FileInfo_file, "`n", false, FileInfo_j) - FileInfo_j)
	if #1 is Integer
		loop, parse, #tmp, CSV
			if A_Index = %#1%
			{
				#Res := A_LoopField
				break
			}

	FileInfo_j += StrLen(#tmp)									;save the last index for to increase search speed in real time 
return


FileInfo_Set(){
	local fn	

	FileInfo_file := "`n"

	fn := A_ScriptDir "\plugins\FileInfo.txt"
	if !FileExist( fn ) {
		FileInfo_file = 
		(LTrim

			1=To rename files, using FileInfo, save the text into the
			2=FileInfo.txt text file. Each file in the list will be
			3=associated with line of the text from this file, based 
			4=on its position in the list. 
			5=
			6=You can set range with [=FileInfo:range] syntax, where
			7=range is specified using the same rules as with [N].
			8=
			9=FileInfo.txt is located in MRS\plugins folder.

		)
		return 
	}

	loop, read, %fn%
		FileInfo_file .=  A_Index "=" A_LoopReadLine "`n"
}

FileInfo_GetFields:
	  #Res = *
return