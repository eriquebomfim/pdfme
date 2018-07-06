# -----------------------------------------------------------
# Pdfme
This is a script written in bash in order to
split large pdf files in small pieces regarding
a give Mb size

@author Erique Bomfim <erique.bomfim@gmail.com>
@created July-2018

pdfme.sh [fileName] [-m:-b:-mb] [firstPage] [finalPage:-a] [sizePerFile]
 
Parameters:
fileName -  fullpath to the file to be splitten
mode     -  tells script what to do
        [-m] merge only
        [-b] break file in pieces only 
        [-bm]break and merge 
 firstPage (integer) - indicate page to start process
 finalPage (mixed)   - [number] : indicate final page to process
		      - [-a]     : All
 sizePerFile (integer) - Define maximum file size in megabytes			
 ----------------------------------------------------------
