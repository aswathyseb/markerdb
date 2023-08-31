import plac, os, sys, csv
from mdbrun import table, taxids, minfo


def create_folder(d):
    # Create the output folder if it doesn't exist
    if not os.path.exists(d):
        os.makedirs(d)
    return


@plac.pos('marker', help="Marker gene. Must be present in the synonyms file. 'ALL' for all markers.")
@plac.pos('taxalist', help="File listing taxa names")
@plac.pos('blastdb', "Path to blast databases including the prefix")
@plac.opt('synonyms', help="CSV file listing synonyms for marker genes. First name is the main identifier.")
@plac.opt('outfasta', help="Output marker fasta file.")
@plac.opt('intermediate', help="Folder with intermediate files.")
def run(marker, taxalist, blastdb='nt', synonyms="synonyms.csv", outfasta="marker.fa", intermediate="misc"):
    # Create folder to store intermediate files.
    create_folder(intermediate)
    #
    # Step1 : Extract taxids for all species under each taxa in taxa list
    #
    taxa_fname = os.path.basename(taxalist)
    taxa_prefix, _ = os.path.splitext(taxa_fname)
    taxa_file = ".".join([taxa_prefix + "_tids", "txt"])
    taxa_file = os.path.join(intermediate, taxa_file)

    ft = open(taxa_file, "w")
    for result in taxids.parse_names(taxalist, children=True):
        ft.write(f"{result}\n")
    ft.close()
    #
    # Step2 : Extract sequence details from blast databases
    #
    # The columns in the resulting table are
    #  accession, title,sequence_length,taxid,scientific_name,common_name

    blast_table_prefix = os.path.basename(blastdb)
    blast_table = ".".join([blast_table_prefix, "txt"])
    blast_table = os.path.join(intermediate, blast_table)
    # Create table from blast databases.
    table.create_table(blastdb, out=blast_table)

    #
    # Step 3: Extract taxa-specific and marker-specific table.
    #
    marker_file = ".".join([taxa_prefix + "_marker_table", "txt"])
    marker_file = os.path.join(intermediate, marker_file)
    fm = open(marker_file, "w")
    tids = minfo.read_taxids(taxa_file)
    for result in minfo.parse_nt_table(blast_table, tids, marker):
        fm.write(f"{result}\n")


if __name__ == "__main__":
    run()
