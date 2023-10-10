import sys
fname = sys.argv[1]
outfile = sys.argv[2]

fo = open(outfile, "w")

fh = open(fname)

for row in fh:
    acc,seq = row.split('|')
    fo.write(">"+acc)
    fo.write("\n")
    fo.write(seq)

