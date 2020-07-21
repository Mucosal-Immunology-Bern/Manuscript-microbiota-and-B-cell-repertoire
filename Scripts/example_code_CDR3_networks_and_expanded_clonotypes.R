# Packages
library(stringdist)
library(igraph)
library(ForceAtlas2) #install via: devtools::install_github("analyxcompany/ForceAtlas2") 
library(dplyr)
library(tidyr)

# Functions for building CDR3 Networks and calculated the percentage of expanded clonotypes within the network
clonotype_network<-function(x){
  threshold <- 1 #threshold determines whether an edge is drawn or not. Here, an edge is only drawn, if sequences are 1 LV apart
  cdr3dist  <- stringdistmatrix(x$cdr3aa, method = "lv")
  names(cdr3dist) <- names(x$cdr3aa)
  cdr3mat <- as.matrix(cdr3dist)
  cdr3bol <- cdr3mat
  cdr3bol[cdr3bol<=threshold] <- 1
  cdr3bol[cdr3bol>threshold] <- 0
  colnames(cdr3bol) <- as.character(x$cdr3aa)
  rownames(cdr3bol) <- as.character(x$cdr3aa)
  cdr3_graph <- igraph::simplify(graph.adjacency(cdr3bol, weighted=T, mode = "undirected"))
  return(cdr3_graph)
}

percentage_expanded_clonotypes_within_network<-function(igraph_network){
  #definition for counting expanded clonotype is at least 2 nodes with same clonotype
  network_components <- components(igraph_network)
  percentage_expanded_clonotypes = ((sum(network_components$csize > 1))/network_components$no)*100
  return(percentage_expanded_clonotypes)
}

Plot_network_igraph<-function(igraph_network){
  png(paste("network_", deparse(substitute(igraph_network)), ".png", sep=""), 3000, 3000)
  layout_network <- layout.kamada.kawai(igraph_network) 
  plot(igraph_network,
       layout=layout_network,
       vertex.color=ifelse(degree(igraph_network)==0, "orange", "blue"),
       vertex.frame.color=NA,
       vertex.label=NA,
       vertex.size=3,
       edge.width=1,
       edge.color = "black",
       rescale=TRUE)
  dev.off()
}
