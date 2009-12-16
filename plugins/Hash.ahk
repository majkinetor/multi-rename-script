;Author:		majkinetor
;Version:		1.0
;Description: 	Returns checksum for the file. Supports CRC32, MD5 and SHA1
;
Hash:
	if #tmp := InStr(Hash_cache_%#1%, #fp ">")
	{
		#tmp += StrLen(#fp)+1
		#Res := SubStr(Hash_cache_%#1%, #tmp, InStr(Hash_cache_%#1%, "`n", false, #tmp) - #tmp)
		goto Hash_case
	}

	FileGetSize, #tmp, %#fp%, M
	if (#tmp >= 64) {
		#RES := "> FILE TO BIG"
		return
	}
	Hash_size := File_WriteMemory(#fp, Hash_sData)
	#Res := Hash(&Hash_sData, Hash_size, #1),	Hash_sData := ""
	Hash_cache_%#1% .= #fp ">" #res "`n"

 Hash_case:
	if (#2 = "Lower")
		 StringLower, #Res, #Res
	else StringUpper, #Res, #Res
return

Hash_GetFields:
	#Res = 
	(LTrim  
		CRC32|Upper|Lower
		MD5|Upper|Lower
		SHA1|Upper|Lower
	)
return

#include plugins\_Hash\File.ahk
#include plugins\_Hash\Hash.ahk