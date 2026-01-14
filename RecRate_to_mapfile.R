setwd('/nesi/nobackup/uoo02423/Sebastian/Turtles')

## This script takes a recombination map and, for every SNP, appends the corresponding local recombination rate to the third column of the PLINK .map file, producing a genetic map with per-site recombination rates as required by GONE ##

# Recombination rates (cM) and chromosome lengths (bp)
mal_cM <- c(125, 131.25, 143.75, 100, 81.25, 118.75, 87.5, 81.25, 62.5, 87.5, 87.5, 62.5, 75, 56.2, 56.2, 56.2, 37.5, 31.25, 31.25, 68.75, 68.75, 43.75, 75, 56.25, 62.5, 43.75, 56.25, 56.25)
fem_cM <- c(131.25, 187.5, 200, 150, 137.5, 181.25, 175, 125, 181.25, 156.25, 137.5, 125, 93.75, 100, 93.75, 75,75, 62.5, 43.75, 87.5, 81.25, 68.75, 56.25, 68.75, 93.75, 75, 62.5, 68.75)
bp <- c(354445513, 272701501, 212153107, 146519289, 137567980, 130998374, 127639529, 109268961, 105169864, 86472350, 79988231, 44227750, 41137519, 40018190, 33183484, 26399810, 25426300, 23658492, 20011669, 19189351, 18857373, 18744624, 17220591, 16917659, 16451672, 16414810, 16292564, 6698849)

# Read the .map file
map_file <- read.table("DerCor_western_pacific_PAP.map", header = FALSE, stringsAsFactors = FALSE)
colnames(map_file) <- c("chr", "snp", "cM", "bp")

# Verify chromosomes are numeric 1-28
if(!all(map_file$chr %in% 1:28)) {
  stop("Chromosome numbers should be 1-28 in your .map file")
}

# Use sex-averaged recombination rates (optional: can use just mal_cM or fem_cM)
avg_cM <- (mal_cM + fem_cM)/2

# VECTORIZED CALCULATION - This replaces the slow loop
map_file$cM <- (map_file$bp / bp[map_file$chr]) * avg_cM[map_file$chr]

# Save the updated .map file
write.table(map_file, "Wdist_DerCor_western_pacific_PAP_updated.map", 
            sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
