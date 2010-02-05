F i l e _ R e a d M e m o r y ( s F i l e ,   p B u f f e r ,   n S i z e   =   5 1 2 ,   b A p p e n d   =   F a l s e )  
 {  
       I f   ! ( 1   +   h F i l e   : =   F i l e _ C r e a t e F i l e ( s F i l e ,   4 ,   0 x 4 0 0 0 0 0 0 0 ,   1 ) )  
       R e t u r n   " F i l e   n o t   c r e a t e d / o p e n e d ! "  
       F i l e _ S e t F i l e P o i n t e r ( h F i l e ,   b A p p e n d   ?   2   :   0 )  
       n S i z e   : =   F i l e _ W r i t e F i l e ( h F i l e ,   p B u f f e r ,   n S i z e )  
       F i l e _ S e t E n d O f F i l e ( h F i l e )  
       F i l e _ C l o s e H a n d l e ( h F i l e )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ W r i t e M e m o r y ( s F i l e ,   B y R e f   s B u f f e r ,   n S i z e   =   0 )  
 {  
       I f   ! ( 1   +   h F i l e   : =   F i l e _ C r e a t e F i l e ( s F i l e ,   3 ,   0 x 8 0 0 0 0 0 0 0 ,   1 ) )  
       R e t u r n   " F i l e   n o t   f o u n d ! "  
       V a r S e t C a p a c i t y ( s B u f f e r ,   n S i z e   + =   n S i z e   ?   0   :   F i l e _ G e t F i l e S i z e ( h F i l e ) )  
       n S i z e   : =   F i l e _ R e a d F i l e ( h F i l e ,   & s B u f f e r ,   n S i z e )  
       V a r S e t C a p a c i t y ( s B u f f e r ,   - 1 )  
       F i l e _ C l o s e H a n d l e ( h F i l e )  
       R e t u r n   n S i z e  
 }  
  
  
 F i l e _ C r e a t e F i l e ( s F i l e ,   n C r e a t e   =   3 ,   n A c c e s s   =   0 x 1 F 0 1 F F ,   n S h a r e   =   7 ,   b F o l d e r   =   F a l s e )  
 {  
 / *  
       C R E A T E _ N E W         =   1  
       C R E A T E _ A L W A Y S   =   2  
       O P E N _ E X I S T I N G   =   3  
       O P E N _ A L W A Y S       =   4  
  
       G E N E R I C _ R E A D         =   0 x 8 0 0 0 0 0 0 0  
       G E N E R I C _ W R I T E       =   0 x 4 0 0 0 0 0 0 0  
       G E N E R I C _ E X E C U T E   =   0 x 2 0 0 0 0 0 0 0  
       G E N E R I C _ A L L           =   0 x 1 0 0 0 0 0 0 0    
  
       F I L E _ S H A R E _ R E A D       =   1  
       F I L E _ S H A R E _ W R I T E     =   2  
       F I L E _ S H A R E _ D E L E T E   =   4  
 * /  
       R e t u r n   D l l C a l l ( " C r e a t e F i l e " ,   " U i n t " ,   & s F i l e ,   " U i n t " ,   n A c c e s s ,   " U i n t " ,   n S h a r e ,   " U i n t " ,   0 ,   " U i n t " ,   n C r e a t e ,   " U i n t " ,   b F o l d e r   ?   0 x 0 2 0 0 0 0 0 0   :   0 ,   " U i n t " ,   0 )  
 }  
  
 F i l e _ D e l e t e F i l e ( s F i l e )  
 {  
       R e t u r n   D l l C a l l ( " D e l e t e F i l e " ,   " U i n t " ,   & s F i l e )  
 }  
  
 F i l e _ R e a d F i l e ( h F i l e ,   p B u f f e r ,   n S i z e   =   1 0 2 4 )  
 {  
       D l l C a l l ( " R e a d F i l e " ,   " U i n t " ,   h F i l e ,   " U i n t " ,   p B u f f e r ,   " U i n t " ,   n S i z e ,   " U i n t P " ,   n S i z e ,   " U i n t " ,   0 )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ W r i t e F i l e ( h F i l e ,   p B u f f e r ,   n S i z e   =   1 0 2 4 )  
 {  
       D l l C a l l ( " W r i t e F i l e " ,   " U i n t " ,   h F i l e ,   " U i n t " ,   p B u f f e r ,   " U i n t " ,   n S i z e ,   " U i n t P " ,   n S i z e ,   " U i n t " ,   0 )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ G e t F i l e S i z e ( h F i l e )  
 {  
       D l l C a l l ( " G e t F i l e S i z e E x " ,   " U i n t " ,   h F i l e ,   " i n t 6 4 P " ,   n S i z e )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ S e t E n d O f F i l e ( h F i l e )  
 {  
       R e t u r n   D l l C a l l ( " S e t E n d O f F i l e " ,   " U i n t " ,   h F i l e )  
 }  
  
 F i l e _ S e t F i l e P o i n t e r ( h F i l e ,   n P o s   =   0 ,   n M o v e   =   0 )  
 {  
 / *  
       F I L E _ B E G I N       =   0  
       F I L E _ C U R R E N T   =   1  
       F I L E _ E N D           =   2  
 * /  
       R e t u r n   D l l C a l l ( " S e t F i l e P o i n t e r E x " ,   " U i n t " ,   h F i l e ,   " i n t 6 4 " ,   n M o v e ,   " U i n t " ,   0 ,   " U i n t " ,   n P o s )  
 }  
  
 F i l e _ C l o s e H a n d l e ( H a n d l e )  
 {  
       R e t u r n   D l l C a l l ( " C l o s e H a n d l e " ,   " U i n t " ,   H a n d l e )  
 }  
  
  
 F i l e _ I n t e r n e t O p e n ( s A g e n t   =   " A u t o H o t k e y " ,   n T y p e   =   4 )  
 {  
       I f   ! D l l C a l l ( " G e t M o d u l e H a n d l e " ,   " s t r " ,   " w i n i n e t " )  
               D l l C a l l ( " L o a d L i b r a r y "         ,   " s t r " ,   " w i n i n e t " )  
       R e t u r n   D l l C a l l ( " w i n i n e t \ I n t e r n e t O p e n A " ,   " s t r " ,   s A g e n t ,   " U i n t " ,   n T y p e ,   " U i n t " ,   0 ,   " U i n t " ,   0 ,   " U i n t " ,   0 )  
 }  
  
 F i l e _ I n t e r n e t O p e n U r l ( h I n e t ,   s U r l ,   n F l a g s   =   0 ,   p H e a d e r s   =   0 )  
 {  
       R e t u r n   D l l C a l l ( " w i n i n e t \ I n t e r n e t O p e n U r l A " ,   " U i n t " ,   h I n e t ,   " U i n t " ,   & s U r l ,   " U i n t " ,   p H e a d e r s ,   " U i n t " ,   - 1 ,   " U i n t " ,   n F l a g s   |   0 x 8 0 0 0 0 0 0 0 ,   " U i n t " ,   0 )       ;   I N T E R N E T _ F L A G _ R E L O A D   =   0 x 8 0 0 0 0 0 0 0  
 }  
  
 F i l e _ I n t e r n e t R e a d F i l e ( h F i l e ,   p B u f f e r ,   n S i z e   =   1 0 2 4 )  
 {  
       D l l C a l l ( " w i n i n e t \ I n t e r n e t R e a d F i l e " ,   " U i n t " ,   h F i l e ,   " U i n t " ,   p B u f f e r ,   " U i n t " ,   n S i z e ,   " U i n t P " ,   n S i z e )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ I n t e r n e t W r i t e F i l e ( h F i l e ,   p B u f f e r ,   n S i z e   =   1 0 2 4 )  
 {  
       D l l C a l l ( " w i n i n e t \ I n t e r n e t W r i t e F i l e " ,   " U i n t " ,   h F i l e ,   " U i n t " ,   p B u f f e r ,   " U i n t " ,   n S i z e ,   " U i n t P " ,   n S i z e )  
       R e t u r n   n S i z e  
 }  
  
 F i l e _ I n t e r n e t S e t F i l e P o i n t e r ( h F i l e ,   n P o s   =   0 ,   n M o v e   =   0 )  
 {  
       R e t u r n   D l l C a l l ( " w i n i n e t \ I n t e r n e t S e t F i l e P o i n t e r " ,   " U i n t " ,   h F i l e ,   " U i n t " ,   n M o v e ,   " U i n t " ,   0 ,   " U i n t " ,   n P o s ,   " U i n t " ,   0 )  
 }  
  
 F i l e _ I n t e r n e t C l o s e H a n d l e ( H a n d l e )  
 {  
       R e t u r n   D l l C a l l ( " w i n i n e t \ I n t e r n e t C l o s e H a n d l e " ,   " U i n t " ,   H a n d l e )  
 }  
 