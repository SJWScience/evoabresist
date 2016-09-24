# evoabresist
#### This is a list of codes used for X paper. Commands have been stripped of file names and replaced with generic placeholders
#####Option 1 - "hands on method"

>**Trimming raw sequences, using TRIMMOMATIC**

```bash
java -jar trimmomatic-0.35.jar PE -threads N -phred33 sample_read1.fastq.gz \
sample_read2.fastq.gz output1_forward_paired.fq.gz output1_forward_unpaired.fq.gz \
output1_reverse_paired.fq.gz output1_reverse_unpaired.fq.gz \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:20 MINLEN:20

``` 
>I intentionally left the trimming to be quite lenient, this is a personal preference

>**Mapping trimmed sequences to a reference sequence**

```bash
bowtie2-build reference.fa outputname

samtools faidx reference.fa

bowtie2 -p N -t -x reference.fa -1 output1_forward_paired.fq.gz \
 -2 output1_reverse_paired.fq.gz -S output1.sam
``` 

>This is simply mapping the trimmed reads to the reference genome, using quite default parameters. There is quite a lot of changes to this that can be made to be more sensitive etc.

>**Processing mapped reads**

```bash
samtools view -b -S -o output1.bam output1.sam

samtools sort output1.bam > output1.sorted.bam

samtools index output1.sorted.bam

```
>**Calling variants using Freebayes**

```bash
freebayes.py -f reference.fa -p 1 output1.sorted.bam > output1.raw.vcf

```

>**Processing variants**

>***I personally found manually processing variants based on quality, coverage, strand bias etc. to be more effective than filtering the vcf files with tools like bcffilter or vcfutils.***

```
filtering based on
- QUAL >100
- DP (coverage) >20
- QR (phred score for variant) > 100
- AO (alternate allele count) < 10

```

>**Mapping variants to genes**

>***The output from this can be directly turned into functional differences like non-synonymous changes, indels etc.***

```bash
bedtools intersect -b output1.vcf -a reference.gbff > overlapping_variants.bed

```

>**Determining genome coverage to visualise large scale genome duplications or deletions**

```bash
genomeCoverageBed -ibam sample1.sorted.bam -g refererence.fa -d > sample1_coverage.bed

```

>**Plotting genome coverage in R - using faceted ggplots**

```R

install.packages(ggplot2)
install.packages(data.table)
library(ggplot2)
library(data.table)

sample1 <- data.table::fread("~/path/to/file/sample1_coverage.bed", header = FALSE, data.table=F)

step <- 100

#step size is the size you want the mean coverage to be determined across#
#for better resolution decrease this, for faster computing and nicer looking outputs increase it#

sequence <- seq(1, nrow(sample1), step)
sample1_means <- rep(NA, floor(nrow(sample1)/step))
for(ii in 1:(length(sequence)-1)){
  jj <- sequence[ii]
  sample1_means[ii] <- mean(sample1[jj:(jj+step-1),3], na.rm=T)
}

sample1_means <- as.data.frame(sample1_means)
sample1_means$sample <- 01
sample1_means <- cbind(sample1_means, seq(0,nrow(sample1_means)*100-1,100))
colnames(sample1_means) <- c("mean", "sample", "pos")

#repeat the above for whichever samples you have, and then combine them to one data frame.#

all_samples <- rbind(sample1_means, sample2_means, sample3_means)
write.csv(all_samples, file = "~/path/you/want/all_samples.csv")

#plotting all of this in a usable way :)#

p <- ggplot(all_samples, aes(x=pos, y=mean, group=sample, colour= factor(sample))) +
geom_line()
P <- p + facet_grid(sample ~ .)
P

```
#####Option 2 - "breSEQ does most of the work"

>**breSEQ (Deatherage & Barrick, 2014. Methods Mol Biol, 1151) will do essentially everything listed above and give an amazing HTML output that just gives an additional level of user interaction, highly recommened, but i would also suggest the manual way for an additional level of validation of mutants.**

```bash
breseq -j 20 -r ~/path/to/rerfernce.gbff -o sample1_out ~/path/to/reads/sample1_R1.fastq.gz \
~/path/to/reads/sample1_R2.fastq.gz

```

>**breSEQ will also give a coverage bed file as an output. This can then be used in the R code to make coverage plots.**
