## source.and.set <- function(x) { 
##         setwd(dirname(x)) 
##         source(x) 
## } 
## # use it like this: 
## source.and.set("/a/b/c.R") 

## parent.frame(2)$ofile
## load
dev.off()
rm(list=ls(all=TRUE))
## knitr                                   #
## knit:::input_dir()
## # directly run a subscript read3.r that read the three mat files
## be careful using this because the new matrix is V6 which is very time
## consuming
#source("read.r")                       

load("read3.RData")



## dev.new(width=8, height=12, colormodel="rgb")
setEPS()
epstitle <- "Figure.eps"
postscript(epstitle,width=8, height=12,onefile = FALSE,
            paper = "special",
          colormodel="rgb"
           ,title=epstitle)
nf <- layout(matrix(c(1,2,3), 3, 1, byrow = TRUE), 
    	 widths=c(1,1), heights=c(1,1))





# a parameter to make the tick labels closer to the graph
# http://www.programmingr.com/content/controlling-margins-and-axes-oma-and-mgp/
# yaxs='i'  -- let the y axis starts exactly from the prescribed boundary
# http://stackoverflow.com/questions/6159484/r-plotting-why-not-starting-from-0-0
# http://chartsgraphs.wordpress.com/2008/11/21/r-adjusting-x-and-y-axes-offset/
# external margin
# http://research.stowers-institute.org/efg/R/Graphics/Basics/mar-oma/
par(mgp = c(0, 0.2, 0) # a parameter to make the tick labels closer to the graph
#    tcl=-0.2,
#     las=1,   # this one changed my orintation of y label
    ,xaxs='i'
    ,yaxs='i'
#    xpd=NA         # allow plot out side the graph
    ,"mar"=c(0, 4, 0, 3)
    ,"oma"=c(3,0,2,0)  # the external margin, very useful when there is only one x label
    ,cex=0.8)    # global parameter for legend



# black red, green3, blue cyan magenta yellow and grey
col=c(1,2,3,4,5,6,7)
spe=seq(0,7)

# (C)ase (NAME)
cname=c("C13(Experiment)","C9(Experiment)","C4(Experiment)","M14(Experiment)","M7(Experiment)","F10(Experiment)","F6(Experiment)")
ccname=c("C13(Model)","C9(Model)","C4(Model)","M14(Model)","M7(Model)","F10(Model)","F6(Model)")

# (C)ase (SEQ)uence
cseq=c(3,2,4,5,4,2,3)

# dtk tick for days
dtk <- seq(0,20,2)


# the dat for stage 2
stg2 <- 3.9
rhtk <- seq(0,1,0.2)
ttk <- seq(20,50,5)
aettk <- seq(0,60,10)
ettk <- seq(0,25,5)
tmtk <- seq(0,6,1)
swtk <- seq(0,1,0.2)
rslog <- c(0.1,1,10,100,1000,10000)
rstk <- seq(0,7000,1000)
lw2 <- 2
iv <- 8
etmx <- 8
rsmx <- 8000
rsmn <- 8
tmx <- 18
aetmx <- 42
m <- 4   # the fourth rs, which is calculated bymeasured rh and temperature
# the first plot for coarse soil
# widths and heights are from upper left



# preparation for the minor tick
# http://stackoverflow.com/questions/5821763/logarithmic-y-axis-tick-marks-in-r-plot-or-ggplot2
y1 <- floor(log10(range(c(1,rsmx))))
pow <- seq(y1[1], y1[2])
rsmtk <- as.vector(sapply(pow, function(p) (1:10)*10^p))



# saturation
plot(NA
     ,lwd = 2 #line thickness
#     ,log="y"
     ,ylab=""
     ,xlab=""
     ,axes = FALSE       # this line clears the orginal tick and tickmarks
     ,xlim=c(0,tmx)
     ,ylim=c(-0.1,1.1)
     )
box(lwd = 2) #- to make it look "as usual"

## snapshot select
j=f2[1]
icol <- 2  #red
## plot out the saturation data
points(tslab[seq(1,dim(tslab)[1],iv),1]-tslab[1,1]
       ,slab[seq(1,dim(tslab)[1],iv),1]
       ,pch=spe[2]      
       ,col=col[icol])

#points(tslab[,2]-tslab[1,2],slab[,2])          

lines(ta[2,seq(1,j)]+ttc
      ,st14cm[seq(1,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol])


axis(1,at=dtk,labels=NA,tck=0.04)
axis(3,at=dtk,labels=NA,tck=0.04)
axis(2,at=swtk,labels=swtk,tck=0.04)
mtext("Saturation (-)",side=2,line=1.2)
axis(4,at=swtk,labels=swtk,tck=0.04)
mtext("(a)",side=3,line=-1.5,at=0.4,cex=1.2)


legend("topright"
       ,inset=c(0.01,0.03)
       ,c("-2cm (Experiment)","-2cm (Model)")
       ,pch=c(1,NA)
       ,lty=c(NA,1)
       ,col=c(2,2)
       ,bg="white"
       )


# the second plot for coarse soil
# widths and heights are from upper left
plot(NA
     ,lwd = 2 #line thickness
     ,ylab=""
     ,xlab=""
     ,axes = FALSE       # this line clears the orginal tick and tickmarks
     ,xlim=c(0,tmx)
     ,ylim=c(23,38)
     )
box(lwd = 2)

icol <- 2
points(ttlab[seq(1,ndt[1],iv),1]-ttlab[1,1]
       ,tlab[seq(1,ndt[1],iv),1]
       ,pch=spe[2]
       ,col=col[icol]
       )
lines(ta[2,seq(1,j)]+ttc
      ,tt1cm[seq(1,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol]
      )



icol <- 3
ilab <- 3
points(ttlab[seq(1,ndt[ilab],iv),ilab]-ttlab[1,ilab]
       ,tlab[seq(1,ndt[ilab],iv),ilab]
       ,pch=spe[3]
       ,col=col[icol]
       )
lines(ta[2,seq(1,j)]+ttc
      ,tt3cm[seq(1,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol]
      )


icol <- 4
ilab <- 4
points(ttlab[seq(1,ndt[ilab],iv),ilab]-ttlab[1,ilab]
       ,tlab[seq(1,ndt[ilab],iv),ilab]
       ,pch=spe[icol]
       ,col=col[icol]
       )
lines(ta[2,seq(1,j)]+ttc
      ,tt8cm[seq(1,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol]
      )




axis(1,at=dtk,labels=NA,tck=0.04)
axis(3,at=dtk,labels=NA,tck=0.04)
axis(2,at=ttk,labels=ttk,tck=0.04)
axis(4,at=ttk,labels=ttk,tck=0.04)
mtext(expression(paste("Temperature (", degree, "C)")),side=2,line=1.2)
axis(4,at=swtk,labels=NA,tck=0.04)
mtext("(b)",side=3,line=-1.5,at=0.4,cex=1.2)
legend("topleft"
       ,inset=c(0.01,0.07)
       ,c("0 (Experiment)"
         ,"0 (Model)"
         ,"-2cm (Experiment)"
         ,"-2cm (Model)"
         ,"-9cm (Experiment)"
         ,"-9cm (Model)"
          )          
       ,pch=c(1,NA,2,NA,3,NA)
       ,lty=c(NA,1,NA,1,NA,1)
       ,col=c(2,2,3,3,4,4)
       ,bg="white"
       )



plot(NA
     ,lwd = 2 #line thickness
#     ,log="y"
     ,ylab=""
     ,xlab=""
     ,axes = FALSE    
     ,xlim=c(0,tmx)
     ,ylim=c(-2,aetmx)
     )
box(lwd = 2)



icol <- 2  #red
ispe <- 2
points(taetlab[seq(1,dim(taetlab)[1],iv),1]-taetlab[1,1]
       ,aetlabat[seq(1,dim(taetlab)[1],iv),1]
       ,pch=spe[ispe]      
       ,col=col[icol]
       )
lines(aet1[1,seq(1,j)]+ttc
      ,aet1[2,seq(1,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol])

axis(1,at=dtk,labels=dtk,tck=0.04)
axis(4,at=aettk,labels=aettk,tck=0.04)
mtext("(c)",side=3,line=-1.5,at=0.4,cex=1.2)

# plot et at the same graph
par(new=TRUE)
plot(NA
     ,lwd = 2 
     ,ylab=""
     ,xlab=""
     ,axes = FALSE    
     ,xlim=c(0,tmx)
     ,ylim=c(-1,etmx)
     )
box(lwd = 2)
icol <- 3
ispe <- 3
points(tetlab[seq(1,dim(tetlab)[1],iv),2]-tetlab[1,2]
       ,etlab[seq(1,dim(etlab)[1],iv),2]*sce
       ,pch=spe[ispe]      
       ,col=col[icol]
       )
lines(et1[1,seq(2,j)]+ttc
      ,et1[2,seq(2,j)]
      ,lwd=lw2
      ,lty=1
      ,col=col[icol])

axis(3,at=dtk,labels=NA,tck=0.04)
axis(2,at=ettk,labels=ettk,tck=0.04)
mtext("Cumulative evaporation (mm)",side=4,line=1.2)
mtext("Evaporation rate (mm/day)",side=2,line=1.2)
mtext("Time (day)",side=1,line=1.2)

legend("right"
       ,inset=c(0.01,0.03)
       ,c("Cumulative evaporation (Experiment)"
         ,"Cumulative evaporation (Model)"
         ,"Evaporation rate (Experiment)"
         ,"Evaporation rate (Model)"
          )          
       ,pch=c(1,NA,2,NA,3,NA)
       ,lty=c(NA,1,NA,1,NA,1)
       ,col=c(2,2,3,3,4,4)
       ,bg="white"
       )


dev.off()
