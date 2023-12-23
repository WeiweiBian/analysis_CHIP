# analysis_CHIP
## Step 1: Download data from Zenedo
There are two directories [Analysis.tgz](https://zenodo.org/records/4277001/files/Analysis.tgz?download=1) and [SetupFiles.tgz](https://zenodo.org/records/4277001/files/SetupFiles.tgz?download=1).

It takes ~ 10 hours to download the first directory (18.6GB) and unfortunately, I don't have the right to download a portion of it.

## Step 2: Select 10 colorectal cancer patients and 10 healthy controls for peak calling using MACS3.
Following the repository of [MACS](https://github.com/macs3-project/MACS), I installed the latest MACS3 supported by Python version 3.12.1. I ran the analysis on my Macbook locally with version 12.6 Monterey and an Intel chip.

I selected the first 10 CRC patients and 10 healthy controls for analysis. The selected samples are listed below:
```
C001.2746.tagAlign.gz C002.2293.tagAlign.gz C003.2737.tagAlign.gz C004.2751.tagAlign.gz
C005.2944.tagAlign.gz C006.2966.tagAlign.gz C007.2968.tagAlign.gz C008.2965.tagAlign.gz
C009.1995.tagAlign.gz C010.1913.tagAlign.gz
```
```
H001.1.tagAlign.gz H002.1.tagAlign.gz H003.1.tagAlign.gz H004.1.tagAlign.gz H005.1.tagAlign.gz
H006.1.tagAlign.gz H007.1.tagAlign.gz H008.1.tagAlign.gz H009.1.tagAlign.gz H010.1.tagAlign.gz
```
## Step 3: Peak calling by MACS3.

I used the histone peak-calling mode (with broad cutoff setting as 0.1) from [MACS](https://github.com/macs3-project/MACS), the following code is for the first CRC sample:

```
macs3 callpeak -f BED -t C001.2746.tagAlign.gz --broad -g hs -n c1 --broad-cutoff 0.1
```

The first attempt resulted in 0 peaks and the following warning messages:
```
WARNING @ 18 Dec 2023 00:32:51: [524 MB] #2 MACS3 needs at least 100 paired peaks at
+ and - strand to build the model, but can only find 0! Please make your MFOLD range broader and try again. If MACS3 still can't build the model, we suggest to use --nomodel and --extsize 147 or other fixed number instead.
WARNING @ 18 Dec 2023 00:32:51: [524 MB] #2 Process for pairing-model is terminated!
```
I followed the issue [#353](https://github.com/macs3-project/MACS/issues/353) by adding options as "--nomodel --extsize 200" to get results.

The code is updated as follows:

```
macs3 callpeak -f BED -t C001.2746.tagAlign.gz --broad -g hs -n c1 --broad-cutoff 0.1 --nomodel --extsize 200
macs3 callpeak -f BED -t H001.1.tagAlign.gz    --broad -g hs -n h1 --broad-cutoff 0.1 --nomodel --extsize 200

```

All the results from this step are uploaded in the folder `peak calling`.

## Step 4: Merge peaks.

I deleted the first several rows in test_peaks.xls and the headers like chr, start, end, etc to generate a text file for downstream analysis.
The text files for cancer patients are named from c1_peak.txt to c10_peak.txt, and text files for controls are named from h1_peak.txt to h10_peak.txt.

I used the following command to merge peaks as a single union set of peaks.
`cat c*_peaks.txt h*_peaks.txt | cut -f 1-3 | sort -k1,1 -k2,2n | bedtools merge -i - > merged.bed` to generate a merged bed file.

The merged file included 55218 peak regions.


## Step 5: Differential peaks between CRC patients and healthy controls.
This step is done by an R script called **differential_peaks.R**. The Rdata for this step is also uploaded here as **differential_peaks.Rdata**.

First, I merge the peak counts in individual files into the merged peaks, where the individual peak overlaps with the merged peaks. Thus, I generated a count table starting with the merged peaks, followed by counts from cases 1-10 and control 1-10, named count_c1 to count_c10, and count_h1 to count_h10. This object is stored as 'peak_region1'.

Then, I calculate the missing value frequency for each merge region and keep those peaks with data from more than 5 cases and 5 controls for downstream analysis. (missing value rate <50% for both cases and controls) However, there are too few outputs (in the object 'peak_region2_Padj'), so I keep all the peaks for differential analysis.

I converted the count matrix into DESeq2-supported data format and used DESeq2 to find the differential peaks between cases and controls. The first attempt got NA values in adjusted P value, so I checked the DESeq and results function and found two related options.

The 'minReplicatesForReplace' option in **DESeq** replaces outliers, and 'cooksCutoff=FALSE, independentFiltering=FALSE' in **results** function for independent filtering. There are some duplicated rows in our data, so I kept the first option valid and added "cooksCutoff=FALSE, independentFiltering=FALSE" when calling **results** function.

I stored the differential peaks with FDR<0.01 as peaks_Padj.csv.

## Step 6: volcano plot based on DESeq2 results
I used the results from DESeq2 to generate the volcano plot. The label is identified from row numbers as peak1 to peak55218. The volcano plots are uploaded named volcano_plot.png.

