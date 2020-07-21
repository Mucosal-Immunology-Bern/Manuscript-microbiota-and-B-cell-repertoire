#Example bash commands for correct export using MIXCR

#mixcr assemble -OassemblingFeatures="[VDJRegion]" alignments_sample1.vdjca clones_sample1_byVDJ.clns
#mixcr exportClones  -count -nMutations VRegion -aaMutations VRegion -nMutations JRegion -aaMutations JRegion -nMutations DRegion -aaMutations DRegion -nFeature CDR3 -nFeature VDJunction -nFeature DJJunction --filter-out-of-frames  --filter-stops  clones_sample1_byVDJ.clns clones_sample1.txt

#Library for R script
library(dplyr)
library(tidyr)
library(stringr)

#Function for counting the median number of mutations per sequence:
median_aa_mut_count_per_sequence<-function(x){
  clones <- x
  clones_small <- clones[, which(str_detect(colnames(clones), "Mutations"))]
  clones_aa <- clones_small[, which(str_detect(colnames(clones_small), "aa"))]
  mutations <- lapply(clones_aa, function(x){
    single_mutations <- str_extract_all(x,  "([SDI][A-Z][1-9][0-9]+[A-Z]){1,100}|([SDI][A-Z]9[A-Z]){1,100}")
    mutations_sum <- sapply(single_mutations, function(k){
      if(identical(k, character(0))){
        0}
      else{
        length(k)}})
    mutations_sum
  })
  sapply(mutations, median)
}

