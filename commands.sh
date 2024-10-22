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



