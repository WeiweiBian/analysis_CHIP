## Step 4: 
setwd("~/Downloads/Analysis/BED/H3K4me3")

## read merged peak regions
peak_region<-read.delim("merged.bed",header = F)
colnames(peak_region)<-c("chr","start","end")
## prepare for reading counts

## read peak counts from CRC patients and controls
## for each peak count file from CRC patient, we read it as c[[i]], we compare each peak region
## from individual peak counts with the merged peak regions. 
## If the peak region in the individual file is the subset of a peak region from the merged file, 
## we identify the peak count value in the merged file as the individual peak count.
c<-NULL
for (i in 1:10) {
   c[[i]]<-read.table(paste("c",i,"_peaks.txt",sep = ''),sep = '\t',header = F)[,1:4]
   colnames(c[[i]])<-c("chr","start0","end0",paste("count_c",i,sep=''))
}
### NOT WOKR IN LOCAL COMPUTER ##
#for (i in 1:10) {
#  for (k in 1:nrow(c[[i]])) {
#    for (j in 1:nrow(peak_matrix)) {
#      if (c[[i]])[k,]$chr0==peak_matrix[j,]$chr & c[[i]])[k,]$start0 >= peak_matrix[j,]$start & 
#          c[[i]])$end0 <= peak_matrix[j,]$start) 
#      {peak_matrix[j,1+3]=c[[i]])[k,4]}  
#}}}
## instaed using data.table for overlapping calculation
library(data.table)
count<-NULL
## initial the loop by merging counts from c1
setDT(c[[1]])
setDT(peak_region)
setkey(peak_region,"chr","start", "end")
count[[1]]<-foverlaps(c[[1]],peak_region, by.x=c("chr","start0","end0"), by.y=c("chr","start","end"), nomatch=NULL, type="within")
peak_region1<-merge(peak_region,count[[1]][,-(4:5)],by=c("chr","start","end"),all.x = T)
## merge all counts to generate the count matrix
for (i in 2:10) {
setDT(c[[i]])
setDT(peak_region)
setkey(peak_region,"chr","start", "end")
count[[i]]<-foverlaps(c[[i]],peak_region, by.x=c("chr","start0","end0"), by.y=c("chr","start","end"), nomatch=NULL, type="within")
peak_region1<-merge(peak_region1,count[[i]][,-(4:5)],by=c("chr","start","end"),all.x = T)

}
## same manipulation for controls
## read counts from healthy controls in the same way
h<-NULL
for (i in 1:10) {
  h[[i]]<-read.table(paste("h",i,"_peaks.txt",sep = ''),sep = '\t',header = F)[,1:4]
  colnames(h[[i]])<-c("chr","start0","end0",paste("count_h",i,sep=''))
}
count_h<-NULL
for (i in 1:10) {
  setDT(h[[i]])
  setDT(peak_region)
  setkey(peak_region,"chr","start", "end")
  count_h[[i]]<-foverlaps(h[[i]],peak_region, by.x=c("chr","start0","end0"), by.y=c("chr","start","end"), nomatch=NULL, type="within")
  peak_region1<-merge(peak_region1,count_h[[i]][,-(4:5)],by=c("chr","start","end"),all.x = T,allow.cartesian=TRUE)
  
}
## calculate the percentage of missing values per row
peak_region1$non_na<-20-rowSums(is.na(peak_region1))
peak_region1$non_na_c<-10-rowSums(is.na(peak_region1[,4:13]))
peak_region1$non_na_h<-10-rowSums(is.na(peak_region1[,14:23]))
table(peak_region1$non_na_c,peak_region1$non_na_h)

## keep peak regions with more than 5 non-missng counts for cases and 5 non-missing counts for controls
#peak_region2<-peak_region1[peak_region1$non_na_c>=5 & peak_region1$non_na_h>=5,]
#too few results, use all peaks instead
## find differential peak counts among cases and controls by DESeq2
library(DESeq2)
cond<-as.data.frame(colnames(peak_reion2)[4:23])
colnames(cond)<-"sampleID"
cond$condition<-rep(c("case","control"),each=10)
peak_region_count<-peak_region1[,4:23]
peak_region_count[is.na(peak_region_count)]<-0
peak_region_count<-as.data.frame(peak_region_count)
row.names(peak_region_count)<-paste('peak',1:nrow(peak_region_count),sep ='' )
dds <- DESeqDataSetFromMatrix(peak_region_count, cond, ~ condition)
## The first attempt shows NAs for Padj, the minReplicatesForReplace option in DESeq replaces outliers,
## and cooksCutoff=FALSE, independentFiltering=FALSE in results function for independent filtering.
## There are some duplicates in our data, so I keep the first option valid and added "cooksCutoff=FALSE, 
## independentFiltering=FALSE" when calling results function.
dds<-DESeq(dds)

res <- results(dds, cooksCutoff=FALSE, independentFiltering=FALSE)
peaks_DE<-cbind(peak_region1[,1:3],peak_region_count,as.data.frame(res))
peaks_Padj<-peak_region1_DE[peak_region1_DE$padj<0.01,]
write.csv(peaks_Padj,"peaks_Padj.csv")

##volcano plot##
if (!requireNamespace('BiocManager', quietly = TRUE))
  install.packages('BiocManager')
BiocManager::install('EnhancedVolcano')
library(EnhancedVolcano)
EnhancedVolcano(res,
                lab = (row.names(res)),
                x = 'log2FoldChange',
                y = 'pvalue')
