# this little script converts matlab data into r data

# ## $ dsfmm of the matrixs
#dev.off()
rm(list=ls(all=TRUE))


#load library
library(R.matlab)

#read matlab matrix
#a=readMat("Coarse.mat")
# m is the base case here
m=readMat("Data.mat")

# nm$name stores all the names of a
nm=attributes(m)



# number of matrcs
# dim here doesn't work
nnm=length(nm$name)

# number

for (i in 1:nnm ) {
eval(parse(text= paste(nm$name[i],"=m$",nm$name[i] ,sep=""  ) ))
}



# delete list a
rm(m)


# save the current image to rdata
#save.image(file="Coarse.RData")
save.image(file="read3.RData")
