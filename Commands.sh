#!/bin/bash
# Complete Workflow
# A comprehensive pipeline for building a custom KRAKEN2 database with completed genomes from NCBI and MAGs from MetaSUB data.

# =============================================
# 1. INSTALLATION AND ENVIRONMENT SETUP
# =============================================

# 1.1 Entrez-Direct (eDirect) Installation
# ---------------------------------------
conda create -n edirect
conda activate edirect
conda install -c bioconda entrez-direct

# 1.2 BIT (Bioinformatics Tools) Installation
# ------------------------------------------
conda create -n bit -c astrobiomike -c conda-forge -c bioconda -c defaults bit

# 1.3 KRAKEN2 Installation
# -----------------------
conda create -n KRAKEN2
conda activate KRAKEN2
conda install -c bioconda kraken2

# 1.4 metaWRAP Installation
# ------------------------
conda install -y mamba
git clone https://github.com/bxlab/metaWRAP.git
cd metaWRAP

# Configure metaWRAP
# (Edit config-metawrap file and set paths for CheckM, BLAST, TAXDUMP, BMTAGGER_DB)
# See below for database downloads and setup.

# Make metaWRAP executable
export PATH=$PATH:$(pwd)/bin

# =============================================
# Database Downloads and Setup for metaWRAP
# =============================================

# CheckM database download:
mkdir MY_CHECKM_FOLDER
cd MY_CHECKM_FOLDER
wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
tar -xvf *.tar.gz
rm *.gz
cd ../
# Set CheckM data root (for newer versions):
checkm data setRoot /path/to/your/dir/MY_CHECKM_FOLDER

# As we have custom kraken2 db built on completed genomes, no need for downloading the kraken1 / kraken2 standard databases.
# Export the custom kraken2 database path:
export KRAKEN2_DB=/path/to/your/kraken2/DB

# NCBI_nt BLAST DB download
mkdir NCBI_nt
cd NCBI_nt
wget "ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz"
for a in nt.*.tar.gz; do tar xzf $a; done
# If using newer BLAST versions, use:
# wget "ftp://ftp.ncbi.nlm.nih.gov/blast/db/v4/nt_v4.*.tar.gz"
export BLASTDB=/your/location/of/database/NCBI_nt

# NCBI Taxonomy download
mkdir NCBI_tax
cd NCBI_tax
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
tar -xvf taxdump.tar.gz
export TAXDUMP=/your/location/of/database/NCBI_tax

# Making host genome index for bmtagger
mkdir BMTAGGER_INDEX
cd BMTAGGER_INDEX
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/*fa.gz
gunzip *fa.gz
cat *fa > hg38.fa
rm chr*.fa
bmtool -d hg38.fa -o hg38.bitmask
srprism mkindex -i hg38.fa -o hg38.srprism -M 100000
export BMTAGGER_DB=/path/to/your/index/BMTAGGER_INDEX

# Finally, set all these paths in your config-metawrap file:
# CHECKM=/path/to/checkm
# BLAST=/path/to/ncbi-blast/bin
# TAXDUMP=/your/location/of/database/NCBI_tax
# BMTAGGER_DB=/path/to/your/index/BMTAGGER_INDEX
# KRAKEN2_DB=/path/to/your/kraken2/DB
# BLASTDB=/your/location/of/database/NCBI_nt


# 1.5 Create metaWRAP environment and install dependencies
mamba create -y -n metawrap-env python=2.7
conda activate metawrap-env
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels ursky
mamba install --only-deps -c ursky metawrap-mg

# 1.6 dRep Installation
conda create -n drep
conda install bioconda::drep

# 1.7 CheckM2 Installation
conda create -n checkm2
conda install bioconda::checkm2

# 1.8 GTDB-Tk Installation
conda create -n gtdbtk-2.3.2
conda activate gtdbtk-2.3.2
conda install bioconda::gtdbtk

# 1.9 taxonomizr (R Package)
Rscript -e 'install.packages("taxonomizr")'

# =============================================
# 2. DOWNLOAD AND PREPARE REFERENCE GENOMES
# =============================================

# 2.1 Archaea
# Accession IDs Download - Download the accession IDs of the completed genomes of archaea, fungi and bacteria that are annotated by ncbi refseq using edirect:
conda activate edirect
cd /path/to/your/archaea_folder
esearch -db assembly -query '"archaea"[filter] AND "complete genome"[filter] NOT anomalous[filter]' | esummary | xtract -pattern DocumentSummary -def "NA" -element AssemblyAccession > archaea_complete.list
grep -v "^GCA" archaea_complete.list > archaea_refseq.txt

# 2.2 Fungi
cd /path/to/your/fungi_folder
esearch -db assembly -query '"fungi"[filter] AND "complete genome"[filter] NOT anomalous[filter]' | esummary | xtract -pattern DocumentSummary -def "NA" -element AssemblyAccession > fungi_complete.list
grep -v "^GCA" fungi_complete.list > fungi_refseq.txt

# 2.3 Bacteria
cd /path/to/your/bacteria_folder
esearch -db assembly -query '"bacteria"[filter] AND "complete genome"[filter] NOT anomalous[filter]' | esummary | xtract -pattern DocumentSummary -def "NA" -element AssemblyAccession > bacteria_complete.list
grep -v "^GCA" bacteria_complete.list > bacteria_refseq.txt

# 2.4 Download Genomes with BIT
# Downloading sequence files - Use the bit tool and the accession IDs to download the respective sequence files:
conda activate bit

# Archaea
cd /path/to/your/archaea_folder
bit-dl-ncbi-assemblies -w archaea_refseq.txt -f fasta
gunzip *.gz
nano archaea_code.py
# Enter the code to concatenate archaea sequence files from the github code.py file into the archaea_code.py file.
python3 archaea_code.py  # (Concatenates .fa files)

# Fungi
cd /path/to/your/fungi_folder
bit-dl-ncbi-assemblies -w fungi_refseq.txt -f fasta
gunzip *.gz
nano fungi_code.py
# Enter the code to concatenate fungi sequence files from the github code.py file into the fungi_code.py file.
python3 fungi_code.py

# Bacteria
cd /path/to/your/bacteria_folder
bit-dl-ncbi-assemblies -w bacteria_refseq.txt -f fasta
gunzip *.gz
# Enter the code to concatenate bacteria sequence files from the github code.py file into the bacteria_code.py file.
python3 bacteria_code.py

# =============================================
# 3. BUILD KRAKEN2 DATABASE (COMPLETED GENOMES)
# =============================================

# 3.1 Concatenate all genomes
mkdir -p /path/to/your/all_refseq_folder
cp /path/to/your/archaea_refseq.fna /path/to/your/all_refseq_folder
cp /path/to/your/fungi_refseq.fna /path/to/your/all_refseq_folder
cp /path/to/your/bacteria_refseq.fna /path/to/your/all_refseq_folder
cd /path/to/your/all_refseq_folder
nano all_sequences_code.py
# Enter the code from the github code.py file to concatenate the files: archaea_refseq.fna, fungi_refseq.fna and bacteria_refseq.fna to all_refseq.fna
python3 all_sequences_code.py  # (Concatenates all .fna files)
mkdir KRAKEN2_DB
cp all_refseq.fna /path/to/your/KRAKEN2_DB_folder

# 3.2 Build KRAKEN2 Database
cd /path/to/your/KRAKEN2_DB_folder
conda activate KRAKEN2
kraken2-build --download-taxonomy --db KRAKEN2_DB
kraken2-build --add-to-library all_refseq.fna --db KRAKEN2_DB
kraken2-build --build --db KRAKEN2_DB

# =============================================
# 4. DOWNLOAD AND PROCESS METASUB DATA
# =============================================

# 4.1 Download MetaSUB Data (Singapore)
# (From Geoseeq)
# Example PBS script:
"""
#!/bin/bash
#PBS -N geoseeq_download
#PBS -o /path/to/clean_reads/geoseeq_download.out
#PBS -e /path/to/clean_reads/geoseeq_download.err
cd /path/to/clean_reads
source /path/to/miniconda3/bin/activate base
csv_file="/path/to/your/csv_file.csv"
export CURL_CA_BUNDLE=""
while IFS= read -r sample_name; do
    echo "Processing sample: $sample_name"
    yes y | yes y | geoseeq download files --folder-name "cap2::clean_reads" "MetaSUB Consortium/Cell Paper" "$sample_name"
done < "$csv_file"
"""

# 4.2 Assemble and Bin MAGs with metaWRAP
# Follow metaWRAP tutorial: https://github.com/bxlab/metaWRAP/blob/master/Usage_tutorial.md
# (Skip steps 1, 3, and 10 as per your workflow)

# =============================================
# 5. QUALITY CONTROL AND DEREPLICATION
# =============================================

# 5.1 Run CheckM2 on MAGs
source /path/to/miniconda3/bin/activate checkm2
# Set TMPDIR to a directory with plenty of space
export TMPDIR=/path/to/tmp
checkm2 predict --input /path/to/MAGs_folder/*.fa --output-directory /path/to/checkm2_output_folder/ --threads 30 --force

# 5.2 Prepare CheckM2 output for dRep
# Extract sample, completeness, and contamination columns to a CSV file.
# Rename headers: genome, completeness, contamination.

# 5.3 Run dRep
source /path/to/miniconda3/bin/activate drep
dRep dereplicate /path/to/drep_output_folder -g /path/to/MAGs_folder/*.fa --genomeInfo /path/to/checkm2_output_folder/quality_report.csv

# Similarly, run CheckM2 on the completed genomes, dereplicate them, and keep them ready for integration with dereplicated MAGs for final KRAKEN2 database building.

# =============================================
# 6. TAXONOMIC CLASSIFICATION
# =============================================

# All genomes must be associated with a taxid: completed genomes are already annotated with NCBI taxonomy during KRAKEN2 database building; for MAGs, use GTDB-tk to get taxonomic names and, for species-level classifications with accession IDs use taxonomizr (R) to map these to NCBI taxon IDs.
# 6.1 Run GTDB-Tk on dereplicated MAGs
source /path/to/miniconda3/bin/activate gtdbtk-2.3.2
MAG_DIR="/path/to/drep_output/dereplicated_genomes/"
OUT_DIR="/path/to/gtdbtk_drep_MAGs_output_directory"
mkdir -p "$OUT_DIR"
gtdbtk classify_wf --genome_dir "$MAG_DIR" --out_dir "$OUT_DIR" --extension .fa --skip_ani_screen


# 6.2 Assign TaxIDs to MAGs using taxonomizr (R)
# For each MAG, extract the last taxonomic name in its GTDBTK classification and write these names into a text file named taxa_names.txt
Rscript -e '
library(taxonomizr)
prepareDatabase("accessionTaxa.sql")
names <- scan("/path/to/taxa_names.txt", what = "", sep = "\\n", quote = "\'")
tax_ids <- getId(names, "accessionTaxa.sql")
result <- data.frame(Name = names, TaxID = tax_ids)
write.table(result, "tax_ids.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
' 
# 6.3 Add a column for tax IDs to the GTDBTK classification and annotate the MAGs with tax IDs in the same order. For MAGs lacking species-level classification (Novel MAGs), where tax IDs cannot be generated using taxonomizr, extract the available taxonomic names up to the assigned level and manually retrieve the corresponding tax IDs from the NCBI taxonomy website.

# 6.4 Add Kraken headers to MAGs

# Using the tax IDs, create Kraken2 headers for each MAG and incorporate these headers as the FASTA header line for each MAG file, following Kraken2 documentation for custom database building.
# The header format should be:
>"MAG_name"|kraken:taxid|"tax_id corresponding to the MAG" "name of the MAG"

# For example:
>haib17CEM5241_HMCMJCCXY_SL336208_BIN_REASSEMBLY_bin_1orig|kraken:taxid|45404 Novel Beijerinckiaceae MAG

# Here, "haib17CEM5241_HMCMJCCXY_SL336208_BIN_REASSEMBLY_bin_1orig" is the MAG name, "45404" is its tax ID, and "Novel Beijerinckiaceae MAG" indicates that this MAG lacks species-level classification and is classified only up to the taxon name Beijerinckiaceae.
# Similarly, generate Kraken2 header lines for all MAGs and add these as an additional column to the GTDBTK classification file.
# Use the script below to add the header line from the GTDBTK classification to each corresponding MAG FASTA file.
for fasta in *.fa; do
    base="${fasta%.fa}"
    kraken_header=$(awk -F'\t' -v name="$base" 'NR>1 && $1==name {print $5}' Processed_GTDBTK_MAGs.csv)
    if [ -n "$kraken_header" ]; then
        tmpfile=$(mktemp)
        echo "$kraken_header" > "$tmpfile"
        cat "$fasta" >> "$tmpfile"
        mv "$tmpfile" "$fasta"
        echo "Prepended Kraken header to $fasta"
    else
        echo "No Kraken_header found for $base"
    fi
done

# =============================================
# 7. FINAL DATABASE INTEGRATION
# =============================================

# 7.1 Combine MAGs and dereplicated completed genomes into one FASTA
# Re-run CheckM2 and dRep on the folder containing all final MAGs and dereplicated completed genomes (in FASTA format) to remove redundancies using the same parameters as previously.
# (Use code corresponding to building All_genomes.fa file from code.py to concatenate all .fa files into All_genomes.fa)

# 7.2 Build Final KRAKEN2 Database
source /path/to/miniconda3/bin/activate kraken2
LIB_DIR="/path/to/FINAL_KRAKEN2_DB"
DB_DIR="/path/to/FINAL_KRAKEN2_DB/DB"
cp -r /path/to/taxonomy_folder "$DB_DIR"
kraken2-build --add-to-library "$LIB_DIR/All_genomes.fa" --db "$DB_DIR"
kraken2-build --build --db "$DB_DIR"
conda deactivate

# =============================================
# 8. EVALUATION
# =============================================

# 8.1 Classify new MetaSUB data (e.g., Chennai) with both databases
# 8.2 Compare results to assess improvement from MAG integration
