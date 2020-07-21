#!/usr/bin/env bash

#Example bash script to pre-process repseq amplicon sequencing tagged with UMIs with pRESTO (documentation: https://presto.readthedocs.io/en/stable/)

gunzip -c UMIsample_R1.fastq.gz > UMIsample_R1.fastq
gunzip -c UMIsample_R2.fastq.gz > UMIsample_R2.fastq
FilterSeq.py quality -s UMIsample_R1.fastq -q 20 --outname UMIsample_R1 --log FS1.log
FilterSeq.py quality -s UMIsample_R2.fastq -q 20 --outname UMIsample_R2 --log FS2.log
#The CRegion and Vsegment fasta files contain the primer sequences used for the experiment
MaskPrimers.py score -s UMIsample_R1_quality-pass.fastq -p Primers_CRegion.fasta \
    --start 15 --mode cut --barcode --outname UMIsample_R1 --log MP1.log
MaskPrimers.py score -s UMIsample_R2_quality-pass.fastq -p Primers_Vsegment.fasta \
    --start 4 --mode mask --outname UMIsample_R2 --log MP2.log
PairSeq.py -1 UMIsample_R1_primers-pass.fastq -2 UMIsample_R2_primers-pass.fastq \
    --1f BARCODE --coord illumina
AlignSets.py muscle -s UMIsample_R1_primers-pass_pair-pass.fastq --bf BARCODE \
    --exec /usr/local/bin/muscle --outname UMIsample_R1 --log AS1.log
AlignSets.py muscle -s UMIsample_R2_primers-pass_pair-pass.fastq --bf BARCODE \
    --exec /usr/local/bin/muscle --outname UMIsample_R2 --log AS2.log
BuildConsensus.py -s UMIsample_R1_primers-pass_pair-pass.fastq --bf BARCODE --pf PRIMER \
    --prcons 0.6 --maxerror 0.1 --maxgap 0.5 --outname UMIsample_R1 --log BC1.log
BuildConsensus.py -s UMIsample_R2_primers-pass_pair-pass.fastq --bf BARCODE --pf PRIMER \
    --maxerror 0.1 --maxgap 0.5 --outname UMIsample_R2 --log BC2.log
PairSeq.py -1 UMIsample_R1_consensus-pass.fastq -2 UMIsample_R2_consensus-pass.fastq \
    --coord presto
AssemblePairs.py align -1 UMIsample_R1_consensus-pass_pair-pass.fastq \
    -2 UMIsample_R2_consensus-pass_pair-pass.fastq --coord presto --rc tail \
    --1f CONSCOUNT --2f CONSCOUNT PRCONS --outname UMIsample --log AP.log
ParseHeaders.py collapse -s UMIsample_assemble-pass.fastq -f CONSCOUNT --act min
CollapseSeq.py -s UMIsample*reheader.fastq -n 20 --inner --uf PRCONS \
    --cf CONSCOUNT --act sum --outname UMIsample
SplitSeq.py group -s UMIsample_collapse-unique.fastq -f CONSCOUNT --num 2 --outname UMIsample
ParseHeaders.py table -s UMIsample_atleast-2.fastq -f ID PRCONS CONSCOUNT DUPCOUNT

#Example bash commands to pass pRESTO's output to MIXCR 
mixcr align -c IGH -s mmu -r alignmentReport_UMIsample.txt UMIsample_collapse-unique.fastq alignments_UMIsample.vdjca
mixcr assemble -r assembleReport_UMIsample.txt -OcloneClusteringParameters=null alignments_UMIsample.vdjca clones_UMIsample.clns
mixcr exportClones clones_UMIsample.clns clones_UMIsample.txt
