C     SUBROUTINE        S  U  T  E  R  R           SUTRA VERSION 2.2     SUTERR.........100
C                                                                        SUTERR.........200
C *** PURPOSE :                                                          SUTERR.........300
C ***  TO HANDLE SUTRA AND FORTRAN ERRORS.                               SUTERR.........400
C                                                                        SUTERR.........500
      SUBROUTINE SUTERR(ERRCOD, CHERR, INERR, RLERR)                     SUTERR.........600
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)                                SUTERR.........700
      CHARACTER*80 ERRCOD,CHERR(10),CODE(3),CODUM(3),UNAME,FNAME(0:13)   SUTERR.........800
      CHARACTER*70 DS(50),EX(50)                                         SUTERR.........900
      CHARACTER CDUM80*80                                                SUTERR........1000
      CHARACTER CINERR(10)*9,CRLERR(10)*15                               SUTERR........1100
      CHARACTER SOLNAM(0:10)*40,SOLWRD(0:10)*10                          SUTERR........1200
      CHARACTER*8 VERNUM, VERNIN                                         SUTERR........1300
      DIMENSION INERR(10), RLERR(10)                                     SUTERR........1400
      COMMON /DIMS/ NN,NE,NIN,NBI,NCBI,NB,NBHALF,NPBC,NUBC,              SUTERR........1500
     1   NSOP,NSOU,NBCN,NCIDB                                            SUTERR........1600
      COMMON /FNAMES/ UNAME,FNAME                                        SUTERR........1700
      COMMON /FUNITS/ K00,K0,K1,K2,K3,K4,K5,K6,K7,K8,K9,                 SUTERR........1800
     1   K10,K11,K12,K13                                                 SUTERR........1900
      COMMON /KPRINT/ KNODAL,KELMNT,KINCID,KPLOTP,KPLOTU,                SUTERR........2000
     1   KPANDS,KVEL,KCORT,KBUDG,KSCRN,KPAUSE                            SUTERR........2100
      COMMON /SOLVC/ SOLWRD,SOLNAM                                       SUTERR........2200
      COMMON /SOLVN/ NSLVRS                                              SUTERR........2300
      COMMON /VER/ VERNUM, VERNIN                                        SUTERR........2400
C                                                                        SUTERR........2500
C.....PARSE THE ERROR CODE                                               SUTERR........2600
      CALL PRSWDS(ERRCOD, '-', 3, CODE, NWORDS)                          SUTERR........2700
C                                                                        SUTERR........2800
C.....IF AN ERROR OTHER THAN A MATRIX SOLVER OR NONLINEAR CONVERGENCE    SUTERR........2900
C        ERROR HAS OCCURRED, OVERRIDE THE SCREEN OUTPUT CONTROLS SO      SUTERR........3000
C        THAT THE ERROR IS PRINTED TO THE SCREEN AND SUTRA PAUSES FOR    SUTERR........3100
C        A USER RESPONSE.                                                SUTERR........3200
      IF ((CODE(1).NE.'SOL').AND.(CODE(1).NE.'CON')) THEN                SUTERR........3300
         KSCRN = +1                                                      SUTERR........3400
         KPAUSE = +1                                                     SUTERR........3500
      END IF                                                             SUTERR........3600
C                                                                        SUTERR........3700
C.....COPY INTEGER AND REAL ERROR PARAMETERS INTO CHARACTER STRINGS      SUTERR........3800
      DO 150 I=1,10                                                      SUTERR........3900
         WRITE(UNIT=CINERR(I), FMT='(I9)') INERR(I)                      SUTERR........4000
         WRITE(UNIT=CRLERR(I), FMT='(1PE15.7)') RLERR(I)                 SUTERR........4100
  150 CONTINUE                                                           SUTERR........4200
C                                                                        SUTERR........4300
C.....INITIALIZE THE ERROR OUTPUT STRINGS                                SUTERR........4400
      DO 200 I=1,50                                                      SUTERR........4500
         DS(I) = "null_line"                                             SUTERR........4600
         EX(I) = "null_line"                                             SUTERR........4700
  200 CONTINUE                                                           SUTERR........4800
C                                                                        SUTERR........4900
C.....SET THE ERROR OUTPUT STRINGS ACCORDING TO THE TYPE OF ERROR        SUTERR........5000
      IF (ERRCOD.EQ.'INP-2A-1') THEN                                     SUTERR........5100
        DS(1)="The first word of SIMULA is not 'SUTRA'."                 SUTERR........5200
        EX(1)="In dataset 2A of the main input file, the first word"     SUTERR........5300
        EX(2)="of the variable SIMULA must be 'SUTRA'."                  SUTERR........5400
        EX(3)=" "                                                        SUTERR........5500
        EX(4)="Example of a valid dataset 2A:"                           SUTERR........5600
        EX(5)="'SUTRA SOLUTE TRANSPORT'"                                 SUTERR........5700
      ELSE IF (ERRCOD.EQ.'INP-2A-2') THEN                                SUTERR........5800
        DS(1)="The second word of SIMULA is not 'SOLUTE' or 'ENERGY'."   SUTERR........5900
        EX(1)="In dataset 2A of the main input file, when the second"    SUTERR........6000
        EX(2)="word is not 'VERSION', the version 2.0 input format is"   SUTERR........6100
        EX(3)="assumed, and the second word must be 'SOLUTE' or"         SUTERR........6200
        EX(4)="'ENERGY'."                                                SUTERR........6300
        EX(5)=" "                                                        SUTERR........6400
        EX(6)="Example of a valid (version 2.0) dataset 2A:"             SUTERR........6500
        EX(7)="'SUTRA SOLUTE TRANSPORT'"                                 SUTERR........6600
      ELSE IF (ERRCOD.EQ.'INP-2A-3') THEN                                SUTERR........6700
        DS(1)="The fourth word of SIMULA is not 'SOLUTE' or 'ENERGY'."   SUTERR........6800
        EX(1)="In dataset 2A of the main input file, the fourth word"    SUTERR........6900
        EX(2)="must be 'SOLUTE' or 'ENERGY' (unless the version 2.0"     SUTERR........7000
        EX(3)="input format is being used)."                             SUTERR........7100
        EX(4)=" "                                                        SUTERR........7200
        EX(5)="Example of a valid (version 2.0) dataset 2A:"             SUTERR........7300
        EX(6)="'SUTRA VERSION " // TRIM(VERNUM) // " SOLUTE TRANSPORT'"  SUTERR........7400
      ELSE IF (ERRCOD.EQ.'INP-2A-4') THEN                                SUTERR........7500
        DS(1)="Unsupported SUTRA version: " // CHERR(1)                  SUTERR........7600
        EX(1)="Input files from SUTRA version " // TRIM(CHERR(1))        SUTERR........7700
        EX(2)="are not supported by version " // TRIM(VERNUM) // "."     SUTERR........7800
      ELSE IF (ERRCOD.EQ.'INP-2B-1') THEN                                SUTERR........7900
        DS(1)="The first word of MSHSTR is not '2D' or '3D'."            SUTERR........8000
        EX(1)="In dataset 2B of the main input file, the first word"     SUTERR........8100
        EX(2)="of the variable MSHSTR must be '2D' or '3D'."             SUTERR........8200
        EX(3)=" "                                                        SUTERR........8300
        EX(4)="Example of a valid dataset 2B:"                           SUTERR........8400
        EX(5)="'3D REGULAR MESH'  10  20  30"                            SUTERR........8500
C.....ERROR CODE 'INP-2B-2' IS NO LONGER USED.                           SUTERR........8600
      ELSE IF (ERRCOD.EQ.'INP-2B-3') THEN                                SUTERR........8700
        DS(1)="At least one of the rectangular dimensions NN1, NN2,"     SUTERR........8800
        DS(2)="and NN3 is set improperly."                               SUTERR........8900
        EX(1)="In dataset 2B of the main input file, the rectangular"    SUTERR........9000
        EX(2)="dimensions NN1, NN2, and (for 3D problems) NN3 must"      SUTERR........9100
        EX(3)="each be greater than 1."                                  SUTERR........9200
        EX(4)=" "                                                        SUTERR........9300
        EX(5)="Example of a valid dataset 2B:"                           SUTERR........9400
        EX(6)="'3D BLOCKWISE MESH'  10  20  30"                          SUTERR........9500
      ELSE IF (ERRCOD.EQ.'INP-2B-4') THEN                                SUTERR........9600
        DS(1)="The second word of MSHSTR is not 'IRREGULAR', 'REGULAR'," SUTERR........9700
        DS(2)="'BLOCKWISE', or 'LAYERED'."                               SUTERR........9800
        EX(1)="In dataset 2B of the main input file, the second word"    SUTERR........9900
        EX(2)="of the variable MSHSTR must be 'IRREGULAR', 'REGULAR',"   SUTERR.......10000
        EX(3)="'BLOCKWISE' or 'LAYERED'.  By definition, only 3D meshes" SUTERR.......10100
        EX(4)="can be LAYERED."                                          SUTERR.......10200
        EX(5)=" "                                                        SUTERR.......10300
        EX(6)="Example of a valid dataset 2B:"                           SUTERR.......10400
        EX(7)="'3D REGULAR MESH'  10  20  30"                            SUTERR.......10500
      ELSE IF (ERRCOD.EQ.'INP-2B-5') THEN                                SUTERR.......10600
        DS(1)="A 2D LAYERED mesh has been specified."                    SUTERR.......10700
        EX(1)="By definition, only 3D meshes can be LAYERED."            SUTERR.......10800
        EX(2)=" "                                                        SUTERR.......10900
        EX(3)="Example of a valid dataset 2B:"                           SUTERR.......11000
        EX(4)="'3D LAYERED MESH'  10  2560  2210  'ACROSS'"              SUTERR.......11100
      ELSE IF (ERRCOD.EQ.'INP-2B-6') THEN                                SUTERR.......11200
        DS(1)="The first word of LAYSTR is not 'ACROSS' or 'WITHIN'."    SUTERR.......11300
        EX(1)="In dataset 2B of the main input file, the first word"     SUTERR.......11400
        EX(2)="of the variable LAYSTR must be 'ACROSS' or 'WITHIN'."     SUTERR.......11500
        EX(3)=" "                                                        SUTERR.......11600
        EX(4)="Example of a valid dataset 2B:"                           SUTERR.......11700
        EX(5)="'3D LAYERED MESH'  10  2560  2210  'ACROSS'"              SUTERR.......11800
      ELSE IF (ERRCOD.EQ.'INP-2B-7') THEN                                SUTERR.......11900
        DS(1)="At least one of the layer dimensions NLAYS, NNLAY,"       SUTERR.......12000
        DS(2)="and NELAY is set improperly."                             SUTERR.......12100
        EX(1)="In dataset 2B of the main input file, the layer"          SUTERR.......12200
        EX(2)="dimensions are subject to the following constraints:"     SUTERR.......12300
        EX(3)="NLAYS>1, NNLAY>3, and NELAY>0."                           SUTERR.......12400
        EX(4)=" "                                                        SUTERR.......12500
        EX(5)="Example of a valid dataset 2B:"                           SUTERR.......12600
        EX(6)="'3D LAYERED MESH'  10  2560  2210  'ACROSS'"              SUTERR.......12700
      ELSE IF (ERRCOD.EQ.'INP-2B,3-1') THEN                              SUTERR.......12800
        DS(1)="The number of nodes, NN, does not match the rectangular"  SUTERR.......12900
        DS(2)="dimensions, NN1*NN2(*NN3)."                               SUTERR.......13000
        EX(1)="In datasets 2B and 3 of the main input file, the total"   SUTERR.......13100
        EX(2)="number of nodes, NN, must equal the product of the"       SUTERR.......13200
        EX(3)="rectangular dimensions, NN1*NN2 in 2D, or NN1*NN2*NN3"    SUTERR.......13300
        EX(4)="in 3D."                                                   SUTERR.......13400
        EX(5)=" "                                                        SUTERR.......13500
        EX(6)="Example:"                                                 SUTERR.......13600
        EX(7)="If NN1=10, NN2=20, and NN3=30 (dataset 2B), then"         SUTERR.......13700
        EX(8)="NN=10*20*30=6000 (dataset 3)."                            SUTERR.......13800
      ELSE IF (ERRCOD.EQ.'INP-2B,3-2') THEN                              SUTERR.......13900
        DS(1)="The number of elements, NE, does not match the"           SUTERR.......14000
        DS(2)="rectangular dimensions, (NN1-1)*(NN2-1)[*(NN3-1)]."       SUTERR.......14100
        EX(1)="In datasets 2B and 3 of the main input file, the total"   SUTERR.......14200
        EX(2)="number of elements, NE, must equal the product of the"    SUTERR.......14300
        EX(3)="rectangular dimensions, (NN1-1)*(NN2-1) in 2D, or"        SUTERR.......14400
        EX(4)="(NN1-1)*(NN2-1)*(NN3-1) in 3D."                           SUTERR.......14500
        EX(5)=" "                                                        SUTERR.......14600
        EX(6)="Example:"                                                 SUTERR.......14700
        EX(7)="If NN1=10, NN2=20, and NN3=30 (dataset 2B), then"         SUTERR.......14800
        EX(8)="NE=9*19*29=4959 (dataset 3)."                             SUTERR.......14900
      ELSE IF (ERRCOD.EQ.'INP-2B,3-3') THEN                              SUTERR.......15000
        DS(1)="The number of nodes, NN, does not match the layered"      SUTERR.......15100
        DS(2)="dimensions, NLAYS*NNLAY."                                 SUTERR.......15200
        EX(1)="In datasets 2B and 3 of the main input file, the total"   SUTERR.......15300
        EX(2)="number of nodes, NN, must equal the product of the"       SUTERR.......15400
        EX(3)="layered dimensions, NLAYS*NNLAY."                         SUTERR.......15500
        EX(4)=" "                                                        SUTERR.......15600
        EX(5)="Example:"                                                 SUTERR.......15700
        EX(6)="If NLAYS=10 and NNLAY=2560 (dataset 2B), then"            SUTERR.......15800
        EX(7)="NN=10*2560=25600 (dataset 3)."                            SUTERR.......15900
      ELSE IF (ERRCOD.EQ.'INP-2B,3-4') THEN                              SUTERR.......16000
        DS(1)="The number of nodes, NE, does not match the layered"      SUTERR.......16100
        DS(2)="dimensions, (NLAYS-1)*NELAY."                             SUTERR.......16200
        EX(1)="In datasets 2B and 3 of the main input file, the total"   SUTERR.......16300
        EX(2)="number of nodes, NE, must equal the product of the"       SUTERR.......16400
        EX(3)="layered dimensions, (NLAYS-1)*NELAY."                     SUTERR.......16500
        EX(4)=" "                                                        SUTERR.......16600
        EX(5)="Example:"                                                 SUTERR.......16700
        EX(6)="If NLAYS=10 and NELAY=2210 (dataset 2B), then"            SUTERR.......16800
        EX(7)="NN=9*2210=19890 (dataset 3)."                             SUTERR.......16900
      ELSE IF (ERRCOD.EQ.'INP-4-1') THEN                                 SUTERR.......17000
        DS(1)="The first word of CUNSAT is not 'SATURATED' or"           SUTERR.......17100
        DS(2)="'UNSATURATED'."                                           SUTERR.......17200
        EX(1)="In dataset 4 of the main input file, the first word"      SUTERR.......17300
        EX(2)="of the variable CUNSAT must be 'SATURATED' or"            SUTERR.......17400
        EX(3)="'UNSATURATED'."                                           SUTERR.......17500
        EX(4)=" "                                                        SUTERR.......17600
        EX(5)="Example of a valid dataset 4:"                            SUTERR.......17700
        EX(6)="'SATURATED FLOW' 'STEADY FLOW' 'TRANSIENT TRANSPORT'" //  SUTERR.......17800
     1        " 'COLD' 10"                                               SUTERR.......17900
      ELSE IF (ERRCOD.EQ.'INP-4-2') THEN                                 SUTERR.......18000
        DS(1)="The first word of CSSFLO is not 'STEADY' or 'TRANSIENT'." SUTERR.......18100
        EX(1)="In dataset 4 of the main input file, the first word"      SUTERR.......18200
        EX(2)="of the variable CSSFLO must be 'STEADY' or 'TRANSIENT'."  SUTERR.......18300
        EX(3)=" "                                                        SUTERR.......18400
        EX(4)="Example of a valid dataset 4:"                            SUTERR.......18500
        EX(5)="'SATURATED FLOW' 'STEADY FLOW' 'TRANSIENT TRANSPORT'" //  SUTERR.......18600
     1        " 'COLD' 10"                                               SUTERR.......18700
      ELSE IF (ERRCOD.EQ.'INP-4-3') THEN                                 SUTERR.......18800
        DS(1)="The first word of CSSTRA is not 'STEADY' or 'TRANSIENT'." SUTERR.......18900
        EX(1)="In dataset 4 of the main input file, the first word"      SUTERR.......19000
        EX(2)="of the variable CSSTRA must be 'STEADY' or 'TRANSIENT'."  SUTERR.......19100
        EX(3)=" "                                                        SUTERR.......19200
        EX(4)="Example of a valid dataset 4:"                            SUTERR.......19300
        EX(5)="'SATURATED FLOW' 'STEADY FLOW' 'TRANSIENT TRANSPORT'" //  SUTERR.......19400
     1        " 'COLD' 10"                                               SUTERR.......19500
      ELSE IF (ERRCOD.EQ.'INP-4-4') THEN                                 SUTERR.......19600
        DS(1)="The first word of CREAD is not 'COLD' or 'WARM'."         SUTERR.......19700
        EX(1)="In dataset 4 of the main input file, the first word"      SUTERR.......19800
        EX(2)="of the variable CREAD must be 'COLD' or 'WARM'."          SUTERR.......19900
        EX(3)=" "                                                        SUTERR.......20000
        EX(4)="Example of a valid dataset 4:"                            SUTERR.......20100
        EX(5)="'SATURATED FLOW' 'STEADY FLOW' 'TRANSIENT TRANSPORT'" //  SUTERR.......20200
     1        " 'COLD' 10"                                               SUTERR.......20300
      ELSE IF (ERRCOD.EQ.'INP-4-5') THEN                                 SUTERR.......20400
        DS(1)="Specified TRANSIENT flow with STEADY transport."          SUTERR.......20500
        EX(1)="In dataset 4 of the main input file, TRANSIENT flow"      SUTERR.......20600
        EX(2)="requires TRANSIENT transport.  Likewise, STEADY"          SUTERR.......20700
        EX(3)="transport requires STEADY flow.  The following are"       SUTERR.......20800
        EX(4)="valid combinations:"                                      SUTERR.......20900
        EX(5)=" "                                                        SUTERR.......21000
        EX(6)="     CSSFLO      CSSTRA"                                  SUTERR.......21100
        EX(7)="   ----------- -----------"                               SUTERR.......21200
        EX(8)="    'STEADY'    'STEADY'"                                 SUTERR.......21300
        EX(9)="    'STEADY'   'TRANSIENT'"                               SUTERR.......21400
        EX(10)="   'TRANSIENT' 'TRANSIENT'"                              SUTERR.......21500
        EX(11)=" "                                                       SUTERR.......21600
        EX(12)="Example of a valid dataset 4:"                           SUTERR.......21700
        EX(13)="'SATURATED FLOW' 'STEADY FLOW' 'STEADY TRANSPORT'" //    SUTERR.......21800
     1        " 'COLD' 10"                                               SUTERR.......21900
      ELSE IF (ERRCOD.EQ.'INP-7B&C-1') THEN                              SUTERR.......22000
        DS(1)="Unrecognized solver name."                                SUTERR.......22100
        EX(1)="In datasets 7B&C, valid solver selections are:"           SUTERR.......22200
        EX(2)=" "                                                        SUTERR.......22300
        DO 400 M=0,NSLVRS-1                                              SUTERR.......22400
           EX(M+3)=SOLWRD(M) // " --> " // SOLNAM(M)                     SUTERR.......22500
  400   CONTINUE                                                         SUTERR.......22600
        EX(NSLVRS+3)=" "                                                 SUTERR.......22700
        EX(NSLVRS+4)="Note that solver selections for P and U must be"   SUTERR.......22800
        EX(NSLVRS+5)="both DIRECT or both iterative."                    SUTERR.......22900
      ELSE IF (ERRCOD.EQ.'INP-7B&C-2') THEN                              SUTERR.......23000
        DS(1)="Solver selections for P and U are not both DIRECT or"     SUTERR.......23100
        DS(2)="both iterative."                                          SUTERR.......23200
        EX(1)="The solver selections for P and U must be both"           SUTERR.......23300
        EX(2)="DIRECT or both iterative."                                SUTERR.......23400
      ELSE IF (ERRCOD.EQ.'INP-7B&C-3') THEN                              SUTERR.......23500
        DS(1)="Invalid selection of the CG solver."                      SUTERR.......23600
        EX(1)="The CG solver may be used only for the flow (P) equation" SUTERR.......23700
        EX(2)="with no upstream weighting (UP=0.0).  It may not be used" SUTERR.......23800
        EX(3)="for the transport (U) equation."                          SUTERR.......23900
C.....ERROR CODE 'INP-7B&C-4' IS NO LONGER USED.                         SUTERR.......24000
      ELSE IF (ERRCOD.EQ.'INP-3,19-1') THEN                              SUTERR.......24100
        DS(1)="The actual number of specified pressure nodes, "          SUTERR.......24200
     1        // CINERR(1) // ","                                        SUTERR.......24300
        DS(2)="does not equal the input value,                "          SUTERR.......24400
     1        // CINERR(2) // "."                                        SUTERR.......24500
        EX(1)="In dataset 3 of the main input file, the variable NPBC"   SUTERR.......24600
        EX(2)="must specify the exact number of specified pressure"      SUTERR.......24700
        EX(3)="nodes listed in dataset 19."                              SUTERR.......24800
      ELSE IF (ERRCOD.EQ.'INP-3,20-1') THEN                              SUTERR.......24900
        DS(1)="The actual number of specified conc. nodes, "             SUTERR.......25000
     1        // CINERR(1) // ","                                        SUTERR.......25100
        DS(2)="does not equal the input value,             "             SUTERR.......25200
     1        // CINERR(2) // "."                                        SUTERR.......25300
        EX(1)="In dataset 3 of the main input file, the variable NUBC"   SUTERR.......25400
        EX(2)="must specify the exact number of specified concentration" SUTERR.......25500
        EX(3)="nodes listed in dataset 20."                              SUTERR.......25600
      ELSE IF (ERRCOD.EQ.'INP-3,20-2') THEN                              SUTERR.......25700
        DS(1)="The actual number of specified temp. nodes, "             SUTERR.......25800
     1        // CINERR(1) // ","                                        SUTERR.......25900
        DS(2)="does not equal the input value,             "             SUTERR.......26000
     1        // CINERR(2) // "."                                        SUTERR.......26100
        EX(1)="In dataset 3 of the main input file, the variable NUBC"   SUTERR.......26200
        EX(2)="must specify the exact number of specified temperature"   SUTERR.......26300
        EX(3)="nodes listed in dataset 20."                              SUTERR.......26400
      ELSE IF (ERRCOD.EQ.'INP-22-1') THEN                                SUTERR.......26500
        DS(1)="Line 1 of the element incidence data does not begin with" SUTERR.......26600
        DS(2)="the word 'INCIDENCE'."                                    SUTERR.......26700
        EX(1)="In dataset 22 of the main input file, the first line"     SUTERR.......26800
        EX(2)="must begin with the word 'INCIDENCE'."                    SUTERR.......26900
      ELSE IF (ERRCOD.EQ.'INP-22-2') THEN                                SUTERR.......27000
        DS(1)="The incidence data for element " // CINERR(1)             SUTERR.......27100
        DS(2)="are not in numerical order in the dataset."               SUTERR.......27200
        EX(1)="In dataset 22 of the main input file, incidence data"     SUTERR.......27300
        EX(2)="must be listed in order of increasing element number."    SUTERR.......27400
        EX(3)="Note that the numbering of elements must begin at 1"      SUTERR.......27500
        EX(4)="and be continuous; element numbers may not be skipped."   SUTERR.......27600
      ELSE IF (ERRCOD.EQ.'INP-14B,22-1') THEN                            SUTERR.......27700
        DS(1)="At least one element has incorrect geometry."             SUTERR.......27800
        EX(1)="Incorrect element geometry can result from improper"      SUTERR.......27900
        EX(2)="specification of node coordinates in dataset 14B of the"  SUTERR.......28000
        EX(3)="main input file, or from improper ordering of nodes in"   SUTERR.......28100
        EX(4)="a node incidence list in dataset 22 of the same file."    SUTERR.......28200
      ELSE IF (ERRCOD.EQ.'FIL-1') THEN                                   SUTERR.......28300
        DS(1)="The file " // CHERR(2)                                    SUTERR.......28400
        DS(2)="does not exist."                                          SUTERR.......28500
        EX(1)="One of the files required by SUTRA does not exist."       SUTERR.......28600
        EX(2)="Check the filename and the directory path."               SUTERR.......28700
      ELSE IF (ERRCOD.EQ.'FIL-2') THEN                                   SUTERR.......28800
        DS(1)="The file " // CHERR(2)                                    SUTERR.......28900
        DS(2)="could not be opened on FORTRAN unit " // CINERR(1) // "." SUTERR.......29000
        EX(1)="One of the files required by SUTRA could not be opened."  SUTERR.......29100
        EX(2)="Check to make sure the file is not protected or in use"   SUTERR.......29200
        EX(3)="by another application, and that the FORTRAN unit number" SUTERR.......29300
        EX(4)="is valid."                                                SUTERR.......29400
C.....ERROR CODE 'FIL-3' IS NO LONGER USED.                              SUTERR.......29500
      ELSE IF (ERRCOD.EQ.'FIL-4') THEN                                   SUTERR.......29600
        DS(1)="An attempt was made to use the file"                      SUTERR.......29700
        DS(2)=CHERR(2)                                                   SUTERR.......29800
        DS(3)="for more than one purpose simultaneously."                SUTERR.......29900
        EX(1)='Each filename listed in "SUTRA.FIL" must be unique'       SUTERR.......30000
        EX(2)='and may not be reused in an "@INSERT" statement.'         SUTERR.......30100
        EX(3)='Also, if you have nested "@INSERT" statements'            SUTERR.......30200
        EX(4)='(i.e., a file inserted into a file, which is itself'      SUTERR.......30300
        EX(5)='inserted into a file, etc.), a given file may be'         SUTERR.......30400
        EX(6)='used only once in the nested sequence.'                   SUTERR.......30500
      ELSE IF (ERRCOD.EQ.'FIL-5') THEN                                   SUTERR.......30600
        DS(1)="Invalid file type: " // CHERR(2)                          SUTERR.......30700
        EX(1)="Valid file types are:"                                    SUTERR.......30800
        EX(2)='   INP (".inp" input file)'                               SUTERR.......30900
        EX(3)='   ICS (".ics" input file)'                               SUTERR.......31000
        EX(4)='   BCS (".bcs" input file)'                               SUTERR.......31100
        EX(5)='   SMY (".smy" output file)'                              SUTERR.......31200
        EX(6)='   LST (".lst" output file)'                              SUTERR.......31300
        EX(7)='   RST (".rst" output file)'                              SUTERR.......31400
        EX(8)='   NOD (".nod" output file)'                              SUTERR.......31500
        EX(9)='   ELE (".ele" output file)'                              SUTERR.......31600
        EX(10)='   OBS (".obs" output file)'                             SUTERR.......31700
        EX(11)='   OBC (".obc" output file)'                             SUTERR.......31800
        EX(12)='   BCOF (".bcof" output file)'                           SUTERR.......31900
        EX(13)='   BCOP (".bcop" output file)'                           SUTERR.......32000
        EX(14)='   BCOS (".bcos" output file)'                           SUTERR.......32100
        EX(15)='   BCOU (".bcou" output file)'                           SUTERR.......32200
      ELSE IF (ERRCOD.EQ.'FIL-6') THEN                                   SUTERR.......32300
        DS(1)="File type " // CHERR(2)                                   SUTERR.......32400
        DS(2)="has been assigned more than once."                        SUTERR.......32500
        EX(1)="The following file types must be assigned:"               SUTERR.......32600
        EX(2)='   INP (".inp" input file)'                               SUTERR.......32700
        EX(3)='   ICS (".ics" input file)'                               SUTERR.......32800
        EX(4)='   LST (".lst" output file)'                              SUTERR.......32900
        EX(5)="The following file types are optional:"                   SUTERR.......33000
        EX(6)='   BCS (".bcs" input file)'                               SUTERR.......33100
        EX(7)='   SMY (".smy" output file; defaults to "SUTRA.SMY")'     SUTERR.......33200
        EX(8)='   RST (".rst" output file)'                              SUTERR.......33300
        EX(9)='   NOD (".nod" output file)'                              SUTERR.......33400
        EX(10)='   ELE (".ele" output file)'                             SUTERR.......33500
        EX(11)='   OBS (".obs" output file)'                             SUTERR.......33600
        EX(12)='   OBC (".obc" output file)'                             SUTERR.......33700
        EX(13)='   BCOF (".bcof" output file)'                           SUTERR.......33800
        EX(14)='   BCOP (".bcop" output file)'                           SUTERR.......33900
        EX(15)='   BCOS (".bcos" output file)'                           SUTERR.......34000
        EX(16)='   BCOU (".bcou" output file)'                           SUTERR.......34100
        EX(17)="No file type except BCS may be assigned more than once." SUTERR.......34200
      ELSE IF (ERRCOD.EQ.'FIL-7') THEN                                   SUTERR.......34300
        DS(1)="Required file type " // CHERR(2)                          SUTERR.......34400
        DS(2)="has not been assigned."                                   SUTERR.......34500
        EX(1)="The following file types must be assigned:"               SUTERR.......34600
        EX(2)='   INP (".inp" input file)'                               SUTERR.......34700
        EX(3)='   ICS (".ics" input file)'                               SUTERR.......34800
        EX(4)='   LST (".lst" output file)'                              SUTERR.......34900
        EX(5)="The following file types are optional:"                   SUTERR.......35000
        EX(6)='   BCS (".bcs" input file)'                               SUTERR.......35100
        EX(7)='   SMY (".smy" output file; defaults to "SUTRA.SMY")'     SUTERR.......35200
        EX(8)='   RST (".rst" output file)'                              SUTERR.......35300
        EX(9)='   NOD (".nod" output file)'                              SUTERR.......35400
        EX(10)='   ELE (".ele" output file)'                             SUTERR.......35500
        EX(11)='   OBS (".obs" output file)'                             SUTERR.......35600
        EX(12)='   OBC (".obc" output file)'                             SUTERR.......35700
        EX(13)='   BCOF (".bcof" output file)'                           SUTERR.......35800
        EX(14)='   BCOP (".bcop" output file)'                           SUTERR.......35900
        EX(15)='   BCOS (".bcos" output file)'                           SUTERR.......36000
        EX(16)='   BCOU (".bcou" output file)'                           SUTERR.......36100
        EX(17)="No file type except BCS may be assigned more than once." SUTERR.......36200
      ELSE IF (ERRCOD.EQ.'FIL-8') THEN                                   SUTERR.......36300
        DS(1)="The file " // CHERR(2)                                    SUTERR.......36400
        DS(2)="could not be inserted."                                   SUTERR.......36500
        EX(1)="Inserts cannot be nested more than 20 levels deep."       SUTERR.......36600
      ELSE IF (ERRCOD.EQ.'FIL-9') THEN                                   SUTERR.......36700
        DS(1)="A file listed in 'SUTRA.FIL' is named 'SUTRA.FIL'."       SUTERR.......36800
        EX(1)="The filename 'SUTRA.FIL' is reserved by SUTRA."           SUTERR.......36900
        EX(2)="Files listed in 'SUTRA.FIL' may not be named"             SUTERR.......37000
        EX(3)="'SUTRA.FIL'."                                             SUTERR.......37100
      ELSE IF (ERRCOD.EQ.'FIL-10') THEN                                  SUTERR.......37200
        DS(1)="SUTRA was unable to automatically"                        SUTERR.......37300
        DS(2)="assign unit number " // CINERR(1)                         SUTERR.......37400
        DS(3)="to file " // CHERR(2)                                     SUTERR.......37500
        EX(1)="SUTRA attempted to automatically assign to one of the "   SUTERR.......37600
        EX(2)="files listed in 'SUTRA.FIL' a unit number that is not"    SUTERR.......37700
        EX(3)="allowed on this computer.  Please check the unit"         SUTERR.......37800
        EX(4)="number assignments in 'SUTRA.FIL'.  It may be possible"   SUTERR.......37900
        EX(5)="to avoid this problem by explicitly assigning a"          SUTERR.......38000
        EX(6)="different unit number to the file in question or by"      SUTERR.......38100
        EX(7)="reducing the number of optional files listed in"          SUTERR.......38200
        EX(8)="'SUTRA.FIL'."                                             SUTERR.......38300
      ELSE IF (ERRCOD.EQ.'INP-6-1') THEN                                 SUTERR.......38400
        DS(1)="NPCYC<1 and/or NUCYC<1."                                  SUTERR.......38500
        EX(1)="In dataset 6 of the main input file, both NPCYC and"      SUTERR.......38600
        EX(2)="NUCYC must be set greater than or equal to 1."            SUTERR.......38700
      ELSE IF (ERRCOD.EQ.'INP-6-2') THEN                                 SUTERR.......38800
        DS(1)="Neither NPCYC nor NUCYC is set to 1."                     SUTERR.......38900
        EX(1)="In dataset 6 of the main input file, either NPCYC or"     SUTERR.......39000
        EX(2)="NUCYC (or both) must be set to 1."                        SUTERR.......39100
      ELSE IF (ERRCOD.EQ.'INP-6-3') THEN                                 SUTERR.......39200
        DS(1)="DELT is greater than DTMAX."                              SUTERR.......39300
        EX(1)="In dataset 6 of the main input file, DELT must be set"    SUTERR.......39400
        EX(2)="less than or equal to DTMAX."                             SUTERR.......39500
      ELSE IF (ERRCOD.EQ.'INP-6-4') THEN                                 SUTERR.......39600
        DS(1)="The actual number of schedules listed does not equal"     SUTERR.......39700
        DS(2)="the input value, or the schedule list does not end"       SUTERR.......39800
        DS(3)="with '-'."                                                SUTERR.......39900
        EX(1)="In dataset 6 of the main input file, the number of"       SUTERR.......40000
        EX(2)="schedules listed must equal the number, NSCH, specified"  SUTERR.......40100
        EX(3)="in dataset 6 of the same file, and the final entry in"    SUTERR.......40200
        EX(4)="the list must be '-'."                                    SUTERR.......40300
        EX(5)=" "                                                        SUTERR.......40400
        EX(6)="Example of a valid dataset 6 with two schedules:"         SUTERR.......40500
        EX(7)="2   1   1"                                                SUTERR.......40600
        EX(8)="'TIME_STEPS' 'TIME CYCLE' 'ELAPSED'  1. 100   0. " //     SUTERR.......40700
     1     "3.e+9 3.e+7 999 1. 0. 1.e+99"                                SUTERR.......40800
        EX(9)="'SCHED_A'    'STEP LIST'        4   20  40  60  80"       SUTERR.......40900
        EX(10)="'-'"                                                     SUTERR.......41000
      ELSE IF (ERRCOD.EQ.'INP-6-5') THEN                                 SUTERR.......41100
        DS(1)="Multiple definitions of schedule " // CHERR(1)            SUTERR.......41200
        EX(1)="A given schedule name may not be defined more than once"  SUTERR.......41300
        EX(2)="in dataset 6 of the main input file."                     SUTERR.......41400
      ELSE IF (ERRCOD.EQ.'INP-6-6') THEN                                 SUTERR.......41500
        DS(1)="Invalid time descriptor " // CHERR(1)                     SUTERR.......41600
        EX(1)="Time-based schedules must be defined in terms of either"  SUTERR.......41700
        EX(2)="ABSOLUTE or ELAPSED times."                               SUTERR.......41800
      ELSE IF (ERRCOD.EQ.'INP-6-7') THEN                                 SUTERR.......41900
        DS(1)="ELAPSED times in TIME_STEPS schedule,"                    SUTERR.......42000
        DS(2)="but initial elapsed time is not zero."                    SUTERR.......42100
        EX(1)="When the TIME_STEPS schedule is defined in terms of"      SUTERR.......42200
        EX(2)="ELAPSED times, the first (initial) elapsed time in the"   SUTERR.......42300
        EX(3)="schedule must be set to zero."                            SUTERR.......42400
      ELSE IF (ERRCOD.EQ.'INP-6-8') THEN                                 SUTERR.......42500
        DS(1)="Invalid number of schedules (NSCH<0)."                    SUTERR.......42600
        EX(1)="The number of schedules, NSCH, must be non-negative."     SUTERR.......42700
        EX(2)="NSCH=0 is allowed only if flow and transport are both"    SUTERR.......42800
        EX(3)="steady-state."                                            SUTERR.......42900
      ELSE IF (ERRCOD.EQ.'INP-6-9') THEN                                 SUTERR.......43000
        DS(1)="Invalid schedule type " // CHERR(1)                       SUTERR.......43100
        EX(1)="An invalid schedule type has been specified."             SUTERR.......43200
        EX(2)="Valid schedule types are:"                                SUTERR.......43300
        EX(3)="   'TIME CYCLE'"                                          SUTERR.......43400
        EX(4)="   'TIME LIST'"                                           SUTERR.......43500
        EX(5)="   'STEP CYCLE'"                                          SUTERR.......43600
        EX(6)="   'STEP LIST'"                                           SUTERR.......43700
      ELSE IF (ERRCOD.EQ.'INP-6-10') THEN                                SUTERR.......43800
        DS(1)="Incomplete TIME_STEPS schedule."                          SUTERR.......43900
        EX(1)="The TIME_STEPS schedule must contain at least two"        SUTERR.......44000
        EX(2)="distinct times, including the starting time."             SUTERR.......44100
      ELSE IF (ERRCOD.EQ.'INP-6-11') THEN                                SUTERR.......44200
        DS(1)="Invalid user-defined schedule name, " // TRIM(CHERR(1))   SUTERR.......44300
        EX(1)="Schedule names 'STEP_0', 'STEP_1', and 'STEPS_1&UP'"      SUTERR.......44400
        EX(2)="are reserved by SUTRA and may not be used to name a"      SUTERR.......44500
        EX(3)="user-defined schedule."                                   SUTERR.......44600
      ELSE IF (ERRCOD.EQ.'INP-6-12') THEN                                SUTERR.......44700
        DS(1)="Repeated " // TRIM(CHERR(1)) // " " // CRLERR(1)          SUTERR.......44800
        DS(2)="in schedule " // CHERR(2)                                 SUTERR.......44900
        EX(1)="A time or time step value may not appear more than once"  SUTERR.......45000
        EX(2)="in a given schedule."                                     SUTERR.......45100
      ELSE IF (ERRCOD.EQ.'INP-6-13') THEN                                SUTERR.......45200
        DS(1)="Invalid number of schedules (NSCH=0)."                    SUTERR.......45300
        EX(1)="NSCH=0 is allowed only if flow and transport are both"    SUTERR.......45400
        EX(2)="steady-state."                                            SUTERR.......45500
      ELSE IF (ERRCOD.EQ.'INP-6-14') THEN                                SUTERR.......45600
        DS(1)="Missing TIME_STEPS schedule."                             SUTERR.......45700
        EX(1)="When transport is transient, a TIME_STEPS schedule must"  SUTERR.......45800
        EX(2)="be defined by the user in dataset 6."                     SUTERR.......45900
      ELSE IF (ERRCOD.EQ.'INP-6-15') THEN                                SUTERR.......46000
        DS(1)="Schedule name " // CHERR(1)                               SUTERR.......46100
        DS(2)="is too long"                                              SUTERR.......46200
        EX(1)="Schedule names are limited to 10 characters."             SUTERR.......46300
      ELSE IF ((ERRCOD.EQ.'INP-8A-1').OR.(ERRCOD.EQ.'INP-8A-2')          SUTERR.......46400
     1     .OR.(ERRCOD.EQ.'INP-8A-3').OR.(ERRCOD.EQ.'INP-8A-4')          SUTERR.......46500
     2     .OR.(ERRCOD.EQ.'INP-8A-5').OR.(ERRCOD.EQ.'INP-8A-6')          SUTERR.......46600
     3     .OR.(ERRCOD.EQ.'INP-8A-7').OR.(ERRCOD.EQ.'INP-8A-8')          SUTERR.......46700
     4     .OR.(ERRCOD.EQ.'INP-8A-9')) THEN                              SUTERR.......46800
        DS(1)=CHERR(1)(1:6) // " is not 'Y' or 'N'."                     SUTERR.......46900
        EX(1)="In dataset 8A of the main input file, " // CHERR(1)(1:6)  SUTERR.......47000
        EX(2)="must be set to either 'Y' or 'N'."                        SUTERR.......47100
        EX(3)=" "                                                        SUTERR.......47200
        EX(4)="Example of a valid dataset 8A:"                           SUTERR.......47300
        EX(5)="10  'N' 'N' 'N' 'Y' 'Y' 'Y' 'Y' 'Y' 'Y' 'Y' 'Y'"          SUTERR.......47400
      ELSE IF (ERRCOD.EQ.'INP-8B-1') THEN                                SUTERR.......47500
        DS(1)="Node number listed in column other than column 1."        SUTERR.......47600
        EX(1)="In dataset 8B of the main input file, if the node number" SUTERR.......47700
        EX(2)="is to appear, it must appear only in column 1, i.e.,"     SUTERR.......47800
        EX(3)="only NCOL(1) can be set to 'N'."                          SUTERR.......47900
      ELSE IF (ERRCOD.EQ.'INP-8B-2') THEN                                SUTERR.......48000
        DS(1)="Specified that 'Z' be output for a 2D problem."           SUTERR.......48100
        EX(1)="In dataset 8B of the main input file, 'Z' can be listed"  SUTERR.......48200
        EX(2)="only if the problem is 3D."                               SUTERR.......48300
      ELSE IF (ERRCOD.EQ.'INP-8B-3') THEN                                SUTERR.......48400
        DS(1)="Unrecognized value for NCOL."                             SUTERR.......48500
        EX(1)="In dataset 8B of the main input file, the following"      SUTERR.......48600
        EX(2)="variables may be listed:"                                 SUTERR.......48700
        EX(3)=" "                                                        SUTERR.......48800
        EX(4)="'N'  =  node number (if used, it must appear first)"      SUTERR.......48900
        EX(5)="'X'  =  X-coordinate of node"                             SUTERR.......49000
        EX(6)="'Y'  =  Y-coordinate of node"                             SUTERR.......49100
        EX(7)="'Z'  =  Z-coordinate of node (3D only)"                   SUTERR.......49200
        EX(8)="'P'  =  pressure"                                         SUTERR.......49300
        EX(9)="'U'  =  concentration or temperature"                     SUTERR.......49400
        EX(10)="'S'  =  saturation"                                      SUTERR.......49500
        EX(11)=" "                                                       SUTERR.......49600
        EX(12)="The symbol '-' (a single dash) is used to end the list." SUTERR.......49700
        EX(13)="Any symbols following '-' are ignored."                  SUTERR.......49800
        EX(14)=" "                                                       SUTERR.......49900
        EX(15)="Example of a valid dataset 8B for a 3D problem:"         SUTERR.......50000
        EX(16)="10  'N'  'X'  'Y'  'Z'  'S'  'U'  '-'"                   SUTERR.......50100
      ELSE IF (ERRCOD.EQ.'INP-8C-1') THEN                                SUTERR.......50200
        DS(1)="Element number listed in column other than column 1."     SUTERR.......50300
        EX(1)="In dataset 8C of the main input file, if the element"     SUTERR.......50400
        EX(2)="number is to appear, it must appear only in column 1,"    SUTERR.......50500
        EX(3)="i.e., only LCOL(1) can be set to 'E'."                    SUTERR.......50600
      ELSE IF (ERRCOD.EQ.'INP-8C-2') THEN                                SUTERR.......50700
        DS(1)="Specified that 'Z' be output for a 2D problem."           SUTERR.......50800
        EX(1)="In dataset 8C of the main input file, 'Z' can be listed"  SUTERR.......50900
        EX(2)="only if the problem is 3D."                               SUTERR.......51000
      ELSE IF (ERRCOD.EQ.'INP-8C-3') THEN                                SUTERR.......51100
        DS(1)="Unrecognized value for LCOL."                             SUTERR.......51200
        EX(1)="In dataset 8C of the main input file, the following"      SUTERR.......51300
        EX(2)="variables may be listed:"                                 SUTERR.......51400
        EX(3)=" "                                                        SUTERR.......51500
        EX(4)="'E'  =  element number (if used, it must appear first)"   SUTERR.......51600
        EX(5)="'X'  =  X-coordinate of element centroid"                 SUTERR.......51700
        EX(6)="'Y'  =  Y-coordinate of element centroid"                 SUTERR.......51800
        EX(7)="'Z'  =  Z-coordinate of element centroid (3D only)"       SUTERR.......51900
        EX(8)="'VX'  =  X-component of fluid velocity"                   SUTERR.......52000
        EX(9)="'VY'  =  Y-component of fluid velocity"                   SUTERR.......52100
        EX(10)="'VZ'  =  Z-component of fluid velocity (3D only)"        SUTERR.......52200
        EX(11)=" "                                                       SUTERR.......52300
        EX(12)="The symbol '-' (a single dash) is used to end the list." SUTERR.......52400
        EX(13)="Any symbols following '-' are ignored."                  SUTERR.......52500
        EX(14)=" "                                                       SUTERR.......52600
        EX(15)="Example of a valid dataset 8B for a 3D problem:"         SUTERR.......52700
        EX(16)="10  'E'  'X'  'Y'  'Z'  'VX'  'VY'  'VZ'  '-'"           SUTERR.......52800
      ELSE IF (ERRCOD.EQ.'INP-8C-4') THEN                                SUTERR.......52900
        DS(1)="Specified that 'VZ' be output for a 2D problem."          SUTERR.......53000
        EX(1)="In dataset 8C of the main input file, 'VZ' can be listed" SUTERR.......53100
        EX(2)="only if the problem is 3D."                               SUTERR.......53200
      ELSE IF (ERRCOD.EQ.'INP-8D-1') THEN                                SUTERR.......53300
        DS(1)="The actual number of observation points listed does not"  SUTERR.......53400
        DS(2)="equal the input value, or the observation point list"     SUTERR.......53500
        DS(3)="does not end with a zero."                                SUTERR.......53600
        EX(1)="In dataset 8D of the main input file, the number of"      SUTERR.......53700
        EX(2)="points listed must equal the number, NOBS, specified in"  SUTERR.......53800
        EX(3)="dataset 3 of the same file, and a zero must appear after" SUTERR.......53900
        EX(4)="the last point in the list when the old format is used."  SUTERR.......54000
        EX(5)="Any information appearing after the zero is ignored."     SUTERR.......54100
        EX(6)=" "                                                        SUTERR.......54200
        EX(7)="Example of a valid old-format dataset 8D with three"      SUTERR.......54300
        EX(8)="observation points (nodes 45, 46, and 7347),"             SUTERR.......54400
        EX(9)="assuming NN>=7347:"                                       SUTERR.......54500
        EX(10)="10   45   46   7347   0"                                 SUTERR.......54600
      ELSE IF (ERRCOD.EQ.'INP-8D-2') THEN                                SUTERR.......54700
        DS(1)="The observation node list contains an invalid node"       SUTERR.......54800
        DS(2)="number."                                                  SUTERR.......54900
        EX(1)="In dataset 8D of the main input file, all node numbers"   SUTERR.......55000
        EX(2)="must be greater than or equal to 1, and less than or"     SUTERR.......55100
        EX(3)="equal to NN, the total number of nodes.  The last entry"  SUTERR.......55200
        EX(4)="must be a zero, which signals the end of the list."       SUTERR.......55300
        EX(5)=" "                                                        SUTERR.......55400
        EX(6)="Example of a valid old-format dataset 8D with three"      SUTERR.......55500
        EX(7)="observation nodes (45, 46, and 7347),"                    SUTERR.......55600
        EX(8)="assuming NN>=7347:"                                       SUTERR.......55700
        EX(9)="10   45   46   7347   0"                                  SUTERR.......55800
      ELSE IF (ERRCOD.EQ.'INP-8D-3') THEN                                SUTERR.......55900
        DS(1)="Element not found for the following observation point:"   SUTERR.......56000
        DS(2)="   " // CHERR(1)                                          SUTERR.......56100
        DS(3)="   " // CHERR(2)                                          SUTERR.......56200
        EX(1)="SUTRA was unable to find an element that contains"        SUTERR.......56300
        EX(2)="the observation point named above.  Please check"         SUTERR.......56400
        EX(3)="to make sure the coordinates specified for that"          SUTERR.......56500
        EX(4)="observation point are within the model domain."           SUTERR.......56600
      ELSE IF (ERRCOD.EQ.'INP-8D-4') THEN                                SUTERR.......56700
        DS(1)="The actual number of observation points listed does not"  SUTERR.......56800
        DS(2)="equal the input value, or the observation point list"     SUTERR.......56900
        DS(3)="does not end with '-'."                                   SUTERR.......57000
        EX(1)="In dataset 8D of the main input file, the number of"      SUTERR.......57100
        EX(2)="points listed must equal the number, NOBS, specified in"  SUTERR.......57200
        EX(3)="dataset 3 of the same file, and the final entry in the"   SUTERR.......57300
        EX(4)="list must be '-'."                                        SUTERR.......57400
        EX(5)=" "                                                        SUTERR.......57500
        EX(6)="Example of a valid dataset 8D with two 3D observation"    SUTERR.......57600
        EX(7)="points, assuming schedules A and B have been defined:"    SUTERR.......57700
        EX(8)="100"                                                      SUTERR.......57800
        EX(9)="'POINT_1'     0.   100.   500.   'A'   'OBS'"             SUTERR.......57900
        EX(10)="'POINT_2'   100.   200.   800.   'B'   'OBC'"            SUTERR.......58000
        EX(11)="'-'"                                                     SUTERR.......58100
      ELSE IF (ERRCOD.EQ.'INP-8D-5') THEN                                SUTERR.......58200
        DS(1)="Undefined schedule " // CHERR(1)                          SUTERR.......58300
        DS(2)="specified for observation " // CHERR(2)                   SUTERR.......58400
        EX(1)="The output schedule specified for one of the"             SUTERR.......58500
        EX(2)="observation points has not been defined in dataset 6"     SUTERR.......58600
        EX(3)="of the main input file."                                  SUTERR.......58700
      ELSE IF (ERRCOD.EQ.'INP-8D-6') THEN                                SUTERR.......58800
        DS(1)="Schedule name " // CHERR(1)                               SUTERR.......58900
        DS(2)="is too long"                                              SUTERR.......59000
        EX(1)="Schedule names are limited to 10 characters."             SUTERR.......59100
      ELSE IF (ERRCOD.EQ.'INP-8E-1') THEN                                SUTERR.......59200
        DS(1)=CHERR(1)(1:6) // " is not 'Y' or 'N'."                     SUTERR.......59300
        EX(1)="In dataset 8E of the main input file, " // CHERR(1)(1:6)  SUTERR.......59400
        EX(2)="must be set to either 'Y' or 'N'."                        SUTERR.......59500
        EX(3)=" "                                                        SUTERR.......59600
        EX(4)="Example of a valid dataset 8E:"                           SUTERR.......59700
        EX(5)="1   1    1    1   'Y'"                                    SUTERR.......59800
      ELSE IF (ERRCOD.EQ.'INP-11-1') THEN                                SUTERR.......59900
        DS(1)="Unrecognized sorption model."                             SUTERR.......60000
        EX(1)="In dataset 11 of the main input file, the sorption model" SUTERR.......60100
        EX(2)="may be chosen from the following:"                        SUTERR.......60200
        EX(3)=" "                                                        SUTERR.......60300
        EX(4)="'NONE'       =  No sorption"                              SUTERR.......60400
        EX(5)="'LINEAR'     =  Linear sorption model"                    SUTERR.......60500
        EX(6)="'FREUNDLICH' =  Freundlich sorption model"                SUTERR.......60600
        EX(7)="'LANGMUIR'   =  Langmuir sorption model"                  SUTERR.......60700
      ELSE IF (ERRCOD.EQ.'INP-11-2') THEN                                SUTERR.......60800
        DS(1)="The second Freundlich sorption coefficient is less than"  SUTERR.......60900
        DS(2)="or equal to zero."                                        SUTERR.......61000
        EX(1)="In dataset 11 of the main input file, the second"         SUTERR.......61100
        EX(2)="coefficient, CHI2, must be positive if Freundlich"        SUTERR.......61200
        EX(3)="sorption is chosen."                                      SUTERR.......61300
      ELSE IF (ERRCOD.EQ.'INP-14A-1') THEN                               SUTERR.......61400
        DS(1)="Dataset 14A does not begin with the word 'NODE'."         SUTERR.......61500
        EX(1)="Dataset 14A of the main input file must begin with the"   SUTERR.......61600
        EX(2)="word 'NODE'."                                             SUTERR.......61700
        EX(3)=" "                                                        SUTERR.......61800
        EX(4)="Example of a valid dataset 14A:"                          SUTERR.......61900
        EX(5)="'NODE'  1000.  1000.  1.  0.1"                            SUTERR.......62000
      ELSE IF (ERRCOD.EQ.'INP-15A-1') THEN                               SUTERR.......62100
        DS(1)="Dataset 15A does not begin with the word 'ELEMENT'."      SUTERR.......62200
        EX(1)="Dataset 15A of the main input file must begin with the"   SUTERR.......62300
        EX(2)="word 'ELEMENT'."                                          SUTERR.......62400
        EX(3)=" "                                                        SUTERR.......62500
        EX(4)="Example of a valid dataset 15A for a " // CHERR(1)(1:2)   SUTERR.......62600
     1         // " problem:"                                            SUTERR.......62700
        IF (CHERR(1).EQ."3D") THEN                                       SUTERR.......62800
          EX(5)="'ELEMENT' 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1. 1." SUTERR.......62900
        ELSE                                                             SUTERR.......63000
          EX(5)="'ELEMENT' 1. 1. 1. 1. 1. 1. 1."                         SUTERR.......63100
        END IF                                                           SUTERR.......63200
      ELSE IF (ERRCOD.EQ.'ICS-1-1') THEN                                 SUTERR.......63300
        DS(1)="Unable to restart simulation."                            SUTERR.......63400
        EX(1)="The time step number from which the simulation is trying" SUTERR.......63500
        EX(2)="to restart (" // CINERR(1) // ") equals or exceeds the"   SUTERR.......63600
        EX(3)="number of the final time step (" // CINERR(2) // ")."     SUTERR.......63700
      ELSE IF (ERRCOD.EQ.'ICS-2-1') THEN                                 SUTERR.......63800
        DS(1)="Unrecognized initialization type."                        SUTERR.......63900
        EX(1)="In dataset 2 of the initial conditions input file,"       SUTERR.......64000
        EX(2)="the valid types of initializations for P are UNIFORM"     SUTERR.......64100
        EX(3)="and NONUNIFORM."                                          SUTERR.......64200
      ELSE IF (ERRCOD.EQ.'ICS-2-2') THEN                                 SUTERR.......64300
        DS(1)="Did not specify NONUNIFORM initial values during a WARM"  SUTERR.......64400
        DS(2)="start."                                                   SUTERR.......64500
        EX(1)="In dataset 2 of the initial conditions input file,"       SUTERR.......64600
        EX(2)="initial values for P must be specified as NONUNIFORM"     SUTERR.......64700
        EX(3)="during a WARM start (i.e., if CREAD='WARM' in dataset 4"  SUTERR.......64800
        EX(4)="of the main input file)."                                 SUTERR.......64900
      ELSE IF (ERRCOD.EQ.'ICS-3-1') THEN                                 SUTERR.......65000
        DS(1)="Unrecognized initialization type."                        SUTERR.......65100
        EX(1)="In dataset 3 of the initial conditions input file,"       SUTERR.......65200
        EX(2)="the valid types of initializations for U are UNIFORM"     SUTERR.......65300
        EX(3)="and NONUNIFORM."                                          SUTERR.......65400
      ELSE IF (ERRCOD.EQ.'ICS-3-2') THEN                                 SUTERR.......65500
        DS(1)="Did not specify NONUNIFORM initial values during a WARM"  SUTERR.......65600
        DS(2)="start."                                                   SUTERR.......65700
        EX(1)="In dataset 3 of the initial conditions input file,"       SUTERR.......65800
        EX(2)="initial values for U must be specified as NONUNIFORM"     SUTERR.......65900
        EX(3)="during a WARM start (i.e., if CREAD='WARM' in dataset 4"  SUTERR.......66000
        EX(4)="of the main input file)."                                 SUTERR.......66100
      ELSE IF (ERRCOD.EQ.'SOL-1') THEN                                   SUTERR.......66200
        DS(1)="Error returned by the " // CHERR(2)(1:10)                 SUTERR.......66300
        DS(2)="solver while solving for " // CHERR(1)(1:1) // "."        SUTERR.......66400
        EX(1)="The iterative solver has stopped because of an error."    SUTERR.......66500
        EX(2)="Error flag values are interpreted as follows:"            SUTERR.......66600
        EX(3)="  "                                                       SUTERR.......66700
        EX(4)="IERR = 2  =>  Method stalled or failed to converge in"    SUTERR.......66800
        EX(5)="              the maximum number of iterations allowed."  SUTERR.......66900
        EX(6)="IERR = 4  =>  Convergence tolerance set too tight for"    SUTERR.......67000
        EX(7)="              machine precision."                         SUTERR.......67100
        EX(8)="IERR = 5  =>  Method broke down because preconditioning"  SUTERR.......67200
        EX(9)="              matrix is non-positive-definite."           SUTERR.......67300
        EX(10)="IERR = 6  =>  Method broke down because matrix is non-"  SUTERR.......67400
        EX(11)="              positive-definite or nearly so."           SUTERR.......67500
        EX(12)=" "                                                       SUTERR.......67600
        EX(13)="If the P-solution resulted in a solver error, an"        SUTERR.......67700
        EX(14)="attempt was still made to obtain a U-solution."          SUTERR.......67800
        EX(15)="The last P and U solutions were written to the"          SUTERR.......67900
        EX(16)="appropriate output files (except the restart file)"      SUTERR.......68000
        EX(17)="whether or not they resulted in solver errors."          SUTERR.......68100
      ELSE IF (ERRCOD.EQ.'INP-3,17-1') THEN                              SUTERR.......68200
        DS(1)="The actual number of"                                     SUTERR.......68300
        DS(2)="specified fluid source nodes,   " // CINERR(1) // ","     SUTERR.......68400
        DS(3)="does not equal the input value, " // CINERR(2) // "."     SUTERR.......68500
        EX(1)="In dataset 3 of the main input file, the variable NSOP"   SUTERR.......68600
        EX(2)="must specify the exact number of specified fluid source"  SUTERR.......68700
        EX(3)="nodes listed in dataset 17."                              SUTERR.......68800
      ELSE IF (ERRCOD.EQ.'INP-3,18-1') THEN                              SUTERR.......68900
        DS(1)="The actual number of"                                     SUTERR.......69000
        DS(2)="specified " // CHERR(1)(1:6) // " source nodes,  "        SUTERR.......69100
     1         // CINERR(1) // ","                                       SUTERR.......69200
        DS(3)="does not equal the input value, " // CINERR(2) // "."     SUTERR.......69300
        EX(1)="In dataset 3 of the main input file, the variable NSOU"   SUTERR.......69400
        EX(2)="must specify the exact number of specified "              SUTERR.......69500
     1         // CHERR(1)(1:6) // " source"                             SUTERR.......69600
        EX(3)="nodes listed in dataset 18."                              SUTERR.......69700
      ELSE IF (ERRCOD.EQ.'INP-17-1') THEN                                SUTERR.......69800
        DS(1)="Invalid node number referenced in dataset 17: "           SUTERR.......69900
     1         // CINERR(1)                                              SUTERR.......70000
        EX(1)="Dataset 17 of the main input file contains a reference"   SUTERR.......70100
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......70200
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......70300
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......70400
        EX(5)="(excluding the negative sign that precedes nodes with"    SUTERR.......70500
        EX(6)="time-dependent boundary conditions)."                     SUTERR.......70600
      ELSE IF (ERRCOD.EQ.'INP-18-1') THEN                                SUTERR.......70700
        DS(1)="Invalid node number referenced in dataset 18: "           SUTERR.......70800
     1         // CINERR(1)                                              SUTERR.......70900
        EX(1)="Dataset 18 of the main input file contains a reference"   SUTERR.......71000
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......71100
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......71200
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......71300
        EX(5)="(excluding the negative sign that precedes nodes with"    SUTERR.......71400
        EX(6)="time-dependent boundary conditions)."                     SUTERR.......71500
      ELSE IF (ERRCOD.EQ.'INP-19-1') THEN                                SUTERR.......71600
        DS(1)="Invalid node number referenced in dataset 19: "           SUTERR.......71700
     1         // CINERR(1)                                              SUTERR.......71800
        EX(1)="Dataset 19 of the main input file contains a reference"   SUTERR.......71900
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......72000
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......72100
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......72200
        EX(5)="(excluding the negative sign that precedes nodes with"    SUTERR.......72300
        EX(6)="time-dependent boundary conditions)."                     SUTERR.......72400
      ELSE IF (ERRCOD.EQ.'INP-20-1') THEN                                SUTERR.......72500
        DS(1)="Invalid node number referenced in dataset 20: "           SUTERR.......72600
     1         // CINERR(1)                                              SUTERR.......72700
        EX(1)="Dataset 20 of the main input file contains a reference"   SUTERR.......72800
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......72900
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......73000
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......73100
        EX(5)="(excluding the negative sign that precedes nodes with"    SUTERR.......73200
        EX(6)="time-dependent boundary conditions)."                     SUTERR.......73300
      ELSE IF (ERRCOD.EQ.'BCS-1-1') THEN                                 SUTERR.......73400
        DS(1)="Undefined schedule " // CHERR(1)                          SUTERR.......73500
        DS(2)="specified in BCS file " // CHERR(2)                       SUTERR.......73600
        EX(1)="The schedule specified in the BCS file mentioned"         SUTERR.......73700
        EX(2)="above has not been defined in dataset 6 of the"           SUTERR.......73800
        EX(3)="main input file."                                         SUTERR.......73900
      ELSE IF (ERRCOD.EQ.'BCS-1-2') THEN                                 SUTERR.......74000
        DS(1)="Schedule " // CHERR(1)                                    SUTERR.......74100
        DS(2)="used in BCS file " // CHERR(2)                            SUTERR.......74200
        DS(3)="includes a fractional time step number, " // CRLERR(1)    SUTERR.......74300
        EX(1)="Schedules that are used in BCS files must not include"    SUTERR.......74400
        EX(2)="fractional time step numbers.  Only whole-numbered"       SUTERR.......74500
        EX(3)="time steps (0, 1, 2, 3, etc.) are allowed."               SUTERR.......74600
      ELSE IF (ERRCOD.EQ.'BCS-1-3') THEN                                 SUTERR.......74700
        DS(1)="Undefined schedule " // CHERR(1)                          SUTERR.......74800
        DS(2)="specified in BCS file " // CHERR(2)                       SUTERR.......74900
        EX(1)="When transport is steady-state, user-defined"             SUTERR.......75000
        EX(2)="schedules are not in effect, and steady-state boundary"   SUTERR.......75100
        EX(3)="conditions in BCS files must be controlled using the"     SUTERR.......75200
        EX(4)="following schedules automatically defined by SUTRA:"      SUTERR.......75300
        EX(5)=" "                                                        SUTERR.......75400
        EX(6)="TIME_STEPS (time steps 0 and 1)"                          SUTERR.......75500
        EX(7)="STEP_0     (time step 0 only)"                            SUTERR.......75600
        EX(8)="STEP_1     (time step 1 only)"                            SUTERR.......75700
        EX(9)="STEPS_1&UP (equivalent to 'STEP_1' in this case)"         SUTERR.......75800
      ELSE IF (ERRCOD.EQ.'BCS-1-4') THEN                                 SUTERR.......75900
        DS(1)="Schedule name " // CHERR(1)                               SUTERR.......76000
        DS(2)="specified in BCS file " // CHERR(2)                       SUTERR.......76100
        DS(3)="is too long"                                              SUTERR.......76200
        EX(1)="Schedule names are limited to 10 characters."             SUTERR.......76300
      ELSE IF (ERRCOD.EQ.'BCS-2-1') THEN                                 SUTERR.......76400
        DS(1)="Transport boundary conditions"                            SUTERR.......76500
        DS(2)="are specified for time step 0"                            SUTERR.......76600
        DS(3)="in the BCS file mentioned above."                         SUTERR.......76700
        EX(1)="Boundary conditions for transport (BCS datasets 4 and 6)" SUTERR.......76800
        EX(2)="cannot be specified for time step 0.  If transport is"    SUTERR.......76900
        EX(3)="steady-state, use time step 1 (not 0) to specify"         SUTERR.......77000
        EX(4)="boundary conditions for transport in BCS files."          SUTERR.......77100
      ELSE IF (ERRCOD.EQ.'BCS-2,3-1') THEN                               SUTERR.......77200
        DS(1)="The actual number of time-"                               SUTERR.......77300
        DS(2)="varying fluid source nodes,     " // CINERR(1) // ","     SUTERR.......77400
        DS(3)="does not equal the input value, " // CINERR(2) // ","     SUTERR.......77500
        DS(4)="for BCS time step " // CINERR(3) // "."                   SUTERR.......77600
        EX(1)="In dataset 2 of the BCS file, the variable NSOP1"         SUTERR.......77700
        EX(2)="must specify the exact number of time-dependent fluid"    SUTERR.......77800
        EX(3)="source nodes listed in dataset 3."                        SUTERR.......77900
      ELSE IF (ERRCOD.EQ.'BCS-2,4-1') THEN                               SUTERR.......78000
        DS(1)="The actual number of time-"                               SUTERR.......78100
        DS(2)="varying " // CHERR(1)(1:6) // " source nodes,    "        SUTERR.......78200
     1         // CINERR(1) // ","                                       SUTERR.......78300
        DS(3)="does not equal the input value, " // CINERR(2) // ","     SUTERR.......78400
        DS(4)="for BCS time step " // CINERR(3) // "."                   SUTERR.......78500
        EX(1)="In dataset 2 of the BCS file, the variable NSOU1"         SUTERR.......78600
        EX(2)="must specify the exact number of time-dependent "         SUTERR.......78700
     1         // CHERR(1)(1:6) // " source"                             SUTERR.......78800
        EX(3)="nodes listed in dataset 4."                               SUTERR.......78900
      ELSE IF (ERRCOD.EQ.'BCS-2,5-1') THEN                               SUTERR.......79000
        DS(1)="The actual number of"                                     SUTERR.......79100
        DS(2)="TIME-DEPENDENT pressure nodes,    " // CINERR(1) // ","   SUTERR.......79200
        DS(3)="does not equal the input value, " // CINERR(2) // ","     SUTERR.......79300
        DS(4)="for BCS time step " // CINERR(3) // "."                   SUTERR.......79400
        EX(1)="In dataset 2 of the BCS file, the variable NPBC1"         SUTERR.......79500
        EX(2)="must specify the exact number of time-dependent"          SUTERR.......79600
        EX(3)="pressure nodes listed in dataset 5."                      SUTERR.......79700
      ELSE IF (ERRCOD.EQ.'BCS-2,6-1') THEN                               SUTERR.......79800
        DS(1)="The actual number of"                                     SUTERR.......79900
        DS(2)="TIME-DEPENDENT " // CHERR(1)(1:13) // " nodes,  "         SUTERR.......80000
     1         // CINERR(1) // ","                                       SUTERR.......80100
        DS(3)="does not equal the input value,   " // CINERR(2) // ","   SUTERR.......80200
        DS(4)="for BCS time step " // CINERR(3) // "."                   SUTERR.......80300
        EX(1)="In dataset 2 of the BCS file, the variable NUBC1"         SUTERR.......80400
        EX(2)="must specify the exact number of time-dependent "         SUTERR.......80500
     1         // CHERR(1)(1:13)                                         SUTERR.......80600
        EX(3)="nodes listed in dataset 6."                               SUTERR.......80700
      ELSE IF (ERRCOD.EQ.'BCS-3-1') THEN                                 SUTERR.......80800
        DS(1)="Invalid node number referenced in dataset 3: "            SUTERR.......80900
     1         // CINERR(1)                                              SUTERR.......81000
        DS(2)="on BCS time step " // CINERR(3) // "."                    SUTERR.......81100
        EX(1)="Dataset 3 of the BCS file contains a reference"           SUTERR.......81200
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......81300
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......81400
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......81500
        EX(5)="(excluding the negative sign that precedes node"          SUTERR.......81600
        EX(6)="numbers for inactive boundary conditions)."               SUTERR.......81700
      ELSE IF (ERRCOD.EQ.'BCS-3-2') THEN                                 SUTERR.......81800
        DS(1)="Invalid node number referenced in dataset 3: "            SUTERR.......81900
     1         // CINERR(1)                                              SUTERR.......82000
        DS(2)="on BCS time step " // CINERR(2) // "."                    SUTERR.......82100
        EX(1)="Dataset 3 of the BCS file contains a reference"           SUTERR.......82200
        EX(2)="to an unrecognized boundary-condition node number."       SUTERR.......82300
        EX(3)="Any node number used in dataset 3 of the BCS file must"   SUTERR.......82400
        EX(4)="also appear in dataset 17 of the main input file"         SUTERR.......82500
        EX(5)="(excluding the negative signs that precede node"          SUTERR.......82600
        EX(6)="numbers for inactive and BCTIME boundary conditions)."    SUTERR.......82700
      ELSE IF (ERRCOD.EQ.'BCS-4-1') THEN                                 SUTERR.......82800
        DS(1)="Invalid node number referenced in dataset 4: "            SUTERR.......82900
     1         // CINERR(1)                                              SUTERR.......83000
        DS(2)="on BCS time step " // CINERR(3) // "."                    SUTERR.......83100
        EX(1)="Dataset 4 of the BCS file contains a reference"           SUTERR.......83200
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......83300
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......83400
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......83500
        EX(5)="(excluding the negative sign that precedes node"          SUTERR.......83600
        EX(6)="numbers for inactive boundary conditions)."               SUTERR.......83700
      ELSE IF (ERRCOD.EQ.'BCS-4-2') THEN                                 SUTERR.......83800
        DS(1)="Invalid node number referenced in dataset 4: "            SUTERR.......83900
     1         // CINERR(1)                                              SUTERR.......84000
        DS(2)="on BCS time step " // CINERR(2) // "."                    SUTERR.......84100
        EX(1)="Dataset 4 of the BCS file contains a reference"           SUTERR.......84200
        EX(2)="to an unrecognized boundary-condition node number."       SUTERR.......84300
        EX(3)="Any node number used in dataset 4 of the BCS file must"   SUTERR.......84400
        EX(4)="also appear in dataset 18 of the main input file"         SUTERR.......84500
        EX(5)="(excluding the negative signs that precede node"          SUTERR.......84600
        EX(6)="numbers for inactive and BCTIME boundary conditions)."    SUTERR.......84700
      ELSE IF (ERRCOD.EQ.'BCS-5-1') THEN                                 SUTERR.......84800
        DS(1)="Invalid node number referenced in dataset 5: "            SUTERR.......84900
     1         // CINERR(1)                                              SUTERR.......85000
        DS(2)="on BCS time step " // CINERR(3) // "."                    SUTERR.......85100
        EX(1)="Dataset 5 of the BCS file contains a reference"           SUTERR.......85200
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......85300
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......85400
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......85500
        EX(5)="(excluding the negative sign that precedes node"          SUTERR.......85600
        EX(6)="numbers for inactive boundary conditions)."               SUTERR.......85700
      ELSE IF (ERRCOD.EQ.'BCS-5-2') THEN                                 SUTERR.......85800
        DS(1)="Invalid node number referenced in dataset 5: "            SUTERR.......85900
     1         // CINERR(1)                                              SUTERR.......86000
        DS(2)="on BCS time step " // CINERR(2) // "."                    SUTERR.......86100
        EX(1)="Dataset 5 of the BCS file contains a reference"           SUTERR.......86200
        EX(2)="to an unrecognized boundary-condition node number."       SUTERR.......86300
        EX(3)="Any node number used in dataset 5 of the BCS file must"   SUTERR.......86400
        EX(4)="also appear in dataset 19 of the main input file"         SUTERR.......86500
        EX(5)="(excluding the negative signs that precede node"          SUTERR.......86600
        EX(6)="numbers for inactive and BCTIME boundary conditions)."    SUTERR.......86700
      ELSE IF (ERRCOD.EQ.'BCS-6-1') THEN                                 SUTERR.......86800
        DS(1)="Invalid node number referenced in dataset 6: "            SUTERR.......86900
     1         // CINERR(1)                                              SUTERR.......87000
        DS(2)="on BCS time step " // CINERR(3) // "."                    SUTERR.......87100
        EX(1)="Dataset 6 of the BCS file contains a reference"           SUTERR.......87200
        EX(2)="to a non-existent node number.  All node numbers must"    SUTERR.......87300
        EX(3)="be less than or equal to the total number of nodes,"      SUTERR.......87400
        EX(4)="NN = " // CINERR(2)                                       SUTERR.......87500
        EX(5)="(excluding the negative sign that precedes node"          SUTERR.......87600
        EX(6)="numbers for inactive boundary conditions)."               SUTERR.......87700
      ELSE IF (ERRCOD.EQ.'BCS-6-2') THEN                                 SUTERR.......87800
        DS(1)="Invalid node number referenced in dataset 6: "            SUTERR.......87900
     1         // CINERR(1)                                              SUTERR.......88000
        DS(2)="on BCS time step " // CINERR(2) // "."                    SUTERR.......88100
        EX(1)="Dataset 6 of the BCS file contains a reference"           SUTERR.......88200
        EX(2)="to an unrecognized boundary-condition node number."       SUTERR.......88300
        EX(3)="Any node number used in dataset 6 of the BCS file must"   SUTERR.......88400
        EX(4)="also appear in dataset 20 of the main input file"         SUTERR.......88500
        EX(5)="(excluding the negative signs that precede node"          SUTERR.......88600
        EX(6)="numbers for inactive and BCTIME boundary conditions)."    SUTERR.......88700
      ELSE IF (ERRCOD.EQ.'CON-1') THEN                                   SUTERR.......88800
        CDUM80 = 's'                                                     SUTERR.......88900
        IF (INERR(4).GT.13) THEN                                         SUTERR.......89000
           LDUM = 1                                                      SUTERR.......89100
        ELSE                                                             SUTERR.......89200
           LDUM = 0                                                      SUTERR.......89300
        END IF                                                           SUTERR.......89400
        DS(1)="Simulation terminated due to unconverged non-linearity"   SUTERR.......89500
        DS(2)="iterations.  Tolerance" // CDUM80(1:LDUM)                 SUTERR.......89600
     1         // " for " // CHERR(1)(1:INERR(4))                        SUTERR.......89700
        DS(3)="not reached."                                             SUTERR.......89800
        EX(1)="The " // CHERR(1)(1:INERR(4)) // " solution"              SUTERR.......89900
     1         // CDUM80(1:LDUM) // " failed"                            SUTERR.......90000
        EX(2)="to converge to the specified tolerance"                   SUTERR.......90100
     1         // CDUM80(1:LDUM) // " within"                            SUTERR.......90200
        EX(3)="the maximum number of iterations allowed to resolve"      SUTERR.......90300
        EX(4)="non-linearities.  The parameters that control these"      SUTERR.......90400
        EX(5)="iterations are set in dataset 7A of the main input file." SUTERR.......90500
      ELSE IF ((CODE(1).EQ.'REA').AND.                                   SUTERR.......90600
     1         ((CODE(2).EQ.'INP').OR.(CODE(2).EQ.'ICS').OR.             SUTERR.......90700
     2          (CODE(2).EQ.'BCS'))) THEN                                SUTERR.......90800
        IF (CODE(2).EQ.'INP') THEN                                       SUTERR.......90900
           CDUM80 = 'main input'                                         SUTERR.......91000
           LDUM = 10                                                     SUTERR.......91100
        ELSE IF (CODE(2).EQ.'ICS') THEN                                  SUTERR.......91200
           CDUM80 = 'initial conditions'                                 SUTERR.......91300
           LDUM = 18                                                     SUTERR.......91400
        ELSE IF (CODE(2).EQ.'BCS') THEN                                  SUTERR.......91500
           CDUM80 = 'boundary conditions'                                SUTERR.......91600
           LDUM = 19                                                     SUTERR.......91700
        END IF                                                           SUTERR.......91800
        IF ((CODE(2).EQ.'ICS').AND.(CODE(3).EQ.'4')) THEN                SUTERR.......91900
          DS(1)="FORTRAN returned an error while reading the restart"    SUTERR.......92000
          DS(2)="information following dataset 3 of the initial"         SUTERR.......92100
          DS(3)="conditions."                                            SUTERR.......92200
        ELSE IF (CODE(3).EQ.'INS') THEN                                  SUTERR.......92300
          CALL PRSWDS(CHERR(1), '-', 3, CODUM, NWORDS)                   SUTERR.......92400
          DS(1)="FORTRAN returned an error while reading an '@INSERT'"   SUTERR.......92500
          DS(2)="statement in the vicinity of dataset " // CODUM(3)(1:3) SUTERR.......92600
          DS(3)="of the " // CDUM80(1:LDUM) // "."                       SUTERR.......92700
        ELSE                                                             SUTERR.......92800
          DS(1)="FORTRAN returned an error while reading"                SUTERR.......92900
          DS(2)="dataset " // CODE(3)(1:3)                               SUTERR.......93000
     1           // " of the " // CDUM80(1:LDUM) // "."                  SUTERR.......93100
        END IF                                                           SUTERR.......93200
        EX(1)="A FORTRAN error has occurred while reading input data."   SUTERR.......93300
        EX(2)="Error status flag values are interpreted as follows:"     SUTERR.......93400
        EX(3)=" "                                                        SUTERR.......93500
        EX(4)="IOSTAT < 0  =>  The end of a line was reached before"     SUTERR.......93600
        EX(5)="                all the required data were read from"     SUTERR.......93700
        EX(6)="                that line.  Check the specified dataset"  SUTERR.......93800
        EX(7)="                for missing data or lines of data that"   SUTERR.......93900
        EX(8)="                exceed 1000 characters."                  SUTERR.......94000
        EX(9)="IOSTAT > 0  =>  An error occurred while the specified"    SUTERR.......94100
        EX(10)="                dataset was being read.  Usually, this"  SUTERR.......94200
        EX(11)="                indicates that the READ statement"       SUTERR.......94300
        EX(12)="                encountered data of a type that is"      SUTERR.......94400
        EX(13)="                incompatible with the type it expected." SUTERR.......94500
        EX(14)="                Check the dataset for typographical"     SUTERR.......94600
        EX(15)="                errors and missing or extraneous data."  SUTERR.......94700
      ELSE IF ((CODE(1).EQ.'REA').AND.(CODE(2).EQ.'FIL')) THEN           SUTERR.......94800
        DS(1)='FORTRAN returned an error while reading "SUTRA.FIL".'     SUTERR.......94900
        EX(1)='A FORTRAN error has occurred while reading "SUTRA.FIL".'  SUTERR.......95000
        EX(2)="Error status flag values are interpreted as follows:"     SUTERR.......95100
        EX(3)=" "                                                        SUTERR.......95200
        EX(4)="IOSTAT < 0  =>  The end of a line was reached before"     SUTERR.......95300
        EX(5)="                all the required data were read from"     SUTERR.......95400
        EX(6)='                that line.  Check "SUTRA.FIL" for'        SUTERR.......95500
        EX(7)="                missing data."                            SUTERR.......95600
        EX(8)="IOSTAT > 0  =>  An error occurred while the input"        SUTERR.......95700
        EX(9)="                file was being read.  Usually, this"      SUTERR.......95800
        EX(10)="                indicates that the READ statement"       SUTERR.......95900
        EX(11)="                encountered data of a type that is"      SUTERR.......96000
        EX(12)="                incompatible with the type it expected." SUTERR.......96100
        EX(13)='                Check "SUTRA.FIL" for typographical'     SUTERR.......96200
        EX(14)="                errors and missing or extraneous data."  SUTERR.......96300
      END IF                                                             SUTERR.......96400
C                                                                        SUTERR.......96500
C.....WRITE ERROR MESSAGE.  FORMAT DEPENDS ON THE TYPE OF ERROR.         SUTERR.......96600
      IF ((CODE(1).EQ.'INP').OR.(CODE(1).EQ.'ICS').OR.                   SUTERR.......96700
     1    (CODE(1).EQ.'BCS')) THEN                                       SUTERR.......96800
C........ERROR TYPES 'INP', 'ICS', AND 'BCS' (INPUT DATA ERROR)          SUTERR.......96900
         IF (KSCRN.EQ.1)                                                 SUTERR.......97000
     1      WRITE (*,1888) '           INPUT DATA ERROR           '      SUTERR.......97100
         WRITE (K00,1888) '           INPUT DATA ERROR           '       SUTERR.......97200
         IF (KSCRN.EQ.1) WRITE (*,1011)                                  SUTERR.......97300
         WRITE (K00,1011)                                                SUTERR.......97400
 1011    FORMAT (/1X,'DESCRIPTION')                                      SUTERR.......97500
         IF (CODE(1).EQ.'INP') THEN                                      SUTERR.......97600
            CDUM80 = FNAME(1)                                            SUTERR.......97700
         ELSE IF (CODE(1).EQ.'ICS') THEN                                 SUTERR.......97800
            CDUM80 = FNAME(2)                                            SUTERR.......97900
         ELSE                                                            SUTERR.......98000
            CDUM80 = FNAME(9)                                            SUTERR.......98100
         END IF                                                          SUTERR.......98200
         IF (KSCRN.EQ.1) WRITE (*,1013) ERRCOD, CDUM80, CODE(2)          SUTERR.......98300
         WRITE (K00,1013) ERRCOD, CDUM80, CODE(2)                        SUTERR.......98400
 1013    FORMAT (/4X,'Error code:',2X,A40                                SUTERR.......98500
     1           /4X,'File:      ',2X,A40                                SUTERR.......98600
     1           /4X,'Dataset(s):',2X,A40/)                              SUTERR.......98700
         DO 1015 I=1,50                                                  SUTERR.......98800
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR.......98900
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR.......99000
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR.......99100
 1015    CONTINUE                                                        SUTERR.......99200
         IF (KSCRN.EQ.1) WRITE (*,1021)                                  SUTERR.......99300
         WRITE (K00,1021)                                                SUTERR.......99400
 1021    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR.......99500
         DO 1025 I=1,50                                                  SUTERR.......99600
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR.......99700
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR.......99800
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR.......99900
 1025    CONTINUE                                                        SUTERR......100000
         IF (KSCRN.EQ.1) WRITE (*,1081)                                  SUTERR......100100
         WRITE (K00,1081)                                                SUTERR......100200
 1081    FORMAT (/1X,'GENERAL NOTE'/                                     SUTERR......100300
     1     /4X,'If the dataset for which SUTRA has reported an error'    SUTERR......100400
     1     /4X,'appears to be correct, check the preceding lines'        SUTERR......100500
     1     /4X,'for missing data or extraneous characters.')             SUTERR......100600
      ELSE IF (CODE(1).EQ.'FIL') THEN                                    SUTERR......100700
C........ERROR TYPE 'FIL' (FILE ERROR)                                   SUTERR......100800
         IF (KSCRN.EQ.1)                                                 SUTERR......100900
     1      WRITE (*,1888)'              FILE ERROR              '       SUTERR......101000
         WRITE (K00,1888) '              FILE ERROR              '       SUTERR......101100
         IF (KSCRN.EQ.1) WRITE (*,1211)                                  SUTERR......101200
         WRITE (K00,1211)                                                SUTERR......101300
 1211    FORMAT (/1X,'DESCRIPTION')                                      SUTERR......101400
         IF (KSCRN.EQ.1) WRITE (*,1213) ERRCOD, CHERR(1)                 SUTERR......101500
         WRITE (K00,1213) ERRCOD, CHERR(1)                               SUTERR......101600
 1213    FORMAT (/4X,'Error code:',2X,A40                                SUTERR......101700
     1           /4X,'File:      ',2X,A40/)                              SUTERR......101800
         DO 1215 I=1,50                                                  SUTERR......101900
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR......102000
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR......102100
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR......102200
 1215    CONTINUE                                                        SUTERR......102300
         IF (KSCRN.EQ.1) WRITE (*,1221)                                  SUTERR......102400
         WRITE (K00,1221)                                                SUTERR......102500
 1221    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR......102600
         DO 1225 I=1,50                                                  SUTERR......102700
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR......102800
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR......102900
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR......103000
 1225    CONTINUE                                                        SUTERR......103100
      ELSE IF (CODE(1).EQ.'SOL') THEN                                    SUTERR......103200
C........ERROR TYPE 'SOL' (MATRIX SOLVER ERROR)                          SUTERR......103300
         IF (KSCRN.EQ.1)                                                 SUTERR......103400
     1      WRITE (*,1888) '         MATRIX SOLVER ERROR          '      SUTERR......103500
         WRITE (K00,1888) '         MATRIX SOLVER ERROR          '       SUTERR......103600
         IF (KSCRN.EQ.1) WRITE (*,1311)                                  SUTERR......103700
         WRITE (K00,1311)                                                SUTERR......103800
 1311    FORMAT (/1X,'DESCRIPTION')                                      SUTERR......103900
         IF (KSCRN.EQ.1) WRITE (*,1313) ERRCOD, CHERR(2),                SUTERR......104000
     1      INERR(1), INERR(2), RLERR(1), RLERR(2)                       SUTERR......104100
         WRITE (K00,1313) ERRCOD, CHERR(2), INERR(1), INERR(2),          SUTERR......104200
     1      RLERR(1), RLERR(2)                                           SUTERR......104300
 1313    FORMAT (/4X,'Error code:',2X,A40                                SUTERR......104400
     1           /4X,'Solver:    ',2X,A40                                SUTERR......104500
     1          //4X,'Error flag..........IERR = ',I3                    SUTERR......104600
     1           /4X,'# of solver iters...ITRS = ',I5                    SUTERR......104700
     1           /4X,'Error estimate.......ERR = ',1PE8.1                SUTERR......104800
     1           /4X,'Error tolerance......TOL = ',1PE8.1/)              SUTERR......104900
         DO 1315 I=1,50                                                  SUTERR......105000
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR......105100
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR......105200
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR......105300
 1315    CONTINUE                                                        SUTERR......105400
         IF (KSCRN.EQ.1) WRITE (*,1321)                                  SUTERR......105500
         WRITE (K00,1321)                                                SUTERR......105600
 1321    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR......105700
         DO 1325 I=1,50                                                  SUTERR......105800
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR......105900
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR......106000
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR......106100
 1325    CONTINUE                                                        SUTERR......106200
      ELSE IF (CODE(1).EQ.'CON') THEN                                    SUTERR......106300
C........ERROR TYPE 'CON' (CONVERGENCE ERROR)                            SUTERR......106400
         IF (KSCRN.EQ.1)                                                 SUTERR......106500
     1      WRITE (*,1888) '          CONVERGENCE ERROR           '      SUTERR......106600
         WRITE (K00,1888) '         CONVERGENCE ERROR          '         SUTERR......106700
         IF (KSCRN.EQ.1) WRITE (*,1411)                                  SUTERR......106800
         WRITE (K00,1411)                                                SUTERR......106900
 1411    FORMAT (/1X,'DESCRIPTION')                                      SUTERR......107000
         IF (KSCRN.EQ.1) WRITE (*,1413) ERRCOD, CHERR(1), INERR(3),      SUTERR......107100
     1       RLERR(1), INERR(1), RLERR(2), RLERR(3), INERR(2), RLERR(4)  SUTERR......107200
         WRITE (K00,1413) ERRCOD, CHERR(1), INERR(3),                    SUTERR......107300
     1       RLERR(1), INERR(1), RLERR(2), RLERR(3), INERR(2), RLERR(4)  SUTERR......107400
 1413    FORMAT (/4X,'Error code: ',2X,A40                               SUTERR......107500
     1           /4X,'Unconverged:',2X,A40                               SUTERR......107600
     1      //4X,'# of iterations.....ITER = ',I5                        SUTERR......107700
     1       /4X,'Maximum P change.....RPM = ',1PE14.5,' (node ',I9,')'  SUTERR......107800
     1       /4X,'Tolerance for P....RPMAX = ',1PE14.5                   SUTERR......107900
     1       /4X,'Maximum U change.....RUM = ',1PE14.5,' (node ',I9,')'  SUTERR......108000
     1       /4X,'Tolerance for U....RUMAX = ',1PE14.5/)                 SUTERR......108100
         DO 1415 I=1,50                                                  SUTERR......108200
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR......108300
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR......108400
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR......108500
 1415    CONTINUE                                                        SUTERR......108600
         IF (KSCRN.EQ.1) WRITE (*,1421)                                  SUTERR......108700
         WRITE (K00,1421)                                                SUTERR......108800
 1421    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR......108900
         DO 1425 I=1,50                                                  SUTERR......109000
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR......109100
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR......109200
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR......109300
 1425    CONTINUE                                                        SUTERR......109400
      ELSE IF ((CODE(1).EQ.'REA').AND.                                   SUTERR......109500
     1         ((CODE(2).EQ.'INP').OR.(CODE(2).EQ.'ICS').OR.             SUTERR......109600
     2          (CODE(2).EQ.'BCS'))) THEN                                SUTERR......109700
C........ERROR TYPE 'REA-INP', 'REA-ICS', OR 'REA-BCS'                   SUTERR......109800
C           (FORTRAN READ ERROR)                                         SUTERR......109900
         IF (KSCRN.EQ.1)                                                 SUTERR......110000
     1      WRITE (*,1888) '          FORTRAN READ ERROR          '      SUTERR......110100
         WRITE (K00,1888) '          FORTRAN READ ERROR          '       SUTERR......110200
         IF (KSCRN.EQ.1) WRITE (*,1511)                                  SUTERR......110300
         WRITE (K00,1511)                                                SUTERR......110400
 1511    FORMAT (/1X,'DESCRIPTION')                                      SUTERR......110500
         IF (CODE(2).EQ.'INP') THEN                                      SUTERR......110600
            CDUM80 = FNAME(1)                                            SUTERR......110700
         ELSE IF (CODE(2).EQ.'ICS') THEN                                 SUTERR......110800
            CDUM80 = FNAME(2)                                            SUTERR......110900
         ELSE                                                            SUTERR......111000
            CDUM80 = FNAME(9)                                            SUTERR......111100
         END IF                                                          SUTERR......111200
         IF (((CODE(2).EQ.'ICS').AND.(CODE(3).EQ.'4')).OR.               SUTERR......111300
     1       (CODE(3).EQ.'INS')) THEN                                    SUTERR......111400
           IF (KSCRN.EQ.1) WRITE (*,1512) ERRCOD, CDUM80, INERR(1)       SUTERR......111500
           WRITE (K00,1512) ERRCOD, CDUM80, INERR(1)                     SUTERR......111600
 1512      FORMAT (/4X,'Error code:',2X,A40                              SUTERR......111700
     1             /4X,'File:      ',2X,A40                              SUTERR......111800
     1            //4X,'Error status flag.....IOSTAT = ',I5/)            SUTERR......111900
         ELSE IF (CODE(2).EQ.'BCS') THEN                                 SUTERR......112000
           IF (KSCRN.EQ.1) WRITE (*,1513) ERRCOD, CDUM80,                SUTERR......112100
     1        ADJUSTL(TRIM(CHERR(1))), ADJUSTL(TRIM(CHERR(2))),          SUTERR......112200
     2        CODE(3)(1:3), INERR(1)                                     SUTERR......112300
           WRITE (K00,1513) ERRCOD, CDUM80, ADJUSTL(TRIM(CHERR(1))),     SUTERR......112400
     1        ADJUSTL(TRIM(CHERR(2))), CODE(3)(1:3), INERR(1)            SUTERR......112500
 1513      FORMAT (/4X,'Error code:',2X,A40                              SUTERR......112600
     1             /4X,'File:      ',2X,A40                              SUTERR......112700
     1             /4X,'Time step: ',2X,A                                SUTERR......112800
     1             /4X,'Identifier:',2X,A                                SUTERR......112900
     1             /4X,'Dataset:   ',2X,A3                               SUTERR......113000
     1            //4X,'Error status flag.....IOSTAT = ',I5/)            SUTERR......113100
         ELSE                                                            SUTERR......113200
           IF (KSCRN.EQ.1) WRITE (*,1514) ERRCOD, CDUM80, CODE(3)(1:3),  SUTERR......113300
     1        INERR(1)                                                   SUTERR......113400
           WRITE (K00,1514) ERRCOD, CDUM80, CODE(3)(1:3), INERR(1)       SUTERR......113500
 1514      FORMAT (/4X,'Error code:',2X,A40                              SUTERR......113600
     1             /4X,'File:      ',2X,A40                              SUTERR......113700
     1             /4X,'Dataset:   ',2X,A3                               SUTERR......113800
     1            //4X,'Error status flag.....IOSTAT = ',I5/)            SUTERR......113900
         END IF                                                          SUTERR......114000
         DO 1515 I=1,50                                                  SUTERR......114100
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR......114200
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR......114300
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR......114400
 1515    CONTINUE                                                        SUTERR......114500
         IF (KSCRN.EQ.1) WRITE (*,1521)                                  SUTERR......114600
         WRITE (K00,1521)                                                SUTERR......114700
 1521    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR......114800
         DO 1525 I=1,50                                                  SUTERR......114900
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR......115000
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR......115100
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR......115200
 1525    CONTINUE                                                        SUTERR......115300
         IF (KSCRN.EQ.1) WRITE (*,1581)                                  SUTERR......115400
         WRITE (K00,1581)                                                SUTERR......115500
 1581    FORMAT (/1X,'GENERAL NOTE'/                                     SUTERR......115600
     1     /4X,'If the dataset for which SUTRA has reported an error'    SUTERR......115700
     1     /4X,'appears to be correct, check the preceding lines'        SUTERR......115800
     1     /4X,'for missing data or extraneous characters.')             SUTERR......115900
      ELSE IF ((CODE(1).EQ.'REA').AND.(CODE(2).EQ.'FIL')) THEN           SUTERR......116000
C........ERROR TYPE 'REA-FIL' (FORTRAN READ ERROR)                       SUTERR......116100
         IF (KSCRN.EQ.1)                                                 SUTERR......116200
     1      WRITE (*,1888) '          FORTRAN READ ERROR          '      SUTERR......116300
         WRITE (K00,1888) '          FORTRAN READ ERROR          '       SUTERR......116400
         IF (KSCRN.EQ.1) WRITE (*,1611)                                  SUTERR......116500
         WRITE (K00,1611)                                                SUTERR......116600
 1611    FORMAT (/1X,'DESCRIPTION')                                      SUTERR......116700
         IF (KSCRN.EQ.1) WRITE (*,1613) ERRCOD, INERR(1)                 SUTERR......116800
         WRITE (K00,1613) ERRCOD, INERR(1)                               SUTERR......116900
 1613    FORMAT (/4X,'Error code:',2X,A40                                SUTERR......117000
     1           /4X,'File:      ',2X,'SUTRA.FIL'                        SUTERR......117100
     1          //4X,'Error status flag.....IOSTAT = ',I5/)              SUTERR......117200
         DO 1615 I=1,50                                                  SUTERR......117300
            IF (DS(I).EQ.'null_line') EXIT                               SUTERR......117400
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') DS(I)                    SUTERR......117500
            WRITE(K00,'(4X,A70)') DS(I)                                  SUTERR......117600
 1615    CONTINUE                                                        SUTERR......117700
         IF (KSCRN.EQ.1) WRITE (*,1621)                                  SUTERR......117800
         WRITE (K00,1621)                                                SUTERR......117900
 1621    FORMAT (/1X,'EXPLANATION'/)                                     SUTERR......118000
         DO 1625 I=1,50                                                  SUTERR......118100
            IF (EX(I).EQ.'null_line') EXIT                               SUTERR......118200
            IF (KSCRN.EQ.1) WRITE(*,'(4X,A70)') EX(I)                    SUTERR......118300
            WRITE(K00,'(4X,A70)') EX(I)                                  SUTERR......118400
 1625    CONTINUE                                                        SUTERR......118500
      END IF                                                             SUTERR......118600
 1888 FORMAT (                                                           SUTERR......118700
     1   /1X,'+--------+',38('-'),'+--------+'                           SUTERR......118800
     1   /1X,'| \\  // |',38('-'),'| \\  // |'                           SUTERR......118900
     1   /1X,'|  \\//  |',38(' '),'|  \\//  |'                           SUTERR......119000
     1   /1X,'|   //   |',A38,    '|   //   |'                           SUTERR......119100
     1   /1X,'|  //\\  |',38(' '),'|  //\\  |'                           SUTERR......119200
     1   /1X,'| //  \\ |',38('-'),'| //  \\ |'                           SUTERR......119300
     1   /1X,'+--------+',38('-'),'+--------+')                          SUTERR......119400
C                                                                        SUTERR......119500
C.....WRITE RUN TERMINATION MESSAGES AND CALL TERMINATION SEQUENCE       SUTERR......119600
      IF (KSCRN.EQ.1) WRITE (*,8888)                                     SUTERR......119700
      WRITE (K00,8888)                                                   SUTERR......119800
      IF (K3.NE.-1) WRITE (K3,8889)                                      SUTERR......119900
      IF (K5.NE.-1) WRITE (K5,8889)                                      SUTERR......120000
      IF (K6.NE.-1) WRITE (K6,8889)                                      SUTERR......120100
 8888 FORMAT (/1X,'+',56('-'),'+'/1X,'| ',54X,' |'/1X,'|',3X,            SUTERR......120200
     1   8('*'),3X,'RUN TERMINATED DUE TO ERROR',3X,9('*'),              SUTERR......120300
     1   3X,'|'/1X,'| ',54X,' |'/1X,'+',56('-'),'+')                     SUTERR......120400
 8889 FORMAT (//13X,'+',56('-'),'+'/13X,'| ',54X,' |'/13X,'|',3X,        SUTERR......120500
     1   8('*'),3X,'RUN TERMINATED DUE TO ERROR',3X,9('*'),              SUTERR......120600
     1   3X,'|'/13X,'| ',54X,' |'/13X,'+',56('-'),'+')                   SUTERR......120700
      IF (KSCRN.EQ.1) WRITE (*,8890)                                     SUTERR......120800
 8890 FORMAT (/' The above error message also appears in the SMY file,'  SUTERR......120900
     1        /' which may contain additional error information.')       SUTERR......121000
      CALL TERSEQ()                                                      SUTERR......121100
C                                                                        SUTERR......121200
      RETURN                                                             SUTERR......121300
      END                                                                SUTERR......121400
C                                                                        SUTERR......121500
