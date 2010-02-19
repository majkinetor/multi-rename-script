; Author:		majkinetor
; Version:		1.0
; Description: 	Extracts substring from file name from str1 up to the str2.
;
; Usage:		=Sub.[|]str1.str2		(both string1 and str2 are optional)
;				Use "|" sign as first char if you want to remove str1 from the result.
;				If the str1 is not found, position 1 will be used.
Sub:	
	if #3 =
	{
		#Res := #fn
		return
	}

	#flag := 0
	if *&#1 = 124								;if first char is | remove it and set the flag
		#1 := SubStr(#1,2), #flag := 1
	Sub1 := (#1 = "") ? 1 : InStr(#fn, #1)		;if user omited str1 use 1, else its position in the string
	if Sub1 && #flag							;if there was |, adjust
		Sub1 += StrLen(#1)	
	IfEqual, Sub1, 0, SetEnv, Sub1, 1			;if nothing was found, set to 1

	Sub2 := (#2 = "") ? StrLen(#fn)+1 : InStr(#fn, #2, false, Sub1+1)
	if !Sub2	
		Sub2 := StrLen(#fn) + 1
	#Res := SubStr(#fn, Sub1, Sub2-Sub1)

return

S_GetFields:
	#Res = *
return