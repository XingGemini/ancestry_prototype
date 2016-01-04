# Executed by typing in command line:
# python parse_markers_in_exome.py markers_file exome_file

# Parses markers and exome file names as arguments
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("markers_file")
parser.add_argument("exome_file")
args = parser.parse_args()

markers_file = getattr(args, 'markers_file')
exome_file = getattr(args, 'exome_file')

# Open and saves marker file into array
with open(markers_file) as f:
	markers = [ map(str, line.strip().split('\t')) for line in f ]

# Sorts markers by locus
markers = sorted(markers, key=lambda x:(str("chr"+x[1]), int(x[2])))

# Open and saves exome file into array
with open(exome_file) as f:
    exons = [ map(str, line.strip().split('\t')) for line in f ]

# Sorts exons by begin position
exons = sorted(exons, key=lambda x:(x[0], int(x[1])))

exon_length = len(exons)
markers_length = len(markers)

# Array to store marker hits
markers_in_exons = []

# Checks for markers within exon coordinates
marker_index = 0
exon_index = 0
while (marker_index < markers_length and exon_index < exon_length):
	marker = markers[marker_index]
	marker_chrom = marker[1]
	locus = int(marker[2])
		
	start = int(exons[exon_index][1])
	end = int(exons[exon_index][2])
	exon_chrom = exons[exon_index][0][3:]

		# Goes to next marker
	if marker_chrom > exon_chrom:
		exon_index = exon_index + 1
		continue

	if marker_chrom < exon_chrom:
		marker_index = marker_index + 1
		continue

	if locus > start and locus <= end and marker_chrom == exon_chrom:
		markers_in_exons.append([marker[0], marker_chrom, locus])
		marker_index = marker_index + 1
		continue

	if locus > end:
		exon_index = exon_index + 1
		continue

	if locus <= start:
		marker_index = marker_index + 1
		continue
# Output array is saved in output file
f = open('3.out.plink.map', 'w')
for marker in markers_in_exons:
	chr = str(marker[1]);
	if (chr == "X"): 
		continue
	else:
		f.write(str(marker[1]) + '\t' + marker[0] + '\t0\t' + str(marker[2]) + '\n')
f.close()