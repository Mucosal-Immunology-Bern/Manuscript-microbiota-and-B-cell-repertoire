### Packages
library(stringr)
library(stringdist)
#####################################################
# Import the amino acid clonotypes sequences to a list of dataframes (one dataframe per sample eg. list1$cdr3aa)
# Relaxed Clonal overlap: calculate overlapping clones to maximum distance identity of 0.1 of sequence length and store overlapping clones in list

fuzzylevdist = function (list1, list2)
{
seq <- c()
for(i in 1:length(list1$cdr3aa)){
  x <- agrep(as.character(list1$cdr3aa[i]),as.character(list2$cdr3aa),ignore.case=T,value=T,max.distance = 0.1, useBytes = FALSE)
  seq <- c(seq, x)
  overlap<-length(unique(seq))
}
return(overlap)
}

clonal_overlap_matrix_threshold <- matrix(NA, ncol = length(dataset_aa), nrow = length(dataset_aa))

for(i in 1:length(dataset_aa)){
  for(j in 1:length(dataset_aa)){
    
    clonal_overlap_matrix_threshold[i,j] <- fuzzylevdist(dataset_aa[[i]], dataset_aa[[j]]) #fuzzy overlap between pairwise combinations
    
  }
}

colnames(clonal_overlap_matrix_threshold) <- names(dataset)
rownames(clonal_overlap_matrix_threshold) <- names(dataset)

