## Custom KRAKEN2 Database Construction and MAG Integration for Enhanced MetaSUB Data Classification

This repository provides a workflow to build a custom KRAKEN2 database from completed genomes of Bacteria, Fungi, and Archaea (NCBI RefSeq), and to integrate Metagenome-Assembled Genomes (MAGs) derived from MetaSUB samples for improved metagenomic classification accuracy.

## Overview

- **Builds a KRAKEN2 database using ~44,000 completed genomes** from NCBI RefSeq.
- **Processes MetaSUB metagenomic samples** using the metaWRAP pipeline for assembly, binning, and dereplication.
- **Integrates high-quality, dereplicated MAGs** into the KRAKEN2 database.
- **Improves taxonomic classification** for new MetaSUB datasets (e.g., Chennai samples) using both reference genomes and MAGs.

## Quick Start

1. Install all required tools and environments.
2. Download and prepare reference genomes.
3. Build an initial KRAKEN2 database.
4. Download and process MetaSUB data.
5. Assemble, bin, and dereplicate MAGs.
6. Classify MAGs with GTDB-Tk and assign taxIDs.
7. Integrate MAGs and completed genomes into the final KRAKEN2 database.
8. Evaluate classification improvements.

## Detailed Workflow

For detailed workflow look into the commands.sh file
