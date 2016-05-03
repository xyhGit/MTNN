	.mmregs
FP	.set	AR7


	.sect	".text"
	.global	_Corr_xy2
;----------------------------------------------------------------------
;  26 | void Corr_xy2(                                                         
;  27 | Word16 xn[],           /* (i) Q0  :Target vector.                  */  
;  28 | Word16 y1[],           /* (i) Q0  :Adaptive codebook.              */  
;  29 | Word16 y2[],           /* (i) Q12 :Filtered innovative vector.     */  
;  30 | Word16 g_coeff[],      /* (o) Q[exp]:Correlations between xn,y1,y2 */  
;  31 | Word16 exp_g_coeff[]   /* (o)       :Q-format of g_coeff[]         */  
;  32 | )                                                                      
;----------------------------------------------------------------------

_Corr_xy2:

        PSHM      AR1
        PSHM      AR6
        PSHM      AR7
        FRAME     #-46
;----------------------------------------------------------------------
;  34 | Word16   i,exp;                                                        
;  35 | Word16   exp_y2y2,exp_xny2,exp_y1y2;                                   
;  36 | Word16   y2y2, xny2, y1y2;                                       
;  37 | Word32   L_acc;                                                        
;  38 | Word16   scaled_y2[L_SUBFR];                   
;  43 | for(i=0; i<L_SUBFR; i++) {                                             
;----------------------------------------------------------------------
        MVMM      SP,AR6
        STL       A,*SP(42)
        STM       #40,AR7
        LD        *SP(53),A
        MAR       *+AR6(#2)
        STL       A,*SP(43)
        MVDK      *SP(51),*(AR1)
        LD        *SP(52),A
        STL       A,*SP(44)
        LD        *SP(50),A
        STL       A,*SP(45)
        SSBX      SXM                ; ****
        SSBX      OVM
        NOP
L1:    

;----------------------------------------------------------------------
;  44 | scaled_y2[i] = shr(y2[i], 3);        }                                 
;----------------------------------------------------------------------
        ;ST        #3,*SP(0)             
        ;RSBX      FRCT
        ;RSBX      OVM
        LD        *AR1+,A
        ;CALL      #_crshft   
        SFTA      A,-3                ; ****
        
        BANZD     L1,*+AR7(-1)          
        NOP
        STL       A,*AR6+

        MVMM      SP,AR1
        MAR       *+AR1(#2)
;----------------------------------------------------------------------
;  47 | L_acc = 1;                       /* Avoid case of all zeros */         
;  48 | for(i=0; i<L_SUBFR; i++)                                               
;----------------------------------------------------------------------
        LD        #1,A
        STM       #39,BRC
        SSBX      FRCT
        ;SSBX      OVM
        ORM       #2,*(PMST)
        RPTB      L3-1
L2:    
;----------------------------------------------------------------------
;  49 | L_acc = L_mac(L_acc, scaled_y2[i], scaled_y2[i]);    /* L_acc:Q19 */   
;  51 | exp      = norm_l(L_acc);                                              
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        *AR1+,B
        ;SSBX      SXM
        ;SFTA      A,8                   
        STLM      B,T
        ;SFTA      A,-8                  
        ;ORM       #2,*(PMST)
        ;SSBX      FRCT
        ;SSBX      OVM
        ;ORM       #2,*(PMST)
        MAC       *(BL), A 
L3:    

;----------------------------------------------------------------------
;  52 | y2y2     = round( L_shl(L_acc, exp) );                                 
;  53 | exp_y2y2 = add(exp, 19-16);                          /* Q[19+exp-16] */
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        A,B                   ; |52| 
        ;SSBX      SXM
        ;SFTA      B,8                  ; |52| 
        ;SFTA      B,-8                 ; |52| 
        EXP       B                     ; |52| 
        ;RSBX      FRCT
        NOP
        MVMD      T,AR1
        ;MVKD      *(AR1),*SP(0)
        ;CALL      #_L_shl               ; |52| 
;-----------------  L_shl inline  -------------------------------------
        ;RSBX      OVM        
        ;LD        *SP(0),B
        LDM        AR1,B
        ;SFTA      A,8
        ;SFTA      A,-8
        BC        SHL_L7,BEQ              
        SUB       #1,B,B
        STLM      B,BRC
        ;SSBX      OVM
        RSBX      OVA
        RPTB      SHL_L7-1                 
        SFTA     A,#1       
        BC       SHL_L7,AOV        
SHL_L7:                          
                        
   
;-----------------  L_shl End     -------------------------------------        
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                   ; |52| 
        ;SSBX      OVM
        ;SFTA      A,-8                  ; |52| 
        ADD       #1,#15,A,A            ; |52| 
        SFTA      A,-16,A               ; |52| 

;----------------------------------------------------------------------
;  55 | g_coeff[2]     = y2y2;                                                 
;----------------------------------------------------------------------
        MVDK      *SP(44),*(AR2)
        STL       A,*AR2(2)

;----------------------------------------------------------------------
;  56 | exp_g_coeff[2] = exp_y2y2;                                             
;----------------------------------------------------------------------
        MVMM      SP,AR2
        ;RSBX      OVM
        LD        *(AR1),16,A           ; |56| 
        ;SSBX      OVM
        MVDK      *SP(43),*(AR1)
        ADD       #3,16,A,A             ; |56| 
        STH       A,*AR1(2)             ; |56| 
        MVDK      *SP(42),*(AR3)
        MAR       *+AR2(#2)

;----------------------------------------------------------------------
;  59 | L_acc = 1;                       /* Avoid case of all zeros */         
;  60 | for(i=0; i<L_SUBFR; i++)                                               
;----------------------------------------------------------------------
        STM       #39,BRC
        LD        #1,A
        ;SSBX      FRCT
        ;SSBX      OVM
        ;ORM       #2,*(PMST)
        RPTB      L5-1
L4:    

;----------------------------------------------------------------------
;  61 | L_acc = L_mac(L_acc, xn[i], scaled_y2[i]);           /* L_acc:Q10 */   
;  63 | exp      = norm_l(L_acc);                                              
;----------------------------------------------------------------------
        ;RSBX      OVM
        ;NOP
        ;SFTA      A,8                   ; |61| 
        ;SFTA      A,-8                  ; |61| 
        ;ORM       #2,*(PMST)
        ;SSBX      FRCT
        ;SSBX      OVM
        ;ORM       #2,*(PMST)
        ;NOP
        MAC       *AR2+, *AR3+, A, A    ; |61| 
L5:    

;----------------------------------------------------------------------
;  64 | xny2     = round( L_shl(L_acc, exp) );                                 
;  65 | exp_xny2 = add(exp, 10-16);                          /* Q[10+exp-16] */
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        A,B                   ; |64| 
        ;SFTA      B,8                   ; |64| 
        ;SFTA      B,-8                  ; |64| 
        EXP       B                     ; |64| 
        ;RSBX      FRCT
        NOP
        MVMD      T,AR1
        ;MVKD      *(AR1),*SP(0)
        ;CALL      #_L_shl               
;-----------------  L_shl inline  -------------------------------------
        ;RSBX      OVM        
        ;LD        *SP(0),B
        LDM        AR1,B
        ;SFTA      A,8
        ;SFTA      A,-8 
        BC        SHL_L8,BEQ             
        SUB       #1,B,B
        STLM      B,BRC
        ;SSBX      OVM
        RSBX      OVA
        RPTB      SHL_L8-1                 
        SFTA     A,#1       
        BC       SHL_L8,AOV        
SHL_L8:                                                   
;-----------------  L_shl End     -------------------------------------        
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                   ; |64| 
        ;SSBX      OVM
        ;SFTA      A,-8                  ; |64| 
        ADD       #1,#15,A,A            ; |64| 
        SFTA      A,-16,A               ; |64| 

;----------------------------------------------------------------------
;  67 | g_coeff[3]     = negate(xny2);                                         
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        *(AL),16,A            ; |67| 
        ;SSBX      OVM
        MVDK      *SP(44),*(AR2)
        NEG       A,A                   ; |67| 
        STH       A,*AR2(3)             ; |67| 

;----------------------------------------------------------------------
;  68 | exp_g_coeff[3] = sub(exp_xny2,1);                   /* -2<xn,y2> */    
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        *(AR1),16,A           ; |68| 
        ;SSBX      OVM
        MVMM      SP,AR2
        ADD       #-6,16,A,A            ; |68| 
        SUB       #1,16,A,A             ; |68| 
        MVDK      *SP(43),*(AR1)
        STH       A,*AR1(3)             ; |68| 
        MVDK      *SP(45),*(AR3)
        MAR       *+AR2(#2)

;----------------------------------------------------------------------
;  71 | L_acc = 1;                       /* Avoid case of all zeros */         
;  72 | for(i=0; i<L_SUBFR; i++)                                               
;----------------------------------------------------------------------
        STM       #39,BRC
        ;SSBX      FRCT
        LD        #1,A
        RPTB      L7-1
        
L6:    

;----------------------------------------------------------------------
;  73 | L_acc = L_mac(L_acc, y1[i], scaled_y2[i]);           /* L_acc:Q10 */   
;  75 | exp      = norm_l(L_acc);                                              
;----------------------------------------------------------------------
        ;RSBX      OVM
        ;NOP
        ;SFTA      A,8                   
        ;SFTA      A,-8                  
        ;ORM       #2,*(PMST)
        ;SSBX      FRCT
        ;SSBX      OVM
        ;ORM       #2,*(PMST)
        ;NOP
        MAC       *AR2+, *AR3+, A, A   
L7:    

;----------------------------------------------------------------------
;  76 | y1y2     = round( L_shl(L_acc, exp) );                                 
;  77 | exp_y1y2 = add(exp, 10-16);                          /* Q[10+exp-16] */
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        A,B                   ; |76| 
        ;SFTA      B,8                   ; |76| 
        ;SFTA      B,-8                  ; |76| 
        EXP       B                     ; |76| 
        ;RSBX      FRCT
        NOP
        MVMD      T,AR1
        ;MVKD      *(AR1),*SP(0)
        ;CALL      #_L_shl               ; |76| 
;-----------------  L_shl inline  -------------------------------------
        ;RSBX      OVM        
        ;LD        *SP(0),B
        LDM        AR1,B
        ;SFTA      A,8
        ;SFTA      A,-8 
        BC        SHL_L9,BEQ             
        SUB       #1,B,B
        STLM      B,BRC
        ;SSBX      OVM
        RSBX      OVA
        RPTB      SHL_L9-1                 
        SFTA     A,#1       
        BC       SHL_L9,AOV        
SHL_L9:                                                   
;-----------------  L_shl End     -------------------------------------                
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                   ; |76| 
        ;SSBX      OVM
        ;SFTA      A,-8                  ; |76| 
        ADD       #1,#15,A,A            ; |76| 
        SFTA      A,-16,A               ; |76| 

;----------------------------------------------------------------------
;  79 | g_coeff[4]     = y1y2;                                                 
;----------------------------------------------------------------------
        MVDK      *SP(44),*(AR2)
        STL       A,*AR2(4)

;----------------------------------------------------------------------
;  80 | exp_g_coeff[4] = sub(exp_y1y2,1);    ;                /* 2<y1,y2> */   
;----------------------------------------------------------------------
        ;RSBX      OVM
        LD        *(AR1),16,A           ; |80| 
        ;SSBX      OVM
        NOP
        ADD       #-6,16,A,A            ; |80| 
        SUB       #1,16,A,A             ; |80| 
        MVDK      *SP(43),*(AR1)
        STH       A,*AR1(4)             ; |80| 

;----------------------------------------------------------------------
;  82 | return;                                                                
;----------------------------------------------------------------------

        ANDM      #-833,*(ST1)
        ANDM      #-4,*(PMST)
        FRAME     #46
        POPM      AR7
        POPM      AR6
        POPM      AR1
        RET



	.sect	".text"
	.global	_Cor_h_X

;----------------------------------------------------------------------
;  92 | void Cor_h_X(                                                          
;  93 | Word16 h[],        /* (i) Q12 :Impulse response of filters      */     
;  94 | Word16 X[],        /* (i)     :Target vector                    */     
;  95 | Word16 D[]         /* (o)     :Correlations between h[] and D[] */     
;  97 | )                                                                      
;----------------------------------------------------------------------

_Cor_h_X:

        PSHM      AR1
        PSHM      AR6
        PSHM      AR7
        FRAME     #-90
;----------------------------------------------------------------------
;  99 | Word16 i, j;                                                           
; 100 | Word32 s, max, L_temp;                                                 
; 101 | Word32 y32[L_SUBFR];                                                   
;----------------------------------------------------------------------
        MVMM      SP,AR1
        STLM      A,AR6               ; a = ar6 = h[]
        MAR       *+AR1(#2)           ; ar1 = sp(2) = y32
        LD        *SP(95),A
        STL       A,*SP(82)           ; sp(82) = n[]
        MVDK      *SP(94),*(AR7)      ; ar7 = x[]

;----------------------------------------------------------------------
; 105 | max = 0;                                                               
;----------------------------------------------------------------------
        LD        #0,A
        DST       A,*SP(84)           ; sp(84) = max

;----------------------------------------------------------------------
; 107 | for (i = 0; i < L_SUBFR; i++)                                          
;----------------------------------------------------------------------
        LD        #0,A
        STL       A,*SP(86)           ; sp(86) = i
L8:    

        RSBX      OVM
        LD        *SP(86),A
        LD        *SP(86),B
        ADD       *(AR7),A
        STLM      A,AR3               ; ar3 = x[]
        LD        #39,A
        SUB       B,A                 ; a = 39-sp(86)
        MVMM      AR6,AR2             ; ar2 = h[]

;----------------------------------------------------------------------
; 109 | s = 0;                                                                 
; 110 | for (j = i; j <  L_SUBFR; j++)                                         
;----------------------------------------------------------------------
        LD        #0,B
        STLM      A,BRC
        DST       B,*SP(88)            ; sp(88) = s
        SSBX      SXM          ;****
        DLD       *SP(88),A    ;****
        SSBX      FRCT         ;****
        SSBX      OVM          ;****
        ORM       #2,*(PMST)   ;****
        RPTB      L10-1
        ; loop starts
L9:    
;----------------------------------------------------------------------
; 111 | s = L_mac(s, X[j], h[j-i]);                                            
;----------------------------------------------------------------------
        ;SSBX      SXM
        ;NOP
        ;DLD       *SP(88),A            
        ;ORM       #2,*(PMST)
        ;SSBX      FRCT
        ;SSBX      OVM
        ;ORM       #2,*(PMST)
        ;NOP
        MAC       *AR2+, *AR3+, A, A    
        ;DST       A,*SP(88)              
        
L10:    
        ;DST       A,*SP(88)    ;****
;----------------------------------------------------------------------
; 113 | y32[i] = s;                                                            
;----------------------------------------------------------------------
        ;SSBX      SXM
        NOP
        ;DLD       *SP(88),A
        DST       A,*AR1+               ; y32[i] = s 

;----------------------------------------------------------------------
; 115 | s = L_abs(s);                                                          
;----------------------------------------------------------------------
        ;SSBX      OVM
        ;NOP
        ABS       A,A                   
        DST       A,*SP(88)             ; sp(88) = s

;----------------------------------------------------------------------
; 116 | L_temp =L_sub(s,max);                                                  
; 117 | if(L_temp>0L) {                                                        
;----------------------------------------------------------------------
        ;RSBX      OVM
        ;RSBX      FRCT
        ;DLD       *SP(84),A
        ;DST       A,*SP(0)              
        ;DLD       *SP(88),A             
        ;CALL      #_L_sub               
;------------------  L_sub inline  ------------------------------------
        DLD        *SP(88),A
        NOP
        DSUB      *SP(84),A

;------------------  L_sub End     ------------------------------------        
        
        
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                    
        ;SFTA      A,-8                 
        BC        L11,ALEQ              ; |116| 

;----------------------------------------------------------------------
; 118 | max = s;                                                               
;----------------------------------------------------------------------
        DLD       *SP(88),A
        DST       A,*SP(84)             ; max = s 
L11:    

        LD        *SP(86),A
        ADD       #1,A             
        STL       A,*SP(86)             ;i++
        ;LD        *(AL),A               
        SUB       #40,A,A               
        BC        L8,ALT                 

;----------------------------------------------------------------------
; 125 | j = norm_l(max);                                                       
; 126 | if( sub(j,16) > 0) {                                                   
;----------------------------------------------------------------------

        DLD       *SP(84),A
        EXP       A                     
        NOP
        ST        T,*SP(86)             ;sp(86) = j
        LD        *SP(86),A
        SUB       #16,A,A                
        BC        L12,ALEQ              ;if( j-16 <= 0) goto L12

;----------------------------------------------------------------------
; 127 | j = 16;                                                                
;----------------------------------------------------------------------
        LD        #16,A
        STL       A,*SP(86)
L12:    

;----------------------------------------------------------------------
; 130 | j = sub(18, j);                                                        
; 132 | for(i=0; i<L_SUBFR; i++) {                                             
;----------------------------------------------------------------------
        LD        #18,16,A              
        LD        *SP(86),B             ; sp(86) = j
        MVMM      SP,AR6
        ;SSBX      OVM
        STM       #40,AR7
        MVDK      *SP(82),*(AR1)        ; ar1 = d[]
        SUB       *(BL),16,A,A          
        MAR       *+AR6(#2)             ; ar6 = y32[]
        SFTA      A,-16,A               
        STL       A,*SP(86)
L13:    
;----------------------------------------------------------------------
; 133 | D[i] = extract_l( L_shr(y32[i], j) );                                  
;----------------------------------------------------------------------
        LD        *SP(86),A
        RSBX      OVM
        RSBX      FRCT
        STL       A,*SP(0)
        DLD       *AR6+,A                
        CALL      #_L_shr  
;------------------- L_shr inline  ------------------------------------
        
;------------------- L_shr inline  ------------------------------------             
        STL       A,*AR1+      
        BANZ      L13,*+AR7(-1)         

        ANDM      #-833,*(ST1)
        ANDM      #-4,*(PMST)
        FRAME     #90
        POPM      AR7
        POPM      AR6
        POPM      AR1
        RET


;***************************************************************
;* UNDEFINED EXTERNAL REFERENCES                               *
;***************************************************************
;	.global	_L_sub
;	.global	_L_shl
	.global	_L_shr
;	.global	_shr

