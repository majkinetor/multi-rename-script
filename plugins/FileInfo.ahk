; A u t h o r : 	 	 m a j k i n e t o r  
 ; V e r s i o n : 	 	 1 . 0  
 ; D e s c r i p t i o n :   	 F i l e I n f o   a s s o c i a t e s   l i n e s   f r o m   t h e   " F i l e I n f o . t x t "   f i l e   w i t h   t h e   f i l e s   i n   t h e   r e n a m e   l i s t .  
 ; 	 	 	 	 T o   t r e a t   F i l e I n f o . t x t   a s   C S V   f i l e   p a s s   n u m b e r   o f   c o l u m n   t h a t   y o u   w a n t   r e t u r n e d   a s   p a r a m e t e r  
 ; 	 	 	 	 f o r   i n s t a n c e   [ F i l e I n f o . 5 ] .  
 F i l e I n f o :  
 	 i f   ( F i l e I n f o _ f i l e   =   " " )  
 	 	 F i l e I n f o _ S e t ( )  
 	  
 	 ; i f   i n   p r e v i e w   w e   d o n ' t   k n o w   w h e r e   w e   a r e   s o ,   a l w a y s   s e a r c h   f r o m   t h e   b e g i n n i n g  
 	 ; i f   i n   r e a l   r e n a m i n g ,   t h e   o r d e r   i s   s e q u e n t i a l   s o   w e   c a n   u s e   l a s t   i n d e x   t o   i n c r e a s e   s p e e d .  
 	 i f   ( # f l a g   =   " p r e v " )  
 	       F i l e I n f o _ j   : =   1  
 	 e l s e   I f E q u a l ,   # n o ,   1 ,   S e t E n v ,   F i l e I n f o _ j ,   1  
  
 	 i f   ! ( F i l e I n f o _ j   : =   I n S t r ( F i l e I n f o _ f i l e ,   " ` n "   # n o ,   f a l s e ,   F i l e I n f o _ j ) )  
 	 	 r e t u r n  
 	  
 	 F i l e I n f o _ j   + =   S t r L e n ( # n o ) + 2  
 	 # t m p   : =   # R e s   : =   S u b S t r ( F i l e I n f o _ f i l e ,   F i l e I n f o _ j ,   I n S t r ( F i l e I n f o _ f i l e ,   " ` n " ,   f a l s e ,   F i l e I n f o _ j )   -   F i l e I n f o _ j )  
 	 i f   # 1   i s   I n t e g e r  
 	 	 l o o p ,   p a r s e ,   # t m p ,   C S V  
 	 	 	 i f   A _ I n d e x   =   % # 1 %  
 	 	 	 {  
 	 	 	 	 # R e s   : =   A _ L o o p F i e l d  
 	 	 	 	 b r e a k  
 	 	 	 }  
  
 	 F i l e I n f o _ j   + =   S t r L e n ( # t m p ) 	 	 	 	 	 	 	 	 	 ; s a v e   t h e   l a s t   i n d e x   f o r   t o   i n c r e a s e   s e a r c h   s p e e d   i n   r e a l   t i m e    
 r e t u r n  
  
  
 F i l e I n f o _ S e t ( ) {  
 	 l o c a l   f n 	  
  
 	 F i l e I n f o _ f i l e   : =   " ` n "  
  
 	 f n   : =   A _ S c r i p t D i r   " \ p l u g i n s \ F i l e I n f o . t x t "  
 	 i f   ! F i l e E x i s t (   f n   )   {  
 	 	 F i l e I n f o _ f i l e   =    
 	 	 ( L T r i m  
  
 	 	 	 1 = T o   r e n a m e   f i l e s ,   u s i n g   F i l e I n f o ,   s a v e   t h e   t e x t   i n t o   t h e  
 	 	 	 2 = F i l e I n f o . t x t   t e x t   f i l e .   E a c h   f i l e   i n   t h e   l i s t   w i l l   b e  
 	 	 	 3 = a s s o c i a t e d   w i t h   l i n e   o f   t h e   t e x t   f r o m   t h i s   f i l e ,   b a s e d    
 	 	 	 4 = o n   i t s   p o s i t i o n   i n   t h e   l i s t .    
 	 	 	 5 =  
 	 	 	 6 = Y o u   c a n   s e t   r a n g e   w i t h   [ = F i l e I n f o : r a n g e ]   s y n t a x ,   w h e r e  
 	 	 	 7 = r a n g e   i s   s p e c i f i e d   u s i n g   t h e   s a m e   r u l e s   a s   w i t h   [ N ] .  
 	 	 	 8 =  
 	 	 	 9 = F i l e I n f o . t x t   i s   l o c a t e d   i n   M R S \ p l u g i n s   f o l d e r .  
  
 	 	 )  
 	 	 r e t u r n    
 	 }  
  
 	 l o o p ,   r e a d ,   % f n %  
 	 	 F i l e I n f o _ f i l e   . =     A _ I n d e x   " = "   A _ L o o p R e a d L i n e   " ` n "  
 }  
  
 F i l e I n f o _ G e t F i e l d s :  
 	     # R e s   =   *  
 r e t u r n 