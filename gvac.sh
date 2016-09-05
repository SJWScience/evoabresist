#!/bin/bash
	txtgrn=$(tput setaf 2) # Green
	txtylw=$(tput setaf 3) # Yellow
	txtblu=$(tput setaf 4) # Blue
	txtpur=$(tput setaf 5) # Purple
	txtcyn=$(tput setaf 6) # Cyan
	txtwht=$(tput setaf 7) # White
	txtrst=$(tput sgr0) # text reset
	txtred=$(tput setaf 1) #red
	echo ""
echo " GVAC (Genome mapping and VAriant Calling), a simple 'user friendly' tool to process raw genomic NGS reads."
echo "lets get this show on the road shall we?"
	echo ""
echo "${txtylw}Hello, $USER you look fantastic today ${txtrst}"
	echo ""
echo "${txtgrn} Tell me $USER do you need your sequences trimmed? ${txtrst}"
	read -p "Trim? (y/n) " CONT
		if [ "$CONT" == "y" ]; then
			echo ""
echo "please tell me what you want your outputs to be called Eg: mysample1 "
read -e output
echo "Please tell me the forward reads, then press ENTER "
	read -e forwardreads
		echo ""
echo "Now the reverse reads please"
	read -e reversereads
java -jar trimmomatic-0.36.jar PE -threads 20 -phred33 "$forwardreads" "$reversereads" "$output"_forward_paired.fq.gz "$output"_forward_unpaired.fq.gz "$output"_reverse_paired.fq.gz "$output"_reverse_unpaired.fq.gz ILLUMINACLIP:../../../pmon/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:20
	echo ""
echo "trimming complete"
	echo ""
echo "mapping reads now, please tell me your reference sequence"
	read -e reference
		echo ""
bowtie2-build "$reference" "$reference"
echo "${txtgrn} Currently mapping reads, please be patient ${txtrst}"
bowtie2 -p20 -t -x "$reference" -1 "$output"_forward_paired.fq.gz -2 "$output"_reverse_paired.fq.gz -S "$output".sam
echo "If more than 50% of your reads did not map, then maybe you have not trimmed your data properly. Or, you are mapping to a genome which is not the best match"
		else
			echo "okay just normal mapping today then"
echo "what would you like your output files to be called Eg: mysample1 "
read -e output1
echo "please tell me you forward reads"
read -e forwardreads1
echo "now the reverse reads"
read -e reversereads1
echo "now the reference genome in .fasta format"
read -e reference1
bowtie2-build "$reference1" "$reference1"
bowtie2 -p20 -t -x "$reference1" -1 "$forwardreads1" -2 "$reversereads1" -S "$output1".sam
echo "If more than 50% of your reads did not map, then maybe you have not trimmed your data properly. Or, you are mapping to a genome which is not the best match"
echo "now i will process your reads"
echo "${txtylw} currently processing data. . . ${txtrst}"
samtools view -b -S -@ 20 -o "$output1".bam "$output1".sam
        echo ""
echo "Conversion from SAM file to BAM file complete, next step sorting"
samtools sort -@20 "$output1".bam > "$output1".sorted.bam
samtools index "$output1".sorted.bam
        echo ""
echo "${txtcyn}Processing is now complete ${txtrst} "
echo "next step is variant calling"
freebayes -f "$reference1" -p 1 "$output1".sorted.bam > "$output1".vcf
echo "${txtpur} thank you $USER for using this package, any feedback would be greatly appreciated - Sam${txtrst}"
			exit;
				fi                        
echo "raw mapping complete, do you wish to continue processing the data? "
read -p "Continue (y/n)?  " CONT
        if [ "$CONT" == "y" ]; then
                echo "$USER you rock"
echo "${txtylw} currently processing data. . . ${txtrst}"
samtools view -b -S -@20 -o "$forwardreads".bam "$output".sam
        echo ""
echo "Conversion from SAM file to BAM file complete, next step sorting"
samtools sort -@20 "$forwardreads".bam > "$output".sorted.bam
samtools index "$output".sorted.bam
        echo ""
echo "${txtcyn}Processing is now complete ${txtrst} "
        echo ""
                        else
                                echo "$USER okay then"
                                        exit;
                                                fi
        echo ""
echo "Do you want to continue on with variant analysis using Freebayes? "
        PWD=$(pwd)
read -p "Continue (y/n)?  " CONT
if [ "$CONT" == "y" ]; then
        echo ""
echo "okay $USER here we go!"
freebayes -f "$reference" -p 1 "$output".sorted.bam > "$output".vcf
echo "${txtpur} thank you $USER for using this ${txtrst}"
                        else "okay then"
                                exit;
                                        fi
