H a s h ( p D a t a ,   n S i z e ,   S I D   =   " C R C 3 2 " ,   n I n i t i a l   =   0 )  
 {  
 	 C A L G _ M D 5   : =   0 x 8 0 0 3  
 	 C A L G _ S H A   : =   C A L G _ S H A 1   : =   0 x 8 0 0 4  
 	 I f   N o t 	 C A L G _ % S I D %  
 	 {  
 	 	 F o r m a t I   : =   A _ F o r m a t I n t e g e r  
 	 	 S e t F o r m a t ,   I n t e g e r ,   H  
 	 	 s H a s h   : =   D l l C a l l ( " n t d l l \ R t l C o m p u t e C r c 3 2 " ,   " U i n t " ,   n I n i t i a l ,   " U i n t " ,   p D a t a ,   " U i n t " ,   n S i z e ,   " U i n t " )  
 	 	 S e t F o r m a t ,   I n t e g e r ,   % F o r m a t I %  
 	 	 S t r i n g T r i m L e f t , 	 s H a s h ,   s H a s h ,   2  
 	 	 S t r i n g U p p e r , 	 s H a s h ,   s H a s h  
 	 	 R e t u r n 	 S u b S t r ( 0 0 0 0 0 0 0   .   s H a s h ,   - 7 )  
 	 }  
  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t A c q u i r e C o n t e x t A " ,   " U i n t P " ,   h P r o v ,   " U i n t " ,   0 ,   " U i n t " ,   0 ,   " U i n t " ,   1 ,   " U i n t " ,   0 x F 0 0 0 0 0 0 0 )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t C r e a t e H a s h " ,   " U i n t " ,   h P r o v ,   " U i n t " ,   C A L G _ % S I D % ,   " U i n t " ,   0 ,   " U i n t " ,   0 ,   " U i n t P " ,   h H a s h )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t H a s h D a t a " ,   " U i n t " ,   h H a s h ,   " U i n t " ,   p D a t a ,   " U i n t " ,   n S i z e ,   " U i n t " ,   0 )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t G e t H a s h P a r a m " ,   " U i n t " ,   h H a s h ,   " U i n t " ,   2 ,   " U i n t " ,   0 ,   " U i n t P " ,   n S i z e ,   " U i n t " ,   0 )  
 	 V a r S e t C a p a c i t y ( H a s h V a l ,   n S i z e ,   0 )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t G e t H a s h P a r a m " ,   " U i n t " ,   h H a s h ,   " U i n t " ,   2 ,   " U i n t " ,   & H a s h V a l ,   " U i n t P " ,   n S i z e ,   " U i n t " ,   0 )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t D e s t r o y H a s h " ,   " U i n t " ,   h H a s h )  
 	 D l l C a l l ( " a d v a p i 3 2 \ C r y p t R e l e a s e C o n t e x t " ,   " U i n t " ,   h P r o v ,   " U i n t " ,   0 )  
  
 	 F o r m a t I   : =   A _ F o r m a t I n t e g e r  
 	 S e t F o r m a t ,   I n t e g e r ,   H  
 	 L o o p , 	 % n S i z e %  
 	 	 s H a s h   . =   S u b S t r ( * ( & H a s h V a l   +   A _ I n d e x   -   1 ) ,   - 1 )  
 	 S e t F o r m a t ,   I n t e g e r ,   % F o r m a t I %  
 	 S t r i n g R e p l a c e , 	 s H a s h ,   s H a s h ,   x ,   0 ,   A l l  
 	 S t r i n g U p p e r , 	 s H a s h ,   s H a s h  
 	 R e t u r n 	 s H a s h  
 }  
 