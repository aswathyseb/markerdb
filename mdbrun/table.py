#
# This script creates a table from blast databases with columns
# accession, title,sequence_length,taxid,scientific_name,common_name
#
# Requirement -BLAST must be installed
#
# Input - path to blast databases including the prefix
#
# Output(s)
# 1.  A tab delimited file with accession, title,sequence_length,taxid,scientific_name,common_name


import plac, os
import subprocess


def create_table(blastdb, out=None):
    out_dir = os.path.dirname(out) if out else None
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    # Execute blastdbcmd command
    blast_cmd = f"blastdbcmd -db {blastdb} -dbtype 'nucl' -outfmt '%a#####%t#####%l#####%T#####%S#####%L' -entry all"
    result = subprocess.run(blast_cmd, capture_output=True, shell=True, text=True)

    # Change the delimiter to tab
    content = result.stdout.replace("#####", "\t")

    if out:
        with open(out, "w") as f:
            f.write(content)
    else:
        print(content)


@plac.pos('blastdb', "path to blast databases including the prefix")
@plac.opt('out', help="output filename")
def run(blastdb, out):
    create_table(blastdb, out)


if __name__ == "__main__":
    run()
