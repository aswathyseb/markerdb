#
# Extract marker sequence for a taxa list
#
# Pre-requisites : Taxonkit and BLAST suite
#


# List of taxa names
TAXA ?= taxa.txt

# Marker name
MARKER ?= COI

# Marker synonyms file
SYNONYMS ?= synonyms.csv

# File with metadata
METADATA ?=

# Directory to store intermediate files
MISC ?= misc

# Basename of the Taxa file
PREFIX = $(basename ${TAXA})

# File to store taxids
TIDS ?= ${MISC}/${PREFIX}_tids.txt

# File with species names
SPECIES ?= species.txt

# Path to nt database including database prefix
BLAST_DB ?= blastdb/demo

# Base name of blast database
BLAST_PREFIX = $(notdir $(basename ${BLAST_DB}))

# Tabular blast nt filename
NT_TABLE ?= ${MISC}/${BLAST_PREFIX}.txt

# A nt database file
BLAST_DB_FILE = ${BLAST_DB}.*.nhr 

# Marker sqlite3 database name
DBNAME ?= marker.db

# Marker fasta file.
MARKER_FASTA ?= marker.fa

# Marker_fasta file.
MARKER_GENE_FASTA ?= ${MARKER}"_marker.fa"

# Basename of the Taxa file
PREFIX = $(notdir $(basename ${TAXA}))

# File with species taxids
TAXIDS = ${MISC}/${PREFIX}_tids.txt

# Marker table as a text file
MARKER_TABLE ?=${MISC}/${PREFIX}_marker_table.txt


# Makefile customizations
.RECIPEPREFIX = >
.DELETE_ON_ERROR:
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# Print usage information
usage::
> @echo "#"
> @echo "# Creates a marker fasta file for the taxa."
> @echo "#"
> @echo "# make create_db MARKER=${MARKER} TAXA=${TAXA} BLAST_DB=${BLAST_DB} SYNONYMS=${SYNONYMS}"
> @echo "#"
> @echo "# MARKER : Marker name eg: COI"
> @echo "# TAXA : Taxa name list"
> @echo "# BLAST_DB: Blast nt database eg:BLAST_DB=nt"
> @echo "# SYNONYMS : Comma separated file with alternative names for marker genes"
> @echo "#"
> @echo "# Note: If nt database is not in the path, provide path to nt database including prefix."
> @echo "# eg:BLAST_DB=/export/refs/nt/nt"
> @echo "#"
> @echo "# Additional variables"
> @echo "#"
> @echo "# METADATA : Metadata file"
> @echo "# MARKER_FASTA : Marker fasta"
> @echo "# DBNAME : Sqlite3 database filename"
> @echo "# MISC : Directory to store intermediate files"



check:
> echo ${BLAST_DB}
> echo ${BLAST_DB_FILE}
> echo ${NT_TABLE}
> echo ${BLAST_PREFIX}
> echo ${METADATA}
> echo ${SYNONYMS}

# Create NT database table
${NT_TABLE}:
#> make -f src/nt_table.mk create_table
>  markerdb table ${BLAST_DB} -o ${NT_TABLE}

# Extract species taxids for each taxa
${TAXIDS}:${TAXA}
> markerdb taxids ${TAXA} -c >${TAXIDS}

# Extract marker specific details
${MARKER_TABLE}:${NT_TABLE} ${TAXIDS}
> markerdb details -f ${NT_TABLE} -t ${TAXIDS} -m ${MARKER} -s ${SYNONYMS} >${MARKER_TABLE}

# Create ALL marker fasta
${MARKER_FASTA}: ${MARKER_TABLE}
> markerdb fasta -m 'ALL' -t ${TAXA} -b ${BLAST_DB} -s ${SYNONYMS} -o ${MARKER_FASTA} -i ${MISC}

# Create marker sqlite3 database
ifeq ($(METADATA),)
CMD = markerdb db ${MARKER_TABLE} -d ${DBNAME} -s ${MARKER_FASTA}
else
CMD =  markerdb db ${MARKER_TABLE} -d ${DBNAME} -s ${MARKER_FASTA} -m ${METADATA}
endif

${DBNAME}: ${MARKER_TABLE} ${MARKER_FASTA}
> ${CMD}

# Extract specified marker sequences.
${MARKER_GENE_FASTA}: ${DBNAME}
> cat ${TIDS} | cut -f 1 >${SPECIES} 
> make -f src/extract.mk all MARKER=${MARKER} TAXA=${SPECIES} DBNAME=${DBNAME} 

nt_table:${NT_TABLE}
> ls -l ${NT_TABLE}

species_tids:${TAXIDS}
> ls -l ${TAXIDS}

marker_table:${MARKER_TABLE}
> ls -l ${MARKER_TABLE}

marker_fasta:${MARKER_FASTA}
> ls -l ${MARKER_FASTA}

marker_db:${MARKER_FASTA} ${DBNAME}
> ls -l ${DBNAME}

extract_seq:${MARKER_GENE_FASTA}
>ls -l ${MARKER_GENE_FASTA}

create_db: ${MARKER_FASTA} ${DBNAME} ${MARKER_GENE_FASTA}
> ls -l ${MARKER_GENE_FASTA}
> ls -l ${DBNAME}


# Do all steps
all: nt_table species_tids marker_table marker_fasta marker_db
> @ls -l ${MARKER_FASTA} ${DBNAME}
