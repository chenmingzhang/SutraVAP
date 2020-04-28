
C     SUBROUTINE        B  C  T  I  M  E           SUTRA VERSION 2.2     BCTIME.........100
C                                                                        BCTIME.........200
C *** PURPOSE :                                                          BCTIME.........300
C ***  USER-PROGRAMMED SUBROUTINE WHICH ALLOWS THE USER TO SPECIFY:      BCTIME.........400
C ***   (1) TIME-DEPENDENT SPECIFIED PRESSURES AND TIME-DEPENDENT        BCTIME.........500
C ***       CONCENTRATIONS OR TEMPERATURES OF INFLOWS AT THESE POINTS    BCTIME.........600
C ***   (2) TIME-DEPENDENT SPECIFIED CONCENTRATIONS OR TEMPERATURES      BCTIME.........700
C ***   (3) TIME-DEPENDENT FLUID SOURCES AND CONCENTRATIONS              BCTIME.........800
C ***       OR TEMPERATURES OF INFLOWS AT THESE POINTS                   BCTIME.........900
C ***   (4) TIME-DEPENDENT ENERGY OR SOLUTE MASS SOURCES                 BCTIME........1000
C                                                                        BCTIME........1100
      SUBROUTINE BCTIME(IPBC,PBC,IUBC,UBC,QIN,UIN,QUIN,IQSOP,IQSOU,      BCTIME........1200
     1   IPBCT,IUBCT,IQSOPT,IQSOUT,X,Y,Z,IBCPBC,IBCUBC,IBCSOP,IBCSOU,
     2   PITER,UITER,GNUP1,GNUU1,RCIT,SW,VOL1,POR,SM,
     3   NDPT,NREF,WMA,HAREA,VAREA,DFR,PWFR,PCFR,POR1,TPT,ACET,QVYN
     4   ,QVX,QVY,TPT1,NREG,YY)
      USE M_PARAMS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                                BCTIME........1400
      DIMENSION IPBC(NBCN),PBC(NBCN),IUBC(NBCN),UBC(NBCN),               BCTIME........1500
     1   QIN(NN),UIN(NN),QUIN(NN),IQSOP(NSOP),IQSOU(NSOU),               BCTIME........1600
     2   X(NN),Y(NN),Z(NN)                                               BCTIME........1700
      INTEGER(1) IBCPBC(NBCN),IBCUBC(NBCN),IBCSOP(NSOP),IBCSOU(NSOU)     BCTIME........1800
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,              BCTIME........1900
     1   NSOP,NSOU,NBCN,NCIDB                                            BCTIME........2000
      COMMON /FUNITS/ K00,K0,K1,K2,K3,K4,K5,K6,K7,K8,K9,                 BCTIME........2100
     1   K10,K11,K12,K13                                                 BCTIME........2200
      COMMON /GRAVEC/ GRAVX,GRAVY,GRAVZ                                  BCTIME........2300
      COMMON /TIMES/ DELT,TSEC,TMIN,THOUR,TDAY,TWEEK,TMONTH,TYEAR,       BCTIME........2400
     1   TMAX,DELTP,DELTU,DLTPM1,DLTUM1,IT,ITBCS,ITRST,ITMAX,TSTART      BCTIME........2500
      COMMON /JCOLS/ NCOLPR,LCOLPR,NCOLS5,NCOLS6,J5COL,J6COL
      COMMON /DEPTH/  MXD,NFY
      INTEGER NDPT(NSOP),NREF(NSOP)
      DIMENSION DFR(NSOP),PWFR(NSOP),PCFR(NSOP)
      DIMENSION KTYPE(2)
      COMMON /CONTRL/ GNUP,GNUU,UP,DTMULT,DTMAX,ME,ISSFLO,ISSTRA,ITCYC, 
     1   NPCYC,NUCYC,NPRINT,NBCFPR,NBCSPR,NBCPPR,NBCUPR,IREAD,          
     2   ISTORE,NOUMAT,IUNSAT,KTYPE,MET,MAR,MSR,MSC,MHT,MVT,MFT,MRK
      COMMON /DIMX2/ NELTA,NNVEC,NDIMIA,NDIMJA   
      COMMON /TIDE/ TA,TP,TM,RHOST,SC,TH,ITT
      COMMON /ET/ QET,UET,PET,UVM,NGT,ITE,TMA,TMI,ALF,RS,RH,AP,BP,U2,
     1   TSD,SCF
      COMMON /HEATPARA/ HSC,HER,ROUS,HCS
      COMMON /SOLVI/ KSOLVP, KSOLVU, NN1, NN2, NN3
      COMMON /ITERAT/ RPM,RPMAX,RUM,RUMAX,ITER,ITRMAX,IPWORS,IUWORS
      DIMENSION GNUP1(NBCN),GNUU1(NBCN),PITER(NN),UITER(NN),RCIT(NN)
      DIMENSION VOL1(NN),SW(NN),POR(NN),WMA(NN),HAREA(NSOP),POR1(NN)
      DIMENSION TPT(NN),TPT1(NN),NREG(NN),YY(NN)
      DIMENSION SM(NNVEC),VAREA(NSOP)
      DIMENSION QVYN(NN1-1)
      DIMENSION QVX(MXD,NFY-1),QVY(MXD-1,NFY)
      DIMENSION ACET(NFY)
      CHARACTER*80 ERRCOD
      CHARACTER INTFIL*1000
C     MXD---MAXIMUM NO. OF LAYERS AT THE EVAPORATION FRONT
C     NFY---NUMBER OF NODES IN EACH LAYER
C                                                                        BCTIME........2600
C.....DEFINITION OF REQUIRED VARIABLES                                   BCTIME........2700
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........2800
C     NN = EXACT NUMBER OF NODES IN MESH                                 BCTIME........2900
C     NPBC = EXACT NUMBER OF SPECIFIED PRESSURE NODES                    BCTIME........3000
C     NUBC = EXACT NUMBER OF SPECIFIED CONCENTRATION                     BCTIME........3100
C            OR TEMPERATURE NODES                                        BCTIME........3200
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........3300
C     IT = NUMBER OF CURRENT TIME STEP                                   BCTIME........3400
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........3500
C     TSEC = TIME AT END OF CURRENT TIME STEP IN SECONDS                 BCTIME........3600
C     TMIN = TIME AT END OF CURRENT TIME STEP IN MINUTES                 BCTIME........3700
C     THOUR = TIME AT END OF CURRENT TIME STEP IN HOURS                  BCTIME........3800
C     TDAY = TIME AT END OF CURRENT TIME STEP IN DAYS                    BCTIME........3900
C     TWEEK = TIME AT END OF CURRENT TIME STEP IN WEEKS                  BCTIME........4000
C     TMONTH = TIME AT END OF CURRENT TIME STEP IN MONTHS                BCTIME........4100
C     TYEAR = TIME AT END OF CURRENT TIME STEP IN YEARS                  BCTIME........4200
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........4300
C     PBC(IP) = SPECIFIED PRESSURE VALUE AT IP(TH) SPECIFIED             BCTIME........4400
C               PRESSURE NODE                                            BCTIME........4500
C     UBC(IP) = SPECIFIED CONCENTRATION OR TEMPERATURE VALUE OF ANY      BCTIME........4600
C               INFLOW OCCURRING AT IP(TH) SPECIFIED PRESSURE NODE       BCTIME........4700
C     IPBC(IP) = ACTUAL NODE NUMBER OF IP(TH) SPECIFIED PRESSURE NODE    BCTIME........4800
C                {WHEN NODE NUMBER I=IPBC(IP) IS NEGATIVE (I<0),         BCTIME........4900
C                VALUES MUST BE SPECIFIED FOR PBC AND UBC.}              BCTIME........5000
C     IBCPBC(IP) = INDICATOR OF WHERE THIS PRESSURE SPECIFICATION        BCTIME........5100
C                  WAS MADE. MUST BE SET TO -1 TO INDICATE THAT THIS     BCTIME........5200
C                  SPECIFICATION WAS MADE IN SUBROUTINE BCTIME.          BCTIME........5300
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........5400
C     UBC(IUP) = SPECIFIED CONCENTRATION OR TEMPERATURE VALUE AT         BCTIME........5500
C                IU(TH) SPECIFIED CONCENTRATION OR TEMPERATURE NODE      BCTIME........5600
C                (WHERE IUP=IU+NPBC)                                     BCTIME........5700
C     IUBC(IUP) = ACTUAL NODE NUMBER OF IU(TH) SPECIFIED CONCENTRATION   BCTIME........5800
C                 OR TEMPERATURE NODE (WHERE IUP=IU+NPBC)                BCTIME........5900
C                 {WHEN NODE NUMBER I=IUBC(IU) IS NEGATIVE (I<0),        BCTIME........6000
C                 A VALUE MUST BE SPECIFIED FOR UBC.}                    BCTIME........6100
C     IBCUBC(IUP) = INDICATOR OF WHERE THIS CONCENTRATION OR TEMPERATURE BCTIME........6200
C                  SPECIFICATION WAS MADE. MUST BE SET TO -1 TO INDICATE BCTIME........6300
C                  THAT THIS SPECIFICATION WAS MADE IN SUBROUTINE        BCTIME........6400
C                  BCTIME.                                               BCTIME........6500
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........6600
C     IQSOP(IQP) = NODE NUMBER OF IQP(TH) FLUID SOURCE NODE.             BCTIME........6700
C                  {WHEN NODE NUMBER I=IQSOP(IQP) IS NEGATIVE (I<0),     BCTIME........6800
C                  VALUES MUST BE SPECIFIED FOR QIN AND UIN.}            BCTIME........6900
C     QIN(-I) = SPECIFIED FLUID SOURCE VALUE AT NODE (-I)                BCTIME........7000
C     UIN(-I) = SPECIFIED CONCENTRATION OR TEMPERATURE VALUE OF ANY      BCTIME........7100
C               INFLOW OCCURRING AT FLUID SOURCE NODE (-I)               BCTIME........7200
C     IBCSOP(IQP) = INDICATOR OF WHERE THIS FLUID SOURCE SPECIFICATION   BCTIME........7300
C                   WAS MADE. MUST BE SET TO -1 TO INDICATE THAT THIS    BCTIME........7400
C                   SPECIFICATION WAS MADE IN SUBROUTINE BCTIME.         BCTIME........7500
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........7600
C     IQSOU(IQU) = NODE NUMBER OF IQU(TH) ENERGY OR                      BCTIME........7700
C                  SOLUTE MASS SOURCE NODE                               BCTIME........7800
C                  {WHEN NODE NUMBER I=IQSOU(IQU) IS NEGATIVE (I<0),     BCTIME........7900
C                  A VALUE MUST BE SPECIFIED FOR QUIN.}                  BCTIME........8000
C     QUIN(-I) = SPECIFIED ENERGY OR SOLUTE MASS SOURCE VALUE            BCTIME........8100
C                AT NODE (-I)                                            BCTIME........8200
C     IBCSOU(IQU) = INDICATOR OF WHERE THIS ENERGY OR SOLUTE MASS        BCTIME........8300
C                   SOURCE SPECIFICATION WAS MADE. MUST BE SET TO -1     BCTIME........8400
C                   TO INDICATE THAT THIS SPECIFICATION WAS MADE IN      BCTIME........8500
C                   SUBROUTINE BCTIME.                                   BCTIME........8600
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........8700
C                                                                        BCTIME........8800
C.....ADDITIONAL USEFUL VARIABLES                                        BCTIME........8900
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........9000
C     "FUNITS" ARE UNIT NUMBERS FOR INPUT AND OUTPUT FILES               BCTIME........9100
C         AS ASSIGNED IN THE INPUT FILE "SUTRA.FIL"                      BCTIME........9200
C                                                                        BCTIME........9300
C     X(I), Y(I), AND Z(I) ARE THE X-, Y-, AND Z-COORDINATES OF NODE I   BCTIME........9400
C     (FOR 2-D PROBLEMS, Z(I) IS THE MESH THICKNESS AT NODE I)           BCTIME........9500
C                                                                        BCTIME........9600
C     GRAVX, GRAVY AND GRAVZ ARE THE X-, Y-, AND Z-COMPONENTS OF THE     BCTIME........9700
C     GRAVITY VECTOR (FOR 2-D PROBLEMS, GRAVZ = 0)                       BCTIME........9800
C . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  BCTIME........9900
C                                                                        BCTIME.......10000
C                                                                        BCTIME.......10100
C.....NSOPI IS ACTUAL NUMBER OF FLUID SOURCE NODES                       BCTIME.......10200
      NSOPI=NSOP-1                                                       BCTIME.......10300
C.....NSOUI IS ACTUAL NUMBER OF ENERGY OR SOLUTE MASS SOURCE NODES       BCTIME.......10400
      NSOUI=NSOU-1                                                       BCTIME.......10500
C.....INITIALIZE ALL OF THE VALUE THAT IS GOING TO BE CHANGED IN THIS 
C    SUBROUTINE
      ETS=0.0
      DO 112 I=1,MXD
       DO 112 J=1,NFY
         IF (I.LT.MXD) QVY(I,J)=0.D0
112         IF (J.LT.NFY) QVX(I,J)=0.D0
      CALL ZERO(QIN,NN,0.D0)
      CALL ZERO(UIN,NN,0.D0)
      CALL ZERO(DFR,NSOP,0.D0)
      CALL ZERO(PWFR,NSOP,0.D0)
      CALL ZERO(PCFR,NSOP,0.D0)
C                                                                        BCTIME.......10600
C                                                                        BCTIME.......10700
C                                                                        BCTIME.......10800
C                                                                        BCTIME.......10900
C                                                                        BCTIME.......11000
C                                                                        BCTIME.......11100
      IF(IPBCT) 50,240,240                                               BCTIME.......11200
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......11300
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......11400
C.....SECTION (1):  SET TIME-DEPENDENT SPECIFIED PRESSURES OR            BCTIME.......11500
C     CONCENTRATIONS (TEMPERATURES) OF INFLOWS AT SPECIFIED              BCTIME.......11600
C     PRESSURE NODES                                                     BCTIME.......11700
C                                                                        BCTIME.......11800
   50 CONTINUE                                                           BCTIME.......11900
      DO 200 IP=1,NPBC                                                   BCTIME.......12000
      I=IPBC(IP)                                                         BCTIME.......12100
      IF(I) 100,200,200                                                  BCTIME.......12200
  100 CONTINUE                                                           BCTIME.......12300
C     NOTE: A FLOW AND TRANSPORT SOLUTION MUST OCCUR FOR ANY             BCTIME.......12400
C           TIME STEP IN WHICH PBC( ) CHANGES.                           BCTIME.......12500
C     PBC(IP) =  ((          ))                                          BCTIME.......12600
C     UBC(IP) =  ((          ))                                          BCTIME.......12700
C.....IBCPBC(IP) MUST BE SET TO -1 TO INDICATE THAT PBC(IP)              BCTIME.......12800
C        AND/OR UBC(IP) HAVE BEEN SET BY SUBROUTINE BCTIME.              BCTIME.......12900
      IBCPBC(IP) = -1                                                    BCTIME.......13000
  200 CONTINUE                                                           BCTIME.......13100
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......13200
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......13300
C                                                                        BCTIME.......13400
C                                                                        BCTIME.......13500
C                                                                        BCTIME.......13600
C                                                                        BCTIME.......13700
C                                                                        BCTIME.......13800
C                                                                        BCTIME.......13900
  240 IF(IUBCT) 250,440,440                                              BCTIME.......14000
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......14100
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......14200
C.....SECTION (2):  SET TIME-DEPENDENT SPECIFIED                         BCTIME.......14300
C     CONCENTRATIONS (TEMPERATURES)                                      BCTIME.......14400
C                                                                        BCTIME.......14500
  250 CONTINUE                                                           BCTIME.......14600
      DO 400 IU=1,NUBC                                                   BCTIME.......14700
      IUP=IU+NPBC                                                        BCTIME.......14800
      I=IUBC(IUP)                                                        BCTIME.......14900
      IF(I) 300,400,400                                                  BCTIME.......15000
  300 CONTINUE                                                           BCTIME.......15100
C     NOTE: A TRANSPORT SOLUTION MUST OCCUR FOR ANY TIME STEP IN WHICH   BCTIME.......15200
C           UBC( ) CHANGES.  IN ADDITION, IF FLUID PROPERTIES ARE        BCTIME.......15300
C           SENSITIVE TO 'U', THEN A FLOW SOLUTION MUST OCCUR AS WELL.   BCTIME.......15400
C     UBC(IUP) =   ((          ))                                        BCTIME.......15500
C.....IBCUBC(IUP) MUST BE SET TO -1 TO INDICATE THAT UBC(IUP)            BCTIME.......15600
C        HAS BEEN SET BY SUBROUTINE BCTIME.                              BCTIME.......15700
      IBCUBC(IUP) = -1                                                   BCTIME.......15800
  400 CONTINUE                                                           BCTIME.......15900
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......16000
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......16100
C                                                                        BCTIME.......16200
C                                                                        BCTIME.......16300
C                                                                        BCTIME.......16400
C                                                                        BCTIME.......16500
C                                                                        BCTIME.......16600
C                                                                        BCTIME.......16700
  440 IF(IQSOPT) 450,640,640                                             BCTIME.......16800
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......16900
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......17000
C.....SECTION (3):  SET TIME-DEPENDENT FLUID SOURCES/SINKS,              BCTIME.......17100
C      OR CONCENTRATIONS (TEMPERATURES) OF SOURCE FLUID                  BCTIME.......17200
C                                                                        BCTIME.......17300
  450 CONTINUE                                                           BCTIME.......17400
      DO 600 IQP=1,NSOPI                                                 BCTIME.......17500
      I=IQSOP(IQP)                                                       BCTIME.......17600
      IF(I) 500,600,600                                                  BCTIME.......17700
  500 CONTINUE                                                           BCTIME.......17800
C     NOTE: A FLOW AND TRANSPORT SOLUTION MUST OCCUR FOR ANY             BCTIME.......17900
C           TIME STEP IN WHICH QIN( ) CHANGES.                           BCTIME.......18000
C     QIN(-I) =   ((           ))                                        BCTIME.......18100
C     NOTE: A TRANSPORT SOLUTION MUST OCCUR FOR ANY                      BCTIME.......18200
C           TIME STEP IN WHICH UIN( ) CHANGES.                           BCTIME.......18300
C     UIN(-I) =   ((           ))                                        BCTIME.......18400
C.....IBCSOP(IQP) MUST BE SET TO -1 TO INDICATE THAT QIN(-I)             BCTIME.......18500
C        AND/OR UIN(-I) HAVE BEEN SET BY SUBROUTINE BCTIME.              BCTIME.......18600
      IBCSOP(IQP) = -1                                                   BCTIME.......18700
      IF ( PITER(IABS(I)).LT.PET) THEN                 ! SATURATION
      IF ( NDPT(IQP).EQ.1)THEN                 ! FIRST LAYER EVAPORATION
      CALL SALTRESIST(RSC,UVM,UITER(IABS(I)),SM(IABS(I)),HAREA(IQP))
      CALL AEROSIST(RAVT,MAR)
      IF (IT.EQ.1517) THEN
       AAA=1.D0
      ENDIF
      CALL EVAPORATION (AET,PITER(IABS(I)),UITER(IABS(I))
     1,RCIT(IABS(I)),WMA(IABS(I)),SM(IABS(I)),PW,PC,DELL,TAUTH,DFR(IQP)
     2,PWFR(IQP),PCFR(IQP),RSC,TPT(IABS(I)),POR(IABS(I)),SW(IABS(I))
     3,NREG(IABS(I)),YY(IABS(I)))
      ACET(NREF(IQP))=AET
      ETS=ETS+AET*3600.*24.*1000.  ! MM/DAY FOR OUTPUT USAGE
      AET=AET*1.D3*HAREA(IQP)       ! M/S * 1000KG/M3 * M2
       QIN(IABS(I))=AET 
       UIN(IABS(I))=UET
      ENDIF                                      !FIRSTLAYER EVAPORATION
C     AET IS THE FLUX INDUCED BY EVAPORATION
C     IIQP IS THE SEQUENCE OF THE SOURCE AND SINK NODE. RANGE: 1-ISOPT
C     II IS THE GLOBAL SEQUENCE OF THE NODE. RANGE 1-NN
C     SEE NOTEBOOK3 P103
      AET=0.D0
      IIQP=0
      II=0


C      MVT IS A SWICH FOR OPEN (=1),OR CLOSE THE VAPOR TRANSPORT
      IF (MVT.EQ.0)GOTO 2650                   
C  FIND OUT HORIZONTAL OR VERTICAL NODE J=1 HORIZONTAL J=2 VERTICAL
      DO 185 J=1,2             
        CALL NNODE(IIQP,J,IQP,NDPT,NREF,NSOPI)
C    THE NEXT NODE SHOULD BE EXIST
        IF (IIQP.NE.0.) THEN                                           
          II=IQSOP(IIQP)
C    THE NEXT NODE SHOULD NOT BE SATURATED
          IF (PITER(IABS(I)).LT.PET)THEN     
           IF (J.EQ.1)THEN 
             X1=X(IABS(I))
             X2=X(IABS(II))
           ELSEIF (J.EQ.2)THEN
             X1=Y(IABS(I))
             X2=Y(IABS(II))
           ENDIF
C    ------ CALCULATING THE VAPOR FLUX BETWEEN TWO CELLS.-----
C    IF POR1 IS USED FOR CALCULATING VAPOR FLOW, IT MEANS THE EFFECT
C    OF SALT PRECIPITATION TO VAPOR FLOW IS ACCOUNTED FOR.
C    FOR DEBUGGING 
C      IF (SW(IABS(II)).LE.0.05.AND.J.EQ.2)THEN
C       DD=1.D0
C      ENDIF
C     VAPOR CALCULATION
          CALL VAPOR (AET,SW(IABS(I)),SW(IABS(II)),PITER(IABS(I))    
     2       ,PITER(IABS(II)),UITER(IABS(I)),UITER(IABS(II)),
     2    POR1(IABS(I)),POR1(IABS(II)),TPT(IABS(I)),TPT(IABS(II)),X1,X2)
C         THE REASON OF HAVING 0.5*(VAREA(IQP)+VAREA(IIQP)) AND
C         0.5*(HAREA(IQP)+HAREA(IIQP)) IS THAT VAPOR FLOW IS CALCULATED 
C         ON THE CELL BASIS, THE INTERFACE IS ACTUALLY NOT AT THE NODE, 
C         BUT IN BETWEEN THE NODES. 
          UIN(IABS(I))=UET
          UIN(IABS(II))=UET
C        HORIZONTAL VAPOR MOVEMENT                                   
            IF (J.EQ.1) THEN     
C        STORING VAPOR VELOCITY FOR FURTHER ANALYSIS
            QVX(NDPT(IQP),NREF(IQP))=AET
C .....MULTIPLYING THE ET RATE (M/S) BY THE AREA BETWEEN THE CELL. THIS
C      IS DONE BY THE HALF OF THE SUMMATION BETWEEN THE 
C......THIS LINE HAS TWO METHODS, ONE IS REGULAR Z METHOD,
C      ANOTHER IS IRREGULAR METHOD
C      IRREGULAR METHOD WHEN CALLING SINKAREACYLINDRICAL,
C      WHERE VAREA IS THE AREA OF THE RIGHTMOST OF THE CELL
             AET=AET*RHOWP*VAREA(IQP)  
C            AET=0.5*AET*RHOW0*(VAREA(IQP)+VAREA(IIQP)) 
           ! REGULAR METHOD WHEN CALLING SINKAREA(
          QIN(IABS(I))=QIN(IABS(I))-AET
        ! THE WRONG DIRECTION OF AET IS APPARENT INDUCED BY 
          QIN(IABS(II))=QIN(IABS(II))+AET
          ELSE
            QVY(NDPT(IQP),NREF(IQP))=AET
            AET=0.5*AET*RHOW0*(HAREA(IQP)+HAREA(IIQP))     
      !    1D-6 IS THE AREA OF THE CROSS SECTION.
          QIN(IABS(I))=QIN(IABS(I))+AET
          QIN(IABS(II))=QIN(IABS(II))-AET
          ENDIF
                         
          ENDIF                ! THE NEXT NODE SHOULD NOT BE SATURATED
        ENDIF                ! THE NEXT NODE SHOULD BE EXIST
185      CONTINUE         !FINDOUT HORIZONTAL OR VERTICAL NODE
2650      CONTINUE
      ENDIF                                     ! SATURATION

  600 CONTINUE                                                           BCTIME.......18800   ! END OF LOOP
      CALL QVCONVERT(QVY,QVYN)


C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......18900
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......19000
C                                                                        BCTIME.......19100
C                                                                        BCTIME.......19200
C                                                                        BCTIME.......19300
C                                                                        BCTIME.......19400
C                                                                        BCTIME.......19500
C                                                                        BCTIME.......19600
  640 IF(IQSOUT) 650,840,840                                             BCTIME.......19700
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......19800
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......19900
C.....SECTION (4):  SET TIME-DEPENDENT SOURCES/SINKS                     BCTIME.......20000
C     OF SOLUTE MASS OR ENERGY                                           BCTIME.......20100
C                                                                        BCTIME.......20200
  650 CONTINUE                                                           BCTIME.......20300
      DO 800 IQU=1,NSOUI                                                 BCTIME.......20400
      I=IQSOU(IQU)                                                       BCTIME.......20500
      IF(I) 700,800,800                                                  BCTIME.......20600
  700 CONTINUE                                                           BCTIME.......20700
C     NOTE: A TRANSPORT SOLUTION MUST OCCUR FOR ANY                      BCTIME.......20800
C           TIME STEP IN WHICH QUIN( ) CHANGES.                          BCTIME.......20900
C     QUIN(-I) =   ((           ))                                       BCTIME.......21000
C.....IBCSOU(IQU) MUST BE SET TO -1 TO INDICATE THAT QUIN(-I)            BCTIME.......21100
C        HAS BEEN SET BY SUBROUTINE BCTIME.                              BCTIME.......21200
      IBCSOU(IQU) = -1                                                   BCTIME.......21300
  800 CONTINUE                                                           BCTIME.......21400
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......21500
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  BCTIME.......21600
C                                                                        BCTIME.......21700
C                                                                        BCTIME.......21800
C                                                                        BCTIME.......21900
C                                                                        BCTIME.......22000
C                                                                        BCTIME.......22100
C                                                                        BCTIME.......22200
  840 CONTINUE                                                           BCTIME.......22300
C                                                                        BCTIME.......22400
      RETURN                                                             BCTIME.......22500
      END                                                                BCTIME.......22600

