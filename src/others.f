
C     SUBROUTINE QVOPT IS TO OUTPUT THE VAPOR FLOW INFORMATION INTO
C     QV.DAT FILE
C     THE DATA RECORD INTERVAL IS MOD(IT,NCOLPR).EQ.0.OR.IT.EQ.1
C     NONE CALLED SUBROUTINE 
      SUBROUTINE QVOPT(QVX,QVY)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                               

      INTEGER(1) IBCPBC(NBCN),IBCUBC(NBCN),IBCSOP(NSOP),IBCSOU(NSOU)    
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,             
     1   NSOP,NSOU,NBCN,NCIDB                                           
      COMMON /TIMES/ DELT,TSEC,TMIN,THOUR,TDAY,TWEEK,TMONTH,TYEAR,      
     1   TMAX,DELTP,DELTU,DLTPM1,DLTUM1,IT,ITBCS,ITRST,ITMAX,TSTART     
      COMMON /JCOLS/ NCOLPR,LCOLPR,NCOLS5,NCOLS6,J5COL,J6COL
      COMMON /DEPTH/  MXD,NFY
      INTEGER NDPT(NSOP)
      INTEGER NREF(NSOP)
      DIMENSION QVX(MXD,NFY-1),QVY(MXD-1,NFY)

      IF (IT.EQ.1) THEN  
      OPEN(125,FILE='QV.DAT',STATUS='UNKNOWN') 
      WRITE(125,5) INT(ITMAX/NCOLPR)
5      FORMAT(I10,2X,'OUTPUTS OVERALL')
      ENDIF    
      WRITE (125,8)IT
8     FORMAT('TIME STEP', I10)         
      DO 1 I=1,MXD
1      WRITE (125,4) (QVX(I,J),J=1,NFY-1)
      DO 3 I=1,MXD-1
3      WRITE (125,4) (QVY(I,J),J=1,NFY)
4     FORMAT (30(1PE15.7))
      RETURN 
      END


C     THIS SUB IS TO FIND OUT THE NODE NEXT TO THE NODE IQP SO VAPOR
C     CALCULATION CAN BE 
C     CONDCTED
C     IIQP -- THE RETURN RESULT SHOWING THE SEQUENCE OF THE NODE NEXT 
C     TO THAT NODE
C     WHEN J=1 FIND NEXT HORIZONTAL NODE
C     WHEN J=2 FIND NEXT VERTICAL NODE
      SUBROUTINE NNODE(IIQP,J,IQP,NDPT,NREF,NSOPI)
      INTEGER NDPT(NSOP)
      INTEGER NREF(NSOP)
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /DEPTH/ MXD,NFY
      IIQP=0
      IF (J.EQ.1) THEN      ! HORIZONTAL CHECK
         INRF=NREF(IQP)+1
         INDP=NDPT(IQP)
      ELSEIF (J.EQ.2) THEN ! VERTICAL CHECK
         INRF=NREF(IQP)
         INDP=NDPT(IQP)+1
      ENDIF
      IF (J.EQ.1.AND.NREF(IQP+1).EQ.INRF.AND.NDPT(IQP+1).EQ.INDP)
     1 IIQP=IQP+1
      IF (J.EQ.2.AND.(IQP+NFY).LE.NSOP) THEN
      DO 1 I=IQP+1, IQP+NFY
1      IF (NREF(I).EQ.INRF.AND.NDPT(I).EQ.INDP)  IIQP=I
      ENDIF
      RETURN 
      END

C *** PURPOSE 
C ***  TO CALCULATE THE WATER AND SOLUTE MASS IN EACH NODE  
C ***  WMA INCLUDES ALL THE SOLUTE IN LIQUID AND SOLID FORM
C ***  SM  IS SOLUTE IN SOLID FORM
C ***  SEE NOTEBOOK3 
      SUBROUTINE WSMASS(WMA,SMA,VOL,POR,SW,RHO,SOP,DSWDP,PVEC,
     1   PM1,UM1,UM2,CS1,CS2,CS3,SL,SR,DPDTITR,UVEC,ITER,POR1,SM,QPLITR,
     2   QIN,QINITR,UIN,IPBC,GNUP1,PBC,UBC,ISTOP,QSB,USB,QPB,UPB,NWS,
     3   WMAM,DWMADT,NDPT,IQSOP)
      USE M_PARAMS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /TIMES/ DELT,TSEC,TMIN,THOUR,TDAY,TWEEK,TMONTH,TYEAR,     
     1   TMAX,DELTP,DELTU,DLTPM1,DLTUM1,IT,ITBCS,ITRST,ITMAX,TSTART     
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /CONTRL/ GNUP,GNUU,UP,DTMULT,DTMAX,ME,ISSFLO,ISSTRA,ITCYC, 
     1   NPCYC,NUCYC,NPRINT,NBCFPR,NBCSPR,NBCPPR,NBCUPR,IREAD,          
     2   ISTORE,NOUMAT,IUNSAT,KTYPE,MET,MAR,MSR,MSC,MHT,MVT,MFT,MRK
      COMMON /DIMX2/ NELTA, NNVEC, NDIMIA, NDIMJA
      COMMON /ET/ QET,UET,PET,UVM,NGT,ITE,TMA,TMI,ALF,RS,RH,AP,BP,U2,
     1   TSD,SCF
      DIMENSION KTYPE(2)
      DIMENSION WMA(NN),SMA(NN),VOL(NN),POR(NN),SW(NN),RHO(NN),UM1(NN),
     1   SOP(NN),DSWDP(NN),PM1(NN),UM2(NN),CS1(NN),
     1   CS2(NN),CS3(NN),SL(NN),SR(NN),DPDTITR(NN),POR1(NN)
      DIMENSION PVEC(NNVEC),UVEC(NNVEC),SM(NNVEC),QPLITR(NBCN)
      DIMENSION QIN(NN),QINITR(NN),UIN(NN),IPBC(NBCN),
     1   GNUP1(NBCN),PBC(NBCN),UBC(NBCN),IQSOP(NSOP)
      DIMENSION QSB(NN), USB(NN), QPB(NPBC), UPB(NPBC),NDPT(NSOP)
      DIMENSION WMA1(NN), SMA1(NN),WMAM(NN),DWMADT(NN)
      LOGICAL NWS
      DOUBLE PRECISION RHOST
      INTEGER,DIMENSION(8) :: IBTIME  !BEGIN TIME
      INTEGER,DIMENSION(8) :: IETIME  !END TIME
      REAL, DIMENSION(2) :: TIMEP 
      REAL ::TEMP
! TIMEP(1)-USER TIME; TIMEP(2)-SYSTEM TIME
      DATA RHOST/2.165D3/
      SAVE RHOST,WMAI,SMAI,IBTIME
C     RHOST -- CRYSTAL SALT DENSITY (KG/M3)
C     WMA1 -- WATER MASS IN THE PREVIOUS TIME STEP  (KG)
C     SMA1 -- SOLUTE MASS IN THE PREVIOUS TIME STEP (KG)
C     WMAM -- WATER MASS IN THE MIDDLE TIME STEP (KG) DUE TO THE CENTRAL
C             DIFFERENCIAL 
C             EQUATION USED FOR HEAT BALANCE 
C            VOL(I)*ROU(I)*POR(I)*SW(I)
C     DWMADT -D(VOL(I)*ROU(I)*POR(I)*SW(I))/DT, USED FOR CENTRAL 
C              DIFFERENCIAL EQUATION
C      QST  -- TOTAL WATER SOURCE AND SINK 
C      UST  -- TOTAL SOLUTE SOURCE AND SINK
C      QPT  -- TOTAL WATER IN/OUT PUT DUE TO PRESSURE
C      SPT  -- TOTAL SOLUTE IN/OUT PUT DUE TO PRESSURE
C     WMAT -- INITIAL OVERALL WATER MASS IN DOMAIN
C     SMAT -- INITIAL OVERALL SOLUTE MASS IN DOMAIN 

C     FIRST TIME COMING TO THIS SUBROUTINE
      IF (.NOT.NWS) THEN   ! IF IT IS THE FIRST TIME TO COME TO THIS SUB
         CALL DATE_AND_TIME(VALUES=IBTIME)    ! SETS THE BEGINNING TIME
            WMAI=0.D0
            SMAI=0.D0
            WMAF=0.D0
            SMAF=0.D0
            QST=0.D0
            UST=0.D0
            QPT=0.D0
            SPT=0.D0
          CALL ZERO(WMAM,NN,0.0D0)
          CALL ZERO(DWMADT,NN,0.0D0)
          CALL ZERO(QSB,NN,0.0D0)
          CALL ZERO(USB,NN,0.0D0)
          CALL ZERO(QPB,NPBC,0.0D0)
          CALL ZERO(UPB,NPBC,0.0D0)
		  
C         ITE==0 SM IS OBTAINED FROM SALT CURVE
C         ITE==1 SM IS INHERITED FROM *.ICS FILE       
C         WARNING!! THIS SALT CURVE MAY BE CHANGED! THIS IS ONLY FOR 'SOLID'
C         CONDITIONS!
        IF (ITE.EQ.0) THEN
          DO 1213 I =1,NN
            SM(I)=(1.D0-POR(I))*RHOS*VOL(I)*CS1(I)*UVEC(I)
1213      CONTINUE
        END IF
		
        DO 1 I=1,NN
          WMA(I)=VOL(I)*POR(I)*SW(I)*RHO(I)
          SMA(I)=WMA(I)*UM1(I)
          WMAI=WMAI+WMA(I)                   !INITIAL OVERALL WATER MASS
          SMAI=SMAI+SMA(I)                !INITIAL OVERALL SOLUTE MASS
1        CONTINUE
C     SECOND TIME CALLING SWMASS
      ELSEIF (NWS) THEN         ! NOT THE FIRST TIME TO COME TO THIS SUB
        DO 2 I=1,NN
            WMA1(I)=WMA(I)                             !LAST WATER MASS
          SMA1(I)=SMA(I)                             !LAST SOLUTE MASS
C       RATE OF CHANGE IN TOTAL STORED FLUID DUE TO PRESSURE CHANGE
          TMP1=(1-ISSFLO/2)*RHO(I)*VOL(I)*
     1     (SW(I)*SOP(I)+POR(I)*DSWDP(I))*(PVEC(I)-PM1(I))   !/DELTP
C       RATE OF CHANGE IN TOTAL STORED FLUID DUE TO CONCENTRATION CHANGE
          TMP2=(1-ISSFLO/2)*POR(I)*SW(I)*DRWDU*VOL(I)*
     1     (UM1(I)-UM2(I))                                   !/DLTUM1
          WMA(I)=WMA(I)+TMP1+TMP2
		  WMAM(I)=(WMA1(I)+WMA(I))/2.D0                !MIDDLE POINT RESULT
          DWMADT(I)=TMP1/DELTP+TMP2/DLTUM1             !ONE TERM

C       RATE OF CHANGE IN SOLUTE DUE TO CONCENTRATION CHANGE
          ESRV=POR(I)*SW(I)*RHO(I)*VOL(I)
          EPRSV=(1.D0-POR(I))*RHOS*VOL(I)
          DUDT=(1-ISSTRA)*(UVEC(I)-UM1(I))      ! HERE IT IS DU NOT DUDT
          SMA(I)=SMA(I)+ESRV*CW*DUDT
C         RATE OF CHANGE OF ADSORBATE
          ADSP=EPRSV*CS1(I)*DUDT
          SMA(I)=SMA(I)+ADSP
          
C         RATE OF CHANGE IN SOLUTE DUE TO CHANGE IN MASS OF FLUID
          SMA(I)=SMA(I)+CW*UVEC(I)*(1-ISSFLO/2)*VOL(I)*
     1     (RHO(I)*(SW(I)*SOP(I)+POR(I)*DSWDP(I))*DPDTITR(I)*DELTP
     2     +POR(I)*SW(I)*DRWDU*(UM1(I)-UM2(I)))
C         FIRST-ORDER PRODUCTION/DECAY OF SOLUTE
          SMA(I)=SMA(I)+ESRV*PRODF1*UVEC(I)
C         FIRST-ORDER PRODUCTION/DECAY OF ADSORBATE
          SMA(I)=SMA(I)+EPRSV*PRODS1*(SL(I)*UVEC(I)+SR(I))
C         ZERO-ORDER PRODUCTION/DECAY OF SOLUTE
        SMA(I)=SMA(I)+ESRV*PRODF0
C         ZERO-ORDER PRODUCTION/DECAY OF ADSORBATE
        SMA(I)=SMA(I)+EPRSV*PRODS0
          SM(I)=EPRSV*SL(I)*UVEC(I)
		
C 		IF (SMA(I).LT.0.D0) 	SMA(I)=UVM*ESRV
	

C      CALCULATING SOLID SALT SM (KG) AND 
C           IF (UVEC(I).LE.UVM)THEN
C             SM(I)=0.0
C           ELSE
C             SM(I)=SMA(I)-UVM*ESRV
C           ENDIF

C         GAIN/LOSS OF FLUID THROUGH FLUID SOURCES AND SINKS
          QSB(I)=QSB(I)+QIN(I)*DELTP
C          GAIN/LOSS OF SOLUTE THROUGH FLUID SOURCES AND SINKS
          USB(I)=USB(I)+QINITR(I)*CW*UIN(I)*DELTU
2        CONTINUE

C     CALCULATING PRECIPITATION INDUCED POROSITY CHANGE POR1
C     BY THIS METHOD, WE ASSUME THE SALT PRECIPTED AT THE SURFACE NODE
C     WILL BE MULCHED ON THE SURFACE, RATHER THAN CHANGING THE POROSITY.
C     INSTEAD, IF PRECIPITATION IS HAPPENED IN THE SOIL, POROSITY WILL
C     BE CHANGED
C     HOWEVER, THE POROSITY CHANGE HERE WILL ONLY AFFECT THE WATER VAPOR
C     FLOW, NOT RATHER FORE WATER RETENTION CURVE, RELATIVE K, AND SO ON
      DO 600 IQP=1,NSOP-1
            I=IQSOP(IQP)    
      IF (SM(IABS(I)).EQ.0.0)THEN
          POR1(IABS(I))=POR(IABS(I))
      ELSE 
         IF (NDPT(IQP).EQ.1)THEN
           POR1(IABS(I))=POR(IABS(I))
         ELSE
             POR1(IABS(I))=POR(IABS(I))-SM(IABS(I))/VOL(IABS(I))/RHOST
         ENDIF
      ENDIF
600      CONTINUE


      DO 200 IP=1,NPBC 
      I=IABS(IPBC(IP))
      QPB(IP)=QPB(IP)+GNUP1(IP)*(PBC(IP)-PVEC(I))*DELTP
      IF (QPLITR(IP).LE.0D0) THEN
         UPB(IP) = UPB(IP)+ QPLITR(IP)*CW*UVEC(I)*DELTU
      ELSE                                                    
         UPB(IP) = UPB(IP)+ QPLITR(IP)*CW*UBC(IP)*DELTU
      ENDIF
  200 CONTINUE 
 1500 CONTINUE
      ENDIF
      
      IF (ISTOP.EQ.1)THEN
      DO 5 I=1,NN
      QST=QST+QSB(I)
      UST=UST+USB(I)
      WMAF=WMAF+WMA(I)
      SMAF=SMAF+SMA(I)
5      CONTINUE
      DO 6 I=1,NPBC
      QPT=QPT+QPB(I)
      UPT=UPT+UPB(I)
6      CONTINUE
      WRITE(21,7)
7      FORMAT(/,'MASS BALANCE')
      WRITE(21,3)WMAI,WMAF,QPT,QST,(WMAF-WMAI),QST+QPT
     1, -(WMAF-WMAI)+QST+QPT,(-(WMAF-WMAI)+QST+QPT)/(QST+QPT)
3      FORMAT('INITIAL WATER STORAGE IS',18X,':',3X,1PE15.8,/
     6,'FINAL WATER STORAGE IS',20X,':',3X,1PE15.8,/
     2,'TOTAL PRESSURE BOUNDARY IN(+)/OUT(-) IS   :',3X,1PE15.8,/
     3,'TOTAL WATER SOURCE(+)/SINK(-) BOUDARY IS  :',3X,1PE15.8,/
     1,'WATER STORAGE DIFF. GAIN(+)/LOSS(-) IS    :',3X,1PE15.8,/
     1,'TOTAL WATER GAIN(+)/LOSS(-) FROM BDY. IS  :',3X,1PE15.8,/
     4,'ABSOLUTE MASS DIF. BTW STORAGE AND IN&OUT :',3X,1PE15.8,/
     5,'RELATIVE MASS DIF. BTW STORAGE AND IN&OUT :',3X,1PE15.8,/)
      WRITE(21,8)
8      FORMAT(/,'SOLUTE BALANCE')
      WRITE(21,4)SMAI,SMAF,UPT,UST,SMAF-SMAI
     1,UPT+UST,-(SMAF-SMAI)+UST+UPT,(-(SMAF-SMAI)+UST+UPT)/(UST+UPT)
4      FORMAT('INITIAL SOLUTE STORAGE IS',17X,':',3X,1PE15.8,/
     6,'FINAL SOLUTE STORAGE IS',19X,':',3X,1PE15.8,/
     2,'TOTAL PRESSURE BOUNDARY IN(+)/OUT(-) IS   :',3X,1PE15.8,/
     3,'TOTAL SOLUTE SOURCE(+)/SINK(-) BOUDARY IS :',3X,1PE15.8,/
     1,'SOLUTE STORAGE DIFF. GAIN(+)/LOSS(-) IS   :',3X,1PE15.8,/
     1,'TOTAL SOLUTE GAIN(+)/LOSS(-) FROM BDY. IS :',3X,1PE15.8,/
     4,'ABSOLUTE MASS DIF. BTW STORAGE AND IN&OUT :',3X,1PE15.8,/
     5,'RELATIVE MASS DIF. BTW STORAGE AND IN&OUT :',3X,1PE15.8,/)
C ......CALCULATE HOW MUCH TIME IS SPENT FOR FINISHING THE PROGRAM
        CALL DATE_AND_TIME(VALUES=IETIME) ! SETS THE FINISHING TIME
C        IEMP=1
        CALL ETIME(TIMEP,TEMP)  
C       TIMEP(1)-USER TIME; TIMEP(2)-SYSTEM TIME
        WRITE(21,10)IBTIME(3),IBTIME(2),IBTIME(1),IBTIME(5),IBTIME(6)
     1,IBTIME(7),IETIME(3),IETIME(2),IETIME(1),IETIME(5),IETIME(6)
     2,IETIME(7)
 10     FORMAT('PROGRAM STARTS AT:',3X,I2,'/',I2,'/',I4,3X
     1,I2,':',I2,':',I2,/,'PROGRAM FINISHES AT:',1X,I2,'/',I2,'/',I4
     2,3X,I2,':',I2,':',I2,/)
        
        IH=INT(TIMEP(1)/3600.)
        IM=INT((TIMEP(1)-3600.*IH)/60.)
        IS=TIMEP(1)-3600.*IH-60.*IM
        WRITE(21,11)IH,IM,IS
 11     FORMAT('USER TIME:',4X,I4,'H',I3,'M',I3,'S')

        IH=INT(TIMEP(2)/3600.)
        IM=INT((TIMEP(2)-3600.*IH)/60.)
        IS=TIMEP(2)-3600.*IH-60.*IM
        WRITE(21,12)IH,IM,IS
 12     FORMAT('SYSTEM TIME:',2X,I4,'H',I3,'M',I3,'S')

        IH=INT((TIMEP(1)+TIMEP(2))/3600.)
        IM=INT(((TIMEP(1)+TIMEP(2))-3600.*IH)/60.)
        IS=(TIMEP(1)+TIMEP(2))-3600.*IH-60.*IM
        WRITE(21,13)IH,IM,IS
 13     FORMAT('OVERALL TIME:',1X,I4,'H',I3,'M',I3,'S')
        ENDIF
      RETURN
      END
C ......




C *** RSC--SALT RESISTANCE
C *** UVM
      SUBROUTINE SALTRESIST(RSC,MSC,C,SM,A)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /SALTRESIS/ AR,BR 
      COMMON /AERORESIS/ RAVT,RAVS,SWRAT
      IF (MSC.LE.0)THEN
      RSC=0.D0
      ELSE
      RSC=(AR*LOG(SM/A*1.D2+EXP(-BR/AR))+BR)*1.D2
	  IF (RSC.LE.0.D0)  RSC = 0.D0 
      ENDIF
      RETURN
      END



C     CALCULATING SENSIBLE HEAT THAT MOVES OUT FROM SOLID TO THE 
C     ATMOSPHERE.
C     WHEN >0 ATMOSPHERE IS HEATING UP SOIL SURFACE
C     WHEN <0 SOIL SURFACE IS HEATING UP ATMOSPHERE
C     THE CALCULATION METHOD IS FROM MICHAEL (2010) AGRICULTRUAL AND
C      FOREST METEOROLOGY 
      DOUBLE PRECISION FUNCTION SENHEAT(TS,TA,RAVT)      
      USE M_PARAMS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C      DOUBLE PRECISION DMAIR,RC,SATM,CP
C      DATA  DMAIR /2.897D-2/, RC/8.314472D+0/,SATM /101.325D+3/
C     1 CP /1.01D+3/
C      SAVE DMAIR,RC,SATM,CP
C     RAVT   -- AERODYNAMIC RESISTANCE [S/M]
C      DMAIR -- MOLECULAR WEIGHT OF AIR 0.02897 [KG/MOL]
C     RC    -- GAS CONSTANT 8.314
C     SATM  -- STANDARD ATMOSPHERE PRESSURE [PA OR KG/M/S2 ]
C     CP    -- HEAT CAPACITY OF AIR   1010  [J/KG/K]
      a=-SATM*DMAIR*CP/RC/TA/RAVT
      SENHEAT=-SATM*DMAIR*CP/RC/TA*(TS-TA)/RAVT

      RETURN
      END


C      QVCONVERT SUB IS USED FOR COVERTING MATRIX QVY (MXD-1,NFY) INTO
C      QVYN(NN1-1)
C      THE MAIN REASON OF HAVING THIS SUB IS DUE TO THE WRONG DIRECTION 
C      OF MATRICES 
C      NREF AND NDPT WHICH IS AGAINST THE DIRECTION OF X AND Y. IN THE
C      FUTURE THIS KIND
C      OF PROBLEM SHOULD ALWAYS BE AVOID
      SUBROUTINE QVCONVERT(QVY,QVYN)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /DEPTH/  MXD,NFY
      DIMENSION QVY(MXD-1,NFY),QVYN(NN1-1)
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3

      DO 1 I=1,NN1-1
      QVYN(I)=QVY(MXD-I,1)
1      CONTINUE
      RETURN
      END

C    QLCONVERT IS TO CONVERT PORE WATER VELOCITY QLY INTO DARCY VELOCITY
C      WHICH IS QLY=SW*POR*VLY. HOWEVER, SINCE THE CURRENT HEAT BALANCE 
C    IS ONLY CONDUCTED IN 1D
C      ONLY THE FIRST COLUMN IS CONVERTED
      SUBROUTINE QLCONVERT(QLY,VLY,SW,POR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC, 
     1   NSOP,NSOU,NBCN,NCIDB 
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
      DIMENSION QLY(NN1-1),VLY(NE),SW(NN),POR(NN)
      DO 1 I=1,NN1-1
       QLY(I)=VLY(I)*(SW(I)+SW(I+1))*(POR(I)+POR(I+1))/4.D0
1      CONTINUE
      RETURN
      END


C      HEATCOND IS TO CALCULATE THE HEAT CONDUCTANCE
C  DATASET 13J: THERMAL CONDUCTIVITIES OF WATER AND LIQUID
C   NTC -- TYPE OF (T)HERMAL (C)ONDUCTIVITIES EQUATION: 
C              NTC=1, USING EQUATIONS FROM SUTRA MANUAL, THEN [TCS]
C                     AND [TCL] HAS TO BE INPUT 
C                     TCS -- THERMAL CONDUCTIVITY OF SOIL  USUALLY 
C                     BETWEEN 2-4 W/M/K
C                     TCL -- THERMAL CONDUCTIVITY OF LIQUID WATER, 0.6 
C                            W/M/K
C              NTC=2, USING EQUATION FROM CHUNG AND HORTON (1987) THREE
C                      PARAMETERS [B1] [B2] [B3] IS REQUIRED 
      SUBROUTINE HEATCOND(HC, POR,SW)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
        COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC, 
     1   NSOP,NSOU,NBCN,NCIDB 
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
        COMMON /TC/ TCS,TCL,B1,B2,B3,NTC
      DIMENSION HC(NN1-1),SW(NN),POR(NN)
        IF (NTC.EQ.1)THEN
        DO 1 I=1,NN1-1
            SWM=(SW(I)+SW(I+1))/2.D0
            PORM=(POR(I)+POR(I+1))/2.D0
           HC(I)=TCL*SWM*PORM+(1.0D0-PORM)*TCS
1        CONTINUE
        ELSEIF(NTC.EQ.2)THEN
        DO 2 I=1,NN1-1
            SWM=(SW(I)+SW(I+1))/2.D0
            PORM=(POR(I)+POR(I+1))/2.D0
            HC(I)=B1+B2*SWM*PORM+B3*(SWM*PORM)**0.5D0
 2        CONTINUE   
        ENDIF
      RETURN
      END

C     FUNCTION YITA IS TO CALCULATE ENHANCEMENT FACTOR PROPOSED BY
C      CASS (1981)
C     THE FIRST INPUT NL, DETERMINES THE LOCATION OF THE ENHANCEMENT 
C     FACTOR AT WATER VAPOR CALCULATION
C   NEF -- THE SWITCH TO THE ENHANCEMENT FACTOR
C     =0, ENHANCEMENT FACTOR EQUALS TO 1
C     =1, APPLY ENHANCEMENT FACTOR TO THE TEMPERATURE GRADIENT TERM ONLY
C     =2, APPLY ENHANCEMENT FACTOR TO ALL OF THE TERMS
C     YITA=9.5D0+3.D0*SW-8.5*EXP(-((1.D0+2.6D0/SQRT(F))*SW)**4.D0)
C     TO 14-10-28   MODIFICATION: ONCE NL=3 OR 4, IT IS THE TEMPERATURE
C     DEPENDENT TERM. THEREFORE, YITA IS CALCULATED BY EQUATION
      DOUBLE PRECISION FUNCTION YITA(NL,SW)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /ENHFAC/ YA,YB,YC,YD,YE,FC,NEF
        IF (NEF.EQ.0)THEN 
           YITA=1.D0
        ELSEIF (NEF.EQ.1)THEN
          IF ((NL.EQ.1).OR.(NL.EQ.2)) THEN !DPDX
           YITA=1.D0
          ELSEIF( (NL.EQ.3).OR.(NL.EQ.4)   )THEN
            YITA=YA+YB*SW-(YA-YD)*EXP(-( (1.D0+YC/SQRT(FC)) *SW) **YE)
          ENDIF
        ELSEIF (NEF.EQ.2)THEN
            YITA=YA+YB*SW-(YA-YD)*EXP(-( (1.D0+YC/SQRT(FC)) *SW) **YE)
        ENDIF
      RETURN 
      END


C
      SUBROUTINE ETOPT(IT,DELT,NFY,ACET)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION ACET(NFY)
      IF (IT.EQ.1) THEN  
C OUTPUT EVAPORATION RATE TO BCO.DAT
      OPEN(21,FILE='BCO.DAT',STATUS='UNKNOWN',POSITION='APPEND')   
C SHOUD IT BE APPENDED?
      WRITE(21,98)
98      FORMAT('  IT',4X,'TIME(DAY)',3X,'ETRATE(M/S)')
      ENDIF
      WRITE(21,99) IT, DBLE(IT)*DELT/3600./24. ,(ACET(I),I=1,NFY)
99      FORMAT(I15,(1PE10.2,2X),500(1PE10.3,1X))
      RETURN
      END

C       OUTPUT HEAT BOUNDARY CONDITIONS
      SUBROUTINE OUTHEAT (X,Y,Z,HANN,VANN,
     1   XX,YY,TPT,HSS,HST,HET,HGT)       
      USE M_PARAMS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /ET/ QET,UET,PET,UVM,NGT,ITE,TMA,TMI,ALF,RS,RH,AP,BP,U2,
     1   TSD,SCF
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /TIMES/ DELT,TSEC,TMIN,THOUR,TDAY,TWEEK,TMONTH,TYEAR,
     1   TMAX,DELTP,DELTU,DLTPM1,DLTUM1,IT,ITBCS,ITRST,ITMAX,TSTART
      DIMENSION X(NN),Y(NN),Z(NN),XX(NN),YY(NN),TPT(NN)
      DIMENSION HANN(NN),VANN(NN),HSS(NN1)
      DIMENSION HLS(NN1),RHVS(NN1)
C      DATA CL/4.186D3/, CP/2.D3/, CA/1.01D3/,DMAIR /2.897D-2/,
C     1     RC/8.314472D+0/,SATM /101.325D+3/
C      SAVE CL,CP,CA,DMAIR,RC,SATM
         NSOPI=NSOP-1
C-----IF IT IS THE FIRST TIME, OUTPUT THE CROSS SECTION OF THE HEAT AREA
      IF (IT.EQ.1) THEN
        OPEN(22,FILE='HEAT.DAT',STATUS='UNKNOWN')           
        WRITE(22,2)
2       FORMAT('NODE',13X,'X',12X,'Y',12X,'Z',8X,'XX',11X,'YY',
     1  11X,'HAREA',8X,'VAREA')
       DO 1 I=1,NN1
            WRITE(22,3) IABS(I), X(I),Y(I),Z(I),
     1       XX(I),YY(I),HANN(I),VANN(I)*SCF
1        CONTINUE
3      FORMAT(I5,1X,9(1PE12.5,1X))
C       HEADERS FOR HEAT RESULT
      WRITE(22,98)
98      FORMAT('  IT',4X,'TIME(DAY)',3X,'G TOP (J)',2X,'ET TOP (J)',
     1       1X,'SEN. TOP (J)','SEN.SIDE',2X,'SEN. SIDE DETAIL.'
     2  ,6X'TPT (K)')
        CLOSE(22)
      ENDIF

      OPEN(22,FILE='HEAT.DAT',STATUS='OLD',POSITION='APPEND')
      WRITE(22,99) IT, DBLE(IT)*DELT/3600./24.,HGT,HET,HST,
     1(HSS(I),I=1,NN1)   !,(TPT(I),I=1,NN1)
99      FORMAT(I7,(1PE10.2,2X),500(1PE10.3,1X))
        CLOSE(22)
        RETURN
        END

C     HEATBALANCE IS TO CALCULATE THE MASS BALANCE OF THE HEAT EQUATION
C     SEE PAGE 125 (BLUECOVER) FOR REFERENCE
      SUBROUTINE  HEATBALANCE (NHEAT,HSS,HST,HET,HGT,HANN,VANN,TPT,TPT1
     1 ,VOL,WMA,RHVS,ACET,DWMADT,HMA,ISTOP)
      USE M_PARAMS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON /TIMES/ DELT,TSEC,TMIN,THOUR,TDAY,TWEEK,TMONTH,TYEAR,      
     1   TMAX,DELTP,DELTU,DLTPM1,DLTUM1,IT,ITBCS,ITRST,ITMAX,TSTART     
      COMMON /ET/ QET,UET,PET,UVM,NGT,ITE,TMA,TMI,ALF,RS,RH,AP,BP,U2,
     1   TSD,SCF
      COMMON /HEATPARA/ HSC,HER,ROUS,HCS
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,    
     1   NSOP,NSOU,NBCN,NCIDB
      COMMON /DEPTH/ MXD,NFY
      COMMON /AERORESIS/ RAVT,RAVS,SWRAT
      DIMENSION ACET(NFY),DWMADT(NN)
      COMMON /SOLVI/ KSOLVP,KSOLVU,NN1,NN2,NN3                          
      DIMENSION HMA(NN1),RHVS(NN1)
      DIMENSION HANN(NN),VANN(NN),HSS(NN1)
      DIMENSION TPT(NN),TPT1(NN),VOL(NN),WMA(NN)
      SAVE HMAI,THET,THGT,THSS,THST
C      DATA CL/4.186D3/, CP/2.D3/, CA/1.01D3/,DMAIR /2.897D-2/,
C     1     RC/8.314472D+0/,SATM /101.325D+3/
C      SAVE CL,CP,CA,DMAIR,RC,SATM,HMAI,THET,THGT,THSS,THST
C     HMAI-- (I)NITIAL (H)EAT (MA)SS FOR ALL THE NODES
C     HMA -- (H)EAT (MA)SS IN THE CURRENT TIME STEP
C     VLH  - LATENT HEAT FOR VAPORIZATION [J/KG]
C     TMAK - ATMOSPHEREIC TEMPERATURE IN [K]
C     TIK  - INITIAL SOIL TEMPERATURE [K]
C     TSDK - TEMPERATURE ON THE SIDE OF THE COLUMN [K]
      VLH=(2.50025-0.002365*(TMA))*1.D6 
      TMAK=TMA+273.15 
      TIK=TMI+273.15                  
      TSDK=TSD+273.15                 
C-------INITIALIZE THE MATRIX AT THE FIRST TIME TO CALL HEATBALANCE-----
      IF (NHEAT.EQ.0)THEN
C         THE INITIALIZATION OF HSS,HST,HET,HGT ARE IN SUB SUTRA
C          BECAUSE THEY NEED TO BE TRANSFERED
        HMAI=0.D0
        THET=0.D0
        THGT=0.D0
        THSS=0.D0
        THST=0.D0
        DO 1 I=1,NN1
          HMA(I)=(HCS*ROUS*VOL(I)+CL*WMA(I))*(TPT(I)-TIK)
          HMAI=HMAI+HMA(I)
 1      CONTINUE
C------CALCULATE HEAT BALANCE FOR THE OTHER TIME CALLING HEATBALANCE----
      ELSEIF(NHEAT.EQ.1)THEN
        DO 2 I=1,NN1
C       HEAT GAIN/LOSS DUE TO TEMPERATURE CHANGE          
          HMA(I)=HMA(I)+(HCS*ROUS*VOL(I)+CL*WMA(I))*(TPT(I)-TPT1(I))
C       HEAT GAIN/LOSS DUE TO WATER CHANGE
          HMA(I)=HMA(I)+CL*DWMADT(I)*DELTP*(TPT(I)-TIK)
C       (H)EAT GAIN/LOSS DUE TO (S)ENSIBLE HEAT EXCHANGE FROM (S)IDE
          HSS(I)=-SCF*CA*SATM*DMAIR/RC/TSDK/RHVS(I)*(TPT(I)-TSDK)
     1        *VANN(I)*DELTP
C   (T)OTAL (H)EAT GAIN/LOSS DUE TO (S)ENSIBLE HEAT EXCHANGE FROM (S)IDE
          THSS=THSS+HSS(I) 
 2         CONTINUE

C       (H)EAT GAIN/LOSS DUE TO (E)VAPORA(T)ION
          HET=+ACET(1)*VLH*RHOW0*HANN(NN1)*DELTP
C       (T)OTAL (H)EAT GAIN/LOSS DUE TO (E)VAPORA(T)ION
          THET=THET+HET
C       (H)EAT GAIN/LOSS DUE TO (S)ENSIBLE HEAT EXCHANGE FROM (T)OP
          HST=-SWRAT*CA*SATM*DMAIR/RC/TMAK/RAVT*(TPT(NN1)-TMAK)
     1        *HANN(NN1)*DELTP
C    (T)OTAL (H)EAT GAIN/LOSS DUE TO (S)ENSIBLE HEAT EXCHANGE FROM (T)OP
          THST=THST+HST
C       (H)EAT (G)AIN FROM THE (T)OP
          HGT=HSC*HANN(NN1)*DELTP
C       (T)OTAL (H)EAT (G)AIN FROM THE (T)OP
          THGT=THGT+HGT
        ENDIF
        
      IF (ISTOP.EQ.1)THEN
       HMAF=0.D0
       DO 3 I=1,NN
C      (H)EAT (M)ASS IN THE DOMAIN AT (F)INAL STEP
         HMAF=HMAF+HMA(I)
3      CONTINUE
      OPEN(22,FILE='HEAT.DAT',STATUS='OLD',POSITION='APPEND')
      WRITE(22,7)
C       NET (H)EAT (S)TORAGE IN THE (D)OMAIN
        HSD=HMAF-HMAI
C       NET (H)EAT (E)XCHANGE FROM (B)OUNDARY
        HEB=THET+THST+THSS+THGT
 7      FORMAT(/,'HEAT BALANCE')
        WRITE(22,8)HMAI,HMAF,THET,THST,THSS,THGT,HSD,
     1 HEB,HSD-HEB,(HSD-HEB)/HEB
 8      FORMAT('INITIAL HEAT STORAGE IS (J)',18X,':',3X,1PE15.8,/
     6,'FINAL HEAT STORAGE IS',24X,':',3X,1PE15.8,/
     2,'TOTAL HEAT LOSS(-) BY EVAPORATIONT  IS (J)   :',3X,1PE15.8,/
     3,'TOTAL SENSIBLE HEAT GAIN(+)/LOSS(-) AT TOP   :',3X,1PE15.8,/
     1,'TOTAL SENSIBLE HEAT GAIN(+)/LOSS(-) AT SIDE  :',3X,1PE15.8,/
     1,'TOTAL HEAT INPUT(+) FROM TOP IS   (J)        :',3X,1PE15.8,//
     4,'NET HEAT STORAGE IN THE DOMAIN IS (J)        :',3X,1PE15.8,/
     5,'NET HEAT GAIN(+)/LOSS(-) FROM BOUNDARY IS (J):',3X,1PE15.8,//
     4,'ABSOLUTE HEAT DIF. BTW STORAGE AND IN&OUT (J):',3X,1PE15.8,/
     5,'RELATIVE HEAT DIF. BTW STORAGE AND IN&OUT (-):',3X,1PE15.8,/)
        CLOSE(22)
        ENDIF
        RETURN
        END


