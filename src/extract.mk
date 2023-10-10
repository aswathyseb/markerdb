# Marker name
MARKER ?= COI

# File with scientific names
TAXA ?= species.txt

# Sqlite3 database name.
DBNAME ?=marker.db

# Output fasta
OUT ?=${MARKER}"_marker.fa"

# Create Query to get taxids.
TAXID_QUERY="SELECT distinct(taxid) from  organism where scientific_name='{}'"

# Makefile customizations.
.RECIPEPREFIX = >
.DELETE_ON_ERROR:
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# Print usage information.
usage::
> @echo "#"
> @echo "# Extracts sequences for user specified marker and taxa list from the sqlite3 database ."
> @echo "#"
> @echo "# make all MARKER=${MARKER} TAXA=${TAXA} DBNAME=${DBNAME} OUT=${OUT}"
> @echo "#"
> @echo "# TAXA : Species name list"
> @echo "# MARKER : Marker name eg: COI"
> @echo "# DBNAME: Sqlite3 database name"
> @echo "# OUT: Output fasta file name"
> @echo "#"



# Get accessions corresponding to scientific names.

${OUT}:${TAXA} ${DBNAME}
ifeq ($(MARKER),ALL)
>cat ${TAXA} | parallel -j 4 -q --trim lr sqlite3 -list ${DBNAME} "SELECT accession,seq FROM sequence WHERE \
taxid=(SELECT distinct(taxid) from  organism where scientific_name='{}');" > ${OUT}
else
>cat ${TAXA} | parallel -j 4 -q --trim lr sqlite3 -list ${DBNAME} "SELECT accession,seq FROM sequence WHERE \
seq_marker='$(MARKER)'  AND taxid=(SELECT distinct(taxid) from organism where scientific_name='{}');" > ${OUT}
endif

all:${OUT}
>python src/write_fasta.py ${OUT} tmp.fa
>mv tmp.fa ${OUT}
