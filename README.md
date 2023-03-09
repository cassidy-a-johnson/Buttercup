# Buttercup

Welcome to Buttercup!
This tool is designed to compute the QV score of assembled genomes. It has been tested on genomes from the [Vertebrate Genomes Project](https://vertebrategenomesproject.org/), and pulls assemblies and genomic data from the online repositories (i.e. [NCBI FTP](https://ftp.ncbi.nlm.nih.gov/genomes/all/) site from NIH and [GenomeArk](https://genomeark.github.io/). Buttercup uses [Meryl](https://github.com/marbl/meryl) and [Merqury](https://github.com/marbl/merqury). Input file is anitcipated to be formatted tab separated.

Note: this current version is optimized for computing the QV when just one data type is available. If multiple types of genomic data are available for your species, we recommend modifying the genomic data download step. 03/2023
