; A u t h o r : 	 	 m a j k i n e t o r  
 ; V e r s i o n : 	 	 1 . 0  
 ; D e s c r i p t i o n :   	 R e t u r n s   c h e c k s u m   f o r   t h e   f i l e .   S u p p o r t s   C R C 3 2 ,   M D 5   a n d   S H A 1  
 ;  
 H a s h :  
 	 i f   # t m p   : =   I n S t r ( H a s h _ c a c h e _ % # 1 % ,   # f p   " > " )  
 	 {  
 	 	 # t m p   + =   S t r L e n ( # f p ) + 1  
 	 	 # R e s   : =   S u b S t r ( H a s h _ c a c h e _ % # 1 % ,   # t m p ,   I n S t r ( H a s h _ c a c h e _ % # 1 % ,   " ` n " ,   f a l s e ,   # t m p )   -   # t m p )  
 	 	 g o t o   H a s h _ c a s e  
 	 }  
  
 	 F i l e G e t S i z e ,   # t m p ,   % # f p % ,   M  
 	 i f   ( # t m p   > =   6 4 )   {  
 	 	 # R E S   : =   " >   F I L E   T O   B I G "  
 	 	 r e t u r n  
 	 }  
 	 H a s h _ s i z e   : =   F i l e _ W r i t e M e m o r y ( # f p ,   H a s h _ s D a t a )  
 	 # R e s   : =   H a s h ( & H a s h _ s D a t a ,   H a s h _ s i z e ,   # 1 ) , 	 H a s h _ s D a t a   : =   " "  
 	 H a s h _ c a c h e _ % # 1 %   . =   # f p   " > "   # r e s   " ` n "  
  
   H a s h _ c a s e :  
 	 i f   ( # 2   =   " L o w e r " )  
 	 	   S t r i n g L o w e r ,   # R e s ,   # R e s  
 	 e l s e   S t r i n g U p p e r ,   # R e s ,   # R e s  
 r e t u r n  
  
 H a s h _ G e t F i e l d s :  
 	 # R e s   =    
 	 ( L T r i m      
 	 	 C R C 3 2 | U p p e r | L o w e r  
 	 	 M D 5 | U p p e r | L o w e r  
 	 	 S H A 1 | U p p e r | L o w e r  
 	 )  
 r e t u r n  
  
 # i n c l u d e   p l u g i n s \ _ H a s h \ F i l e . a h k  
 # i n c l u d e   p l u g i n s \ _ H a s h \ H a s h . a h k 