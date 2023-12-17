# analysis_CHIP
## Step 1: download data from Zenedo
There are two directories [Analysis.tgz](https://zenodo.org/records/4277001/files/Analysis.tgz?download=1) and [SetupFiles.tgz](https://zenodo.org/records/4277001/files/SetupFiles.tgz?download=1).

It takes ~ 8 hours to download the first directory (18.6GB) it and unfortunately I don't have right to download a portion of it.

## Step 2: Select 10 colorectal cancer patients and 10 healthy controls for peak calling using MACS3.
Following the repository of [MACS](https://github.com/macs3-project/MACS), I installed the latest version MACS3 supported by python version of 3.12.1. I ran the analysis in my Macbook locally with version 12.6 and Intel chip.

I selected the first 10 CRC patients and 10 healthy controls for analysis. The selected samples are listed below:
```
C001.2746.tagAlign.gz C002.2293.tagAlign.gz C003.2737.tagAlign.gz C004.2751.tagAlign.gz C005.2944.tagAlign.gz C006.2966.tagAlign.gz C007.2968.tagAlign.gz C008.2965.tagAlign.gz C009.1995.tagAlign.gz C010.1913.tagAlign.gz
```
H001.1.tagAlign.gz H002.1.tagAlign.gz H003.1.tagAlign.gz H004.1.tagAlign.gz H005.1.tagAlign.gz H006.1.tagAlign.gz H007.1.tagAlign.gz H008.1.tagAlign.gz H009.1.tagAlign.gz H010.1.tagAlign.gz
```
