! *** ASSIGNING EVAPORATION RATE THROUGH RELEVANT FUNCTIONS
! *** WHEN QET=1 THEN USING PENMAN (1948) EQUATION,
! *** THIS IS FURTHER MODIFIED BY KONUKCU (2007)
! *** WHEN QET=2 THEN USING PDV (1957) EQUATION.
! *** SEE NOTEBOOK2 PAGE47 FOR FURTHER EXPLANATION 
SUBROUTINE EVAPORATION (AET,PC,CC,RHO,WMA,SM,HM,HO,DELL,TAUTH,DFR &
  ,PWFR,PCFR,RSC,TSK,POR,SW,KREG,YY)
  USE M_PARAMS
  IMPLICIT DOUBLE PRECISION (A-H,O-Z)
  COMMON /ET/ QET,UET,PET,UVM,NGT,ITE,TMA,TMI,ALF,RS,RH,AP,BP,U2,TSD,SCF
  COMMON /AERORESIS/ RAVT,RAVS,SWRAT
  COMMON /SALTRESIS/ AR,BR
  COMMON /GRAVEC/ GRAVX,GRAVY,GRAVZ 
  COMMON /CONTRL/ GNUP,GNUU,UP,DTMULT,DTMAX,ME,ISSFLO,ISSTRA,ITCYC,&
        NPCYC,NUCYC,NPRINT,NBCFPR,NBCSPR,NBCPPR,NBCUPR,IREAD, &
        ISTORE,NOUMAT,IUNSAT,KTYPE,MET,MAR,MSR,MSC,MHT,MVT,MFT,MRK 
  DIMENSION KTYPE(2)
  DOUBLE PRECISION SBC,GAM
  DATA  SBC /4.896E-9/, GAM /6.6E-2/, DP/1.8E+0/
  SAVE SBC,GAM,DP

!     AET  -- ACTUAL EVAPORATION RATE [MM/DAY]
!     PC   -- PRESSURE AT THE SPECIFIED NODE [KG/M/S2]
!     CC   -- CONCENTRATION AT THE SPECIFIED NODE  [KG/KG]
!     RHO  -- DENSITY OF THE SPECIFIED NODE [KG/M2]
!     TMA  -- AIR TEMPERATURE [CELSIUS]
!     TMI  -- SOIL SURFACE TEMPERATURE [CELSIUS]
!     TM   -- MEAN DAILY AIR TEMPERATURE [CELSIUS]
!     DLT  -- SLOPE OF SATURATION VAPOR PRESSURE CURVEE/T[KPA/CELSIUS]
!     VLH  -- LATENT HEAT OF VAPORISATION [J/KG] 
!     ALF  -- ALBEDO [I]
!     RS   -- SHORT WAVE INCOMING RADIATION  [MJ/M2/DAY]
!     RH   -- RELATIVE HUMIDITY 0<RH<1
!     ED   -- SATURATED VAPOUR PRESSURE AT DEW POINT [KPA]
!     EMI  -- EMMISIVITY [I]
!     RN   -- NET RADIANT ENERGY 
!     GAM  -- PSYCHROMETRIC CONSTANT [KPA/CELSIUS]
!     EO(NOT ZERO)   -- SATURATED VAPOUR PRESSURE AT MEAN DAILY AIR
!                        TEMP. (TM) [PA]
!     FU   -- WIND FUNCTION [MJ/M2/KPA/DAY]
!     AP,BP-- PARAMETER IN WIND FUNCTION
!     U2   -- DAILY MEAN WIND SPEED AT 2M ABOVE GROUND [KM/DAY]
!     RC   -- UNIVERSAL GAS CONSTANT [J/MOL/K]
!     WMW   -- MOLECULAR WEIGHT OF WATER [KG/MOL]
!     TS   -- SOIL TEMPERATURE [CELSIUS]
!     DP   -- VAN'T HOFF DISSOCIATION FACTOR
!     STM  -- MOLECULAR WEIGHT OF NACL [KG/MOL]
!     FIO(NOT ZERO)  -- OSMOTIC POTENTIALS (M)
!     HO(NOT ZERO)   -- OSMOTIC PARAMETER
!     RHOW0   -- INITIAL WATER DENSITY (KG/M3)
!      TSK   -- TEMPERATURE AT THAT NODE
!      TMAK   -- TEMPERATURE AT THAT NODE  
! ... PEMAN METHOD ...      
      IF (MET.EQ.1) THEN ! USING PENMAN EVAPORATION EQUATION
      TMAK=273.15D0+TMA                                   
      ! AIR TEMPERATURE TMAK=(TMA-273.15D0)
!     LATENT HEAT FOR VAPORIZATION   [J/KG]
      VLH=(2.50025-0.002365*(TMAK-273.15D0))*1.D6   
! CAPITAL GAMA FOR CALCULATING DEW POINT TEMP.
      CGA=17.271*(TMAK-273.15D0)/(237.7+(TMAK-273.15D0))+LOG(RH)      
    ! DEW POINT [K]
      TD=237.7*CGA/(17.271-CGA)+273.15                            
!      EMI=0.34-0.139*SQRT(ED)            
!      RN=RS*(1-ALF)-EMI*SBC*((TMA+273.15)**4+(TMI+273.15)**4)/2
!      FU=AP+BP*U2
!.....EQUATION FROM KONUKCU OBVIOUSLY THIS EQUATION IS DODGY
!      FIO=-RC*(TS+273.15)*(CC*RHO/STM)*DP/DABS(GRAVY)/RHO
!.....END OF KONUKCU EQUATION
!....START OF FUJIMAKI EQUATION FOR CALCULATING SOIL RELATIVE HUMIDITY
!..... 0.204=0.102*2
  ! THIS IS (RN-G) WHICH CHANGES OVER TIME
      RMG=0.D0                            
      HO=EXP(-WMW*2.D0*CHI(CC)*CC/STM)
      HM=EXP(WMW*PC/RHOW0/RC/TSK)
      DFR=RSC                                          ! OUTPUT 
      PWFR=HO                                          ! OUTPUT
      PCFR=HM                                          ! OUTPUT


      PA=1.01D5    ! ATMOSPHEREIC PRESSURE                 [PA]
      DMOA=0.02897       ! MOLECULAR WEIGHT OF AIR (KG/MOL)       

      RHOA=PA*DMOA/RC/TMAK
      GAMA=66.D0                      ! PSYCHOMETRIC CONSTANT  [PA/K]
      DLNUM=HO*HM*PSAT(2,TMAK)*RMG
      DRNUM=CA*RHOA/RAVT*(HO*HM*PSAT(1,TMAK)-PSAT(1,TD))
      DENO=VLH*RHOW0*(HO*HM*PSAT(2,TMAK)+GAMA*(RAVT+RSC)/RAVT)
      AET=-(DLNUM+DRNUM)/DENO
!      FIO=-0.204*X*CC/STM*RC*(TS+273.15)
!.....END OF FUJIMAKI EQUATION
!      AA=PC/RHO
!      BB=PC/RHO/9.81
!      HM=EXP(WMW*(PC/RHO)/RC/(TS+273.15))
!      HO=EXP(WMW*DABS(GRAVY)*FIO/RC/(TS+273.15))
!
!      AET=-(HM*HO*DLT*RN+GAM*(HM*HO*EO-ED)*FU)/VLH/(DLT+GAM)
!        IF (AET.GT.0) THEN
!        AET=0
!        ENDIF

! ... DIRECT METHOD OF CALCULATING EVAPORATION   
! SEE NOTEBOOK3 P5
! USING VAPOR FLOW EQUATION
      ELSEIF (MET.EQ.2) THEN                         
! AIR TEMPERATURE TMAK=(TMA-273.15D0)
      TMAK=273.15D0+TMA     
      TERM1=WMW/RHOW0/RC
! RELATIVE HUMIDITY INDUCED BY OSMOTICAL POTENTIAL 
      HO=EXP(-WMW*2.D0*CHI(CC)*CC/STM)      
! RELATIVE HUMIDITY INDUCED BY MATRIC POTENTIAL
      HM=EXP(WMW*PC/RHOW0/RC/TSK)         
! DFR, PWFR AND PCFR IS USED FOR OUTPUT IN .BCOF
      DFR=RSC                                       
      PWFR=HO
      PCFR=HM
      SURF=SURFRSIS(PC,POR,SW,MSR,KREG,TSK,YY)
      AET=-TERM1*(PSAT(1,TSK)*HO*HM/TSK-PSAT(1,TMAK)*RH/TMAK)/  &
          (RAVT+SURF+RSC)
      WRITE (48,"( 7(1PE15.7))") SURF,SW,PC,TSK,HO,HM,AET
! SOME COMMENTS ON FORMAT IN FORTRAN 90 
! 7(1PE15.7) HERE 7 MEANS OUTPUT 7 TIMES
!                1P MEANS THE FIRST VALUE IS NON-ZERO 
!                   E.G., 1.3D1 NOT 0.13D2
!              EW.D EXPONENTIAL, TOTAL WIDTH, AND DECIMAL WIDTH
!                   IT IS ALSO ACCEPTABLE TO USE NUMBER TO REFERENCE THE
!                      FORMAT STYLE  
!1 FORMAT( 7(1PE20.7))
       ENDIF
      RETURN
      END SUBROUTINE EVAPORATION