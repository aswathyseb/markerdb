# DNA Marker Database for Metabarcoding

Accurate species identification relies on the marker sequence's resolution and the quality and comprehensiveness of the
reference library.

This repository contains a tool for creating a DNA marker database suitable for metabarcoding studies. The database can
be tailored to include various organisms, taxonomic groups, and specific marker sequences.

The tool employs sequence information from BLAST databases and NCBI's taxonomy to create the reference database. The
tool is compatible with sequences conforming to NCBI's taxonomy standards and supports multiple markers such as COI,
COII, COIII, 12S, 16S, Cytb, and rbcL. Users can add additional markers by editing the synonyms file.

### Quick start

The tools utilize sequence titles from BLAST databases to identify marker sequences and uses a synonyms file to obtain
alternative names for these markers.

The different steps involved in the process are

1. Create a table with sequence details from blast databases.
2. Extract species taxids for all species under each taxa specified in a taxalist file.
3. Parses sequence titles from the table obtained in step1 and synonyms file to extract marker-specific details.
4. Get fasta sequence for the marker accessions obtained in step3.
5. Create sqlite3 database with marker sequence details.

The entire process typically takes ~45 minutes using NCBI's `nt` database.

**How to install the script?**

Step1: Install script

    pip install markerdb --upgrade

Step2: Install additional requirements

    conda install --file conda-requirements.txt

The tool uses Taxonkit for fetching taxonomy details. See [here](https://bioinf.shenwei.me/taxonkit/usage/#before-use)
for the additional requirements before using the Taxonkit for the first time.

**How to run**

The command below uses NCBI's nucleotide blast databases (nt) to extract fish specific COI marker sequences.
`nt` databases should be in the BLASTDB variable

    markerdb create -m COI -t fish_taxa.txt -b nt

To test the tool, use the blast databases included here.

    markerdb create -m COI -t fish_taxa.txt -b blastdb/toy_nt 

**Inputs**

1. Marker name ( eg: COI)
2. Taxa list (eg: fish_taxa.txt)
3. NCBI's nucleotide blast databases (nt)

**1.Marker Name:** Specify the marker gene for which the sequences must be obtained. The specified gene and its
alternative names must be present in the synonyms file. To extract all markers listed in the synonyms file, use 'ALL'.

**2.Taxa list:** This is a list of taxonomic names for which marker gene sequences are extracted. The list can contain
names at the species level or higher taxonomic ranks. Marker genes for all species and subspecies within each taxon are
extracted. For instance, specifying 'Viridiplantae' will yield marker genes for all plants. An example taxa list file is

    Coelacanthimorpha
    Hyperoartia
    Hyperotreti
    Actinopterygii
    Dipnoi
    Chondrichthyes

**3.Blast databases:** Indicate the BLAST database from which to extract marker sequences. If the database is not in the
system path, provide its absolute path, including the prefix. For example /export/refs/nt/nt.

**Synonyms file**

Additionally, a csv synonyms file with alternative names for the marker genes is also required. This file is provided in
this repository. Users can also specify it from the commandline as

    markerdb create -m COI -t fish_taxa.txt -b blastdb/toy_nt -s synonyms.csv

**Outputs**

The main outputs are

1. A FASTA file containing the marker sequences (marker.fa)
2. SQLite3 database file with sequence details of the marker accessions (marker.db).

Additional files including sequence details from BLAST databases, species list and taxids, and marker accession list are
also provided in a separate folder.

### Additional details

**Getting NCBI blast databases**

Users can use the `update_blastdb.pl` script from the BLAST suite to download the preformatted databases. For example to
download `nt` blast databases use the command

    update_blastdb.pl --decompress nt

**Using custom blast databases**

Users can also create custom blast databases for use in the workflow. This can be done using the `makeblastdb` command
from the BLAST suite. A taxid-map file connecting the sequence ids to the NCBI taxid must be provided with
the `-taxid_map` option while creating the custom databases.

    makeblastdb -in seq.fa -out blastdb/seq -dbtype 'nucl' -taxid_map taxa_map.txt -parse_seqids

A taxid map file would look like this

    #
    # cat taxa_map.txt
    #
    A 217026
    B 335001
    C 990597
    D 990597

### Makefile workflow

The tool is also implemented as a Makefile workflow. To run the workflow use the command

    make create_db MARKER=COI TAXA=fish_taxa.txt BLAST_DB=blastdb/toy_nt

To get details on the usage of the Makefile, run the command `make`.

    make

