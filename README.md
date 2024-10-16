# scg

## Prerequisites
- **Python** >= 3.8
- **edirect** - https://www.ncbi.nlm.nih.gov/books/NBK179288/
- **gtdbtk** - access to /data1/software/gtdb/GTDB-Tk/gtdbtk-2.3.2
- **checkm** - access to /data1/software/checkm/CheckM-1.2.2
- **scg.pl** v1.09

## Data Preperation
list of relevant projects: 
- For each project, the name would be: <project ID from NCBI/ENA>.<environment column from the spreadsheet>. For example:
```
/data2/MAGs-data/PRJEB45634.rice
```
- Each project must contain `{PROJECT_NAME}_AssemblyDetails.txt`
  
**Link to the MAG collections spreadsheet**: [here](https://docs.google.com/spreadsheets/d/1pf6ybMyQ8l-Sv5rKdoKyk6lPjHx6LFTzGNpD7y5aUsg/edit?usp=sharing)

## Usage 
1. Clone the repo 
2. ```cd /scg``` 
3. Run ```./main {PROJECT_PATH}``` 
   For example: ```noyd@vega:~/scripts/scg$ ./main /data2/MAGs-data/PRJEB45634.rice```

## Script Output

- Under each project we will have the following sub-directories:
  + **download** (optional): where the files were downloaded to. The directory should have a run.sh file+possibly additional files that include the code and information used for the downloading. 
  + **MAGs**: all sequences for the MAGs
  + **gtdbtk**: results of gtdbtk run(s) for the MAGs
  + **checkm**: results of checkm run(s) for the MAGs. Output should be in tabular format under checkm/checkm.stdout
  + **info.txt**: a file with at least the following information: prodigal version, scg.pl version, checkm version, gtdbtk version, link to the dataset's paper (if any)
- Each MAG will have its own directory under MAGs with at least these files:
  + <MAG-ID>_genomic.fna: the scaffolds and contigs for the MAG
  + <MAG-ID>_genes.fna: predicted genes
  + <MAG-ID>_proteins.faa: predicted proteins
  + <MAG-ID>_genomic.fna:
  + <MAG-ID>_proteins.scg.*: output of scg.pl script
