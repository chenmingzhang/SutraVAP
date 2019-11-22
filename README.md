# SutraVAP
modified sutra with vapor flow considered


##  DATASET 7:  Iteration and Matrix Solver Controls
##  [ITRMAX]        [RPMAX]        [RUMAX]
      20            1.0E+2         1.0E-3
##  [CSOLVP]  [ITRMXP]         [TOLP]
 'ORTHOMIN'     2000          1.0E-12   #this value can only be 1e-12. if it is greater than 1e-12  there will be no vapour flow 191122
##  [CSOLVU]  [ITRMXU]         [TOLU]
 'ORTHOMIN'     2000          1.0E-12

