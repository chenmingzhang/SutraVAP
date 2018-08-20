C     SUBROUTINE        U  N  S  A  T              SUTRA VERSION 2.2     UNSAT..........100
C                                                                        UNSAT..........200
C *** PURPOSE :                                                          UNSAT..........300
C ***  USER-PROGRAMMED SUBROUTINE GIVING:                                UNSAT..........400
C ***  (1)  SATURATION AS A FUNCTION OF PRESSURE ( SW(PRES) )            UNSAT..........500
C ***  (2)  DERIVATIVE OF SATURATION WITH RESPECT TO PRESSURE            UNSAT..........600
C ***       AS A FUNCTION OF EITHER PRESSURE OR SATURATION               UNSAT..........700
C ***       ( DSWDP(PRES), OR DSWDP(SW) )                                UNSAT..........800
C ***  (3)  RELATIVE PERMEABILITY AS A FUNCTION OF EITHER                UNSAT..........900
C ***       PRESSURE OR SATURATION ( REL(PRES) OR RELK(SW) )             UNSAT.........1000
C ***                                                                    UNSAT.........1100
C ***  CODE BETWEEN DASHED LINES MUST BE REPLACED TO GIVE THE            UNSAT.........1200
C ***  PARTICULAR UNSATURATED RELATIONSHIPS DESIRED.                     UNSAT.........1300
C ***                                                                    UNSAT.........1400
C ***  DIFFERENT FUNCTIONS MAY BE GIVEN FOR EACH REGION OF THE MESH.     UNSAT.........1500
C ***  REGIONS ARE SPECIFIED BY BOTH NODE NUMBER AND ELEMENT NUMBER      UNSAT.........1600
C ***  IN INPUT DATA FILE FOR UNIT K1 (INP).                             UNSAT.........1700
C                                                                        UNSAT.........1800
      SUBROUTINE UNSAT(SW,DSWDP,RELK,PRES,KREG)                          UNSAT.........1900
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                                UNSAT.........2000
      DIMENSION KTYPE(2)                                                 UNSAT.........2100
      COMMON /CONTRL/ GNUP,GNUU,UP,DTMULT,DTMAX,ME,ISSFLO,ISSTRA,ITCYC,  UNSAT.........2200
     1   NPCYC,NUCYC,NPRINT,NBCFPR,NBCSPR,NBCPPR,NBCUPR,IREAD,           UNSAT.........2300
     2   ISTORE,NOUMAT,IUNSAT,KTYPE                                      UNSAT.........2400
	COMMON /UNSA/ SWRES1,AA1,VN1,SWRES2,AA2,VN2
C                                                                        UNSAT.........2500
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- UNSAT.........2600
C     E X A M P L E   C O D I N G   FOR                                  UNSAT.........2700
C     MESH WITH TWO REGIONS OF UNSATURATED PROPERTIES USING              UNSAT.........2800
C     THREE PARAMETER-UNSATURATED FLOW RELATIONSHIPS OF                  UNSAT.........2900
C     VAN GENUCHTEN(1980)                                                UNSAT.........3000
C        RESIDUAL SATURATION, SWRES, GIVEN IN UNITS {L**0}               UNSAT.........3100
C        PARAMETER, AA, GIVEN IN INVERSE PRESSURE UNITS {m*(s**2)/kg}    UNSAT.........3200
C        PARAMETER, VN, GIVEN IN UNITS {L**0}                            UNSAT.........3300
C                                                                        UNSAT.........3400
C      REAL SWRES,AA,VN,SWRM1,AAPVN,VNF,AAPVNN,DNUM,DNOM,SWSTAR           UNSAT.........3500
	DOUBLE PRECISION SWRES,AA,VN,SWRM1,AAPVN,VNF,AAPVNN,DNUM,DNOM
     1,SWSTAR
	DOUBLE PRECISION SA,PMM
	DATA SA/1.D-1/,PMM/-5.D9/
	SAVE SA, PMM
C      REAL SWRES1,SWRES2,AA1,AA2,VN1,VN2                                 UNSAT.........3600
C                                                                        UNSAT.........3700
C     DATA FOR REGION 1:                                                 UNSAT.........3800
C      DATA   SWRES1/0.1E0/,   AA1/6.12E-4/,   VN1/1.4E0/                 UNSAT.........3900
C      SAVE SWRES1, AA1, VN1                                              UNSAT.........4000
C     DATA FOR REGION 2:                                                 UNSAT.........4100
C      DATA   SWRES2/0.30E0/,   AA2/5.0E-5/,   VN2/2.0E0/                 UNSAT.........4200
C      SAVE SWRES2, AA2, VN2                                              UNSAT.........4300
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- UNSAT.........4400
C                                                                        UNSAT.........4500
C *** BECAUSE THIS ROUTINE IS CALLED OFTEN FOR UNSATURATED FLOW RUNS,    UNSAT.........4600
C *** EXECUTION TIME MAY BE SAVED BY CAREFUL CODING OF DESIRED           UNSAT.........4700
C *** RELATIONSHIPS USING ONLY INTEGER AND SINGLE PRECISION VARIABLES!   UNSAT.........4800
C *** RESULTS OF THE CALCULATIONS MUST THEN BE PLACED INTO DOUBLE        UNSAT.........4900
C *** PRECISION VARIABLES SW, DSWDP AND RELK BEFORE LEAVING              UNSAT.........5000
C *** THIS SUBROUTINE.                                                   UNSAT.........5100
C                                                                        UNSAT.........5200
C                                                                        UNSAT.........5300
C*********************************************************************** UNSAT.........5400
C*********************************************************************** UNSAT.........5500
C                                                                        UNSAT.........5600
C     SET PARAMETERS FOR CURRENT REGION, KREG                            UNSAT.........5700
      IF(KREG.EQ.0)THEN                                                   UNSAT.........5800
      SWRES=SWRES1                                                       UNSAT.........5900
      AA=AA1                                                             UNSAT.........6000
      VN=VN1                                                             UNSAT.........6100
      ELSE                                                           
      SWRES=SWRES2                                                       UNSAT.........6300
      AA=AA2                                                             UNSAT.........6400
      VN=VN2                                                             UNSAT.........6500
	ENDIF                                                          
C                                                                        UNSAT.........6700
C                                                                        UNSAT.........6800
C*********************************************************************** UNSAT.........6900
C*********************************************************************** UNSAT.........7000
C.....SECTION (1):                                                       UNSAT.........7100
C     SW VS. PRES   (VALUE CALCULATED ON EACH CALL TO UNSAT)             UNSAT.........7200
C     CODING MUST GIVE A VALUE TO SATURATION, SW.                        UNSAT.........7300
C                                                                        UNSAT.........7400
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT.........7500
C     THREE PARAMETER MODEL OF VAN GENUCHTEN(1980)                       UNSAT.........7600
C      SWRM1=1.E0-SWRES                                                   UNSAT.........7700
C      AAPVN=1.E0+(AA*(-PRES))**VN                                        UNSAT.........7800
C      VNF=(VN-1.E0)/VN                                                   UNSAT.........7900
C      AAPVNN=AAPVN**VNF                                                  UNSAT.........8000
C      S W   =   DBLE (SWRES+SWRM1/AAPVNN)                                UNSAT.........8100
	SI=SA/LOG(-PMM/9.8D3)*LOG(PMM/PRES)
	SWRMS1=1.D0-SI
      SWRM1=1.D0-SWRES                                                   UNSAT.........7700
      AAPVN=1.D0+(AA*(-PRES))**VN                                        UNSAT.........7800
      VNF=(VN-1.D0)/VN                                                   UNSAT.........7900
      AAPVNN=AAPVN**VNF                                                  UNSAT.........8000
	SW=SI+SWRMS1/AAPVNN
	IF(SW.GT.1.D0) SW=1.D0
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT.........8200
C*********************************************************************** UNSAT.........8300
C*********************************************************************** UNSAT.........8400
C                                                                        UNSAT.........8500
C                                                                        UNSAT.........8600
C                                                                        UNSAT.........8700
C                                                                        UNSAT.........8800
C                                                                        UNSAT.........8900
C                                                                        UNSAT.........9000
      IF(IUNSAT-2) 600,1200,1800                                         UNSAT.........9100
C*********************************************************************** UNSAT.........9200
C*********************************************************************** UNSAT.........9300
C.....SECTION (2):                                                       UNSAT.........9400
C     DSWDP VS. PRES, OR DSWDP VS. SW   (CALCULATED ONLY WHEN IUNSAT=1)  UNSAT.........9500
C     CODING MUST GIVE A VALUE TO DERIVATIVE OF SATURATION WITH          UNSAT.........9600
C     RESPECT TO PRESSURE, DSWDP.                                        UNSAT.........9700
C                                                                        UNSAT.........9800
  600 CONTINUE                                                           UNSAT.........9900
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........10000
C      DNUM=AA*(VN-1.E0)*SWRM1*(AA*(-PRES))**(VN-1.E0)                    UNSAT........10100
	DNUM=AA*(VN-1.D0)*SWRMS1*(AA*(-PRES))**(VN-1.D0)
	DSIDP=-SA/LOG(-PMM/9.8D3)/PRES
      DNOM=AAPVN*AAPVNN                                                  UNSAT........10200
C      D S W D P   =   DBLE (DNUM/DNOM)                                   UNSAT........10300
	D S W D P   =   DBLE (DSIDP-DSIDP/AAPVNN+DNUM/DNOM)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........10400
      GOTO 1800                                                          UNSAT........10500
C*********************************************************************** UNSAT........10600
C*********************************************************************** UNSAT........10700
C                                                                        UNSAT........10800
C                                                                        UNSAT........10900
C                                                                        UNSAT........11000
C                                                                        UNSAT........11100
C                                                                        UNSAT........11200
C                                                                        UNSAT........11300
C*********************************************************************** UNSAT........11400
C*********************************************************************** UNSAT........11500
C.....SECTION (3):                                                       UNSAT........11600
C     RELK VS. P, OR RELK VS. SW   (CALCULATED ONLY WHEN IUNSAT=2)       UNSAT........11700
C     CODING MUST GIVE A VALUE TO RELATIVE PERMEABILITY, RELK.           UNSAT........11800
C                                                                        UNSAT........11900
 1200 CONTINUE                                                           UNSAT........12000
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........12100
C     GENERAL RELATIVE PERMEABILITY MODEL FROM VAN GENUCHTEN(1980)       UNSAT........12200
c      SWSTAR=(SW-SWRES)/SWRM1                                            UNSAT........12300
	SWSTAR=(SW-SI)/SWRMS1
      R E L K   =   DBLE (SQRT(SWSTAR)*                                  UNSAT........12400
     1                   (1.D0-(1.D0-SWSTAR**(1.D0/VNF))**(VNF))**2.D0)  UNSAT........12500

	IF (RELK.LT.1D-20) RELK=0.D0
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  UNSAT........12600
C                                                                        UNSAT........12700
C*********************************************************************** UNSAT........12800
C*********************************************************************** UNSAT........12900
C                                                                        UNSAT........13000
C                                                                        UNSAT........13100
C                                                                        UNSAT........13200
C                                                                        UNSAT........13300
C                                                                        UNSAT........13400
C                                                                        UNSAT........13500
 1800 RETURN                                                             UNSAT........13600
C                                                                        UNSAT........13700
      END                                                                UNSAT........13800
