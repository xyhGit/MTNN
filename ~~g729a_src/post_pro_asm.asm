	.mmregs
FP	.set	AR7
	.bss	_y2_hi,1,0,0
	.bss	_y2_lo,1,0,0
	.bss	_y1_hi,1,0,0
	.bss	_y1_lo,1,0,0
	.bss	_x0,1,0,0
	.bss	_x1,1,0,0

	.sect	".text"
	.global	_Post_Process

;----------------------------------------------------------------------
;  60 | void Post_Process(                                                      
;  61 | Word16 signal[],    /* input/output signal */                          
;  62 | Word16 lg)          /* length of signal    */                          
;----------------------------------------------------------------------
_Post_Process:

        PSHM      AR1
        PSHM      AR6
        PSHM      AR7
        FRAME     #-8
        NOP
        MVDK      *SP(12),*(AR6)     ;ar6 = lg
;----------------------------------------------------------------------
;  67 | for(i=0; i<lg; i++)                                                    
;----------------------------------------------------------------------
        SSBX      SXM
        LD        *(AR6),B               
        BC        L2,BLEQ               

        STLM      A,AR1              ;ar1 = signal[]
        LD        #_y1_hi,A
        STL       A,*SP(2)           ;sp(2) = y1_hi
        LD        #_y1_lo,A
        STL       A,*SP(3)           ;sp(3) = y1_lo
L1:    

;----------------------------------------------------------------------
;  69 | x2 = x1;                                                               
;----------------------------------------------------------------------
        LD        *(_x1),A
        STL       A,*SP(4)           ;sp(4) = x1
        MVDK      *(_x0),*(_x1)      ;x1 = x0
        MVDK      *AR1,*(_x0)        ;x0 = signal[0]   

;----------------------------------------------------------------------
;  76 | L_tmp     = Mpy_32_16(y1_hi, y1_lo, a100[1]);                          
;----------------------------------------------------------------------
        STM       #_a100,AR7
        ;RSBX      FRCT
        ;RSBX      OVM
        ;MVKD      *(_y1_lo),*SP(0)       
        ;LD        *AR7(1),A
        ;STL       A,*SP(1)
        LD        *AR7(1), B
        ;LD        *(_y1_hi),A
        MVDK      *(_y1_hi),*(AR4) ;**** 
        ;CALL      #_Mpy_32_16           
;-------------------  Mpy_32_16  --------------------------------------
        ;LD        *SP(0),T         ; T = lo
        LD         *(_y1_lo), T
        ;LD        *SP(1),B        ; B = n
        ;STLM      A,AR4           ; ar1 = hi
        SSBX      SXM
        SSBX      FRCT
        SSBX      OVM
        LD        *(BL),16,A       ; ah = n   
        NOP
        MPYA      A                ; a = L_mult(lo, n)  
        STLM      B,T              ; T = n
        STH       A,*(AR2)         ; (ar2) = L_mult(lo, n)  
        MPY       *(AR4),A         ; a = L_mult(hi, n)           
        MVMD      AR2,T            
        MAC       #1, A   

;-------------------  Mpy_32_16 End  ----------------------------------
        DST       A,*SP(6)         ;sp(6) = L_tmp      

;----------------------------------------------------------------------
;  77 | L_tmp     = L_add(L_tmp, Mpy_32_16(y2_hi, y2_lo, a100[2]));            
;----------------------------------------------------------------------
        ;MVKD      *(_y2_lo),*SP(0)      
        ;RSBX      FRCT
        ;LD        *AR7(2),A
        ;RSBX      OVM
        ;STL       A,*SP(1)
        ;LD        *(_y2_hi),A
        ;CALL      #_Mpy_32_16           
;-------------------  Mpy_32_16  --------------------------------------
        LD        *AR7(2), B
        ;LD        *(_y1_hi),A
        MVDK      *(_y2_hi),*(AR4) ;**** 
        ;LD        *SP(0),T         ; T = lo
        LD         *(_y2_lo), T
        ;LD        *SP(1),B        ; B = n
        ;STLM      A,AR4           ; ar1 = hi
        ;SSBX      SXM
        ;SSBX      FRCT
        ;SSBX      OVM
        LD        *(BL),16,A       ; ah = n   
        NOP
        MPYA      A                ; a = L_mult(lo, n)  
        STLM      B,T              ; T = n
        STH       A,*(AR2)         ; (ar2) = L_mult(lo, n)  
        MPY       *(AR4),A         ; a = L_mult(hi, n)           
        MVMD      AR2,T            
        MAC       #1, A   

;-------------------  Mpy_32_16 End  ----------------------------------
        ;SSBX      SXM
        ;SSBX      OVM
        DLD       *SP(6),B
        ;RSBX      SXM
        NOP
        ADD       A,B              ; b = L_tmp      

;----------------------------------------------------------------------
;  78 | L_tmp     = L_mac(L_tmp, x0, b100[0]);                                 
;  79 | L_tmp     = L_mac(L_tmp, x1, b100[1]);                                 
;  80 | L_tmp     = L_mac(L_tmp, x2, b100[2]);                                 
;----------------------------------------------------------------------
        LD        B,A
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                    
               
        STM       #_b100,AR2
        ;SFTA      A,-8                  
        LD        *(_x0),T
        ;ORM       #2,*(PMST)
        ;SSBX      OVM
        ;SSBX      FRCT
        ORM       #2,*(PMST)
        MAC       *(_b100), A          
        ;RSBX      OVM
        LD        *(_x1),T
        ;SFTA      A,8                    
        ;SFTA      A,-8                  
        ;SSBX      OVM
        MAC       *AR2(1), A            
        ;RSBX      OVM
        ;NOP
        ;SFTA      A,8                   
        ;SSBX      OVM
        ;SFTA      A,-8                   
        LD        *SP(4),T
        MAC       *AR2(2), A            

;----------------------------------------------------------------------
;  81 | L_tmp     = L_shl(L_tmp, 3);      /* Q28 --> Q31 (Q12 --> Q15) */      
;----------------------------------------------------------------------
        ;RSBX      FRCT
        ;RSBX      OVM
        ;ST        #3,*SP(0)             
        ;CALL      #_L_shl               
        SFTA      A,2;;wly
        NOP
        
        DST       A,*SP(6)              

	SFTA      A,1;;wly

;----------------------------------------------------------------------
;  82 | signal[i] = round(L_tmp);                                              
;----------------------------------------------------------------------
        ;RSBX      OVM
        ;SSBX      SXM
        ;SFTA      A,8                    
        ;SFTA      A,-8                   
        ;SSBX      OVM
        ADD       #1,#15,A,A             
        STH       A,*AR1+                

;----------------------------------------------------------------------
;  84 | y2_hi = y1_hi;                                                         
;----------------------------------------------------------------------
        MVDK      *(_y1_hi),*(_y2_hi)   

;----------------------------------------------------------------------
;  85 | y2_lo = y1_lo;                                                         
;----------------------------------------------------------------------
        MVDK      *(_y1_lo),*(_y2_lo)   

;----------------------------------------------------------------------
;  86 | L_Extract(L_tmp, &y1_hi, &y1_lo);                                      
;----------------------------------------------------------------------
        ;LD        *SP(2),A
        ;STL       A,*SP(0)
        ;LD        *SP(3),A
        ;RSBX      OVM
        ;STL       A,*SP(1)
        ;RSBX      FRCT
        DLD       *SP(6),A             
        ;CALL      #_L_Extract   
;-----------------  L_Extract inline  ---------------------------------
        ;SSBX      SXM             ; ****
        ;RSBX      OVM
        ;SSBX      FRCT
        ;SFTA      A,8
        ;SFTA      A,-8
        ;SSBX      OVM

        MVDK      *SP(3),*(AR4)
        MVDK      *SP(2),*(AR2)
        
        LD        A,B                   
        SFTL      B,#-16,B              
        STLM      B,AR3
        MVKD      *(AR3),*AR2

        SFTA      A,-1              
        
        MVMD      AR3,T
        LD        #16384,B
        ORM       #2,*(PMST)
        MAS       *(BL), A              
        STL       A,*AR4 
;-----------------  L_Extract End     ---------------------------------        
        NOP
;----------------------------------------------------------------------
;  88 | return;                                                                
;----------------------------------------------------------------------
        BANZ      L1,*+AR6(-1)          
L2:    
        ANDM      #-833,*(ST1)
        ANDM      #-4,*(PMST)
        FRAME     #8
        POPM      AR7
        POPM      AR6
        POPM      AR1
        RET



	.sect	".text"
	.global	_Init_Post_Process
;----------------------------------------------------------------------
;  49 | void Init_Post_Process(void)                                            
;----------------------------------------------------------------------
_Init_Post_Process:

;----------------------------------------------------------------------
;  51 | y2_hi = 0;                                                             
;----------------------------------------------------------------------
        ST        #0,*(_y2_hi)          ; |51| 
;----------------------------------------------------------------------
;  52 | y2_lo = 0;                                                             
;----------------------------------------------------------------------
        ST        #0,*(_y2_lo)          ; |52| 
;----------------------------------------------------------------------
;  53 | y1_hi = 0;                                                             
;----------------------------------------------------------------------
        ST        #0,*(_y1_hi)          ; |53| 
;----------------------------------------------------------------------
;  54 | y1_lo = 0;                                                             
;----------------------------------------------------------------------
        ST        #0,*(_y1_lo)          ; |54| 
;----------------------------------------------------------------------
;  55 | x0   = 0;                                                              
;----------------------------------------------------------------------
        ST        #0,*(_x0)             ; |55| 
;----------------------------------------------------------------------
;  56 | x1   = 0;                                                              
;----------------------------------------------------------------------
        ST        #0,*(_x1)             ; |56| 
        RET


;***************************************************************
;* UNDEFINED EXTERNAL REFERENCES                               *
;***************************************************************
	.global	_b100
	.global	_a100



