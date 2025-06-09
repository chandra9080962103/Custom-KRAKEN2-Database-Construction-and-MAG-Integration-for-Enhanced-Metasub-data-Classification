# KRAKEN2 Custom Database and MAG Integration for Metagenomics

This repository provides a workflow to build a custom KRAKEN2 database from completed genomes of Bacteria, Fungi, and Archaea (NCBI RefSeq), and to integrate Metagenome-Assembled Genomes (MAGs) derived from MetaSUB samples for improved metagenomic classification accuracy.

## Overview

- **Builds a KRAKEN2 database using ~44,000 completed genomes** from NCBI RefSeq.
- **Processes MetaSUB metagenomic samples** using the metaWRAP pipeline for assembly, binning, and dereplication.
- **Integrates high-quality, dereplicated MAGs** into the KRAKEN2 database.
- **Improves taxonomic classification** for new MetaSUB datasets (e.g., Chennai samples) using both reference genomes and MAGs.

## Workflow

1. **Database Construction**
   - Download completed genomes from NCBI RefSeq.
   - Use KRAKEN2 to build a custom reference database.

2. **MAG Assembly and Dereplication**
   - Assemble and bin metagenomic reads from MetaSUB samples using metaWRAP.
   - Dereplicate MAGs using dRep to obtain a non-redundant genome set.

3. **MAG Integration**
   - Assign unique taxIDs to MAGs.
   - Add MAGs to the KRAKEN2 database as new reference sequences[3].
   - Use GTDB-tk for taxonomic classification of MAGs.

4. **Classification of New Data**
   - Use the updated KRAKEN2 database to classify new metagenomic samples (e.g., Chennai MetaSUB data).
   - Evaluate improvements in taxonomic assignment.
