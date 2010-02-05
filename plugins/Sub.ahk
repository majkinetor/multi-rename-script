;   A u t h o r : 	 	 m a j k i n e t o r  
 ;   V e r s i o n : 	 	 1 . 0  
 ;   D e s c r i p t i o n :   	 E x t r a c t s   s u b s t r i n g   f r o m   f i l e   n a m e   f r o m   s t r 1   u p   t o   t h e   s t r 2 .  
 ;  
 ;   U s a g e : 	 	 = S u b . [ | ] s t r 1 . s t r 2 	 	 ( b o t h   s t r i n g 1   a n d   s t r 2   a r e   o p t i o n a l )  
 ; 	 	 	 	 U s e   " | "   s i g n   a s   f i r s t   c h a r   i f   y o u   w a n t   t o   r e m o v e   s t r 1   f r o m   t h e   r e s u l t .  
 ; 	 	 	 	 I f   t h e   s t r 1   i s   n o t   f o u n d ,   p o s i t i o n   1   w i l l   b e   u s e d .  
 S u b : 	  
 	 i f   # 3   =  
 	 {  
 	 	 # R e s   : =   # f n  
 	 	 r e t u r n  
 	 }  
  
 	 # f l a g   : =   0  
 	 i f   * & # 1   =   1 2 4 	 	 	 	 	 	 	 	 ; i f   f i r s t   c h a r   i s   |   r e m o v e   i t   a n d   s e t   t h e   f l a g  
 	 	 # 1   : =   S u b S t r ( # 1 , 2 ) ,   # f l a g   : =   1  
 	 S u b 1   : =   ( # 1   =   " " )   ?   1   :   I n S t r ( # f n ,   # 1 ) 	 	 ; i f   u s e r   o m i t e d   s t r 1   u s e   1 ,   e l s e   i t s   p o s i t i o n   i n   t h e   s t r i n g  
 	 i f   S u b 1   & &   # f l a g 	 	 	 	 	 	 	 ; i f   t h e r e   w a s   | ,   a d j u s t  
 	 	 S u b 1   + =   S t r L e n ( # 1 ) 	  
 	 I f E q u a l ,   S u b 1 ,   0 ,   S e t E n v ,   S u b 1 ,   1 	 	 	 ; i f   n o t h i n g   w a s   f o u n d ,   s e t   t o   1  
  
 	 S u b 2   : =   ( # 2   =   " " )   ?   S t r L e n ( # f n ) + 1   :   I n S t r ( # f n ,   # 2 ,   f a l s e ,   S u b 1 + 1 )  
 	 i f   ! S u b 2 	  
 	 	 S u b 2   : =   S t r L e n ( # f n )   +   1  
 	 # R e s   : =   S u b S t r ( # f n ,   S u b 1 ,   S u b 2 - S u b 1 )  
  
 r e t u r n  
  
 S _ G e t F i e l d s :  
 	 # R e s   =   *  
 r e t u r n 