# evoabresist
#### This is a list of codes used for X paper. Commands have been stripped of file names and replaced with generic placeholders
#####Option 1 - "hands on method"

>Trimming raw sequences, using TRIMMOMATIC
```bash
trimmomatic-0.30.jar PE -threads N -phred33 sample_read1.fastq.gz sample_read2.fastq.gz output1_forward_paired.fq.gz output1_forward_unpaired.fq.gz output1_reverse_paired.fq.gz output1_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:20 MINLEN:20
``` 
>I intentionally left the trimming to be quite lenient, this is a personal preference
>Mapping trimmed sequences to a reference sequence
```bash
bowtie2-build reference.fa outputname

samtools faidx reference.fa

bowtie2 -p N -t -x reference.fa -1 output1_forward_paired.fq.gz /
 -2 output1_reverse_paired.fq.gz -S output1.sam
``` 
>This is simply mapping the trimmed reads to the reference genome, using quite default parameters. There is quite a lot of changes to this that can be made to be more sensitive etc.
