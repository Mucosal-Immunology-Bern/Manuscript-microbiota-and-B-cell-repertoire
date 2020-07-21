
library(ggplot2)
library(plyr)
library(iNEXT)

#Import clonotype list and filter as in example: 
sample1 <- subset(sample1, select = -c(freq, cdr3nt, cdr3aa, v, d, j, VEnd, DStart, DEnd, JStart))
colnames(sample1)[1] <- "sample1"
#Combined samples into a single dataframe
JoinedSamples <- as.data.frame(join_all(list(sample1, sample2), by="rownames", type='full'))
JoinedSamples <- subset(JoinedSamples, select = -c(rownames))
#Plot rarefaction curves
i.out <- iNEXT(JoinedSamples, q=0, datatype="abundance", endpoint = max(colSums(JoinedSamples)), knots = 102)   
ggiNEXT(i.out, se=TRUE, type=1) + theme_bw(base_size = 18) + theme(legend.position="right") + ylim(0, 60000)

