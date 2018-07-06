# -----------------------------------------------------------
# Pdfme
# this is a script written in bash in order to
# split large pdf files in small pieces regarding
# a give Mb size
# @author Erique Bomfim <erique.bomfim@gmail.com>
# @created July-2018
#
# pdfme.sh [fileName] [-m:-b:-mb] [firstPage] [finalPage:-a] [sizePerFile]
# 
# Parameters:
# fileName -  fullpath to the file to be splitten
# mode     -  tells script what to do
#        [-m] merge only
#        [-b] break file in pieces only 
#        [-bm]break and merge 
# firstPage (integer) - indicate page to start process
# finalPage (mixed)   - [number] : indicate final page to process
#		      - [-a]     : All
# sizePerFile (integer) - Define maximum file size in megabytes			
# ----------------------------------------------------------


bufferSize=0
lastPosition=0
totalPages=0
sizePerFile=1 #in Mb

declare -a mergins=()
declare -a merginsID=()
merginsLength=0
filesToMerge=""


merge(){

s=0

for i in `seq 1 $merginLength`
do

: $(( s=$i-1 ))

echo "mergin...${merginsID[$s]}.......$i/$merginLength"

gs -sDEVICE=pdfwrite \
	-sPAPERSIZE=a4\
       	-dFIXEDMEDIA \
	-dPDFFitPage \
	-dAutoRotatePages=/None\
	-dNOPAUSE \
	-dBATCH \
	-dSAFER \
 	-sOutputFile=out$i.pdf \
	${mergins[$s]} > nul
done

}

pdfbrk(){

totalPages=$4
fileName=$1
do_merge=0
do_break=0

case $2 in
	-b) do_break=1
	;;
	-m) do_merge=1
	;;	
	-bm|-mb) do_merge=1; do_break=1
	;;	
esac

case $4 in 
-a) totalPages=$(pdfinfo $fileName | awk 'NR==9 {print $2}')
;;
*) totalPages=$4
;;
esac

if [ "$do_break" = 1 ]; then
echo "breaking pages first..."
for i in `seq $3 $totalPages`
do
: $(gs -sDEVICE=pdfwrite \
	-sPAPERSIZE=a4\
       	-dFIXEDMEDIA \
	-dPDFFitPage \
	-dAutoRotatePages=/None\
	-dNOPAUSE \
	-dBATCH \
	-dSAFER \
	-dFirstPage=$i \
	-dLastPage=$i \
	-sOutputFile=tmp/sample_$i.pdf $1 > nul)
clear
echo "Processando $i de $totalPages."
done
fi

if [ "$do_merge" = 1 ]; then
pdfset $3 $totalPages
fi


}

#-----------------------------------------------------
# Read files sizes and calculate for merging
#-----------------------------------------------------

pdfset(){

: $((sizePerFile = $sizePerFile * 1024 * 1024))

for i in `seq $1 $2`
do
	
#read filesize

fsize=$( stat -c%s "tmp/sample_$i.pdf" )

if [ $(( $bufferSize + $fsize )) -gt $sizePerFile ];then
: $(( p=$i-1 ))

  mergins+=("$filesToMerge")
  merginsID+=("$lastPosition-$p")
  lastPosition=$i

: $(( merginLength+=1 ))

  if [ "$lastPosition" -lt "$totalPages" ]; then  	
      bufferSize=0
      filesToMerge=""
  fi

fi

: $(( bufferSize+=$fsize ))	
filesToMerge="$filesToMerge tmp/sample_$i.pdf"  

if [ "$i" = "$totalPages" ]; then	
   mergins+=("$filesToMerge")
   merginsID+=("$lastPosition-$totalPages")
:   $(( merginLength+=1))
   merge
fi

done
}
#-----------------------------------------------------
# [filename] [params] [startPage] [endPage]
#-----------------------------------------------------

case $5 in
*) sizePerFile=$5
;;
esac

pdfbrk $1 $2 $3 $4
