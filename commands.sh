#!/bin/bash

# E-direct installation - create a conda environment with any name (ex: edirect), then install the Entrez-Direct command line tools in that environment:

$ conda create -n edirect
$ conda activate edirect
$ conda install -c bioconda entrez-direct

# Accession IDs Download - Download the accession IDs of the completed genomes of archaea, fungi and bacteria that are annotated by ncbi refseq using edirect:

# Archaea:
$ conda activate edirect
$ cd /path/to/your/archaea_folder
$ esearch -db assembly -query ‘“archaea”[filter] AND “complete genome”[filter] NOT anomalous[filter]’ | esummary | xtract -pattern DocumentSummary -def “NA” -element AssemblyAccession > archaea_complete.list
$ grep -v "^GCA" archaea_complete.list > archaea_refseq.txt

#Fungi:
$ cd /path/to/your/fungi_folder
$ esearch -db assembly -query ‘“fungi”[filter] AND “complete genome”[filter] NOT anomalous[filter]’ | esummary | xtract -pattern DocumentSummary -def “NA” -element AssemblyAccession > fungi_complete.list
$ grep -v "^GCA" fungi_complete.list > fungi_refseq.txt

#Bacteria:
$ cd /path/to/your/bacteria_folder
$ esearch -db assembly -query ‘“bacteria”[filter] AND “complete genome”[filter] NOT anomalous[filter]’ | esummary | xtract -pattern DocumentSummary -def “NA” -element AssemblyAccession > bacteria_complete.list
$ grep -v "^GCA" bacteria_complete.list > bacteria_refseq.txt

# BioInformatics tools (bit) Installation - This tool is installed using conda in a environment named bit:

$ conda create -n bit  -c astrobiomike -c conda-forge -c bioconda -c defaults bit

# Downloading sequence files - Use the bit tool and the accession IDs to download the respective sequence files:

#Archaea:
$ conda activate bit
$ cd /path/to/your/archaea_folder
$ bit-dl-ncbi-assemblies  -w archaea_refseq.txt  -f fasta
$ gunzip *.gz
$ nano archaea_code.py
# Enter the code to concatenate archaea sequence files from the github code.py file into the archaea_code.py file.
$ python3 archaea_code.py

#Fungi:
$ cd /path/to/your/fungi_folder
$ bit-dl-ncbi-assemblies -w fungi_refseq.txt -f fasta
$ gunzip *.gz
$ nano fungi_code.py
# Enter the code to concatenate fungi sequence files from the github code.py file into the fungi_code.py file.
$ python3 fungi_code.py

#Bacteria:
$ cd /path/to/your/bacteria_folder
$ bit-dl-ncbi-assemblies -w bacteria_refseq.txt -f fasta
$ gunzip *.gz
$ nano bacteria_code.py
# Enter the code to concatenate bacteria sequence files from the github code.py file into the bacteria_code.py file.
$ python3 bacteria_code.py

# KRAKEN2 Installation:

$ conda create -n KRAKEN2
$ conda activate KRAKEN2
$ conda install -c bioconda kraken2

# Creating KRAKEN2 Database - Move/copy all the concatenated archaea, fungi and bacteria sequence files into a single folder and concatenate all 3 files into a single sequence file named all_refseq.fna

$ cp /path/to/your/archaea_refseq.fna  /path/to/your/all_refseq_folder
$ cp /path/to/your/fungi_refseq.fna /path/to/your/all_refseq_folder
$ cp /path/to/your/bacteria_refseq.fna /path/to/your/all_refseq_folder
$ cd /path/to/your/all_refseq_folder
$ nano all_sequences_code.py
# Enter the code from the github code.py file to concatenate the files: archaea_refseq.fna, fungi_refseq.fna and bacteria_refseq.fna to all_refseq.fna
$ python3 all_sequences_code.py
$ mkdir KRAKEN2_DB
$ cp all_refseq.fna /path/to/your/KRAKEN2_DB_folder
$ cd /path/to/your/KRAKEN2_DB_folder
$ conda activate KRAKEN2
$ kraken2-build --download-taxonomy --db KRAKEN2_DB
$ kraken2-build --add-to-library all_refseq.fna --db KRAKEN2_DB
$ kraken2-build --build --db KRAKEN2_DB

## Install MetaWRAP to process the raw reads from Metasub data.
# The best way to install and manage metaWRAP is to install it directly from github, and then install all of its dependancies through conda.
$ conda install -y mamba
$ git clone https://github.com/bxlab/metaWRAP.git
# Carefully configure the yourpath/metaWRAP/bin/config-metawrap and download the databases below:

# CheckM database download:
$ mkdir MY_CHECKM_FOLDER
# Now manually download the database:
$ cd MY_CHECKM_FOLDER
$ wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
$ tar -xvf *.tar.gz
$ rm *.gz
$ cd ../
# Now you need to tell CheckM where to find this data before running anything:
$ checkm data setRoot     # CheckM will prompt to to chose your storage location
# On newer versions of CheckM, you would run:
$ checkm data setRoot /path/to/your/dir/MY_CHECKM_FOLDER

# As we have custom kraken2 db built on completed genomes, no need for downloading the kraken1 / kraken2 standard databases.
# So instead export the custom kraken2 database path: KRAKEN2_DB=/path/to/your/kraken2/DB to config-metawrap file.

# NCBI_nt BLAST DB download 
$ mkdir NCBI_nt
$ cd  NCBI_nt
$ wget "ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz"
$ for a in nt.*.tar.gz; do tar xzf $a; done
# Note: if you are using a more recent blast verions (beyond v2.6) you will need a the newer database format: wget "ftp://ftp.ncbi.nlm.nih.gov/blast/db/v4/nt_v4.*.tar.gz"
# set BLAST DB variable in config-metawrap file: BLASTDB=/your/location/of/database/NCBI_nt

# NCBI Taxonomy download
$ mkdir NCBI_tax
$ cd NCBI_tax
$ wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
$ tar -xvf taxdump.tar.gz
# set the TAXDUMP variable in the config-metawrap file: TAXDUMP=/your/location/of/database/NCBI_tax

# Making host genome index for bmtagger
# First, lets download and merge the human genome hg38:
$ mkdir BMTAGGER_INDEX
$ cd BMTAGGER_INDEX
$ wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/*fa.gz
$ gunzip *fa.gz
$ cat *fa > hg38.fa
$ rm chr*.fa

# Now lets index the human genome
$ bmtool -d hg38.fa -o hg38.bitmask
$ srprism mkindex -i hg38.fa -o hg38.srprism -M 100000

# Note: metaWRAP looks for files hg38.bitmask and hg38.srprism - make sure they are names exactly like this.
# Finally set BMTAGGER_DB variable path in the config-metawrap file: BMTAGGER_DB=/path/to/your/index/BMTAGGER_INDEX

# Make metaWRAP executable by adding yourpath/metaWRAP/bin/ directory to to your $PATH. Either add the line PATH=yourpath/metaWRAP/bin/:$PATH to your ~/.bash_profile script, or copy over the contents of yourpath/metaWRAP/bin/ into a location already in your $PATH (such as /usr/bin/ or /miniconda2/bin/).

# Make a new conda environment to install and manage all dependancies:
$ mamba create -y -n metawrap-env python=2.7
$ conda activate metawrap-env

# Install all metaWRAP dependancies with conda:
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels ursky

# Unix/Linux only
mamba install --only-deps -c ursky metawrap-mg
# `conda install --only-deps -c ursky metawrap-mg` also works, but much slower


# Now use the below script to download singapore Metasub data (or modify it for any dataset you need) from the Metasub consrotium in geoseeq 
#!/bin/bash
# Job Name
#PBS -N geoseeq_download
# Output and Error Log
#PBS -o /path/to/clean_reads/geoseeq_download.out
#PBS -e /path/to/clean_reads/geoseeq_download.err

# Change to the working directory
cd /path/to/clean_reads

# Load conda environment
source /path/to/miniconda3/bin/activate base

# Path to the CSV file with sample names (fetched from geoseeq)
csv_file="/path/to/your/csv_file.csv"

# Disable SSL verification
export CURL_CA_BUNDLE=""

# GeoSeq download command loop with auto-confirm
while IFS= read -r sample_name; do
    echo "Processing sample: $sample_name"
    yes y | yes y | geoseeq download files --folder-name "cap2::clean_reads" "MetaSUB Consortium/Cell Paper" "$sample_name"
done < "$csv_file"


# USE the metawrap tutorial https://github.com/bxlab/metaWRAP/blob/master/Usage_tutorial.md to build / bin Metagenome Assembled Genomes (MAGs) from the downloaded clean reads. Skip steps 1, 3 and 10

# dereplicate the MAGs using dRep to remove the ones that has more than 99% similarity.
# dRep installation
$ conda install bioconda::drep

# checkm2 installation
$ conda install bioconda::checkm2 

# export all the binned MAGs to a separate directory. Now, run checkm2 to annotate these MAGs using the following script:
#!/bin/bash

# Activate conda environment
source /path/to/miniconda3/bin/activate checkm2

# Set TMPDIR to a directory with plenty of space
export TMPDIR=/path/to/tmp

# Run CheckM2
checkm2 predict --input /path/to/MAGs_folder/*.fa --output-directory /path/to/checkm2_output_folder/ --threads 30 --force

# Before running dRep, the checkm2 output should be provided to dRep in a certain manner. For that take the quality_report.tsv output file extract the 3 columns that correspond to sample name, completeness and contanimination values and put it into a csv file. Now rename the headers to be genome, completeness and contamination in the csv file.
# Now run dRep using the following script
#!/bin/bash

# Activate the GTDB-Tk environment
source /data/chandrasekaran/miniconda3/bin/activate drep

#command
dRep dereplicate /path/to/drep_output_folder -g /path/to/MAGs_folder/*.fa --genomeInfo /path/to/checkm2_output_folder/quality_report.csv

# Now next step is to classify these MAGs using GTDBTK (120 marker gene based classification). 
# GTDBTK installation
$ conda create -n gtdbtk-2.3.2
$ conda install bioconda::gtdbtk
# install the GTDBTK database and set the path.

#Now use the following script to run GTDBTK
#!/bin/bash

# Activate the GTDB-Tk environment
source /path/to/miniconda3/bin/activate gtdbtk-2.3.2

# Directory containing all MAGs as .fa files
MAG_DIR="/path/to/drep_output/dereplicated_genomes/"
OUT_DIR="/path/to/gtdbtk_drep_MAGs_output_directory"

# Create the output directory if it doesn't exist
mkdir -p "$OUT_DIR"

# Run GTDB-Tk classify_wf on all MAGs
gtdbtk classify_wf \
    --genome_dir "$MAG_DIR" \
    --out_dir "$OUT_DIR" \
    --extension .fa \
    --skip_ani_screen







