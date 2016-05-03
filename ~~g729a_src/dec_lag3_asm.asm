;***************************************************************
;* TMS320C54x C/C++ Codegen                  PC Version 3.831  *
;* Date/Time created: Wed May 11 09:36:27 2005                 *
;***************************************************************
	.mmregs
FP	.set	AR7

;	c:\ti\c5400\cgtools\bin\opt500.exe -i20 -q -s -O3 D:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\TI3612_2 D:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\TI3612_5 -w F:/ATA/Code/g729a_v1.4/G729A/Debug 

	.sect	".text"
	.global	_Dec_lag3

;----------------------------------------------------------------------
;  21 | void Dec_lag3(                                                         
;  22 | Word16 index,       /* input : received pitch index           */       
;  23 | Word16 pit_min,     /* input : minimum pitch lag              */       
;  24 | Word16 pit_max,     /* input : maximum pitch lag              */       
;  25 | Word16 i_subfr,     /* input : subframe flag                  */       
;  26 | Word16 *T0,         /* output: integer part of pitch lag      */       
;  27 | Word16 *T0_frac     /* output: fractional part of pitch lag   */       
;  28 | )                                                                      
;----------------------------------------------------------------------

;***************************************************************
;* FUNCTION DEF: _Dec_lag3                                     *
;***************************************************************

;***************************************************************
;*                                                             *
;* Using -g (debug) with optimization (-o3) may disable key op *
;*                                                             *
;***************************************************************
_Dec_lag3:
;* A     assigned to _index
	.sym	_index,0, 3, 17, 16
	.sym	_pit_min,4, 3, 9, 16
	.sym	_pit_max,5, 3, 9, 16
	.sym	_i_subfr,6, 3, 9, 16
	.sym	_T0,7, 19, 9, 16
	.sym	_T0_frac,8, 19, 9, 16
;* BK    assigned to _index
	.sym	_index,19, 3, 4, 16
;* AR3   assigned to _pit_min
	.sym	_pit_min,12, 3, 4, 16
;* AR2   assigned to _pit_max
	.sym	_pit_max,11, 3, 4, 16
;* AR4   assigned to _i_subfr
	.sym	_i_subfr,13, 3, 4, 16
;* AR1   assigned to _T0
	.sym	_T0,10, 19, 4, 16
;* AR5   assigned to _T0_frac
	.sym	_T0_frac,14, 19, 4, 16
;* B     assigned to _T0_min
	.sym	_T0_min,6, 3, 4, 16
;* A     assigned to C$2
	.sym	C$2,0, 4, 4, 16
;* AR2   assigned to C$1
	.sym	C$1,11, 4, 4, 16
;** 33	-----------------------    if ( i_subfr ) goto g4;
        PSHM      AR1
        FRAME     #-2
        NOP
;----------------------------------------------------------------------
;  30 | Word16 i;                                                              
;  31 | Word16 T0_min, T0_max;                                                 
;----------------------------------------------------------------------
        MVDK      *SP(4),*(AR3)
        MVDK      *SP(5),*(AR2)
        MVDK      *SP(7),*(AR1)
        MVDK      *SP(8),*(AR5)
        MVDK      *SP(6),*(AR4)
        STLM      A,BK

;----------------------------------------------------------------------
;  33 | if (i_subfr == 0)                  /* if 1st subframe */               
;----------------------------------------------------------------------
        BANZ      L2,*AR4               ; |33| 
        ; branch occurs ; |33| 
;** 35	-----------------------    if ( index < 197 ) goto g3;
	.line	15
;----------------------------------------------------------------------
;  35 | if (sub(index, 197) < 0)                                               
;  39 |   *T0 = add(mult(add(index, 2), 10923), 19);                           
;  43 |   i = add(add(*T0, *T0), *T0);                                         
;  44 |   *T0_frac = add(sub(index, i), 58);                                   
;  46 | else                                                                   
;----------------------------------------------------------------------
        SSBX      SXM
        ;;RSBX      OVM
        SSBX      OVM;;wly
        LD        *(BK),A               ; |35| 
        SUB       #197,A,A              ; |35| 
        BC        L1,ALT                ; |35| 
        ; branch occurs ; |35| 
;** 48	-----------------------    *T0 = _ssub(index, 112);
;** 49	-----------------------    *T0_frac = 0;
;** 49	-----------------------    goto g9;
	.line	28
;----------------------------------------------------------------------
;  48 | *T0 = sub(index, 112);                                                 
;----------------------------------------------------------------------
        LD        *(BK),16,A            ; |48| 
        ;;SSBX      OVM
        NOP
        SUB       #112,16,A,A           ; |48| 
        STH       A,*AR1                ; |48| 
	.line	29
;----------------------------------------------------------------------
;  49 | *T0_frac = 0;                                                          
;  54 | else  /* second subframe */                                            
;----------------------------------------------------------------------
        BD        L5                    ; |49| 
        ST        #0,*AR5               ; |49| 
        ; branch occurs ; |49| 
L1:    
;**	-----------------------g3:
;** 39	-----------------------    *T0 = C$2 = _sadd(_smpy(_sadd(index, 2), 10923), 19);
;** 44	-----------------------    *T0_frac = _sadd(_ssub(index, _sadd(_sadd(C$2, C$2), C$2)), 58);
;** 45	-----------------------    goto g9;
	.line	19
        LD        #10923,16,A           ; |39| 
        LD        *(BK),16,B            ; |39| 
        ;;SSBX      OVM
        NOP
        ADD       #2,16,B,B             ; |39| 
        SFTA      B,#-16,B
        SSBX      FRCT
        STLM      B,T
        NOP
        MPYA      A                     ; |39| 
        ADD       #19,16,A,A            ; |39| 
        SFTA      A,-16,A               ; |39| 
        STL       A,*AR1
	.line	24
        ;;RSBX      OVM
        LD        *(AL),16,B            ; |44| 
        ;;SSBX      OVM
        ADD       *(AL),16,B,B          ; |44| 
        ADD       *(AL),16,B,A          ; |44| 
        ;;RSBX      OVM
        LD        *(BK),16,B            ; |44| 
        ;;SSBX      OVM
        SFTA      A,-16,A               ; |44| 
        SUB       *(AL),16,B,A          ; |44| 
        ADD       #58,16,A,A            ; |44| 
        STH       A,*AR5                ; |44| 
	.line	25
        B         L5                    ; |45| 
        ; branch occurs ; |45| 
L2:    
;**	-----------------------g4:
;** 58	-----------------------    T0_min = _ssub(*T0, 5);
;** 59	-----------------------    if ( _ssub(T0_min, pit_min) >= 0 ) goto g6;
	.line	38
;----------------------------------------------------------------------
;  58 | T0_min = sub(*T0, 5);                                                  
;----------------------------------------------------------------------
        ;;RSBX      OVM
        ;;SSBX      SXM
        NOP
        LD        *AR1,16,A             ; |58| 
        ;;SSBX      OVM
        NOP
        SUB       #5,16,A,A             ; |58| 
        SFTA      A,-16,B               ; |58| 
	.line	39
;----------------------------------------------------------------------
;  59 | if (sub(T0_min, pit_min) < 0)                                          
;----------------------------------------------------------------------
        ;;RSBX      OVM
        LD        *(BL),16,A            ; |59| 
        ;;SSBX      OVM
        SUB       *(AR3),16,A,A         ; |59| 
        SFTA      A,-16,A               ; |59| 
        LD        *(AL),A               ; |59| 
        BC        L3,AGEQ               ; |59| 
        ; branch occurs ; |59| 
;** 61	-----------------------    T0_min = pit_min;
	.line	41
;----------------------------------------------------------------------
;  61 | T0_min = pit_min;                                                      
;  64 | T0_max = add(T0_min, 9);                                               
;----------------------------------------------------------------------
        LDM       AR3,B
L3:    
;**	-----------------------g6:
;** 65	-----------------------    if ( _ssub(_sadd(T0_min, 9), pit_max) <= 0 ) goto g8;
	.line	45
;----------------------------------------------------------------------
;  65 | if (sub(T0_max, pit_max) > 0)                                          
;  67 |   T0_max = pit_max;                                                    
;----------------------------------------------------------------------
        ;;RSBX      OVM
        LD        *(BL),16,A            ; |65| 
        ;;SSBX      OVM
        NOP
        ADD       #9,16,A,A             ; |65| 
        SUB       *(AR2),16,A,A         ; |65| 
        SFTA      A,-16,A               ; |65| 
        LD        *(AL),A               ; |65| 
        BC        L4,ALEQ               ; |65| 
        ; branch occurs ; |65| 
;** 68	-----------------------    T0_min = _ssub(pit_max, 9);
	.line	48
;----------------------------------------------------------------------
;  68 | T0_min = sub(T0_max, 9);                                               
;  74 | i = sub(mult(add(index, 2), 10923), 1);                                
;----------------------------------------------------------------------
        ;;RSBX      OVM
        LD        *(AR2),16,A           ; |68| 
        ;;SSBX      OVM
        NOP
        SUB       #9,16,A,A             ; |68| 
        SFTA      A,-16,B               ; |68| 
L4:    
;**	-----------------------g8:
;** 75	-----------------------    C$1 = _ssub(_smpy(_sadd(index, 2), 10923), 1);
;** 75	-----------------------    *T0 = _sadd(C$1, T0_min);
;** 80	-----------------------    *T0_frac = _ssub(_ssub(index, 2), _sadd(_sadd(C$1, C$1), C$1));
;**	-----------------------g9:
;**  	-----------------------    return;
	.line	55
;----------------------------------------------------------------------
;  75 | *T0 = add(i, T0_min);                                                  
;  79 | i = add(add(i, i), i);                                                 
;----------------------------------------------------------------------
        ;;RSBX      OVM
        NOP
        LD        #10923,16,A           ; |75| 
        DST       A,*SP(0)              ; |75| 
        LD        *(BK),16,A            ; |75| 
        ;;SSBX      OVM
        SSBX      FRCT
        ADD       #2,16,A,A             ; |75| 
        ;;RSBX      OVM
        SFTA      A,#-16,A
        STLM      A,T
        DLD       *SP(0),A              ; |75| 
        ;;SSBX      OVM
        NOP
        MPYA      A                     ; |75| 
        SUB       #1,16,A,A             ; |75| 
        SFTA      A,-16,A               ; |75| 
        STLM      A,AR2
        ;;RSBX      OVM
        LD        *(AR2),16,A           ; |75| 
        ;;SSBX      OVM
        ADD       *(BL),16,A,B          ; |75| 
        STH       B,*AR1                ; |75| 
	.line	60
;----------------------------------------------------------------------
;  80 | *T0_frac = sub(sub(index, 2), i);                                      
;  83 | return;                                                                
;----------------------------------------------------------------------
        ;;RSBX      OVM
        LD        *(AR2),16,B           ; |80| 
        ;;SSBX      OVM
        ADD       *(AR2),16,B,B         ; |80| 
        ADD       *(AR2),16,B,A         ; |80| 
        ;;RSBX      OVM
        LD        *(BK),16,B            ; |80| 
        ;;SSBX      OVM
        NOP
        SUB       #2,16,B,B             ; |80| 
        SFTA      A,-16,A               ; |80| 
        SUB       *(AL),16,B,A          ; |80| 
        STH       A,*AR5                ; |80| 
L5:    
	.line	64
        ANDM      #-833,*(ST1)
        ANDM      #-4,*(PMST)
        FRAME     #2
        POPM      AR1
        RET
        ; return occurs
;;	.endfunc	84,000000400h,3



;***************************************************************
;* TYPE INFORMATION                                            *
;***************************************************************
	.sym	_Word16, 0, 3, 13, 16
	.sym	_Word16, 0, 3, 13, 16
