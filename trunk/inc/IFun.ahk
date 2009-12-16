;   Globals
;   ------------------------------------
;   #Res    - result
;
;   #fn     - file name without extension
;   #fp     - file path
;   #fe     - file extension
;   #fd	    - file directory
;   #no     - file number in the list
;
;   #1 - #3 - params
;   #tmp    - temprorary placeholder
;   #flag   - prev|real
;==============================================================================
_TC:
	#Res := TCWdx_GetField(#fp, #1, #2, #3)
return

_Const:
	#Res := #1
return

;------------------------------------------------------------------------------
;[N]      Return unchanged		
;[N  n]	  Nth char					#1=n							(#2=-  #3=n)

;[N  n-m] From n to m				#1=n   #2=-  #3=m
;[N   n-] From n to end				#1=n   #2=-						(#3=StrLen)
;[N n--m] From n to -m				#1=n   #2=-  #3=-m	

;[N -n-m] From -n to -m				#1=-n  #2=-  #3=m
;[N  -n-] From -n to end			#1=-n  #2=-						(#3=StrLen)

;[N  n,m] From n, m.				#1=n   #2=,  #3=m
;[N  n, ] From n to end				#1=n   #2=,						(#3=StrLen)

;[N -n,m] from - n, m				#1=-n  #2=,  #3=m
;[N -n,]  from - n tp end			#1=-n  #2=,						(#3=StrLen)

_FN:
E:
N:
	#Res =
	if (A_ThisLabel != "N")
		#fn := (A_ThisLabel = "E") ? #fe : #fp

	if (#1 #2 #3 = ""){
		#Res := #fn
		return
	}

	if (#1 <= 0) {
		#1 += StrLen(#fn) + 1
		IfLess #1, 1, SetEnv #1, 1
												 
		if (#3 != "") && (#2 = "-") {		
			#3 := StrLen(#fn)-#3+1
			IfLess, #3, %#1%, return
		}
	}
	
	if (#3!="") and (#3 < 0) {
		#3 += StrLen(#fn)
		IfLess, #3, %#1%, return
	}														  

	if #3=
		#3 := (#2 = "") ? #1 : StrLen(#fn)

	#Res := #2="," ? SubStr(#fn, #1, #3) : SubStr(#fn, #1, #3-#1+1)			;in case  #2=""  it will evaluate as -
return

;------------------------------------------------------------------------------
; [C s+i:w] Counter  s-start, i-increment, w-width
C:
	#1 .= (#1 = "") ? 1 : 
	#2 := (#2 = "") ? 0 : #2-1
	#3 .= (#3 = "") ? 1 : 
	#Res := (#no-1)+#1 + (#no-1)*#2

	if (#tmp := #3-StrLen(#Res)) > 0
		VarSetCapacity(C_w, #tmp, 48),  NumPut(0, &C_W+#tmp, "Char"),  VarSetCapacity(C_W, -1),  #Res := C_w #Res
return

;------------------------------------------------------------------------------

;[Y] Paste year in 4 digit form
Y:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,1,4)
return

;[y] Paste year in 2 digit form
_y:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,3,2)
return

;[M] Paste month, 2 digit   
M:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,3,2)
return

;[D] Paste day, 2 digit
D:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,7,2)
return

;[t] Paste time, as defined in current country settings. : is replaced by a dot.
_t:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,9,2) "." SubStr(#tmp,11,2) "." SubStr(#tmp,13,2)
return

;[h]	Paste hours, always in 24 hour 2 digit format
_h:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,9,2)
return

;[m]	Paste minutes, in 2 digit format
_m:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,11,2)
return

;[s]	Paste seconds, in 2 digit format
_s:
	FileGetTime, #tmp, %#fp%, M
	#Res := SubStr(#tmp,13,2)
return

;[P]	Parent directory
P:
	#Res := SubStr(#fd, InStr(#fd, "\", false, 0)+1)
	if StrLen(#Res) = 2
		StringTrimRight, #Res, #Res, 1
return

;[G]    Grand parent dir
G:
	StringMid, #fd, #fd, 1, InStr(#fd, "\", false, 0)-1
	goto P
return

;-------------------------------------------------------------------------------